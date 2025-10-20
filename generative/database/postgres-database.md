# Database Implementation

* PostgreSQL 17 with Hibernate schema auto-generation.
* No Flyway/Liquibase unless modularized.
* Tests use Testcontainers with real PostgreSQL instances.
* Connection pooling optimized per environment.
* JSON/Binary column types explicitly declared for compatibility.
* Avoid N+1 queries via eager loading or batch joins.
* PostgreSQL driver and Hibernate Validator must be shaded and JPMS-modularized where used.
