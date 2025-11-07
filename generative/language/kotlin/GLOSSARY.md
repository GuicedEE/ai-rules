# Kotlin — Topic Glossary (Priority over root glossary)

Scope
- Minimal canonical terms for Kotlin in this topic. When this topic is referenced, these terms and directives take precedence over the root glossary. Keep entries concise and route to rules/guides for detail.

LLM interpretation guidance (how to apply these terms)
- Language posture
  - Prefer idiomatic Kotlin over Java-style code (expressive stdlib, extension functions, data/inline/value/sealed classes).
  - Enable explicit null-safety and avoid platform types at interop boundaries.
  - Generate small, focused top-level functions or extensions where they improve readability.
- Coroutines and structured concurrency
  - Prefer suspend functions for async; ensure structured concurrency via CoroutineScope and lifecycle-aware ownership.
  - Use withContext for dispatcher hops; avoid blocking calls on default/IO dispatchers.
  - Prefer Flow for cold streams and Channel for hot/actor patterns (only when needed).
- Interop with Java and JSpecify
  - Treat Kotlin types as source of truth. For Java interop, align nullness with JSpecify (@NullMarked/@Nullable) and set compiler flag -Xjsr305=strict (where applicable).
  - Avoid platform types: add JSpecify/nullness annotations in Java sources to remove ambiguity.
- Defaults for code generation
  - Favor immutable data (val) and pure functions; avoid mutable state (var) unless scoped and justified.
  - Prefer expression bodies where trivial; keep explicit return types on public API.
  - Use result-oriented APIs (sealed hierarchies) over unchecked exceptions for recoverable conditions.

Routing
- Language index — ./README.md
- Consolidated rules — ./kotlin.rules.md
- Java interop/jSpecify — ../../backend/jspecify/README.md
- Reactive/Vert.x (if applicable) — ../../backend/vertx/README.md

Canonical terms

- Null-safety (Kotlin)
  - Meaning: Types are non-null by default; T vs T? (nullable).
  - LLM: avoid !!; prefer safe-call (?.), elvis (?:), and require/check/assert or early returns.

- Platform type
  - Meaning: Type whose nullability is unknown at compile time due to Java interop.
  - LLM: eliminate platform types by annotating Java with JSpecify (@NullMarked/@Nullable) and using -Xjsr305=strict.

- Safe-call operator (?.)
  - Meaning: Calls right-hand side only if receiver is non-null; returns null otherwise.
  - LLM: pair with elvis for fallback or early return.

- Elvis operator (?:)
  - Meaning: Provide default when left operand is null.
  - LLM: prefer meaningful defaults or early exits; avoid masking errors silently.

- Non-null assertion (!!)
  - Meaning: Asserts non-null; throws NPE at runtime if null.
  - LLM: avoid; replace with safe-call + elvis or explicit precondition.

- let / run / also / apply / with
  - let: scoped variable (it) for nullable or pipeline; returns last expression.
  - run: executes block with receiver (this); returns last expression.
  - also: side-effect on receiver; returns receiver.
  - apply: configure receiver; returns receiver (builder-style).
  - with: non-extension scope function; prefer run/apply for extension context.
  - LLM: choose by intent; avoid nested/overused scope functions harming clarity.

- Data class
  - Meaning: Value holder with equals/hashCode/toString/copy components generated.
  - LLM: use for immutable records; prefer val; keep business logic outside.

- Inline class / Value class
  - Meaning: Zero-cost wrapper around a single value (compile-time); value semantics.
  - LLM: use for domain primitives (IDs, constrained types); add validation at construction or factory.

- Sealed class / Sealed interface
  - Meaning: Closed hierarchy for exhaustive modeling (ADTs).
  - LLM: prefer for Result/State/Event variants; ensure exhaustive when statements (use else only if justified).

- object / companion object
  - object: singleton declaration.
  - companion object: static-like holder for factory/constants.
  - LLM: use factory functions in companion for invariants; avoid static util patterns.

