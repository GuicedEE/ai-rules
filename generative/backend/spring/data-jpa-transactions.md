# Spring (Boot MVC) — Data JPA and Transactions

Scope
- Non-reactive persistence using Spring Data JPA (Hibernate ORM) under Spring Boot MVC.
- Guidance covers entity modeling, repository patterns, transactional boundaries, locking, pagination/projections, performance, and testing.

Choose the stack
- This module assumes blocking JDBC with Hibernate ORM. For reactive persistence, route to Hibernate 7 Reactive under Vert.x.

Core principles
- Keep transactions short and focused; avoid non-DB work inside a transaction.
- Use service layer methods as the primary transactional boundary (@Transactional on services).
- Prefer optimistic locking with @Version; use pessimistic locks sparingly for hot contention.
- Expose DTOs/records to web/API layers; do not expose entities outside the data/service boundary.
- Default to LAZY fetch on relationships; avoid EAGER except for stable, small, immutable associations.

Entity modeling (Hibernate ORM)
- Use explicit table/column names and constraints; model ownership of relationships (owning side).
- Keep bidirectional associations minimal; define clear aggregate roots.
- For collections, prefer Set unless ordering or duplicates matter; specify @OrderBy when stable ordering is required.
- Use @Version long (or int) for optimistic locking; enforce update preconditions with If-Match/ETags at API boundary when applicable.

Example entity
```java
// com.example.data.UserEntity.java
package com.example.data;

import jakarta.persistence.*;

@Entity
@Table(name = "users", uniqueConstraints = {
  @UniqueConstraint(name = "uk_users_email", columnNames = "email")
})
public class UserEntity {
  @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Version
  private long version;

  @Column(nullable = false, unique = true, length = 320)
  private String email;

  @Column(nullable = false, length = 64)
  private String name;

  // getters/setters
}
```

Repositories (Spring Data)
- Define repository interfaces extending JpaRepository for aggregate roots.
- For read models, prefer interface-based projections or DTO constructors; avoid returning entities to upper layers.
- Use explicit @Query for tuned reads; avoid leaking JPA specifics to controllers.

Example repository with projections
```java
// com.example.data.UserRepository.java
package com.example.data;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserRepository extends JpaRepository<UserEntity, Long> {

  Optional<UserEntity> findByEmail(String email);

  interface UserRow {
    Long getId();
    String getEmail();
    String getName();
  }

  @Query("""
      select u.id as id, u.email as email, u.name as name
      from UserEntity u
      where (:q is null or lower(u.email) like lower(concat('%', :q, '%')))
      """)
  Page<UserRow> search(@Param("q") String q, Pageable pageable);
}
```

Transactional boundaries (service layer)
- Place @Transactional on service methods, not on repositories or controllers.
- Default read paths to @Transactional(readOnly = true) to reduce overhead and avoid accidental writes.
- For write paths, set isolation/propagation only when required; defaults are usually sufficient (Isolation.DEFAULT).

Example service with transactions
```java
// com.example.domain.UserService.java
package com.example.domain;

import com.example.data.UserEntity;
import com.example.data.UserRepository;
import com.example.domain.errors.DomainExceptions;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {
  private final UserRepository repo;

  public UserService(UserRepository repo) { this.repo = repo; }

  @Transactional(readOnly = true)
  public UserEntity getEntity(long id) {
    return repo.findById(id).orElseThrow(() -> new DomainExceptions.NotFound("user " + id));
  }

  @Transactional
  public long create(String email, String name) {
    if (repo.findByEmail(email).isPresent()) {
      throw new DomainExceptions.Conflict("email already exists");
    }
    var e = new UserEntity();
    e.setEmail(email);
    e.setName(name);
    return repo.saveAndFlush(e).getId();
  }
}
```

Optimistic and pessimistic locking
- Optimistic: add @Version and carry the version through updates. On conflict, map OptimisticLockException to HTTP 409 with a stable problem code.
- Pessimistic: for hot rows, use @Lock on repository methods (LockModeType.PESSIMISTIC_WRITE/READ). Keep lock scope as short as possible.

Example pessimistic lock usage
```java
// com.example.data.UserLockingRepository.java
package com.example.data;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.*;
import java.util.Optional;

public interface UserLockingRepository extends JpaRepository<UserEntity, Long> {
  @Lock(LockModeType.PESSIMISTIC_WRITE)
  @Query("select u from UserEntity u where u.id = :id")
  Optional<UserEntity> lockById(Long id);
}
```

Fetch strategies and N+1
- Default relationships to LAZY.
- Avoid N+1 via explicit fetch joins for controlled graphs or projection queries for read models.
- Do not overuse fetch join across multiple collections (cartesian explosion). Consider DTO projections.

