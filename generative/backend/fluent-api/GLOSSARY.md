# Fluent API — Topic Glossary (Priority over root glossary)

Scope
- This glossary defines canonical, minimal terms for Fluent API strategies in this topic. It overrides the root glossary for this scope. Avoid duplication; link to rules for details.

Canonical terms
- Fluent API Strategy — Project-wide choice of one fluent approach: CRTP or Builder; never mix both in the same project.
  - Priority: If GuicedEE or JWebMP is present, CRTP is implied and enforced.
  - See: ./README.md
- CRTP (Generic Self-Type) — Fluent chaining via a generic self parameter (e.g., Base<J extends Base<J>>); setters return J with an unchecked cast.
  - Rule: Handwrite setters; do not use Lombok-generated setters to return J.
  - See: ./crtp.rules.md
- Manual CRTP setter — A fluent mutator that returns the CRTP type using a cast.
  - Pattern: return (J) this;
  - Suppression: @SuppressWarnings("unchecked") on the method.
  - See: ./crtp.rules.md
- Builder Pattern — Fluent object construction via a builder with centralized validation; prefer immutable targets.
  - Lombok: @Builder (optionally @Value, toBuilder=true) or manual builders.
  - See: ./builder.rules.md
- Strategy exclusivity — Exactly one: [CRTP] or [Builder] per project. If GuicedEE/JWebMP → CRTP only.
  - See: ./README.md
- Lombok interop
  - CRTP: Do not use @Builder on CRTP types; global chain config does not produce J returns.
  - Builder: Prefer @Builder; avoid CRTP chaining rules.
  - See: ../lombok/lombok.md
- JSpecify interop — Adopt @org.jspecify.annotations.NullMarked; use @org.jspecify.annotations.Nullable precisely on optional fields/params/returns.
  - See: ../jspecify/README.md
- MapStruct interop — Configure NullValueCheckStrategy/NullValueMappingStrategy; add lombok-mapstruct-binding for Lombok builders.
  - See: ../mapstruct/README.md

Prompt alignment (selection priority)
- New/Adopt/Library/Health prompts select one strategy. If GuicedEE/JWebMP is selected, CRTP is enforced.
- When this topic is referenced, these terms take precedence over any root glossary entries.

See also
- Index — ./README.md
- CRTP rules — ./crtp.rules.md
- Builder rules — ./builder.rules.md
- Lombok — ../lombok/README.md
- JSpecify — ../jspecify/README.md
- GuicedEE — ../guicedee/README.md
- JWebMP — ../../frontend/jwebmp/README.md
## LLM interpretation guidance (how to apply these terms)

General
- Strategy resolution
  - If the prompt mentions “fluent”, “chain”, or “fluent API” without a declared strategy, resolve via the project selection in prompts. If GuicedEE or JWebMP is present anywhere, select CRTP automatically (enforced).
  - Do not mix strategies. If both CRTP and Builder cues appear, prefer the declared project selection; otherwise prefer CRTP when GuicedEE/JWebMP are present, else ask for clarification.
- Routing
  - “CRTP”, “generic self type”, “self‑bounded generic”, “fluent setter returning self” → open ./crtp.rules.md
  - “Builder”, “@Builder”, “toBuilder”, “immutable value with builder” → open ./builder.rules.md
  - “Lombok” implications for fluent API selection → open ../lombok/GLOSSARY.md and ../lombok/lombok.md
  - Nullness contracts for APIs → open ../jspecify/GLOSSARY.md

Term-level directives
- CRTP (Generic Self‑Type)
  - Meaning: fluent mutators on a base class parameterized by the concrete subtype; methods return the generic self type.
  - Implementation rule: write setters manually with an unchecked cast: return (J) this; add @SuppressWarnings("unchecked") on the method.
  - Lombok: do not generate setters for CRTP returns (Lombok returns the declaring class, not J). Keep @Getter; disable @Setter per-field if needed.
  - Naming: use setX(…) for mutators. No @Builder on CRTP types.
  - Where to apply: use for in-place configurators and API surfaces that favor chaining over immutable assembly.
  - Route: ./crtp.rules.md

- Builder pattern
  - Meaning: immutable (preferred) or controlled-mutable construction via a builder; validation centralized in build().
  - Implementation rule: use Lombok @Builder or manual builder; prefer @Value for immutability; validate invariants in build().
  - Naming: builder methods typically x(…) or withX(…); ensure consistency and clarity; consider toBuilder=true for controlled cloning.
  - Constraints: when Builder is selected, do not implement CRTP chaining; avoid handwritten setX(…) chaining on the domain model.
  - Where to apply: when immutable construction, validation, and completeness at creation are priorities.
  - Route: ./builder.rules.md

- Strategy exclusivity
  - Exactly one strategy per project. If conflicting cues appear in code (e.g., @Builder on CRTP types), refactor to the declared strategy and flag a violation in health checks.

- GuicedEE / JWebMP implication
  - If either stack is present, select CRTP for fluent APIs without asking. Treat mentions of “builder” in these contexts as non‑authoritative unless explicitly overriding project policy (rare).

- Nullness (JSpecify) in fluent APIs
  - Under @org.jspecify.annotations.NullMarked defaults, treat unannotated references as non‑null.
  - Use @org.jspecify.annotations.Nullable on DTO fields, optional inputs, or explicit opt‑in for nullability in fluent APIs.
  - Prefer Optional&lt;T&gt; for return values that encode presence/absence; avoid @Nullable Optional&lt;T&gt;.

- MapStruct interop
  - CRTP: mappers may call CRTP setters; configure NullValueCheckStrategy/NullValueMappingStrategy explicitly.
  - Builder: ensure Lombok‑mapstruct‑binding is included so mappers detect Lombok @Builder; align null handling consistently.

- Terminology hints
  - “generic self” / “self type” → CRTP
  - “immutable aggregate”, “validate in build”, “toBuilder” → Builder
  - “chain=true” (Lombok accessors) → does not produce CRTP return types; only valid for standard setters returning the declaring type.

Routing table (open these when the terms appear)
- CRTP rules — ./crtp.rules.md
- Builder rules — ./builder.rules.md
- Lombok topic — ../lombok/lombok.md
- Lombok glossary — ../lombok/GLOSSARY.md
- JSpecify glossary — ../jspecify/GLOSSARY.md