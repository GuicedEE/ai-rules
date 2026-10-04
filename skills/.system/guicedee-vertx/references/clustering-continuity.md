# Clustering and WebSocket continuity

This reference records behavior verified in DevSuite and NE1 Core on 2026-10-04 using Vert.x 5.2 and GuicedEE/JWebMP 2.0.3-SNAPSHOT. Recheck source, resolved versions, and runtime artifacts when applying it after upgrades. The framework behavior below is reusable; Core's topology, capacity limits, and authentication fixtures are application-specific examples.

## Trace owners before changing behavior

| Concern | Source owner |
|---|---|
| Activation and prepared member configuration | `HazelcastPreStartup`, `HazelcastClusterConfigurator` |
| Shared options, runtime readiness, asynchronous close | `VertXPreStartup`, `VertxConfigurator`, Vert.x destroy hook |
| Startup failure and ordered rollback | `GuiceContext`, `IGuicePreDestroy.shutdownSortOrder()` |
| Owned client/member and JCache annotation resolver | `HazelcastClientProvider`, `HazelcastBinderGuice`, owned caching provider |
| HTTP request capture and physical socket close | `VertxWebServerPostStartup`, `WebSocketBackpressure` |
| Raw group consumers and socket context cleanup | GuicedEE WebSocket group registry and connection handler |
| Owner-local commands and private replies/storage | `OwnerLocalCommandIngress`, Angular incoming consumer |
| Protected STOMP policy and connection cleanup | `StompServerHandlerConfigurator`, `BoundedStompSocket` |
| Ordinary public broadcast | JWebMP STOMP bridge, `StompEventBusPublisher` |
| Generated browser reconnect ordering | Java-authored `EventBusService` and `ContextIdService` |
| Identity, tickets, snapshots, and persistence access | Application policy/backend, not framework GUID metadata |

Use the existing lifecycle and bridge extension points. A second Vert.x instance, cluster manager, STOMP server, or generated client bypasses the actual owning path and can hide failures.

## Activation and resource ownership

An incidental Hazelcast dependency must leave Vert.x unclustered and must not create a Hazelcast member or client. Explicit `VERTX_CLUSTER_ENABLED` takes precedence. Without it, an intentional server annotation uses its `clustered` flag; intentional server configuration SPI or `startLocal` preserves legacy activation when no annotation exists. A custom `ClusterVertxConfigurator` defaults to enabled for compatibility, so review its explicit gate separately.

`startLocal=true, clustered=false` deliberately requests an embedded cache member while leaving the event bus local. `HAZELCAST_CLIENT_ENABLED` independently gates client startup. Do not describe disabling event-bus clustering as disabling every intentional cache resource.

Prepare server `Config` once before building Vert.x. Reuse that configuration or an owned member; do not let a default manager select a separate `dev`/multicast configuration. Configure membership and event-bus networking separately, including bind and advertised endpoints. Joining Hazelcast does not prove that nodes can reach the advertised event-bus ports.

Options composition must retain all settings: apply each `VertxConfigurator.options` hook to the shared `VertxOptions`, attach it once, then compose builder hooks. In particular, metrics must not replace event-bus or worker/event-loop settings with a new options object.

Startup order is metrics `MIN_VALUE + 36`, prepared Hazelcast `+37`, Vert.x `+38`, then intentional client startup `+71`. A failed join, failed event-bus bind, synchronous exception, failed pre-startup future, or startup timeout aborts injection and invokes ordered rollback. `GUICEDEE_STARTUP_TIMEOUT_SECONDS` controls pre-startup waiting, default 60 seconds.

Destroy hooks run in ascending `shutdownSortOrder()` with class-name tie-breaking. Await Vert.x close at `MAX_VALUE - 200` before shutting down owned Hazelcast instances at `MAX_VALUE - 100`. Close only instances created or adopted by the lifecycle; global shutdown APIs can destroy unrelated application resources.

The injected `HazelcastInstance` resolves a running owned client first, otherwise the owned member. Every JCache provider overload and the annotation `DefaultCacheResolverFactory` must use the same owned instance/manager. Static default JCache provider lookups can bypass injection and create an extra instance.

## Wire semantics and private delivery

| Path | Required behavior |
|---|---|
| `/toBus/incoming` command | Socket-owner local request to a local consumer; policy runs first |
| Command reply | Direct frame to the originating connection's registered reply subscription |
| Command storage response | Direct frame to that connection's matching GUID-scoped storage subscription |
| Intended shared `dataReturns` or public group update | Existing cluster publish/fan-out |
| Protected application destination | Verified identity and session-bound capability checks before subscribe/send |

Retain the normal JWebMP `/toStomp/<group>` publish bridge. Raw GuicedEE WebSocket groups use their own unprefixed addresses. Do not change the common bridge to point-to-point `send` to fix one private command path.

Ingress caps concurrent commands at 32 per connection, body at 1 MiB, and request timeout at ten seconds. Reject transactional commands and reply addresses absent from that connection's registered subscriptions. Replace a claimed `stomp-session` with the actual server connection session.

Storage addresses are `/toStomp/<guid>.SessionStorage` and `/toStomp/<guid>.LocalStorage`. Owner ingress delivers storage response headers directly to the requesting connection; legacy internal callers still publish GUID-scoped storage updates. GUIDs and `RequestContextId` are correlation, never identity or consent. A guessed address must not reveal another socket's command replies or storage.

Compose `StompServerHandlerConfigurator` with existing subscribe/send/unsubscribe defaults. A policy returns true when it handled a frame, including denial. Keep close callbacks and fail configuration on exceptions; silently discarding a broken policy removes authorization. Dual-register SPI implementations in JPMS and `META-INF/services`.

## Ephemeral capabilities: Core example

