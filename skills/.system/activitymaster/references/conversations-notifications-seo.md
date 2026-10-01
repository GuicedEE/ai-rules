# Conversation, Notification, and SEO Master interactions

These modules use existing FSDM rows and reactive `Uni` operations. The consuming host owns authentication and binds verified identity where required. Keep its client transport separate from privileged FSDM row access. There are no dedicated conversation, notification, or SEO tables.

## Conversation Master

A conversation is a typed Arrangement; `ArrangementXInvolvedParty` links members. Each message is an Event linked to the Arrangement and sender, with its plain-text body in a private ResourceItem. The host binds `ConversationIdentityProvider.current()` to a verified, call-scoped `ConversationIdentity(partyId, enterpriseId, context, identityToken, installationPartyId)`. Work context owner is the authorized enterprise. Personal and Social context owner is the verified organic party. Never derive identity from request IDs or substitute the system token for the caller token. The four-argument constructor defaults installationPartyId to partyId; the host
must verify membership before binding an organization installation. The default
binding denies requests. Conversation Master is an independent IMasterPlugin,
declaring Core. Install it for the authorized party and obtain the acting user's
consent to Core; every lower service operation checks current installation,
consent and administrator policy before its existing context/membership/row
checks. This includes reads and message history. A Plugin credential cannot act
for a user. Forward module update 1174 converts legacy System identity while
preserving registration and data; taxonomy update 1175 uses Core bootstrap only.

Inject `ConversationApi` and use `create(enterprise, Create)`, `find(enterprise, id)`, `list(enterprise, offset, limit)`, `send(enterprise, id, Send)`, `messages(enterprise, id, offset, limit)`, and `leave(enterprise, id)`. `Create` carries `(realm, ownerId, participants)` and `Send` carries `(text)`. Results are `Conversation(id, realm, ownerId, participants)`, `Message(id, conversationId, senderId, text, createdAt)`, or `Page(items, offset, limit, hasMore)`. The lower `IConversationService` methods take the caller-owned `Mutiny.StatelessSession`, resolved system, and verified identity. Await every related write in the caller's transaction.

REST base `/{enterprise}/conversations`: `POST /` creates; `GET /` lists the current context; `GET /{id}` reads one; `POST /{id}/messages` sends; `GET /{id}/messages` lists in creation order; `DELETE /{id}/membership` ends only the caller's membership. The requested owner must match the trusted host context. Participant IDs are invite targets, never actor authority. Participants must be live involved parties in the enterprise. Personal is a one-party note. A Social creator owns the Arrangement while invitees read and reply through their own verified Social contexts and live memberships. Every read and send checks current grants, context, and membership. Leaving expires only the caller's membership and preserves history for remaining members.

Limits: 50 participants, 65,536 UTF-16 message units, offset 0..10,000, limit 1..100. Rows have no independent public grants. There is no record-topic attachment, message edit, reply-thread, channel, or GraphQL mutation contract.

## Notification Master

A notification, state transition, and delivery attempt are separate Events. `EventXInvolvedParty` links publisher and recipients; classifications hold category, severity, subject, and context; a private `Notification Body` ResourceItem holds plain-text body and JSON payload. State is append-only: `UNREAD` means no state Event, while `READ`, `DISMISSED`, and `ACKNOWLEDGED` are recorded transitions. The host binds `NotificationIdentityProvider.current()` to a verified, call-scoped `NotificationIdentity(partyId, enterpriseId, context, identityToken)` with the same Work versus Personal/Social owner rule. The default binding denies. Path and payload IDs cannot identify the actor.

For delegated notifications use the five-argument
`NotificationIdentity(partyId, enterpriseId, context, identityToken, invocation)`.
The compatible four-argument constructor has no invocation for direct host use.
Preserve the initiating plugin and authorized installation party when converting
Forum identity or composing a post/notice. Current plugin installation, declared
Notification target, per-user consent and administrator policy are checked when
invocation is present; they never replace publisher behavior grants or recipient
row permissions. Forum's shared transaction checks each invoked target. See the
[plugin contract](scoped-plugins.md). Conversation's own built-in admission does not automatically authorize calls from
another plugin. SEO and other Masters still require explicit delegation integration
before exposing new delegated paths. Preserve both initiating plugin context and
the target plugin's own admission when composing such an integration.

Publishing requires a current `notifications.publish` scoped provider behavior grant; delivery audit requires `notifications.audit`. Installation defines grant vocabulary but grants no provider or actor access. All other operations require a live recipient link. Return 404 for an inaccessible item to avoid disclosing existence. Notification, state, and delivery rows have restricted security and no default public grants.

Inject `NotificationApi` for `publish(enterprise, Publish)`, `find(enterprise, id)`, `list(enterprise, state, category, offset, limit)`, `counts(enterprise)`, `transition(enterprise, id, state)`, `readAll(enterprise, category)`, and `deliveries(enterprise, id, offset, limit)`. `Publish(category, severity, subject, body, data, recipients, channels)` returns `Published(id, recipientsActuallyAddressed)`. Severity defaults to `INFO`; values are `INFO`, `SUCCESS`, `WARNING`, `CRITICAL`. The `Notification` result has `id, category, severity, subject, body, data, publisherId, createdAt, state`. `Delivery` has `id, notification, recipientId, channel, result, detail, attemptedAt`. The lower service methods use the caller's stateless session, resolved system, and identity. Finish the publishing transaction before external channel dispatch.

