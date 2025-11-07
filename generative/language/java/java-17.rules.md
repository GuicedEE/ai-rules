# Java 17 LTS — Language Rules

Audience: JVM services and libraries targeting Java 17 LTS. Optimized for AI-assisted generation and human maintenance. Aligns with repository modularity and forward-only policy.

Goals
- Provide enforceable Java 17 baselines (toolchains, compiler flags, CI).
- Standardize language features, nullness contracts, testing, and observability.
- Ensure compatibility with backend topics (Vert.x, Hibernate Reactive, Security).

Scope
- Toolchains (Gradle, Maven), source/target compatibility
- Language features to use/avoid on 17
- Concurrency and async programming (no virtual threads on 17)
- Nullness contracts (JSpecify) and static analysis
- Testing, logging, observability

---

Project setup — Toolchains and compiler

- Centralize build configuration in build-tooling. See ./build-tooling.md for Gradle/Maven toolchains, maven-compiler-plugin, toolchains.xml, formatting, and CI alignment.

---

Language features — Java 17 baseline
- Records (finalized): Use for immutable DTOs and value carriers.
- Sealed classes/interfaces (finalized): Use for closed hierarchies.
- Switch expressions (standard): Prefer expression form for concise logic.
- Text blocks: Use for multi-line strings (SQL, JSON); keep indentation clean.
- Pattern matching for instanceof (standard): Replace explicit casts where applicable.
- Avoid preview/incubator features unless an explicit project decision enables them across build/run/test.

Example — record and sealed
```java
public record UserId(String value) {}

public sealed interface Result permits Ok, Err {}

public record Ok<T>(T value) implements Result {}
public record Err(String message) implements Result {}
```

---

Concurrency and async (no virtual threads)
- Java 17 does not include virtual threads; prefer non-blocking frameworks (e.g., Vert.x) or structured CompletableFuture usage.
- Avoid blocking on event loops; where blocking IO is unavoidable, dedicate separate thread pools.
- Use CompletableFuture for async composition; prefer explicit timeouts and cancellation.

Example — CompletableFuture with timeout
```java
var executor = Executors.newFixedThreadPool(8);
CompletableFuture<User> cf = CompletableFuture.supplyAsync(() -> repo.find(id), executor)
    .orTimeout(2, TimeUnit.SECONDS);
```

For Vert.x guidance, see: ../../backend/vertx/README.md

---

Nullness and API contracts
- Standardize on JSpecify annotations for nullness.
- Adopt @NullMarked at package level in libraries; annotate @Nullable only where necessary.
- For Kotlin interop, keep nullness explicit to avoid platform types.

See JSpecify rules — ../../backend/jspecify/jspecify.rules.md
Examples — ../../backend/jspecify/examples.md

---

Static analysis and formatting
- Error Prone (prefer) or SpotBugs for static analysis.
- Formatting configuration for Spotless (Gradle) and fmt-maven-plugin (Maven): see ./build-tooling.md

---

Testing
- JUnit 5 (Jupiter) with AssertJ/Hamcrest as needed.
- Use Testcontainers for integration tests.
- Keep tests parallelizable; avoid static global mutable state.

Build integration (Gradle/Maven): see ./build-tooling.md

---

Observability and logging
- SLF4J API with implementation bound per environment.
- Redact secrets; never log tokens. Propagate tracing context (OpenTelemetry preferred).

---

JPMS (modules) guidance
- For libraries, provide module-info.java with narrow exports and requires.
- For applications, start modularization at boundaries; keep unnamed module dependencies minimized.

Example — module descriptor
```java
module com.example.lib {
  exports com.example.lib.api;
  requires static org.jspecify;
}
```

---

Interoperability
- Kotlin interop: maintain null-safety and avoid raw types; prefer sealed hierarchies and records for simple data.
- MapStruct and Lombok: prefer explicit mapping and avoid heavy codegen in core domain where possible. See ../../backend/mapstruct/README.md and ../../backend/lombok/README.md

---

Anti-patterns
- Relying on preview features without CI alignment
- Blocking event loops or using shared ForkJoinPool for blocking IO
- Returning null collections instead of empty
- Exposing internal entities (JPA) directly to transport layer

---

See also
- Language index — ../README.md
- Build tooling — ./build-tooling.md
- Backend index — ../../backend/README.md
- Vert.x 5 — ../../backend/vertx/README.md
- Security (Reactive) — ../../backend/security-reactive/README.md
- Logging — ../../backend/logging/README.md
- JSpecify — ../../backend/jspecify/README.md

Versioning and forward-only policy
- Apply edits forward-only; update references in the same change.
- Keep this file modular and concise; link to deeper topics rather than duplicating.