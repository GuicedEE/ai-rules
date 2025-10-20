# Hibernate 7 Reactive — Transactions (Modular Overview)

Use this entry when prompts reference withTransaction, transactional boundaries, or error handling in non-blocking flows.

## Quick start
```java
sf.withTransaction((session, tx) -> session.persist(entity));
```

## Patterns and guidance
- Prefer `withTransaction((s, tx) -> ...)` for implicit begin/commit/rollback.
- Return `Uni<T>` from the lambda; avoid side-effect-only code where possible.
- Chain additional work inside the same transaction via `flatMap`:

```java
sf.withTransaction((s, tx) -> s.persist(a)
  .flatMap(v -> s.persist(b))
  .replaceWith(b));
```

- For read-only flows, `withSession(s -> ...)` is sufficient.
- Avoid manual `begin/commit`; only do it for rare, advanced orchestration.

## Error handling
- Throwing inside the lambda marks the transaction for rollback.
- Use `onFailure().recoverWithItem(...)` to convert known errors to domain-safe responses.

## See also
- Overview — ./hibernate-7-reactive-overview.md
- SessionFactory — ./hibernate-7-reactive-session-factory.md
- CRUD Patterns — ./hibernate-7-reactive-crud.md
- Topic Index — ./README.md