REST base `/{enterprise}/notifications`: `POST /` publishes; `GET /` lists with optional `state` and exact `category`; `GET /counts` returns `unread, total, capped`; `GET /{id}` includes body; `POST /{id}/read`, `/dismiss`, or `/acknowledge` changes state; `POST /read-all` marks a bounded batch read; `GET /{id}/deliveries` audits attempts. Lists are newest first, omit bodies, and exclude dismissed items unless filtered for them. Transitions are idempotent. `read-all` changes at most 200 items per call, so repeat while its changed count is nonzero. Counts stop at 1,000; `capped=true` means a lower bound. Pages have `hasMore`, no unfiltered total, offset 0..10,000, and limit 1..100. Recipient-driven filtered searches cover the newest 10,100 items, not all history.

Subject is at most 150 characters, category 128, body 65,536 UTF-16 units, JSON payload 16,384 units, and publish at most 500 recipients. Unknown or inactive recipients are dropped and the response reports who was addressed. Reject null characters and broken surrogate pairs in text; escape it when rendering. Body and payload belong in ResourceItem data, not short relationship values.

`STORE` is the durable FSDM record. Optional requested channels are `MAIL`, `WEBHOOK`, and `EVENT_BUS`; there is no SMS channel. Publish returns when storage is durable. Delivery outcomes (`SENT`, `FAILED`, `SKIPPED`) are later Events visible to audit callers. Mail uses optional Mail Master and sends plain text; absent Mail Master means a recorded skip without preventing startup. Webhook posts JSON over HTTPS without redirects. Webhook URL, shared secret, email address, and event-bus destination come from host transport bindings, never notification payload. Event bus uses `activitymaster.notifications.{enterpriseId}`; the host must verify the connected websocket or SSE session belongs to the recipient before forwarding. Missing destinations produce recorded skips.

## SEO Master

One JSON SEO file per host is a secured binary `SeoSite` ResourceItem. `SeoSystemInstall` creates taxonomy, not a site file. Dynamic pages expand readable FSDM ResourceItems and classifications such as `SeoSlug`, `SeoSlugHistory`, `SeoTitle`, `SeoDescription`, `SeoImage`, and `SeoLastModified`. SEO reads run with the SEO Master's own identity token; only rows granted to that system enter dynamic output. A lower-sort-order `ISeoContentProvider` can replace expansion for a source. There is no SEO REST mutation endpoint or generic row-read endpoint.

Publish with `ISeoService.publish(session, host, jsonBytes, system, identityTokens...)`; it validates before writing, returns the ResourceItem UUID, and invalidates that host's cache. The caller owns the stateless session and transaction. `read(session, host, system, tokens...)` returns the parsed file or null; `hosts(session, system, tokens...)` lists hosts; `build(session, host, system, tokens...)` builds a snapshot. Route-facing `resolve(host)` loads or serves the snapshot, `refresh(host)` rebuilds, `cached(host)` reads memory only, and `invalidate(host)` drops cache. Failed rebuilds leave the previous snapshot serving. With no published file, the host has no SEO redirects. `SEO_ENABLED=false` mounts no routes. `SEO_CACHE_SECONDS` defaults to 300; startup warms published hosts and stale snapshots refresh in the background.

File format: JSON `version` defaults to 1 and only version 1 is supported; maximum size is 8 MiB. Required `site` contains a matching `host` and HTTP(S) origin `baseUrl`. Optional site fields include default locale, title template containing `{title}`, default title/description/image, Twitter handle, and organization JSON-LD. Optional `canonical` has `enabled` (default false), `forceHttps`, `preferredHost`, `trailingSlash` (`never`, `always`, `preserve`), `lowercasePaths`, and `redirectStatus` (301 or 308). Optional `robots` contains agent groups and sitemap announcement. Optional `sitemap` sets `maxUrlsPerFile` (1..50,000), frequency, and priority (0..1). `pages[]` declares path, retired aliases, head metadata, locale, robots meta, alternates, JSON-LD, last-modified, frequency, priority, and sitemap inclusion. `redirects[]` declares from/to/status. `dynamic[]` names a ResourceItem type, a path template with exactly one `{slug}`, slug and optional metadata classifications, and a limit of 1..50,000. Retired slugs in `SeoSlugHistory` are newline-separated.

Minimal file: `{"version":1,"site":{"host":"www.example.com","baseUrl":"https://www.example.com"},"pages":[{"path":"/","title":"Home"}]}`. Publish a replacement file to change output. Paths normalize to lowercase and reject absolute or scheme-relative paths, traversal, whitespace, and controls. Snapshot construction rejects duplicate live paths and collisions with retired paths. Retired aliases always 301 to the live page and explicit redirects apply when a file exists. Scheme, host, slash, and request-case canonicalization applies only to declared pages when `canonical.enabled=true`.

HTTP: `GET /robots.txt` serves directives and sitemap announcement; `GET /sitemap.xml` is always a sitemap index; `GET /sitemap-{n}.xml` serves bounded URLs and alternates. `GET /seo/meta?path=...` returns title, description, canonical, robots, Open Graph, Twitter, and JSON-LD as JSON. `GET /seo/head?path=...` renders the head fragment; `GET /seo/site` returns the resolved file and diagnostics. Retired paths resolve to their live page for meta and head. The canonical handler reads only the in-memory snapshot and passes unrelated routes through. Host headers select canonical URLs, never identity or row-read authority.
