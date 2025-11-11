# PostgreSQL Client Guide

Using the Vert.x Reactive PostgreSQL Client:

* Connection setup with `PgBuilder` and `PoolOptions`.
* Use `withTransaction()` or manage connections manually.
* Enable pipelining for batch efficiency.
* Avoid blocking operations; prefer prepared query caching.
* Create one global `PgPool` per service.
* Use `maxSize` for pool control and `maxWaitQueueSize` to avoid overload.
* Apply `PipeliningLimit` tuning with caution.