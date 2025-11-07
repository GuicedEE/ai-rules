# Java — Topic Glossary (Priority over root glossary)

Scope
- Minimal canonical terms and LLM interpretation guidance for Java in this repository. When this topic is active, these terms take precedence over the root glossary. Keep entries concise and route to version rules and adjacent topics for detail.

LLM interpretation guidance (how to apply these terms)
- Version selection (LTS)
  - Select exactly one LTS per project (17/21/25) in prompts. Route to version rules:
    - Java 17 — ./java-17.rules.md
    - Java 21 — ./java-21.rules.md
    - Java 25 — ./java-25.rules.md
  - Apply guidance in ./build-tooling.md for toolchains, compiler flags, and module setup. Do not mix language features across versions.

- JPMS (module system) policy
  - Prefer JPMS for libraries/modules. Provide module-info.java with tight requires/exports. For annotation-only dependencies (e.g., JSpecify), use requires static.
  - Open packages to processors only when necessary (e.g., opens com.example.mapper to org.mapstruct.processor).

- Nullness contracts (JSpecify)
  - Standardize on JSpecify. Adopt @org.jspecify.annotations.NullMarked at package/class level and annotate @org.jspecify.annotations.Nullable precisely.
  - Do not return null collections/optionals. Prefer empty collections and Optional.empty(). Avoid @Nullable Optional<T>.
  - For Kotlin interop, configure -Xjsr305=strict on Kotlin and add JSpecify to Java sources to eliminate platform types (see ../backend/jspecify/README.md).

- Records and immutability
  - Prefer records for DTOs/value carriers where appropriate. Use immutable collections (List.copyOf, Set.copyOf, Map.copyOf).
  - For entities or mutable aggregates, model explicit mutation with clear invariants; do not conflate DTO and entity responsibilities.

- Sealed hierarchies and ADTs
  - Prefer sealed classes/interfaces for closed polymorphic domains. Use exhaustive switch with pattern matching to enforce completeness (21+).

- Optional policy
  - Use Optional<T> only for return types to indicate absence/presence. Do not use Optional in fields, parameters, or collections. Prefer empty collections/optionals over null.

- Concurrency and async
  - Choose one dominant async model per module:
    - Virtual threads (21+/25): structured concurrency, blocking style APIs made scalable; avoid mixing with event-loop stacks.
    - Reactive stacks (Vert.x/Hibernate Reactive): non-blocking, event loop safe; never block the event loop; use Mutiny Uni/Multi.
  - Align with selected backend: if Vert.x/Hibernate Reactive is present, prefer reactive patterns; otherwise consider virtual threads for traditional blocking code that needs scalability.

- Exceptions and error handling
  - Use checked exceptions sparingly; prefer domain-specific unchecked exceptions or result types (sealed ADTs) for recoverable flows. Use try-with-resources, declare precise throws for interop.

- Serialization and representations
  - Prefer explicit mapping/representation layers (MapStruct, representation libs) over reflection-heavy generic mappers. Avoid exposing entities directly over boundaries.

- Annotation processing and interop
  - Coordinate Lombok/MapStruct/Hibernate processors with correct ordering (Lombok first; MapStruct last). Configure processor paths in toolchains (see ../backend/lombok/lombok.md, ../backend/mapstruct/README.md).

- Build/tooling posture
  - Enforce compiler flags via ./build-tooling.md; set release level; enable preview features only within version-policy if required.

Routing
- Java index — ./README.md
- Version rules — ./java-17.rules.md, ./java-21.rules.md, ./java-25.rules.md
- Build/tooling — ./build-tooling.md
- JSpecify — ../../backend/jspecify/README.md
- Lombok — ../../backend/lombok/README.md
- MapStruct — ../../backend/mapstruct/README.md
- Vert.x — ../../backend/vertx/README.md
- Hibernate Reactive — ../../backend/hibernate/README.md

Canonical terms

- JPMS (Java Platform Module System)
  - Meaning: Module boundary system providing explicit dependencies and exports.
  - LLM: define module-info.java; use requires for runtime deps and requires static for compile‑time‑only (e.g., JSpecify). Use exports only for public API packages.

- module-info.java (descriptor)
  - Meaning: Declares module name, dependencies (requires), and exported packages (exports); optional opens for reflection/processing.
  - LLM: keep minimal surface; use opens to processors only (e.g., opens com.example.mapper to org.mapstruct.processor).

- requires static
  - Meaning: Compile-time‑only dependency that is not required at runtime (e.g., annotation libraries).
  - LLM: apply for org.jspecify and similar annotation-only libs.

- Record (record Foo(...))
  - Meaning: Immutable value class with canonical constructor, accessors, equals/hashCode/toString.
  - LLM: prefer for DTOs and value carriers; maintain invariants in canonical/compact constructor.

- Sealed class/interface (sealed … permits …)
  - Meaning: Closed inheritance hierarchy enabling exhaustive analysis and safe polymorphism.
  - LLM: model domain variants as sealed hierarchies; ensure exhaustive switches.

