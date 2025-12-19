# Lifecycle and Bootstrap Rules

Scope: Activity Master client bootstrap flows (system discovery, enterprise provisioning, updates, and scripts) on GuicedEE + Vert.x 5 + Hibernate Reactive 7 with CRTP services.

Core flows
- Follow the sequence diagrams at ../../../../../docs/architecture/sequence-system-load.md and ../../../../../docs/architecture/sequence-system-token.md (Mermaid MCP rendered) for system load and token cache usage.
- IActivityMasterService orchestrates loadSystems/loadUpdates/runScript and delegates to ISystemsService and IEnterpriseService for persistence and token issuance.
- Keep SYSTEM_TOKEN_CACHE reads/writes within guarded sections to prevent duplicate token fetches; never bypass the cache in production flows.

GuicedEE integration
- Register ActivityMasterClientModuleInclusion and ensure IGuiceScanModuleInclusions picks up client modules before runtime services start.
- Event hooks (IOnSystemInstall/IOnSystemUpdate/IOnCreateUser/IOnExpireUser) must be wired via GuicedEE observability/logging per ../../../backend/guicedee/README.md and ../../../platform/observability/README.md.

Persistence and reactive rules
- Use Hibernate Reactive 7 session boundaries aligned with Vert.x 5 contexts; avoid blocking calls during bootstrap.
- Enterprise lifecycle (startNewEnterprise/createNewEnterprise/performPostStartup) must validate classification/configuration references before inserts. Coordinate with EntityAssist builders where needed.
- For row-level security and classification joins, align schema expectations with ../../../data/entityassist/README.md and document any new columns in IMPLEMENTATION.md.

Error handling and retries
- Wrap system registration and token fetches with retry/backoff strategies appropriate for Vert.x/Mutiny (see ../../../backend/vertx/README.md). Log via Log4j2 per ../../../backend/logging/README.md.
- Record failure points and recovery actions in IMPLEMENTATION.md to maintain traceability across PACT/RULES/GUIDES.

See also
- ../interface_hierarchies.md for the service tree.
- ./configuration.rules.md for secrets and environment wiring.
- ./token-cache.rules.md for cache lifecycle and eviction guidance.
