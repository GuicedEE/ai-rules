# 📘 Vert.x Service Discovery Strategy

## Purpose

This document describes how services in the AI Experiment backend architecture will be dynamically located, resolved, and consumed using Vert.x's service discovery and service resolver modules.

---

# 📗 Rules

## Service Identity

* Each backend microservice must register itself in the service discovery registry with a unique name.
* The service name must follow the pattern: `domain.service-name.version`.
* Only one active registration should exist per deployment target and version.

## Discovery Mechanism

* Vert.x `ServiceDiscovery` must be initialized using environment-aware backends (e.g., Consul, Kubernetes, Redis, or in-memory for local).
* All service interfaces must define a `ServiceReference` contract and expose their capabilities via metadata.
* Use `EventBusService` or `HttpEndpoint` record types depending on implementation.

## Consumption

* Service consumers must not hardcode endpoints.
* Use `ServiceReference` or `ServiceProxyBuilder` from the Vert.x service-resolver module.
* Apply retry policies and circuit breakers via `io.vertx.circuitbreaker.CircuitBreaker`.

## Security and Isolation

* Service registrations should carry metadata describing scopes, audience, and allowed clients.
* Services not intended for external consumption must be registered as `internal-only=true`.

---

# 📙 Guides

## Local Mode

* For local development, in-memory discovery is enabled by default.
* `ServiceDiscovery.create(vertx)` with `new ServiceDiscoveryOptions().setBackendConfiguration(...)` pointing to embedded store.
* Optionally use `.json` or YAML files to simulate remote services.

## Production Mode

* GCP-compatible discovery backend is deployed (e.g., via Redis or Cloud MemoryStore).
* Services are tagged with environment and service metadata.
* Health check integration via Vert.x Health module feeds discovery status.

## EventBus Service Resolver

This strategy is preferred for internal services that communicate over the Vert.x EventBus:

```java
Record record = EventBusService.createRecord(
  "user.account.v1",
  "com.aiexperiment.user.AccountService",
  new JsonObject().put("version", "1.0.0")
);
discovery.publish(record, ar -> {
  if (ar.succeeded()) {
    System.out.println("Service published!");
  }
});
```

## Resolving a Service with ServiceProxyBuilder

```java
ServiceDiscovery discovery = ServiceDiscovery.create(vertx);
discovery.getRecord(new JsonObject().put("name", "user.account.v1"), ar -> {
  if (ar.succeeded() && ar.result() != null) {
    Record record = ar.result();
    AccountService service = discovery.getReference(record).getAs(AccountService.class);
    service.doSomething();
  }
});
```

## Fallback and Retry

Use `CircuitBreaker` with retry:

```java
CircuitBreaker breaker = CircuitBreaker.create("account-breaker", vertx,
  new CircuitBreakerOptions()
    .setMaxFailures(3)
    .setTimeout(1000)
    .setFallbackOnFailure(true)
);

breaker.execute(promise -> {
  // Call service here
});
```

## Example Metadata

```json
{
  "version": "1.0.0",
  "env": "dev",
  "internal-only": true,
  "audience": ["frontend", "admin"]
}
```

---

# 📒 Implementation

## Discovery Registration Hook

* Each service's `MainVerticle` should perform registration on startup and deregistration on shutdown.
* Use async coordination to prevent startup before successful registration.

## Integration with Health Checks

* Registration is valid only while service is healthy.
* If a service enters a critical state, its record should be automatically marked as out-of-service.

## Service Consumption Pattern

```java
ServiceDiscovery discovery = ServiceDiscovery.create(vertx);
discovery.getRecord(new JsonObject().put("name", "user.account.v1"), ar -> {
  if (ar.succeeded() && ar.result() != null) {
    Record record = ar.result();
    AccountService service = discovery.getReference(record).getAs(AccountService.class);
    service.doSomething();
  }
});
```

## Cleanup

* Always release service references using `release()` to avoid memory/resource leaks.

---

Ready for integration into backend scaffolding.
