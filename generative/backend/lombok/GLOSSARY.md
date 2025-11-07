# Lombok — Topic Glossary (Priority over root glossary)

Scope
- Minimal canonical terms for Lombok in this topic. These entries take precedence when this topic is referenced. Prefer linking to rules; avoid duplicating definitions.

Canonical terms
- Lombok — Annotation-based boilerplate reduction (getters, setters, constructors, equals/hashCode, logging). See: ./lombok.md
- Accessors chaining — Project-level setting enabling chained setters (`lombok.accessors.chain=true`); does not change return types for CRTP generic self. See: ./lombok.config
- @Getter / @Setter — Recommended explicit accessors on entities; avoid `@Data`. See: ./lombok.md
- @EqualsAndHashCode / @ToString — Prefer explicit usage; beware of cycles on entities. See: ./lombok.md
- @NoArgsConstructor / @AllArgsConstructor / @RequiredArgsConstructor — Constructor generation where needed. See: ./lombok.md
- @Log4j2 — Standard logging annotation across modules. See: ./lombok.md
- Avoid @Data — Do not use `@Data` for entities or complex domain types. See: ./lombok.md

CRTP vs Builder alignment (do not mix)
- CRTP (generic self type) — Handwrite fluent setters returning the CRTP type (`return (J) this;`) with `@SuppressWarnings("unchecked")` on the method; do NOT rely on Lombok-generated setters for CRTP return types. See: ../fluent-api/crtp.rules.md
- Builder pattern — For immutable construction/validation; prefer `@Builder` (or manual builders). Do NOT apply CRTP chaining rules if Builder is selected. See: ../fluent-api/builder.rules.md
- Strategy exclusivity — Exactly one strategy per project; if GuicedEE or JWebMP is present, CRTP is enforced. See: ../fluent-api/README.md

Interop and processor ordering
- Annotation processor order — Lombok first; framework processors (e.g., Hibernate) next; MapStruct last. Ensure `lombok-mapstruct-binding` when using Lombok with MapStruct. See: ./lombok.md
- MapStruct interop — Configure `NullValueCheckStrategy` and `NullValueMappingStrategy`; rely on binding jar for Lombok builders. See: ../mapstruct/README.md
- Hibernate/ORM interop — Prefer non-null fields; annotate truly nullable columns and validate at service layer. See: ./lombok.md

Nullness contracts (JSpecify)
- @NullMarked — Adopt package/class default non-null. See: ../jspecify/README.md
- @Nullable — Apply precisely to optional fields/params/returns. See: ../jspecify/jspecify.rules.md

Configuration anchors
- Project config — `lombok.accessors.chain=true` (enables chaining for non-CRTP setters). See: ./lombok.config
- Maven/Gradle processors — Ensure Lombok precedes others; include MapStruct processor and Lombok binding as needed. See: ./lombok.md

Prompt alignment
- When Lombok is selected in prompts, also select a Fluent API Strategy (CRTP vs Builder). If GuicedEE/JWebMP are present, CRTP is enforced. Populate host project glossary from this topic; link back to ../fluent-api/ for strategy details.

See also
- Topic index — ./README.md
- Lombok rules/guide — ./lombok.md
- Config — ./lombok.config
- Fluent API index — ../fluent-api/README.md
- CRTP rules — ../fluent-api/crtp.rules.md
- Builder rules — ../fluent-api/builder.rules.md
- MapStruct — ../mapstruct/README.md
- JSpecify — ../jspecify/README.md
## LLM interpretation guidance (how to apply these terms)

General resolution
- Strategy dependency
  - Resolve fluent API behavior via the project’s Fluent API Strategy selection. If GuicedEE or JWebMP is present anywhere, select CRTP automatically (enforced).
  - Do not mix CRTP with Builder. If both cues appear, follow the declared project strategy; otherwise prefer CRTP when GuicedEE/JWebMP are present.
- Routing
  - “CRTP”, “generic self type”, “self‑bounded generic”, “fluent setter returning self” → see ../fluent-api/crtp.rules.md and ./lombok.md (CRTP setter policy)
  - “Builder”, “@Builder”, “toBuilder”, “immutable value with builder” → see ../fluent-api/builder.rules.md and ./lombok.md (builder usage + processor ordering)
  - Nullness annotations and platform types interop → see ../jspecify/GLOSSARY.md and ../jspecify/jspecify.rules.md

Term-level directives
- CRTP (Generic Self‑Type) with Lombok
  - Meaning: fluent mutators return the generic self type (J). Lombok-generated setters do not return J; do not use @Setter for CRTP returns.
  - Implementation rule: handwrite setters on CRTP classes; mark with @SuppressWarnings("unchecked") and return (J) this; consider @Setter(AccessLevel.NONE) per field to avoid Lombok generation; keep @Getter.
  - Naming: use setX(…) for mutators on CRTP types; avoid @Builder on these types.
  - Where to apply: in-place configurators, GuicedEE/JWebMP integrations, type-safe chains across inheritance.
  - Route: ../fluent-api/crtp.rules.md, ./lombok.md

- Builder pattern with Lombok
  - Meaning: immutable or controlled-mutable construction via a builder with validation in build().
  - Implementation rule: use @Builder (optionally @Value and toBuilder = true) or a manual builder; validate invariants in build()/constructor; do not apply CRTP chaining on these types.
  - Naming: builder methods typically x(…) or withX(…); ensure consistency; expose canonical constructor or factory method if builder is manual.
  - MapStruct: include lombok-mapstruct-binding; configure NullValueCheckStrategy/NullValueMappingStrategy.
  - Route: ../fluent-api/builder.rules.md, ./lombok.md

- Strategy exclusivity (project level)
  - Exactly one strategy per project. If conflicting patterns exist (e.g., @Builder on CRTP types), refactor to the declared strategy and flag a violation.

Annotation processors and interop
- Processor order: Lombok first; framework processors (e.g., Hibernate) next; MapStruct last; include lombok-mapstruct-binding when using Lombok builders.
- Hibernate/ORM: prefer non-null fields; annotate truly nullable ones and validate at service layer.
- MapStruct:
  - CRTP: mappers may call CRTP setters; set null strategies explicitly.
  - Builder: ensure builder discovery; align null handling with JSpecify.

Nullness (JSpecify) with Lombok
- Adopt @org.jspecify.annotations.NullMarked at package/class level; use @org.jspecify.annotations.Nullable precisely on optional fields/params/returns.
- Avoid @Nullable Optional&lt;T&gt;; prefer Optional.empty(); avoid returning null collections/optionals—prefer empty instances.

Terminology hints (routing)
- “generic self”, “self type”, “return (J) this” → CRTP
- “immutable aggregate”, “validate in build”, “@Builder”, “toBuilder” → Builder
- “chain=true” (Lombok accessors) → does not implement CRTP return types; valid only for standard setters returning the declaring type.

Routing table
- Fluent API index — ../fluent-api/README.md
- CRTP rules — ../fluent-api/crtp.rules.md
- Builder rules — ../fluent-api/builder.rules.md
- Lombok rules/guide — ./lombok.md
- JSpecify glossary/rules — ../jspecify/GLOSSARY.md, ../jspecify/jspecify.rules.md