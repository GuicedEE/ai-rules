# Interface Hierarchies - Activity Master Client

Overview
- All public interfaces follow CRTP to enforce type-safe chaining; implementations must return `(J)` in fluent setters per ../../backend/fluent-api/crtp.rules.md.
- Service surfaces coordinate through GuicedEE modules (ActivityMasterClientModuleInclusion) and rely on Vert.x 5/Hibernate Reactive 7 contexts.

Service surfaces (high level)
- IActivityMasterService orchestrates system discovery, updates, scripts, and token cache lookups (src/main/java/com/guicedee/activitymaster/fsdm/client/services/IActivityMasterService.java).
- ISystemsService, IEnterpriseService (extends IProgressable), and ISecurityTokenService expose system metadata, enterprise lifecycle, and token issuance respectively; these are the primary dependencies for client bootstrap flows.
- Capability interfaces (IManageProducts, IManageEvents, IManageClassifications, etc.) extend IWarehouseBaseTable derivatives to provide CRUD semantics over warehouse tables.
- Event hooks (IOnSystemInstall, IOnSystemUpdate, IOnCreateUser, IOnExpireUser) implement IDefaultService and are designed for asynchronous/observability-aware workflows.

Query and warehouse builders
- Base hierarchy: IWarehouseBaseTable -> IWarehouseCoreTable/IWarehouseTable plus specializations (IWarehouseRelationshipTable, IWarehouseNameAndDescriptionTable, IWarehouseSecurityTable).
- Query builders compose targeted capabilities: IQueryBuilderDefault, IQueryBuilderFlags, IQueryBuilderSecurity, IQueryBuilderClassifications, IQueryBuilderValues, and SCD-specific IQueryBuilderSCD.
- Domain builders: IEnterpriseQueryBuilder, ISystemsQueryBuilder, IClassificationQueryBuilder, IResourceItemQueryBuilder, IArrangementQueryBuilder, and event/product/party builders extend the base query contracts for their aggregates.
- Relationship helpers: IWarehouseRelationshipClassificationTable/IWarehouseRelationshipClassificationTypeTable and IRelationshipValue encapsulate classification-to-entity joins and value typing.

Usage guidance
- Keep new interfaces aligned with the CRTP generics pattern used by existing builders; avoid Lombok @Builder in favor of manual fluent setters.
- When extending the hierarchy, document the new surface in ./client/builders.rules.md and link back to ./GLOSSARY.md to preserve prompt-language alignment.
- Anchor lifecycle flows and token cache usage to the sequence diagrams at ../../../../docs/architecture/sequence-system-load.md and ../../../../docs/architecture/sequence-system-token.md (Mermaid MCP rendered).