DTO projections vs entity graphs
- DTO projections (interface or constructor) are the preferred read pattern for API payloads.
- Entity graphs provide fetch plans for entities when needed; use sparingly and document.

Pagination and sorting
- Prefer Pageable for repository methods. Normalize API parameters in controller/service layers.
- Set sensible maximum page sizes; document defaults and caps in OpenAPI.

Example paginated query
```java
// com.example.domain.UserQueries.java
package com.example.domain;

import com.example.data.UserRepository;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;

@Service
public class UserQueries {
  private final UserRepository repo;
  public UserQueries(UserRepository repo) { this.repo = repo; }

  public Page<UserRepository.UserRow> search(String q, int page, int size, Sort sort) {
    var pageable = PageRequest.of(Math.max(0, page), Math.min(100, size), sort);
    return repo.search(q, pageable);
  }
}
```

Flushing, batching, and write performance
- Call saveAndFlush only when necessary; otherwise let the transaction commit flush changes.
- Batch writes by minimizing per-entity flushes; prefer repository.saveAll for bulk inserts, but be aware it returns managed instances.
- Configure Hibernate JDBC batch size where appropriate (hibernate.jdbc.batch_size) and order_inserts/updates for stability.

Isolation and propagation
- Use defaults unless a specific anomaly must be prevented.
- For idempotent retry strategies, prefer application-level retry around transactions with careful duplicate protection (unique constraints, idempotency keys).

Outbox, events, and consistency
- For cross-system communication (e.g., publish to Kafka), avoid dual-write within the same transaction without a pattern.
- Use the transactional outbox pattern: write domain event to an outbox table within the DB transaction; a separate reliable publisher reads and publishes.
- Ensure unique constraints and retry-safe consumers; prefer exactly-once semantics at business level.

Migrations
- Use Flyway or Liquibase; forward-only migrations, checksum discipline.
- Do not rely on hbm2ddl.auto outside local development. In tests, prefer migrations to match production schemas.

Testing strategy (persistence)
- @DataJpaTest for repository-focused tests; slice starts JPA and config but not web.
- Testcontainers for real DB (PostgreSQL) integration tests; apply migrations on startup.
- Seed deterministic fixtures; wrap test logic in transactions with rollback or clean DB between tests.

Example @DataJpaTest
```java
// com.example.data.UserRepositoryTest.java
package com.example.data;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
class UserRepositoryTest {

  @Autowired UserRepository repo;

  @Test
  void findByEmail_roundtrip() {
    var e = new UserEntity();
    e.setEmail("a@b.test");
    e.setName("Alice");
    repo.save(e);

    assertThat(repo.findByEmail("a@b.test")).isPresent();
  }
}
```

Observability and troubleshooting
- Log SQL only for debugging (do not enable show_sql in production). Prefer category-based logging with parameterized SQL (org.hibernate.SQL, org.hibernate.orm.jdbc.bind).
- Surface key metrics: connection pool utilization (Hikari), transaction durations, slow query alerts.
- Propagate correlation IDs to JDBC logs; include trace/span IDs if tracing is enabled.

Configuration anchors (application.yml snippets)
```yaml
spring:
  jpa:
    open-in-view: false # prefer service-layer transactions; avoid OSIV
    properties:
      hibernate.jdbc.time_zone: UTC
      hibernate.format_sql: true
      hibernate.jdbc.batch_size: 50
      hibernate.order_inserts: true
      hibernate.order_updates: true
```

Open Session in View (OSIV)
- Disable spring.jpa.open-in-view to avoid lazy loads during view rendering and to keep transactional boundaries explicit in services.

Common pitfalls
- Returning entities from services to controllers → leaks persistence concerns.
- EAGER on large graphs → memory blowups, hidden N+1 issues.
- Performing remote calls (HTTP, mail) inside transactions → long transactions; move after-commit via events/outbox.
- Ignoring unique constraints and expecting app-only checks → race conditions; enforce at DB level.

Checklist
- Entities model aggregates with explicit ownership; @Version present where needed.
- Repositories return DTO projections for read models; tuned queries use @Query.
- Service layer owns @Transactional boundaries; read paths use readOnly.
- OSIV disabled; N+1 avoided with projections or targeted fetch joins.
- Migrations forward-only; tests use Testcontainers and apply real migrations.
- Observability: SQL logs off in prod; metrics/slow query alerts configured.

See also
- Spring topic index — ./README.md
- MVC REST & Validation — ./mvc-rest-validation.md
- Hibernate ORM overview — ../hibernate/hibernate-orm-overview.md
- Hibernate ORM transactions — ../hibernate/hibernate-orm-transactions.md
- Database reference — ../../data/database/README.md
- Observability — ../../platform/observability/README.md