# Hibernate 7 Reactive — SessionFactory (Modular Overview)

Use this entry when prompts reference bootstrapping Mutiny.SessionFactory or persistence unit configuration.

## Quick start
```java
import org.hibernate.reactive.mutiny.Mutiny;
import jakarta.persistence.Persistence;

Mutiny.SessionFactory sf = Persistence
  .createEntityManagerFactory("my-unit")
  .unwrap(Mutiny.SessionFactory.class);
```

## Patterns and guidance
- Treat SessionFactory as an application singleton; initialize once at startup and dispose on shutdown.
- Prefer dependency injection of SessionFactory into repositories/services; do not create per-request.
- Use `withSession`/`withTransaction` helpers on SessionFactory for lifecycle safety.

## Example utility
```java
import org.hibernate.reactive.mutiny.Mutiny;
import io.smallrye.mutiny.Uni;

@FunctionalInterface
interface TxOp<T> { Uni<T> apply(Mutiny.Session s, Mutiny.Transaction tx); }

class HRx {
  static <T> Uni<T> tx(Mutiny.SessionFactory sf, TxOp<T> op) { return sf.withTransaction(op); }
}
```

## See also
- Overview — ./hibernate-7-reactive-overview.md
- Transactions — ./hibernate-7-reactive-transactions.md
- CRUD Patterns — ./hibernate-7-reactive-crud.md
- Topic Index — ./README.md