- Extension function / property
  - Meaning: Add behavior to existing types without inheritance.
  - LLM: use for cohesive, domain-relevant helpers; avoid polluting with unrelated extensions.

- Infix / operator
  - Meaning: Natural syntax for domain operations.
  - LLM: apply where algebraic/DSL semantics justify; document clearly.

- Variance (in/out) and reified type parameters
  - Meaning: Declaration-site variance (out producer, in consumer). Reified enables type checks at runtime in inline functions.
  - LLM: encode variance in APIs; use reified for type-safe builders and reflection-less checks.

- Coroutines (suspend)
  - Meaning: Suspension-based async; cooperatively scheduled.
  - LLM: avoid GlobalScope; scope to lifecycle (e.g., viewModelScope/applicationScope). Prefer supervisorScope where partial failure tolerated.

- Dispatcher (Default/IO/Main/Unconfined)
  - Meaning: Execution contexts for coroutines.
  - LLM: choose heuristically (CPU → Default, blocking IO→IO). Wrap blocking with withContext(Dispatchers.IO).

- Flow vs Channel
  - Flow: cold, declarative streams; operators for backpressure.
  - Channel: hot queue/mailbox.
  - LLM: prefer Flow; use Channel only for advanced concurrency/actor patterns.

- suspendCancellableCoroutine / ensureActive
  - Meaning: Bridge callback APIs to suspend; cooperative cancellation checks.
  - LLM: expose cancellation support; clean up resources on cancel.

- DSL builder pattern (type-safe builders)
  - Meaning: Lambdas with receiver to compose domain structures.
  - LLM: use for configuration; annotate with @DslMarker to avoid scope leaks.

- Visibility modifiers (public/internal/protected/private)
  - Meaning: Access boundaries; internal is module-scoped.
  - LLM: default to internal for library internals; public for API; minimize protected.

- lateinit vs lazy
  - lateinit: deferred non-null var; throws if uninitialized at access.
  - lazy: thread-safe by default lazy val.
  - LLM: prefer lazy; avoid lateinit unless DI/framework constraints.

- Exception handling
  - Meaning: No checked exceptions in Kotlin.
  - LLM: model error states via sealed results; use exceptions for truly exceptional cases.

- Serialization (kotlinx.serialization)
  - Meaning: Compiler plugin-based serialization; multiplatform-friendly.
  - LLM: prefer kotlinx.serialization over Jackson unless integration demands; annotate @Serializable and provide Module format.

- Testing
  - Meaning: JUnit5 or Kotest common; coroutine tests via runTest; Flow tests via Turbine.
  - LLM: use runTest (kotlinx-coroutines-test), TestScope, and proper virtual-time utilities.

Java/Kotlin interop notes
- Nullness: align Java with JSpecify (@NullMarked/@Nullable) and configure Kotlin compiler with -Xjsr305=strict to enforce contracts.
- Overloads: provide @JvmOverloads selectively for interop ergonomics; annotate @Throws for checked exceptions exposed to Java consumers.
- Collections: prefer Kotlin collections; convert at boundaries to Java types with .toList()/.toMutableList() etc.

Prompt alignment
- When this topic is selected in prompts:
  - Generate suspend-based async APIs with structured concurrency; avoid blocking.
  - Favor immutable data classes, sealed results, extension functions, and DSLs with @DslMarker where helpful.
  - Configure interop: enforce JSpecify on Java modules and -Xjsr305=strict; avoid platform types; add @JvmOverloads/@Throws only where justified.
  - If Vert.x/Reactive stack present, route to backend Vert.x topic and apply non-blocking patterns.

See also
- Topic index — ./README.md
- Kotlin consolidated rules — ./kotlin.rules.md
- Java interop nullness — ../../backend/jspecify/README.md
- Vert.x reactive guidelines — ../../backend/vertx/README.md