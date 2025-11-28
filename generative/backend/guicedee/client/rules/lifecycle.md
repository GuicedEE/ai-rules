# Lifecycle Rules — GuicedEE Inject Client

Scope
- Defines how to implement and register lifecycle services provided by the client library under package com.guicedee.client.services.lifecycle.

Lifecycle SPIs
- IGuicePreStartup<J>
  - Runs before Guice is injected. Returns List<io.vertx.core.Future<Boolean>> for async steps.
  - Default sortOrder() = 100; may be overridden by implementations. Not injectable (@INotInjectable).
- IGuicePostStartup<J>
  - Runs after initial startup to finalize client initialization.
- IGuicePreDestroy<J>
  - Used for closing or terminating resources before shutdown; invoked prior to final destroy. Must be idempotent and thread-safe.
- IGuicePreDestroy<J>
  - Runs during shutdown to release resources; must be idempotent.
- IGuiceModule<J> extends com.google.inject.Module
  - Service-located Guice module; default enabled() = true. Use for bindings only; avoid heavy logic.
- IGuiceConfigurator
  - Functional interface to configure IGuiceConfig for GuiceContext/Injector.
- IOnCallScopeEnter<J>
  - Hook when a call/request scope begins; onScopeEnter(Scope scope).
- IOnCallScopeExit<J>
  - Hook when a call/request scope ends; onScopeExit().

Registration Policy (mandatory)
- Dual registration: META-INF/services AND JPMS provides clauses. See ../services/services.md for concrete filenames and module-info.java snippets.

Scoping & Ordering
- Prefer Application/Singleton scope for lifecycle services; implementations must be stateless and thread-safe.
- Use sortOrder() to control startup execution order where applicable. Reserve very low values for foundational configuration (e.g., Integer.MIN_VALUE + 1 as used by GuicedEEClientStartup).

Idempotency & Side Effects
- Lifecycle hooks must be idempotent; repeated invocations must not corrupt state.
- Avoid blocking calls on event loops. Use Vert.x Futures/Promises or Mutiny Uni for async work.

References
- Source package: com.guicedee.client.services.lifecycle
- Host implementation examples: see ../../../../src/main/java/com/guicedee/client/implementations/
- Topic index: ../README.md