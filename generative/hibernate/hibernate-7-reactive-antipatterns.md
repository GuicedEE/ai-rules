# Hibernate 7 Reactive — Anti-Patterns (Modular Overview)

Use this entry to quickly check what NOT to do with Hibernate Reactive 7.x.

## Common mistakes
- Blocking the reactive pipeline (e.g., `.toCompletableFuture().get()`, `Thread.sleep()` in flow).
- Manually managing transactions for simple cases; prefer `withTransaction`.
- Sharing `Mutiny.Session` across threads/requests.
- Relying on JPA lazy proxies; prefer explicit fetches or DTOs.
- Mixing blocking JDBC APIs with reactive flows.
- Creating a SessionFactory per request; it must be a singleton.

## Safer alternatives
- Propagate `Uni<T>` from repositories up to handlers/controllers.
- Use `withSession` for read-only flows and `withTransaction` for writes.
- For batch work, chain operations with `flatMap` and avoid parallel thread pools unless fully isolated.

## See also
- Transactions — ./hibernate-7-reactive-transactions.md
- Threading & Context — ./hibernate-7-reactive-threading.md
- CRUD Patterns — ./hibernate-7-reactive-crud.md
- Topic Index — ./README.md