- Pattern matching for switch (21+)
  - Meaning: switch with type patterns and guards.
  - LLM: prefer for sealed hierarchies; enforce exhaustiveness with default throwing or no default where compiler enforces completeness.

- Text blocks ("""…""")
  - Meaning: Multiline strings with preserved formatting.
  - LLM: prefer for embedded SQL/JSON/test fixtures. Avoid concatenation.

- var (local variable type inference)
  - Meaning: Infers local variable type at compile time.
  - LLM: use when type is obvious from initializer and improves readability; avoid obscuring types in public APIs.

- Optional<T> (return-only)
  - Meaning: Return type signalling absence/presence.
  - LLM: return Optional; do not accept Optional parameters nor store Optionals in fields. Prefer Optional.empty() over null.

- Stream API
  - Meaning: Fluent operations for collections/streams.
  - LLM: prefer clarity; use streams for transformations/aggregation; do not abuse chaining where loops are clearer. Close streams/resources deterministically.

- Immutability (unmodifiable vs persistent)
  - Meaning: Unmodifiable views vs truly immutable data structures.
  - LLM: prefer immutable copies for DTOs (List.copyOf); expose unmodifiable views only when necessary and well‑documented.

- SPI (Service Provider Interface)
  - Meaning: Pluggable interface discovered at runtime via service loader / META‑INF/services or provides in module-info.
  - LLM: publish SPI using provides … with … in module-info where JPMS is used; otherwise use META‑INF/services. Keep contracts small and cohesive.

- Annotation processing
  - Meaning: Compile‑time codegen/validation (Lombok/MapStruct/Hibernate).
  - LLM: order processors correctly (Lombok → framework → MapStruct); ensure opened packages and processor paths; avoid runtime reflection for what processors can generate.

- Testing (JUnit Jupiter)
  - Meaning: JUnit 5 platform (jupiter API/engine) with parameterized tests, lifecycle, assertions.
  - LLM: prefer JUnit 5; use Testcontainers for integration DB/tests; avoid flaky timing‑sensitive tests.

- Logging (Log4j2/SLF4J)
  - Meaning: Facade vs backend; consistent logging policy and patterns.
  - LLM: prefer repository’s standard (e.g., Log4j2 via Lombok @Log4j2 where allowed); avoid static loggers in non‑final classes unless policy accepts.

- Virtual threads (21+/25)
  - Meaning: Lightweight threads suitable for high concurrency blocking IO.
  - LLM: use Executors.newVirtualThreadPerTaskExecutor(); keep blocking IO; avoid mixing with event‑loop frameworks in the same module.

- Reactive (Vert.x/Mutiny)
  - Meaning: Non‑blocking IO with event loop; primitives Future/Uni/Multi.
  - LLM: never block the event loop; use withTransaction patterns for Hibernate Reactive; prefer compositional APIs (compose/flatMap) over blocking joins.

- Serialization (JSON/XML/CSV)
  - Meaning: Convert domain objects to external formats.
  - LLM: prefer explicit mappers (MapStruct) and representation libraries over reflection‑heavy generic conversions in hot paths.

Patterns and directives

- Nullness & interop
  - Adopt @NullMarked; annotate @Nullable precisely. Avoid null returns for collections/optionals. Configure interop with Kotlin (-Xjsr305=strict) to remove platform types.

- Module boundaries
  - Model public API via exports; keep internals unexported. Use provides/uses for SPIs. Validate that shading is not used for drivers where policy forbids it (e.g., PostgreSQL JPMS policy under GuicedEE).

- DTO vs Entity
  - Keep DTOs immutable (records) and entities explicit with lifecycle. Map via MapStruct; set null/collection policies explicitly.

- Concurrency selection
  - Default to either virtual threads (blocking style) or reactive (event‑loop). Do not mix within a module; bridge at boundaries only.

- Processors
  - Lombok first, then framework processors (Hibernate, etc.), MapStruct last. Ensure lombok‑mapstruct‑binding is present when combining Lombok and MapStruct.

Prompt alignment
- When Java is selected in prompts:
  - Select LTS version (17/21/25) and apply the corresponding rules file (./java-XX.rules.md) plus ./build-tooling.md.
  - Enforce JPMS for libraries/modules with correct requires/exports/opens. Use requires static for annotations like JSpecify.
  - Apply JSpecify nullness policy and Optional/collections policy consistently across code and mappers.
  - Align with chosen backend strategy (reactive vs virtual threads). If reactive stacks are selected (Vert.x/Hibernate Reactive), avoid blocking on event loops and use non‑blocking transaction patterns.

See also
- Language index — ./README.md
- Java 17 rules — ./java-17.rules.md
- Java 21 rules — ./java-21.rules.md
- Java 25 rules — ./java-25.rules.md
- Build tooling — ./build-tooling.md
- JSpecify — ../../backend/jspecify/README.md
- Lombok — ../../backend/lombok/README.md
- MapStruct — ../../backend/mapstruct/README.md
- Vert.x — ../../backend/vertx/README.md
- Hibernate Reactive — ../../backend/hibernate/README.md