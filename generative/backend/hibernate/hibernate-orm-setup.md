# Hibernate ORM 6 — Setup & Configuration (Blocking JDBC)

Purpose
- Minimal, modular setup for classic Hibernate ORM/JPA on synchronous stacks (JDBC, thread-per-request).
- Aligns with Document Modularity Policy; links back to the topic index — see [README.md](rules/generative/backend/hibernate/README.md).

When to use
- Non-reactive stacks (e.g., Jakarta EE/Spring/GuicedEE blocking flows).
- JDBC drivers and a connection pool (HikariCP recommended).
- Do not mix with Hibernate Reactive in the same code path.

Bootstrap Options
- JPA (Jakarta Persistence) via persistence.xml
- Native Hibernate (Configuration/ServiceRegistry)

JPA — persistence.xml (resource-local example)
```xml
<!-- META-INF/persistence.xml -->
<persistence xmlns="https://jakarta.ee/xml/ns/persistence" version="3.1">
  <persistence-unit name="appPU" transaction-type="RESOURCE_LOCAL">
    <provider>org.hibernate.jpa.HibernatePersistenceProvider</provider>
    <class>com.example.User</class>

    <properties>
      <property name="jakarta.persistence.jdbc.url" value="jdbc:postgresql://localhost:5432/app"/>
      <property name="jakarta.persistence.jdbc.user" value="app"/>
      <property name="jakarta.persistence.jdbc.password" value="secret"/>
      <property name="jakarta.persistence.jdbc.driver" value="org.postgresql.Driver"/>

      <!-- Hibernate behavior -->
      <property name="hibernate.hbm2ddl.auto" value="validate"/>
      <property name="hibernate.show_sql" value="false"/>
      <property name="hibernate.format_sql" value="false"/>

      <!-- HikariCP (via hibernate-hikaricp) -->
      <property name="hibernate.hikari.maximumPoolSize" value="10"/>
      <property name="hibernate.hikari.minimumIdle" value="2"/>
    </properties>
  </persistence-unit>
</persistence>
```

JPA — Bootstrap (EntityManagerFactory)
```java
// Bootstrap JPA EntityManagerFactory
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

EntityManagerFactory emf = Persistence.createEntityManagerFactory("appPU");
```

Native Hibernate — Programmatic
```java
// Hibernate native bootstrap (no persistence.xml)
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

Configuration cfg = new Configuration();
// cfg.addAnnotatedClass(User.class);
// cfg.setProperty("hibernate.connection.url", "jdbc:postgresql://localhost:5432/app");
// cfg.setProperty("hibernate.connection.username", "app");
// cfg.setProperty("hibernate.connection.password", "secret");
// cfg.setProperty("hibernate.hikari.maximumPoolSize", "10");

SessionFactory sf = cfg.configure().buildSessionFactory();
```

Connection Pooling
- Prefer HikariCP (hibernate-hikaricp) for performance and stability.
- Tune:
  - maximumPoolSize ~ concurrent request × db limits
  - minimumIdle small but nonzero for warm pool
- Keep transactions short to avoid idle connections.

Basic Entity Example
```java
// User.java
import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User {
  @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(nullable = false, length = 100)
  private String name;

  // getters/setters
}
```

Unit of Work — Per Request/Slice
```java
// Simple per-request pattern with resource-local transactions
import jakarta.persistence.*;

EntityManager em = emf.createEntityManager();
EntityTransaction tx = em.getTransaction();
try {
  tx.begin();

  User u = new User();
  u.setName("Jane");
  em.persist(u);

  tx.commit();
} catch (RuntimeException e) {
  if (tx.isActive()) tx.rollback();
  throw e;
} finally {
  em.close();
}
```

DDL and Migrations
- hbm2ddl.auto:
  - validate (recommended): verify schema, do not create/update
  - update/create-drop only for prototypes; prefer migrations in production
- Use a migration tool (Flyway/Liquibase) for schema evolution.

Logging
- SQL logging:
  - hibernate.show_sql=false in production
  - Prefer parameterized SQL logs via logging framework categories
- Enable slow query logging at DB or application layer to detect hotspots.

JPMS Considerations
- Expose only API packages; keep impl internals encapsulated.
- For tests:
  - open packages as needed via test runtime flags (e.g., surefire argLine with --add-opens)
- JDBC driver module depends on vendor (ensure module on path or use automatic modules).

PostgreSQL Driver Policy (enterprise)
- Do not shade the driver in host projects.
- Prefer enterprise-distributed JPMS-friendly coordinates as per services policy.
- Declare explicit requires org.postgresql; align version via BOM where applicable.

Validation
- Jakarta Validation integrates with persist/merge when Bean Validation provider present.
- Annotate fields with @NotNull, @Size, etc., and handle constraint violations at service boundary.

Production Defaults (baseline)
- hbm2ddl.auto=validate
- show_sql=false, format_sql=false
- Connection pool sized for workload
- 2nd-level cache off initially (enable intentionally with proper invalidation)
- Transactions explicit and short

Testing with Testcontainers (JPA)
```java
// Example JUnit 5 lifecycle sketch
import org.testcontainers.containers.PostgreSQLContainer;
import org.junit.jupiter.api.*;

@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class JpaIT {
  PostgreSQLContainer<?> pg = new PostgreSQLContainer<>("postgres:16");
  EntityManagerFactory emf;

  @BeforeAll
  void start() {
    pg.start();
    System.setProperty("jakarta.persistence.jdbc.url", pg.getJdbcUrl());
    System.setProperty("jakarta.persistence.jdbc.user", pg.getUsername());
    System.setProperty("jakarta.persistence.jdbc.password", pg.getPassword());
    emf = Persistence.createEntityManagerFactory("appPU");
  }

  @AfterAll
  void stop() {
    emf.close();
    pg.stop();
  }
}
```

Security and Observability
- Credentials from env/secrets; avoid committing secrets in persistence.xml
- Add correlation IDs to logs; track DB latency and pool utilization

Anti-Patterns (summary)
- Long-lived EntityManager shared across threads (not thread-safe)
- EAGER fetching everywhere (leads to unbounded joins)
- Business logic outside transactions mutating attached entities unpredictably
- Depending on hbm2ddl.create/update for production schema

LLM Interpretation Guidance
- Use ORM for synchronous JDBC code paths; do not mix with Reactive flows.
- Keep transactions short, use DTO projections and fetch joins to avoid N+1.
- Treat EntityManager/Session as per-unit-of-work; do not share across threads.

See Also
- Overview — [hibernate-orm-overview.md](rules/generative/backend/hibernate/hibernate-orm-overview.md)
- EntityManager/Session — [hibernate-orm-entitymanager-session.md](rules/generative/backend/hibernate/hibernate-orm-entitymanager-session.md)
- Transactions — [hibernate-orm-transactions.md](rules/generative/backend/hibernate/hibernate-orm-transactions.md)
- CRUD Patterns — [hibernate-orm-crud.md](rules/generative/backend/hibernate/hibernate-orm-crud.md)
- Caching — [hibernate-orm-caching.md](rules/generative/backend/hibernate/hibernate-orm-caching.md)
- Testing — [hibernate-orm-testing.md](rules/generative/backend/hibernate/hibernate-orm-testing.md)
- Anti-Patterns — [hibernate-orm-antipatterns.md](rules/generative/backend/hibernate/hibernate-orm-antipatterns.md)
- Upgrade Notes — [hibernate-orm-upgrade.md](rules/generative/backend/hibernate/hibernate-orm-upgrade.md)