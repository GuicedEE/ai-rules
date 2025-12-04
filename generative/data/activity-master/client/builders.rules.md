# Builder and Query Rules

Scope: CRTP builders and warehouse/query interfaces for Activity Master client aggregates (systems, enterprises, classifications, arrangements, resources, parties, rules).

CRTP contract
- All builders extend the CRTP pattern (return `(J)`), avoiding Lombok @Builder; align with ../../../backend/fluent-api/crtp.rules.md.
- IWarehouseBaseTable is the root for table abstractions; IWarehouseCoreTable adds system/enterprise identity fields, and IWarehouseTable specializes for CRUD capabilities.
- Maintain generic bounds consistency (e.g., IQueryBuilderDefault<J, E, I>) to keep compile-time safety and Mutiny-friendly method signatures.

Query builder composition
- Compose builders from small capabilities: IQueryBuilderFlags, IQueryBuilderSecurity, IQueryBuilderClassifications, IQueryBuilderValues, and IQueryBuilderRelationships drive filtering, security, and joins.
- SCD entities implement ISCDEntity with IQueryBuilderSCD for temporal validity; ensure effective/expiry timestamps flow through validation layers.
- Domain builders (IEnterpriseQueryBuilder, ISystemsQueryBuilder, IClassificationQueryBuilder, IArrangementQueryBuilder, IResourceItemQueryBuilder, IProductQueryBuilder, IEventQueryBuilder, IInvolvedPartyQueryBuilder) should not diverge from the base composition unless a new capability is documented here first.

Relationships and classifications
- Relationship helpers (IWarehouseRelationshipClassificationTable, IWarehouseRelationshipClassificationTypeTable, IRelationshipValue) must keep classification IDs typed and enforce row-level security alignment with ../../../data/entityassist/README.md.
- When adding classification or arrangement capabilities, update ./lifecycle.rules.md to reflect any new bootstrap ordering.

Usage patterns
- Provide fluent setters for identifiers, names/descriptions, security tokens, enterprise IDs, and classification associations; avoid overloading setters with side effects.
- Example scaffolding: a new query builder should extend the nearest peer (e.g., IProductQueryBuilder -> IQueryBuilderDefault + IQueryBuilderValues + IQueryBuilderSecurity) and return `(J)this` in overrides.
- Update ../GLOSSARY.md and ../interface_hierarchies.md whenever adding a new builder or capability to keep prompt alignment accurate.

See also
- ../../../backend/guicedee/persistence/README.md for persistence wiring.
- ../../../backend/hibernate/hibernate-7-reactive.md for reactive ORM constraints.
- ./testing.rules.md for validation guidance on builders.
