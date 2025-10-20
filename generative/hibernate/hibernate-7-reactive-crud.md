# Hibernate 7 Reactive — CRUD Patterns (Modular Overview)

Use this entry when prompts reference create/read/update/delete with Hibernate Reactive 7.x.

## Quick start
```java
// Create
sf.withTransaction((s, tx) -> s.persist(new MyEntity(...)));

// Read
sf.withSession(s -> s.find(MyEntity.class, id));

// Update
sf.withTransaction((s, tx) -> s.merge(entity));

// Delete
sf.withTransaction((s, tx) -> s.remove(entity));
```

## Guidance
- Prefer stateless operations per request; do not keep Session across threads.
- For batch operations, chain `flatMap` per entity; avoid blocking loops.
- Fetch associations explicitly via joins or subsequent reads; avoid relying on ORM proxies.

## See also
- Transactions — ./hibernate-7-reactive-transactions.md
- Threading & Context — ./hibernate-7-reactive-threading.md
- Topic Index — ./README.md
