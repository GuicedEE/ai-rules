# Integration & JPMS — JWebMP Client

Scope
- How consumers wire the JWebMP Client into JVM builds with JPMS and dependency management.

Rules
- **Dependency**: Add the library as a Maven/Gradle dependency (`com.jwebmp:jwebmp-client:<version>`); avoid shading it.
- **JPMS**: Require `com.jwebmp.client` in `module-info.java`; open only the packages your app reflects over. Keep exports/opens minimal.
- **Binders**: Install the provided Guice binder that supplies `AjaxCall`/`AjaxResponse` in call scope and registers interception keys. Do not duplicate bindings.
- **Configuration hook**: Use the provided configuration class to enable classpath scanning; prefer overrides that avoid global mutable state.
- **Interceptors via ServiceLoader**: Register interceptors using ServiceLoader metadata (and JPMS provides clauses if you use JPMS); avoid manual singleton registration.
- **Environment**: Keep secrets/config in your application configuration (.env, config files); the client library should receive values through normal DI/config mechanisms.

See also
- Topic index — README.md
- GuicedEE platform — ../../backend/guicedee/README.md
- Java/Maven build tooling — ../../language/java/build-tooling.md