Core permits HTTP ticket issuance on one node and WebSocket redemption on another. Ticket binding includes verified issuer/subject, server STOMP session, and destination. Redemption atomically consumes the ticket and reserves the subscription, so concurrent contenders have at most one successful redemption. Replay, wrong session, wrong destination, expired tickets, and unavailable shared state fail closed.

Core keeps one bounded aggregate entry in an `IMap` and executes capacity check plus reservation/redemption in one `EntryProcessor`. Separate get/check/put operations, multiple independently updated maps, or node-local actor quotas do not provide cluster-wide bounds. Socket objects and handlers remain local; distributed values contain only serializable lease metadata.

The verified Core choices were planned data members 3 (allowed 2–64), minimum observed membership `floor(N/2)+1`, one backup, 90-second aggregate TTL, pending tickets 20 seconds, active leases at most 60 seconds, four reservations per verified actor, and 256 combined cluster reservations. Node-local caps were 16 store operations, 128 local subscriptions, and eight concurrent backend reads. These are examples to review against application requirements, not framework defaults.

Keep the backend-read permit until the underlying operation actually completes, even if its outward response times out or the connection closes. Releasing the permit on outward timeout while the backend still runs allows unbounded work. Core queues at most one pending refresh per active subscription and rechecks verified identity/authorization for authoritative snapshots.

Readiness checks the initialized runtime, running member, and configured observed quorum. Two planned data members require both; three permit one loss after membership converges. Hazelcast membership and AP maps have failure-detection and partition limits; this design does not prove instantaneous CP exclusion during a partition.

Preserve Core's SELECT-only persistence boundary. Capability storage does not authorize database writes, locking reads, wider grants, or plugin access. Fixture identities do not prove live Keycloak or database authorization.

## Slow peers, cleanup, and reconnects

Use a 64 KiB write queue and outgoing UTF-8 payload limit of 1 MiB in both raw and STOMP paths. Reject overload with close status 1013. `WebSocketBackpressure.close` adds a physical transport deadline of two seconds because Vert.x 5.2's handshake timeout starts after the close frame flushes. A peer that stops reading can prevent that flush.

Preserve `WebSocketBackpressure.capture(request)` before routing and forwarded-header wrappers. It obtains the exported Vert.x internal HTTP interfaces and Netty transport context without reflection or JVM export flags. Captured lookup uses header-object identity, and channel close removes captured metadata. The module needs direct `io.netty.transport` and `io.netty.common` requirements. Recheck this integration when upgrading Vert.x.

Observe both socket `end` and `close`, performing cleanup once. Local graceful close may emit only `close`; wiring only `end` can retain STOMP subscriptions. Raw close clears group membership, empty-group consumers, socket/context mappings, and call properties. A null `textHandlerID` requires a server UUID rather than a null key. Group caps are 4096 groups per node, 4096 recipients per group, and names at most 256 characters.

Generate browser services from their Java owners. The ordinary offline command queue is bounded at 256 and reports overflow. Reconnect restores ordinary listeners before queued commands flush, with idempotent subscription registration. Secure session-bound tickets are never queued/replayed: clear stale capability state, obtain a fresh server session and authorization, restore allowed subscriptions, and request an authoritative snapshot. Explicit disconnect/destruction cancels timers and clears state.

## Acceptance and effective artifacts

In DevSuite, `verify-vertx-clustering.ps1` is the repeatable workflow. In the separate NE1 checkout, Core's `web/core/docs/clustering.md` describes the application and loopback fixtures. Inspect the current script and docs before running; neither is a production deployment command.

1. Preserve dirty work and existing build output. Install dependencies in order: Hazelcast wrapper, inject, Vert.x, web, metrics, Hazelcast integration, raw WebSockets, TypeScript client, Angular bridge. Quote Windows Maven `-D` arguments and select the repository's required JDK. Do not invoke Maven clean.
2. Run focused framework tests, render the actual Java-authored TypeScript, compile it with resolved dependencies, and exercise reconnect ordering/queue bounds. Handwritten substitute clients cannot prove the generation path.
3. Launch isolated JVMs with distinct member and event-bus ports. Demonstrate advertised TCP reachability, one owner command execution with zero execution on other nodes, cross-node broadcast once per intended subscriber, and multiple tabs.
4. Spy on reply addresses and guessed storage GUIDs from a different connection. Prove no private reply/storage leakage while public broadcasts still fan out.
5. Exercise cross-node ticket issue/redemption; replay, session/destination mismatch, expiry, concurrent redemption, cluster-wide actor and total capacity, and retained backend permits under actual timeouts.
6. Kill the socket owner, reconnect elsewhere with fresh session/capabilities, and restore subscriptions plus authoritative snapshot. Remove and restore majority membership; test occupied event-bus ports and failed joins with resource rollback.
7. Use a real TCP peer that stops reading against both raw and routed STOMP sockets. Assert bounded physical closure and empty local consumers/lease/socket registries, not only that a close method was called.
8. Use two isolated browser contexts with different HTTP and socket owners. Check separate private channels and restored public subscriptions/snapshot state after owner loss.
9. Repeat acceptance against the packaged production application JAR. Record its effective module path and compare the exact tested framework JARs with build outputs using SHA-256. With preserved `target`, old versioned artifacts can coexist; select tested filenames, not the first glob result.

The 2026-10-04 workflow passed 312 framework tests, generated-service rendering checks, five reconnect tests, 100 focused Core tests including six multi-JVM acceptance tests, and a repeat of the six acceptance tests against the packaged Core JAR. It compared nine framework artifacts on Core's tested module path. These are dated evidence, not a promise that a future checkout passes. Browser and authentication fixtures establish the tested paths; they do not establish production network behavior, live identity-provider/database acceptance, whole-reactor success, or deployment readiness.
