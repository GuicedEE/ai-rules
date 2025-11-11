# JSpecify — Topic Glossary (Priority over root glossary)

Scope
- Minimal canonical terms for JSpecify nullness in this topic. These entries take precedence when this topic is referenced. Prefer linking to rules; avoid duplicating definitions.

Canonical terms
- JSpecify — Standard, tool-agnostic nullness annotations for Java; consumed by IDEs/compilers/static analyzers. See: ./README.md, ./jspecify.rules.md
- @NullMarked — Package/class default: all reference types are non-null unless annotated otherwise. See: ./jspecify.rules.md
- @Nullable — Marks values that may be null; applicable to fields, params, returns, and type-use (generics/arrays). See: ./jspecify.rules.md
- Type-use nullness — Annotate inside generic arguments and arrays to distinguish container vs element nullness (e.g., List<@Nullable String>). See: ./examples.md
- Optional vs @Nullable — Prefer Optional<T> for return values encoding absence; prefer @Nullable on DTO fields or interop boundaries. See: ./jspecify.rules.md
- Overriding nullness — Do not widen nullness in overrides; keep non-null contracts intact. See: ./jspecify.rules.md
- API boundary validation — Fail fast on external inputs (HTTP/JSON/DB); keep internal paths non-null under @NullMarked. See: ./jspecify.rules.md
- Analyzer integration — Configure IntelliJ/Error Prone/Checker Framework to interpret JSpecify and fail builds on violations. See: ./jspecify.rules.md
- JPMS usage — Library modules add requires static org.jspecify for compile-time annotations. See: ./jspecify.rules.md
- Package-level default — Use package-info.java with @org.jspecify.annotations.NullMarked. See: ./examples.md

Prompt alignment
- When this topic is selected in prompts, populate the host project glossary from these entries; do not replicate detailed prose. Link to ./jspecify.rules.md and ./examples.md for specifics.

See also
- Topic index — ./README.md
- Rules — ./jspecify.rules.md
- Examples — ./examples.md
- Lombok — ../lombok/README.md
- MapStruct — ../mapstruct/README.md
## LLM interpretation guidance (how to apply these terms)

General resolution
- Topic precedence
  - When this JSpecify topic is in scope, interpret nullness terminology using this glossary first (over root glossary). Avoid legacy nullness systems unless explicitly bridged at boundaries.
- Defaults and assumptions
  - Assume non-null-by-default under @NullMarked; treat unannotated references as non-null.
  - Prefer Optional&lt;T&gt; for return types encoding presence/absence; prefer @Nullable for DTO fields or interop parameters where null is semantically meaningful.
- Routing
  - “Null-marked”, “non-null-by-default”, “package default” → open ./jspecify.rules.md (package/class defaults) and ./examples.md (package-info.java).
  - “Nullable field/param/return”, “type-use nullness”, “List&lt;@Nullable T&gt;” → open ./jspecify.rules.md and ./examples.md (generics).
  - “Override nullness”, “widening” → open ./jspecify.rules.md (overrides).
  - “Analyzer”, “IDE flags”, “Error Prone/Checker” → open ./jspecify.rules.md (tooling).
  - “requires static org.jspecify” → open ./jspecify.rules.md (JPMS).

Term-level directives
- @NullMarked (non-null by default)
  - Meaning: all reference types are non-null unless annotated otherwise within a package/class.
  - How to apply: prefer package-level default via package-info.java; if not feasible, apply at class level.
  - LLM behavior: generate non-null types by default; only allow null after explicit @Nullable.
  - Route: ./jspecify.rules.md, ./examples.md

- @Nullable (opt-in for null)
  - Meaning: this specific value may be null; may be used on fields, params, returns, and as a type-use on generics/arrays.
  - How to apply: annotate precisely; do not use @Nullable Optional&lt;T&gt;; for return values use Optional&lt;T&gt; instead where absence is intended.
  - LLM behavior: where @Nullable appears, ensure callers perform presence checks; where absent under @NullMarked, do not introduce nulls.
  - Route: ./jspecify.rules.md, ./examples.md

- Type-use nullness (generics/arrays)
  - Meaning: distinguishes container vs element nullness (e.g., List&lt;@Nullable String&gt; vs @Nullable List&lt;String&gt;).
  - How to apply: annotate element positions for collections/maps; annotate the container if the entire reference may be null.
  - LLM behavior: maintain positional nullness consistently in signatures and implementations; avoid raw types.
  - Route: ./jspecify.rules.md, ./examples.md

- Optional vs @Nullable
  - Guidance: prefer Optional&lt;T&gt; for return values signaling absence; for DTO fields and interop, @Nullable fields are acceptable (avoid @Nullable Optional).
  - LLM behavior: if returning Optional, avoid returning null; use Optional.empty().
  - Route: ./jspecify.rules.md

- Overriding nullness (no widening)
  - Meaning: overrides must not relax contracts; non-null stays non-null in overrides.
  - LLM behavior: preserve base method nullness contracts exactly when generating overrides/implementations.
  - Route: ./jspecify.rules.md

- API boundary validation (fail fast)
  - Meaning: validate external inputs (HTTP/JSON/DB) before using; keep internal flows non-null under @NullMarked.
  - LLM behavior: generate boundary checks for inputs that may be null; avoid internal propagation of nulls unless explicitly nullable.
  - Route: ./jspecify.rules.md

- Analyzer integration (tooling)
  - Meaning: IDE/compiler/static analyzers enforce or check semantics.
  - LLM behavior: include/assume analyzer configuration (IntelliJ inspections; Error Prone/Checker flags) and fail-on-violation guidance in CI.
  - Route: ./jspecify.rules.md

- JPMS usage
  - Meaning: annotations available at compile time without runtime dependency.
  - LLM behavior: add requires static org.jspecify in module-info for libraries.
  - Route: ./jspecify.rules.md

Terminology hints (routing)
- “non-null by default”, “package default” → @NullMarked
- “maybe null” → @Nullable
- “element nullness”, “List&lt;@Nullable T&gt;”, “Map&lt;K,@Nullable V&gt;” → type-use nullness
- “absence”, “return Optional” → Optional vs @Nullable
- “do not widen nullness” → overriding contracts
- “Error Prone”, “Checker Framework”, “inspection” → analyzer integration
- “requires static org.jspecify” → JPMS integration

Routing table
- Topic index — ./README.md
- Rules — ./jspecify.rules.md
- Examples — ./examples.md
- Lombok — ../lombok/README.md
- MapStruct — ../mapstruct/README.md