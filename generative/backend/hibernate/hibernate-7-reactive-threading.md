# Hibernate 7 Reactive — Threading & Context (Modular Overview)

Use this entry when prompts reference Vert.x event loop context, Mutiny threading, or reactive composition with Hibernate Reactive 7.x.

## Quick start
- Assume operations run on Vert.x context threads managed by Hibernate Reactive/Mutiny.
- Do not hop to worker threads in the middle of a DB flow unless necessary.
- Expose reactive types outward; only subscribe at application edges.

## Patterns and guidance
- Return `Uni<T>` all the way up from repositories to services/handlers.
- For Vert.x handlers, compose with `onItem().transformToUni(...)` and respond in the `subscribe()` callback.
- Never share Mutiny.Session across threads or requests.
- For logging/tracing, prefer context-aware loggers and propagate correlation ids explicitly.

## Example (Vert.x handler)
```java
router.get("/users/:id").handler(rc -> {
  String id = rc.pathParam("id");
  userRepo.find(id)
    .subscribe().with(
      user -> rc.response().end(user.toJson()),
      err -> rc.fail(err)
    );
});
```

## See also
- Transactions — ./hibernate-7-reactive-transactions.md
- CRUD Patterns — ./hibernate-7-reactive-crud.md
- Topic Index — ./README.md
