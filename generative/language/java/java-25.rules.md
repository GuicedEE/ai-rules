# Java 25 LTS — Language Rules

Audience: JVM services and libraries targeting Java 25 LTS. Optimized for AI-assisted generation and human maintenance. Aligns with repository modularity and forward-only policy.

Goals
- Provide enforceable Java 25 baselines (toolchains, compiler flags, CI).
- Standardize language features, concurrency (virtual threads), nullness, testing, and observability.
- Ensure compatibility with backend topics (Vert.x, Hibernate Reactive, Security).

Scope
- Toolchains (Gradle, Maven), source/target compatibility
- Language features to use/avoid on 25
- Concurrency and async programming (virtual threads)
- Nullness contracts (JSpecify) and static analysis
- Testing, logging, observability
- JPMS for libraries and modular apps

---

Project setup — Toolchains and compiler

- Centralize build configuration in build-tooling. See ./build-tooling.md for Gradle/Maven toolchains, maven-compiler-plugin, toolchains.xml, formatting, and CI alignment.

---

Language features — Java 25 baseline
- Records: Use for immutable DTOs and value carriers.
- Sealed classes/interfaces: Use for closed hierarchies.
- Pattern matching for instanceof: Prefer over explicit casts.
- Enhanced switch (expressions): Prefer expression form for concise logic.
- Text blocks: Use for multi-line strings (SQL, JSON) with clean indentation.
- Sequenced collections: Prefer standard APIs where applicable.
- Unused lambda parameters: Use a leading-underscore identifier for intentionally unused parameters (single "_" is a reserved keyword since Java 9 and cannot be used). Examples: _ignored or __.
```java
someApi.notUsed(_ignored -> { });
someApi.notUsed(__ -> { });
```
- Avoid preview features (e.g., string templates, record patterns, structured concurrency incubator) unless a project-wide decision is made and CI is configured accordingly.

Example — record and sealed
```java
public record UserId(String value) {}

public sealed interface Result permits Ok, Err {}

public record Ok<T>(T value) implements Result {}
public record Err(String message) implements Result {}
```

---

Concurrency and async — Virtual threads
- Prefer virtual threads for blocking-style concurrency when using blocking IO or classic libraries/SDKs.
- Use Executors.newVirtualThreadPerTaskExecutor() for request-per-task models.
- Do not mix blocking IO on event loops (e.g., Vert.x) — choose either non-blocking stack or virtual-threads blocking style per service.

Example — Virtual thread per task
```java
try (var executor = java.util.concurrent.Executors.newVirtualThreadPerTaskExecutor()) {
  var futures = java.util.stream.IntStream.range(0, 10)
      .mapToObj(i -> executor.submit(() -> repository.fetch(i)))
      .toList();

  for (var f : futures) {
    f.get(2, java.util.concurrent.TimeUnit.SECONDS);
  }
}
```

Guidance:
- For high-throughput IO-bound services that already use reactive stacks (Vert.x), continue non-blocking design.
- For simpler codebases or heavy use of blocking drivers/SDKs, virtual threads provide simpler concurrency with strong scalability on 25.

See Vert.x guidance — ../../backend/vertx/README.md

---

Foreign Function & Memory (FFM) API
- Use FFM API (Project Panama) for native interop where applicable; avoid JNI for new integrations.
- Encapsulate native access behind small interfaces; mock in tests.
- Ensure memory session lifetimes are well-scoped; avoid leaking arena allocations.

---

Nullness and API contracts
- Standardize on JSpecify annotations for nullness.
- Adopt @NullMarked at package level in libraries; annotate @Nullable only where necessary.
- Maintain consistency at module/package boundaries to avoid ambiguity for Kotlin consumers.

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
- When using virtual threads in tests, use per-test executors and ensure deterministic shutdown.

Build integration (Gradle/Maven): see ./build-tooling.md

---

Observability and logging
- SLF4J API with environment-bound implementation.
- Redact secrets; never log tokens.
- Propagate tracing context (OpenTelemetry preferred).

---

JPMS (modules) guidance
- For libraries, provide module-info.java with narrow exports and requires.
- For applications, modularize boundaries gradually; keep unnamed dependencies minimized.

Example — module descriptor
```java
module com.example.lib {
  exports com.example.lib.api;
  requires static org.jspecify;
}
```

---

Interoperability
- Kotlin interop: maintain null-safety; avoid raw types; leverage records/sealed types for DTOs/hierarchies.
- MapStruct and Lombok: prefer explicit mapping; avoid heavy codegen in core domain. See ../../backend/mapstruct/README.md and ../../backend/lombok/README.md

---

Migration notes
- From Java 17: evaluate replacing reactive or custom thread-pool blocking code with virtual threads where appropriate; upgrade toolchains and CI; rebaseline warnings to -Werror.
- From Java 21: virtual threads remain default; re-evaluate any preview features used on 21 and migrate only if the features are GA on 25 or keep them off by default.

---

Anti-patterns
- Enabling preview features ad hoc without CI alignment
- Blocking event loops in reactive frameworks
- Returning null collections instead of empty
- Exposing internal entities (JPA) directly to transport
- Leaking memory sessions when using FFM API

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