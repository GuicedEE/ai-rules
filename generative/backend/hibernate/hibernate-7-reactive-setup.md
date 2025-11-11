# Hibernate 7 Reactive — Setup & Configuration (Modular Overview)

Use this entry when prompts reference dependencies, persistence.xml, JPMS, or environment configuration for Hibernate Reactive 7.x.

## Quick start
- Add dependency: `org.hibernate.reactive:hibernate-reactive-core:{version}`
- Add Vert.x SQL client for your database (e.g., `io.vertx:vertx-pg-client:{version}`)
- Provide `META-INF/persistence.xml` with provider:

```xml
<persistence ...>
  <persistence-unit name="my-unit">
    <provider>org.hibernate.reactive.provider.ReactivePersistenceProvider</provider>
    <!-- list entities here -->
    <properties>
      <property name="jakarta.persistence.jdbc.url" value="${DB_URL}"/>
      <property name="jakarta.persistence.jdbc.user" value="${DB_USER}"/>
      <property name="jakarta.persistence.jdbc.password" value="${DB_PASS}"/>
      <property name="hibernate.show_sql" value="false"/>
    </properties>
  </persistence-unit>
</persistence>
```

## JPMS considerations
- Export entity packages: `module com.example.domain { exports com.example.domain; requires hibernate.reactive.core; }`
- Open model to Hibernate for reflection: `opens com.example.domain to hibernate.core, hibernate.reactive.core;`
- Use `--add-opens` only as a last resort in dev tooling.

## Environment-driven config
- For tests, pass DB credentials via system properties (e.g., Testcontainers) and reference with `${...}` in persistence.xml.
- Prefer ESM-like central configuration for runtime setups; avoid hardcoding.

## See also
- Overview — ./hibernate-7-reactive-overview.md
- SessionFactory — ./hibernate-7-reactive-session-factory.md
- Transactions — ./hibernate-7-reactive-transactions.md
- Topic Index — ./README.md
- Rules — ../../RULES.md#document-modularity-policy
