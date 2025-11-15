# Fluent API Strategies — CRTP vs Builder

Use this topic to standardize how your project exposes fluent APIs. Choose exactly one strategy for a project: CRTP (generic self type) or the Builder pattern. Do not mix. If GuicedEE or JWebMP is selected anywhere in the stack, CRTP is implied and enforced.

## How to use this index
- Start here to decide your fluent API strategy.
- Open the rule file for your chosen approach:
  - CRTP (generic self type) — ./crtp.rules.md
  - Builder pattern — ./builder.rules.md
- Update host project RULES and GLOSSARY to declare the chosen strategy (see prompts).
- Ensure code, Lombok usage, and generators align with the chosen strategy.

## Strategy selection rules
- Mutual exclusivity: exactly one strategy per project (module families may align to a single choice).
- GuicedEE and JWebMP imply CRTP. If either is selected, CRTP is enforced for fluent APIs.
- Do not mix CRTP with Builder for the same API surface. Choose one and refactor accordingly.
- Align Lombok usage:
  - CRTP: do not use @Builder for these fluent types. Handwrite CRTP setters returning the generic self type with a cast (return (J) this;) and suppress the unchecked warning at method-level.
  - Builder: prefer Lombok @Builder or manual builders; avoid CRTP chaining rules.

## Prompt linkage (selection and enforcement)
- New Project / Adopt Existing / Library Update prompts include:
  - “Fluent API Strategy (choose exactly one): [ ] CRTP … [ ] Builder … Only one may be selected; if GuicedEE or JWebMP is selected, CRTP is enforced.”
- Health Check prompt:
  - Detects presence of GuicedEE/JWebMP and flags conflicts if Builder is selected or both strategies are mixed.
- After selecting, ensure:
  - Project RULES.md declares the chosen strategy and links back to this topic.
  - GLOSSARY.md contains the core terms (CRTP fluent setters vs Builder constructs).
  - Implementation matches (no mixed usage).

## Index
- CRTP — ./crtp.rules.md
- Builder — ./builder.rules.md

## See also
- Lombok topic — ../lombok/README.md
- Lombok guide — ../lombok/lombok.md
- MapStruct — ../mapstruct/README.md
- JSpecify — ../jspecify/README.md
- GuicedEE — ../guicedee/README.md
- JWebMP — ../../frontend/jwebmp/README.md

## Rationale
- CRTP offers type-safe chaining without runtime cost and is the default for GuicedEE and JWebMP ecosystems.
- Builder offers immutable aggregate creation, validation, and object construction ergonomics where chaining setters is undesirable or where object validity requires staged construction.

## Migration guidance (summary)
- Moving to CRTP:
  - Remove @Builder on fluent entities.
  - Implement manual CRTP setters returning the generic self type via cast; add @SuppressWarnings("unchecked") on the method.
  - Keep @Getter; disable Lombok @Setter per-field if needed (use @Setter(AccessLevel.NONE)).
  - Adopt @org.jspecify.annotations.NullMarked and apply @Nullable only where necessary.
- Moving to Builder:
  - Replace chainable setters with a builder API.
  - For Lombok, annotate a canonical constructor or class with @Builder.
  - Maintain nullness via JSpecify on constructor parameters and builder fields; validate in build().

## Anti-patterns (both strategies)
- Mixing CRTP and Builder on the same type surface.
- Returning null collections/optionals (prefer empty instances).
- Using @Nullable Optional<T> (prefer Optional.empty()).
- Omitting nullness contracts (JSpecify) when interoperating with Kotlin or across module boundaries.
