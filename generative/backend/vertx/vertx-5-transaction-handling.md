# 📘 Topic Rules: Vert.x Transaction Handling

These rules define how transactions should be handled in Vert.x applications, with support for both blocking and reactive JDBC-style database clients. These are intended to support modular, non-framework-based systems (e.g., GuicedEE + Vert.x 5) that explicitly manage resources, thread context, and side effects.

---

## 🔖 General Principles

* Transactions must be explicitly managed; Vert.x does not provide automatic transaction wrapping.
* All blocking code (e.g., JDBC) must be executed inside `executeBlocking` to avoid blocking the event loop.
* All reactive code (e.g., `Pool`, `SqlConnection`) must return `Future<T>` and be chained with proper error handling.
* Event bus consumers should delegate transactional logic to a helper or service method to ensure separation of concerns.
* Transaction boundaries must be clear: Begin → Work → Commit/Rollback → Cleanup.

---

## 🧱 Blocking Transactions (e.g., JDBC)

### 🔹 Interface

```java
@FunctionalInterface
public interface BlockingTransactionCallable<T> {
    T call(Connection conn) throws Exception;
}
```

### 🔹 Usage Pattern

```java
vertx.executeBlocking(promise -> {
    try (Connection conn = dataSource.getConnection()) {
        conn.setAutoCommit(false);
        T result = transactionCallable.call(conn);
        conn.commit();
        promise.complete(result);
    } catch (Exception e) {
        try { conn.rollback(); } catch (SQLException ignored) {}
        promise.fail(e);
    }
}, res -> {
    if (res.succeeded()) {
        // handle result
    } else {
        // handle failure
    }
});
```

---

## 🌊 Reactive Transactions (e.g., Vert.x SQL Client)

### 🔹 Interface

```java
@FunctionalInterface
public interface ReactiveTransactionCallable<T> {
    Future<T> call(SqlConnection conn);
}
```

### 🔹 Usage Pattern

```java
pool.getConnection()
  .compose(conn -> conn.begin()
    .compose(tx -> {
      return transactionCallable.call(conn)
        .compose(result -> tx.commit().map(result))
        .onFailure(err -> tx.rollback());
    })
    .eventually(v -> conn.close())
  );
```

---

## 🧰 Utility Class Example

```java
public class TransactionManager {

    public static <T> Future<T> runTransaction(ReactiveTransactionCallable<T> callable, Pool pool) {
        return pool.getConnection()
            .compose(conn -> conn.begin()
                .compose(tx -> callable.call(conn)
                    .compose(res -> tx.commit().map(res))
                    .onFailure(err -> tx.rollback())
                )
                .eventually(v -> conn.close())
            );
    }

    public static <T> void runBlockingTransaction(Vertx vertx, BlockingTransactionCallable<T> callable, DataSource ds, Handler<AsyncResult<T>> resultHandler) {
        vertx.executeBlocking(promise -> {
            try (Connection conn = ds.getConnection()) {
                conn.setAutoCommit(false);
                T result = callable.call(conn);
                conn.commit();
                promise.complete(result);
            } catch (Exception e) {
                try { conn.rollback(); } catch (SQLException ignored) {}
                promise.fail(e);
            }
        }, resultHandler);
    }
}
```

---

## 🧪 Testing & Error Handling

* Always verify rollback triggers under error conditions.
* Include `.eventually(v -> conn.close())` to guarantee cleanup.
* Wrap all commit/rollback in `.compose()` or `try/catch` as needed.
* Do not log or act on transaction errors inside `TransactionManager`; delegate to callers.

---

## 🪝 Event Bus Consumers

```java
eventBus.consumer("wallet.persist", msg -> {
    TransactionManager.runTransaction(conn -> {
        // perform insert/update/delete using conn
        return walletDao.save(conn, msg.body());
    }, pool).onSuccess(saved -> msg.reply(saved))
      .onFailure(err -> msg.fail(500, err.getMessage()));
});
```

---

## 🚫 Anti-Patterns

* ❌ Calling JDBC operations directly on the event loop
* ❌ Omitting rollback on error in a transaction block
* ❌ Sharing the same `SqlConnection` across multiple requests
* ❌ Mixing reactive and blocking transaction styles

---

## 📎 Related Topics

* [Vert.x SQL Client Docs](https://vertx.io/docs/vertx-sql-client/java/)
* [Worker Threads and `executeBlocking`](https://vertx.io/docs/vertx-core/java/#_worker_threads)
* JDBC Connection Pooling Best Practices

---

📌 Follow these rules when migrating from a threaded transactional system (like RabbitMQ or Spring) to Vert.x event-based transactional flows.
