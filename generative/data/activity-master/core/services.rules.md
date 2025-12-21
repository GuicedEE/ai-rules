# Core Services & Bootstrapping

## Overview
ActivityMaster Core exposes the FSDM services (`EnterpriseService`, `AddressService`, `EventsService`, etc.) through GuicedEE binders and the `ActivityMasterSystemsManager`. This document scopes the rules for wiring those services into a reactive host using Vert.x 5, GuicedEE, and CRTP-powered builders.

## Usage
- Register services exclusively via the binder implementations inside `com.guicedee.activitymaster.fsdm.implementations` so clients can obtain an `IActivityMasterSystem` that aggregates the Enterprise/Address/Event flows.
- Populate `ActivityMasterSystemsManager` with the same binder order documented in the host `GUIDES.md` and sequence diagrams; keep verticles’ Mutiny contexts within the service APIs.
- Annotate all service classes with Lombok `@Log4j2` for consistent Log4j2 instrumentation (`rules/generative/platform/observability/README.md`).
- Clients should consume the injected systems (either `@Inject` or `IGuiceContext.get()`) to build dynamic UIs/tables over the FSDM relationship graph; they must not modify the database schema or structure beyond the supported GUI flows and documented persistence APIs.

## Inputs/Outputs/Events
- Each service consumes a validated `SecurityToken` (see `rules/generative/platform/security-auth/README.md`) and emits classification-aware DTOs backed by the `activity-master` database schema.
- Lifecycle events (enterprise creation, updates, resource provisioning) must follow the host architecture sequence diagrams and reuse the same event definitions used by the Java Micro Harness tests.

## Patterns & Constraints
- CRTP is mandatory: service builders and fluent setters must return `(J)this` with `@SuppressWarnings("unchecked")` to keep downstream chaining safe (`rules/generative/backend/fluent-api/README.md`).
- Avoid ad-hoc binder registration; mirror the host’s `ActivityMasterSystemsManager` startup pipeline with `ISystemUpdate`/`@SortedUpdate` updates for classification/type bootstrapping.
- Logging instrumentation should annotate moments when classification joins are resolved so the host sequence diagrams correlate with log traces.

## See also
- `../README.md` for the topic index.
- `../../backend/guicedee/README.md`, `../../backend/vertx/README.md`, `../../backend/fluent-api/README.md` for underlying GuicedEE/Vert.x/runtime guidance.
