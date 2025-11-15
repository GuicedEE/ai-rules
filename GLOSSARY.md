# Enterprise Glossary — Rules Repository Canonical Terms

Purpose
- Canonical, human-readable definitions for terms, components, acronyms, product names, and prompt-aligned labels used across this repository and host projects.
- Ensures consistent Prompt Language Alignment across Pact, Rules, Guides, Implementation, and code.

Population model
- Populate from the topics actually in use for your project based on prompts and selected stacks in [PROMPT_NEW_PROJECT.md](./PROMPT_NEW_PROJECT.md) and [PROMPT_ADOPT_EXISTING_PROJECT.md](./PROMPT_ADOPT_EXISTING_PROJECT.md).
- For UI/component topics that enforce Prompt Language Alignment, copy the aligned names and mappings here. See [generative/frontend/webawesome/README.md](./generative/frontend/webawesome/README.md).
- For backend/framework topics, define agreed terminology (e.g., DDD vs. CRUD nouns, OAuth2/OIDC identities, JPMS/SPI module terms), and record domain-specific acronyms.

How to use (prompts, templates, and code)
- Prompt templates MUST align language to these entries and keep names consistent when generating files.
- When a prompt mentions a variant without a dedicated file, use the glossary-aligned base term and link to the rule’s subsection anchor (e.g., [input.rules.md#number-input](./generative/frontend/webawesome/input.rules.md#number-input)).
- Use these names consistently in RULES, GUIDES, and IMPLEMENTATION artifacts. Cross-link back to entries when terms are introduced.

Maintenance rules
- Forward-only: update terms when rules or libraries change; do not maintain legacy aliases unless explicitly required by a host project. See [RULES.md](./RULES.md).
- Keep entries concise; prefer one-line definitions, with “See also” links to rules or component files.
- Close loops:
  - Pact references these canonical terms.
  - Rules point back to glossary entries where naming is enforced.
  - Guides use glossary names consistently and link back on first use.
  - Implementation avoids inventing new terminology; reference glossary names in comments/docs.

Anchor and linking conventions
- File links use relative paths to this repository. Example: [RULES.md](./RULES.md), [generative/README.md](./generative/README.md).
- Subsection anchors follow Markdown IDs in rule files. Example: [input.rules.md#number-input](./generative/frontend/webawesome/input.rules.md#number-input).
- When a term maps to a component variant, include the base component and the anchor (e.g., “Number Input (WaInput → #number-input)”).

See also (repository navigation)
- Structure of Work — [README.md](./README.md) (Pact, Glossary, Rules, Guides, Implementation)
- Rules reference — [RULES.md](./RULES.md)
- Generative master index — [generative/README.md](./generative/README.md)
- Frontend category — [generative/frontend/README.md](./generative/frontend/README.md)
- Language category — [generative/language/README.md](./generative/language/README.md)
- Backend category — [generative/backend/README.md](./generative/backend/README.md)
- Platform category — [generative/platform/README.md](./generative/platform/README.md)

---

Core repository constructs
- Pact — The project agreement that defines language, ethos, and continuity; the source for Ubiquitous Language in a host project. See [README.md](./README.md).
- Glossary (this file) — Canonical terms and prompt-aligned labels; the single source of truth for names used across Rules, Guides, and Implementation.
- Rules — Technical and stylistic standards per domain; authoritative reference. See [RULES.md](./RULES.md).
- Guides — How-to execution: scaffolding, step-by-step, and process that apply the Rules.
- Implementation — Tangible code/structure/design output that references the Guide and Rule it implements.
- Owner mode — Operating in this repository as the active workspace (not as a submodule). Do not refer to it as a submodule; apply forward-only edits; use project-scoped Skills where applicable. See [README.md](./README.md).
- Host project mode — Downstream project consuming this repository as a Git submodule. Host artifacts (PACT, RULES, GUIDES, IMPLEMENTATION) live outside the submodule. See [README.md](./README.md).
- Forward-Only Change Policy — Default stance: no backwards compatibility for docs/anchors/APIs unless a host project explicitly requests it. Update all references in the same change. See [RULES.md](./RULES.md).
- Document Modularity Policy — Split large docs into modular, AI-friendly files; remove monoliths; update indexes and links accordingly. See [RULES.md](./RULES.md).
- Component Topic Indexing Policy — Each component-topic directory provides an index README linking to component .rules.md files and variant anchors. See [RULES.md](./RULES.md).
- Generative Topic Taxonomy — Canonical category layout for generative/ content. See [RULES.md](./RULES.md).

Prompt Language Alignment (enforced)
- Use aligned component names to route to correct rules. Copy these into project glossaries when WebAwesome is selected:
  - “button” → WaButton — See [webawesome/button.rules.md](./generative/frontend/webawesome/button.rules.md)
  - “icon button” → WaIconButton — See [webawesome/icon-button.rules.md](./generative/frontend/webawesome/icon-button.rules.md)
  - “input” → WaInput — See [webawesome/input.rules.md](./generative/frontend/webawesome/input.rules.md)
  - “row (layout)” → WaCluster — See [webawesome/README.md](./generative/frontend/webawesome/README.md)
  - “column/stack (layout)” → WaStack — See [webawesome/README.md](./generative/frontend/webawesome/README.md)
- If a variant lacks a dedicated file, use the base component + subsection anchor (e.g., “Number Input (WaInput)” → [input.rules.md#number-input](./generative/frontend/webawesome/input.rules.md#number-input)).

---

Frontend — Web Components and frameworks
- Custom Element — A W3C-standard element registered via Custom Elements API; framework-agnostic UI primitive. See [webcomponents/custom-elements.md](./generative/frontend/webcomponents/custom-elements.md).
- Shadow DOM — Scoped DOM and styles for component encapsulation. See [webcomponents/shadow-dom.md](./generative/frontend/webcomponents/shadow-dom.md).
- HTML Template — Declarative inert markup with slots for stamping content. See [webcomponents/html-templates.md](./generative/frontend/webcomponents/html-templates.md).
- ES Module — Standards-based module format for JavaScript delivery/import. See [webcomponents/es-modules.md](./generative/frontend/webcomponents/es-modules.md).
- Angular 20 Elements — Angular components packaged as Custom Elements for cross-framework consumption. See [webcomponents/angular20-producing-web-components.md](./generative/frontend/webcomponents/angular20-producing-web-components.md) and [webcomponents/angular20-consuming-web-components.md](./generative/frontend/webcomponents/angular20-consuming-web-components.md).
- Micro Frontends (MFE) — Domain-aligned, independently deployable UI slices integrated via Web Components or federation. See [webcomponents/microfronts-overview.md](./generative/frontend/webcomponents/microfronts-overview.md).
- WebAwesome — A component set consumed directly (as web components) or via wrappers; rules live under [webawesome/](./generative/frontend/webawesome/README.md).
- Angular Awesome — Aligned Angular wrappers for WebAwesome; follow WebAwesome names for Prompt Language Alignment. See [angular-awesome/README.md](./generative/frontend/angular-awesome/README.md).
- JWebMP — Java-first UI composition compiled to HTML/JS; integrates with WebAwesome and Angular generation. See [jwebmp/jwebmp_ai_guide.md](./generative/frontend/jwebmp/jwebmp_ai_guide.md).

Backend — Reactive, modules, and integration
- Vert.x 5 — Event-driven toolkit with event loop, verticles, event bus, and non-blocking primitives. See [backend/vertx/README.md](./generative/backend/vertx/README.md).
- Event Loop — Single-threaded reactor per context; never block it; run blocking work in executeBlocking.
- Verticle — Deployable processing unit in Vert.x; encapsulates behavior and lifecycle.
- Event Bus — Lightweight pub/sub RPC fabric across verticles and processes.
- executeBlocking(...) — Offloads blocking code from the event loop; returns Future<T>. See [vertx-5-transaction-handling.md](./generative/backend/vertx/vertx-5-transaction-handling.md).
- Hibernate Reactive 7 — Non-blocking ORM using Mutiny; operations return Uni<T>/Multi<T>; explicit transactions via withTransaction. See [backend/hibernate/README.md](./generative/backend/hibernate/README.md).
- Mutiny Uni<T>/Multi<T> — Asynchronous single/stream primitives used across Hibernate Reactive and Vert.x integrations.
- SessionFactory (Reactive) — Singleton factory for sessions; initialize once; manage lifecycle.
- withTransaction(...) — Pattern to ensure commit/rollback semantics around units of work.
- JPMS (Java Platform Module System) — Module boundaries (module-info.java) with requires/exports; enforced in GuicedEE modules and libraries.
- SPI (Service Provider Interface) — Pluggable contract discovered at runtime; used heavily in GuicedEE.
- GuicedEE Services — Shaded, JPMS-aligned artifacts replacing originals with consistent coordinates and module names. See [backend/guicedee/services/services.md](./generative/backend/guicedee/services/services.md).
- PostgreSQL JPMS Policy — Use GuicedEE Services driver artifact; do not shade in host projects; module requires org.postgresql. See [RULES.md](./RULES.md) and [data/database/postgres-database.md](./generative/data/database/postgres-database.md) if present.
- MapStruct — Compile-time bean mapping generator; favors type-safe mappings and update methods. See [backend/mapstruct/README.md](./generative/backend/mapstruct/README.md).
- Lombok — Annotation-driven boilerplate reduction; compatible with other processors (MapStruct, Hibernate). See [backend/lombok/README.md](./generative/backend/lombok/README.md).

Security and platform
- OAuth 2.0 — Authorization framework enabling delegated access via tokens (client credentials, auth code, etc.).
- OpenID Connect (OIDC) — Identity layer on top of OAuth2 providing user authentication and ID tokens.
- Issuer — Token authority identifier (iss).
- Audience — Intended token consumer (aud).
- Realm/Tenant — Identity or resource segmentation boundary; choose one term and use consistently in a project.
- Health Endpoint — Liveness/readiness standardization for ops. See [platform/observability/health.md](./generative/platform/observability/health.md).
- Tracing — Distributed tracing conventions/instrumentation. See [platform/observability/tracing.md](./generative/platform/observability/tracing.md).
- OpenAPI — API contract and documentation source of truth. See [platform/observability/openapi-map.md](./generative/platform/observability/openapi-map.md).
- Secrets and Config — Environment variable and secret handling conventions. See [platform/secrets-config/README.md](./generative/platform/secrets-config/README.md).

Architecture and data
- DDD — Strategic and tactical patterns connecting code to an evolving domain model. See [architecture/ddd/domaindrivendesign.md](./generative/architecture/ddd/domaindrivendesign.md).
- Bounded Context — Explicit boundary within which a domain model applies uniformly.
- Aggregate — Consistency boundary with a root entity controlling invariants.
- Entity — Identity-carrying domain object subject to lifecycle.
- Value Object — Identity-less, immutable concept with value equality.
- Domain Event — Captures something that happened in the domain; used for integration and consistency.
- Repository — Collection-like interface to aggregates; mediates persistence.
- Ubiquitous Language — Shared vocabulary used in code and conversation; captured in Pact and mirrored here.
- Micro Frontends — Domain-aligned frontend decomposition across teams/stacks. See [architecture/ddd/microfronts.md](./generative/architecture/ddd/microfronts.md).
- Testcontainers — On-demand containerized infra for integration tests; recommended for DB and broker testing.

UI component anchor patterns (WebAwesome examples)
- Base component — WaInput; Variants via anchors:
  - Number Input — [input.rules.md#number-input](./generative/frontend/webawesome/input.rules.md#number-input)
- Navigation via topic index — Start at [webawesome/README.md](./generative/frontend/webawesome/README.md) and follow component links.

Glossary usage conventions
- Use the canonical name as the term heading and keep the definition to a single sentence when possible.
- Include “See also” links to the governing rule file(s) or topic index.
- Avoid synonyms; when migration occurs, replace the old term rather than keeping aliases (forward-only).
- For project-specific choices (e.g., “realm” vs. “tenant”), record the chosen term and remove the other from the local project glossary.

Acronyms (canonical)
- DDD — Domain-Driven Design
- MFE — Micro Frontends
- JPMS — Java Platform Module System
- SPI — Service Provider Interface
- DI — Dependency Injection
- DTO — Data Transfer Object
- ORM — Object-Relational Mapping
- OIDC — OpenID Connect
- OAuth2 — OAuth 2.0
- FSDM — Financial Services Data Model

See also (quick links)
- Repository rules and policies — [RULES.md](./RULES.md)
- Workspace policy (Roo) — [ROO_WORKSPACE_POLICY.md](./ROO_WORKSPACE_POLICY.md)
- Frontend topic indexes — [generative/frontend/README.md](./generative/frontend/README.md)
- Web Components — [generative/frontend/webcomponents/README.md](./generative/frontend/webcomponents/README.md)
- WebAwesome — [generative/frontend/webawesome/README.md](./generative/frontend/webawesome/README.md)
- Backend topic indexes — [generative/backend/README.md](./generative/backend/README.md)
- Platform topic indexes — [generative/platform/README.md](./generative/platform/README.md)

## JSpecify — Glossary (Nullness Contracts for Java)

Overview
- JSpecify provides standard, tool-agnostic annotations to express nullness in Java source code. It documents intent and enables static analysis without runtime overhead.
- See topic index and rules: [rules/generative/backend/jspecify/README.md](rules/generative/backend/jspecify/README.md), [rules/generative/backend/jspecify/jspecify.rules.md](rules/generative/backend/jspecify/jspecify.rules.md), [rules/generative/backend/jspecify/examples.md](rules/generative/backend/jspecify/examples.md)

Canonical terms and definitions
- JSpecify — A set of annotations that define nullness semantics for Java code; consumed by IDEs/compilers/analyzers for static checks. See [rules/generative/backend/jspecify/README.md](rules/generative/backend/jspecify/README.md)
- Nullness default (@NullMarked) — Package- or class-level annotation that makes all reference types non-null by default unless marked otherwise; establish this at boundaries to prevent accidental nulls. See [rules/generative/backend/jspecify/jspecify.rules.md](rules/generative/backend/jspecify/jspecify.rules.md)
- Nullable (@Nullable) — Type-use or declaration annotation indicating a value may be null; apply precisely to fields, parameters, return types, and generic type arguments. See [rules/generative/backend/jspecify/jspecify.rules.md](rules/generative/backend/jspecify/jspecify.rules.md)
- Type-use annotations — Annotations placed directly on types (including generic type arguments, arrays, wildcards), e.g., List&lt;@Nullable String&gt; or Map&lt;String, @Nullable Integer&gt;; distinguishes container vs. element nullness. See [rules/generative/backend/jspecify/examples.md](rules/generative/backend/jspecify/examples.md)
- Non‑null by default — A project policy enabled via @NullMarked that treats all unannotated references as non-null; @Nullable becomes the explicit exception.
- Optional vs @Nullable — Prefer Optional&lt;T&gt; for return values that encode presence/absence; prefer @Nullable on DTO fields and interop boundaries where Optional is undesirable. See [rules/generative/backend/jspecify/jspecify.rules.md](rules/generative/backend/jspecify/jspecify.rules.md)
- Generics nullness (container vs element) — Express element nullness using type-use (List&lt;@Nullable Foo&gt;); container itself may also be nullable via @Nullable List&lt;Foo&gt;; avoid ambiguous raw types.
- Overriding nullness (LSP) — Do not widen nullness in overrides: non-null in base remains non-null in overrides; parameter nullness cannot be narrowed contrary to base contracts. See patterns in [rules/generative/backend/jspecify/examples.md](rules/generative/backend/jspecify/examples.md)
- API boundary validation — Fail fast at boundaries: validate external inputs (HTTP/JSON/DB) for nulls/empties; keep internal @NullMarked code paths non-null.
- Analyzer integration — Configure your static analyzer (IntelliJ inspections, Error Prone, Checker Framework) to interpret JSpecify annotations and fail builds on violations. See Tooling in [rules/generative/backend/jspecify/jspecify.rules.md](rules/generative/backend/jspecify/jspecify.rules.md)
- JPMS usage (module-info) — Library modules should add requires static org.jspecify; this exposes annotations at compile time without runtime dependency.
- Package-level default (package-info.java) — Place @NullMarked in package-info.java to set a consistent nullness default across all sources in that package. See examples in [rules/generative/backend/jspecify/examples.md](rules/generative/backend/jspecify/examples.md)
- Lombok interop — Ensure Lombok preserves type-use annotations; use onX or annotate fields/getters explicitly; avoid generated APIs that mask nullness semantics.
- MapStruct interop — Align null handling using NullValueCheckStrategy and NullValueMappingStrategy; map @Nullable sources/targets explicitly. See [rules/generative/backend/jspecify/examples.md](rules/generative/backend/jspecify/examples.md)
- Hibernate/ORM interop — Prefer non-null entity fields; annotate truly nullable columns with @Nullable and validate at service layer; avoid returning null collections.
- Kotlin interop — Kotlin respects annotated Java types; adopt @NullMarked to avoid platform types and ensure null-safety across languages (pair with Kotlin’s -Xjsr305=strict where applicable).
- Anti‑patterns (disallowed) — @Nullable Optional&lt;T&gt; (prefer Optional.empty()); returning null for collections/optionals (prefer empty instances); mixing multiple nullness systems without a plan (standardize on JSpecify; add adapters only at boundaries).

Quick recipes (inline)
- Package default (non-null by default)
  - Add package-info.java:
    ```java
    @org.jspecify.annotations.NullMarked
    package com.example.users;
    ```
  - All references in this package are non-null unless annotated with @org.jspecify.annotations.Nullable.
- Selectively nullable DTO fields
  ```java
  import org.jspecify.annotations.Nullable;
  public record User(String id, String email, @Nullable String middleName) {}
  ```
- Collections and generics element nullness
  ```java
  import org.jspecify.annotations.Nullable;
  java.util.List<@Nullable String> names = new java.util.ArrayList<>();
  ```

Project integration anchors
- Topic index — [rules/generative/backend/jspecify/README.md](rules/generative/backend/jspecify/README.md)
- Rules — [rules/generative/backend/jspecify/jspecify.rules.md](rules/generative/backend/jspecify/jspecify.rules.md)
- Examples — [rules/generative/backend/jspecify/examples.md](rules/generative/backend/jspecify/examples.md)
- Java language rules cross-links — [rules/generative/language/java/java-17.rules.md](rules/generative/language/java/java-17.rules.md), [rules/generative/language/java/java-21.rules.md](rules/generative/language/java/java-21.rules.md), [rules/generative/language/java/java-25.rules.md](rules/generative/language/java/java-25.rules.md)

Prompt usage guidance
- When a Structural: JSpecify topic is selected in prompts, enforce a non-null-by-default policy using @NullMarked, annotate variability with @Nullable, and configure analyzers to fail on nullness violations.
- From prompts like “JSpecify package defaults” or “nullable generics,” navigate to the topic Rules and Examples above for precise application and code snippets.

See also
- Backend category index — [rules/generative/backend/README.md](rules/generative/backend/README.md)
- Repository rules and policies — [rules/RULES.md](rules/RULES.md)

## Lombok — Glossary (Boilerplate Reduction & Patterns)

Overview
- Project Lombok reduces Java boilerplate via annotations while integrating with other processors. Use explicit patterns for Entities, mapping, logging, and CRTP fluent APIs.
- Topic and rules: [rules/generative/backend/lombok/README.md](rules/generative/backend/lombok/README.md), [rules/generative/backend/lombok/lombok.md](rules/generative/backend/lombok/lombok.md), sample config [rules/generative/backend/lombok/lombok.config](rules/generative/backend/lombok/lombok.config)

Canonical terms and definitions
- Lombok — Annotation-based code generation for getters, setters, equals/hashCode, constructors, logging. See [rules/generative/backend/lombok/lombok.md](rules/generative/backend/lombok/lombok.md)
- Accessors chaining — Global/project config enabling chained setters; configure `lombok.accessors.chain=true` in [rules/generative/backend/lombok/lombok.config](rules/generative/backend/lombok/lombok.config). Note: this does not change return types to the CRTP type.
- @Getter / @Setter — Generate accessor methods; prefer explicit usage on entities instead of `@Data`.
- @EqualsAndHashCode / @ToString — Generate equality and string methods; be careful on entities with bidirectional relations.
- @NoArgsConstructor / @AllArgsConstructor / @RequiredArgsConstructor — Generate constructors where needed.
- @Log4j2 — Standard logging annotation for this repository’s patterns; prefer over alternatives.
- Avoid @Data — Do not use `@Data` for entities; use `@Getter`, `@Setter`, and `@EqualsAndHashCode` explicitly. See guidance in [rules/generative/backend/lombok/lombok.md](rules/generative/backend/lombok/lombok.md)
- Avoid @Builder — Prefer CRTP for fluent APIs instead of Lombok builders in this repo’s conventions.

CRTP fluent setters (generic self type)
- Problem — Lombok-generated setters (even with chain=true) return the declaring class, not the CRTP type parameter.
- Rule — For CRTP bases like `abstract class Base&lt;J extends Base&lt;J&gt;&gt;`, write setters manually to return `J` via an unchecked cast, and suppress the warning on the method.
- Pattern (base, non-null-by-default):
  ```java
  @org.jspecify.annotations.NullMarked
  public abstract class Base<J extends Base<J>> {
    private String name;
    @SuppressWarnings("unchecked")
    public J setName(String name) {
      this.name = name;
      return (J) this;
    }
  }
  ```
- Subclass (JWebMP/GuicedEE - extensible):
  ```java
  public class User<J extends User<J>> extends Base<J> { 
    @SuppressWarnings("unchecked")
    public J setAge(int age) { return (J) this; }
  }
  ```
- Notes:
  - Do not put Lombok `@Setter` on these fields; if present globally, disable per-field (`@Setter(AccessLevel.NONE)`) and keep `@Getter` if desired.
  - Global chain config is insufficient; manual override is required for CRTP.
  - Use JSpecify: `@NullMarked` at package/class level and `@Nullable` only where null is part of the contract.

Annotation processor ordering and interop
- Ordering — Lombok first; then framework processors (e.g., Hibernate); MapStruct last so it sees the final model. See examples in [rules/generative/backend/lombok/lombok.md](rules/generative/backend/lombok/lombok.md)
- MapStruct interop — Use `lombok-mapstruct-binding` and configure `NullValueCheckStrategy`/`NullValueMappingStrategy`. Prefer explicit null handling aligned with JSpecify.
- Hibernate interop — Ensure Lombok runs before Hibernate’s processor; annotate truly nullable columns and validate at service layer.
- JSpecify interop — Adopt `@NullMarked` defaults, annotate `@Nullable` precisely, and ensure IDE/analyzers enforce nullness semantics.

Configuration anchors
- Lombok config (project root):
  ```
  lombok.accessors.chain=true
  ```
  File: [rules/generative/backend/lombok/lombok.config](rules/generative/backend/lombok/lombok.config)
- Maven (processors order sketch):
  ```xml
  <annotationProcessorPaths>
    <path>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <version>${lombok.version}</version>
    </path>
    <!-- Framework processors (e.g., Hibernate) -->
    <path>
      <groupId>org.hibernate.orm</groupId>
      <artifactId>hibernate-processor</artifactId>
      <version>${hibernate.version}</version>
    </path>
    <!-- MapStruct last -->
    <path>
      <groupId>org.mapstruct</groupId>
      <artifactId>mapstruct-processor</artifactId>
      <version>${mapstruct.version}</version>
    </path>
    <path>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok-mapstruct-binding</artifactId>
      <version>0.2.0</version>
    </path>
  </annotationProcessorPaths>
  ```

Quick recipes
- Enable chaining globally — add `lombok.accessors.chain=true` in [rules/generative/backend/lombok/lombok.config](rules/generative/backend/lombok/lombok.config); use for simple setters returning the declaring type.
- CRTP fluent API — write manual setters returning `J` with `return (J) this;` and `@SuppressWarnings("unchecked")` on each method.
- Entities — annotate with `@Getter`, `@Setter`, `@EqualsAndHashCode`, avoid `@Data`; be explicit with relationships; avoid `@Builder` in favor of CRTP.
- Logging standard — prefer `@Log4j2` for consistent logging across modules.

See also
- Topic index — [rules/generative/backend/lombok/README.md](rules/generative/backend/lombok/README.md)
- Full guide — [rules/generative/backend/lombok/lombok.md](rules/generative/backend/lombok/lombok.md)
- MapStruct — [rules/generative/backend/mapstruct/README.md](rules/generative/backend/mapstruct/README.md)
- JSpecify — [rules/generative/backend/jspecify/README.md](rules/generative/backend/jspecify/README.md), [rules/generative/backend/jspecify/jspecify.rules.md](rules/generative/backend/jspecify/jspecify.rules.md)

## Glossary Precedence Policy (Topic‑First)

- Definition — Host projects compose their root glossary from topic-scoped glossaries. When a topic glossary and the root define the same term, the topic version wins for its scope.
- Policy anchors — See RULES: Document Modularity and Generative Topic Taxonomy for structure and precedence.
- Host usage — The host GLOSSARY.md acts as an index/aggregator with minimal duplication; copy only enforced Prompt Language Alignment mappings and otherwise link to topic files/anchors.

See also
- RULES — ./RULES.md
- Structure of Work (Glossary role) — ./README.md

## Stage‑Gated Workflow — Canonical Terms

- Stage 1: Architecture & Foundations — Produce Pact, architecture overview, C4 L1/L2/L3 (initial), key sequence diagrams, ERDs, dependency map, glossary composition plan. No code. STOP gate required.
- Stage 2: Guides & Design Validation — RULES mapping, GUIDES (“how to apply”), API surface sketches/contracts, UI flows/components, test strategy, acceptance criteria. STOP gate required.
- Stage 3: Implementation Plan — Scaffolding plan, module/file tree, build/processor wiring, CI and env plan, rollout and risks. STOP gate required.
- Stage 4: Implementation & Scaffolding — Code allowed only after explicit approval; iterate in small reviewable steps; present diffs and validation after each step.
- STOP gate (approval phrase) — Required approval phrasing: “APPROVED Stage N → Stage N+1”.
- Universal STOP rule — If approval is not granted, revise docs; do not produce code.

See also
- Repository policy (stage‑gated) — ./README.md
- Prompt templates (gated flow) — ./PROMPT_NEW_PROJECT.md, ./PROMPT_ADOPT_EXISTING_PROJECT.md, ./PROMPT_CODEBASE_HEALTH_CHECK.md, ./PROMPT_LIBRARY_RULES_UPDATE.md

## Docs‑as‑Code Diagrams — Canonical Terms

- C4 Level 1 (Context) — System and external dependencies.
- C4 Level 2 (Container) — Major services/containers and responsibilities.
- C4 Level 3 (Component) — Key components per bounded context.
- C4 Level 4 (Code, optional) — Deep drill‑down for select components.
- Sequence Diagram — Critical flow of interactions, including async boundaries (bus/schedulers).
- ERD — Entity‑relationship diagram showing core domain, ownership, and lifecycles.
- Mermaid — Preferred text diagram syntax in fenced markdown blocks.
- PlantUML — Alternative text diagram syntax (fenced or .puml).
- Docs placement — Host repository under docs/architecture/*; images optional and must not replace sources.

See also
- Docs‑as‑Code policy — ./README.md#docs-as-code-diagrams-policy

## Fluent API Strategy — CRTP vs Builder (Canonical)

- CRTP (Curiously Recurring Template Pattern) — Generic self‑type pattern enabling fluent APIs that return the most specific subclass type. Manual setters return J via unchecked cast; do not use Lombok @Builder under CRTP. Enforced when GuicedEE or JWebMP is selected.
- Builder Pattern — Object construction via builders (Lombok @Builder or manual). If Builder is selected, do not apply CRTP chaining rules.
- Enforcement — Exactly one strategy must be chosen. If GuicedEE/JWebMP is present, CRTP is implied and Builder is disallowed for those fluent APIs.
- Lombok interop — With CRTP, prefer explicit setters and @Getter; avoid @Data and @Builder. With Builder, ensure processor ordering (Lombok before framework processors; MapStruct last).

See also
- Lombok topic — ./generative/backend/lombok/README.md
- MapStruct topic — ./generative/backend/mapstruct/README.md

## Testing Architectures — TDD and BDD

- TDD (Test‑Driven Development) — Red → Green → Refactor loop. Write a failing test (red), implement minimal code to pass (green), then refactor to improve design. Emphasizes unit tests, fast feedback, and incremental design.
  - Topic index — ./generative/architecture/tdd/README.md
- BDD (Behavior‑Driven Development) — Discovery → Formulation → Automation. Specify behaviors in ubiquitous language (Given/When/Then), then automate with executable specs (e.g., Cucumber) and end‑to‑end tools (e.g., Playwright).
  - Topic index — ./generative/architecture/bdd/README.md

## Frontend Policies — Angular Versioning (Single Selection)

- Single‑version rule — Select exactly one Angular version (17/19/20) per repository.
- Base + overrides — Use base Angular rules plus exactly one version override; do not mix APIs across versions in a single project.
- Links — Base: ./generative/language/angular/README.md; Overrides: ./generative/language/angular/angular-17.rules.md | ./generative/language/angular/angular-19.rules.md | ./generative/language/angular/angular-20.rules.md
- Plugins — Angular Awesome is additive to the selected version; follow plugin topic index and glossary.

## Frontend — Next.js Execution Model (Canonical)

- SSR (Server‑Side Rendering) — Render at request time on the server.
- SSG (Static‑Site Generation) — Pre‑render at build time.
- ISR (Incremental Static Regeneration) — Rebuild static pages incrementally in production.
- RSC (React Server Components) — Server‑executed components for data fetching and streaming UX.
- Streaming — Progressive rendering of server responses for improved TTFB and interactivity.
- App Router — Modern routing/data‑fetching model recommended by this repository.

See also
- Next.js overview — ./generative/frontend/nextjs/nextjs-overview.md
- SSR/SSG/ISR — ./generative/frontend/nextjs/nextjs-ssr-ssg.md
- Security — ./generative/frontend/nextjs/nextjs-security.md
- Web Components interop — ./generative/frontend/nextjs/nextjs-web-components.md

## Frontend — Vue 3 Composition Model (Canonical)

- Composition API — Prefer `<script setup>` with `ref`, `reactive`, `computed`, and composables; Options API reserved for legacy interop.
- Single File Components — Keep logic slim; move business logic into composables or Pinia stores.
- Pinia Stores — Define via `defineStore` returning typed refs/computed values; avoid mutating shared reactive objects without actions.
- Web Components interop — Wrap custom elements inside Vue components to normalize props/events; guard registration when SSR is involved.

See also
- Vue overview — ./generative/language/vue/vue-overview.md
- Composition API guide — ./generative/language/vue/vue-composition-api.md
- Web Components in Vue — ./generative/language/vue/vue-web-components.md
- Vue TDD — ./generative/language/vue/tdd.md
- Vue BDD — ./generative/language/vue/bdd.md

## Frontend — Nuxt Execution Model (Canonical)

- File-based routing — `pages/` directory defines routes; `[param].vue` for dynamic segments, layouts wrap via `layouts/`.
- Data fetching — `useAsyncData`/`useFetch` orchestrate server/client data loads; Nitro server routes live under `server/api/`.
- Rendering modes — Mix SSR, SSG, and ISR per route via `routeRules`; document adapter choice and runtime config separation (server vs public).
- Runtime config and plugins — Secrets under `runtimeConfig`, client-safe under `runtimeConfig.public`; plugins annotated `.client`/`.server`.

See also
- Nuxt overview — ./generative/frontend/nuxt/nuxt-overview.md
- Routing & data guide — ./generative/frontend/nuxt/nuxt-routing-data.md
- SSR vs SSG strategy — ./generative/frontend/nuxt/nuxt-ssr-ssg.md
- Nuxt security — ./generative/frontend/nuxt/nuxt-security.md
- Web Components in Nuxt — ./generative/frontend/nuxt/nuxt-web-components.md

## Platform — CI/CD Providers (Canonical)

- GitHub Actions — See ./generative/platform/ci-cd/providers/github-actions.md
- GitLab CI — See ./generative/platform/ci-cd/providers/gitlab-ci.md
- Jenkins — See ./generative/platform/ci-cd/providers/jenkins.md
- TeamCity — See ./generative/platform/ci-cd/providers/teamcity.md
- Google Cloud Build — See ./generative/platform/ci-cd/providers/google-cloud-build.md
- Azure Pipelines — See ./generative/platform/ci-cd/providers/azure-pipelines.md
- AWS CodeBuild/CodePipeline — See ./generative/platform/ci-cd/providers/aws-codebuild-codepipeline.md
- Octopus Deploy — See ./generative/platform/ci-cd/providers/octopus-deploy.md

Guidance
- Declare chosen providers in host RULES.md.
- Provide minimal build/test and deploy pipelines, with secure secret handling and environment promotion.

## Platform — Security/Auth Providers (Canonical)

- OpenID Connect (OIDC) — Identity layer over OAuth2 for authentication and ID tokens. See ./generative/platform/security-auth/openid-connect.md
- Google Cloud (IAP/OIDC) — Identity‑Aware Proxy and OIDC integrations on GCP. See ./generative/platform/security-auth/gcp-auth.md
- Firebase Auth — Authentication for web/mobile with token validation patterns. See ./generative/platform/security-auth/firebase-auth.md
- Microsoft Entra ID (Azure AD) — OIDC/OAuth2 with Microsoft identity platform. See ./generative/platform/security-auth/microsoft-auth.md

## LLM Interpretation Guidance (Glossary Usage)

- Purpose — Provide minimal canonical terms and routing hints that AI must honor when generating docs or code.
- Routing — Use topic indexes and glossary anchors to select the correct module/variant (e.g., versioned Angular overrides; WebAwesome component anchors).
- Consistency — Use glossary terms in RULES, GUIDES, and IMPLEMENTATION; avoid synonyms; update forward‑only.
- Traceability — Close loops across Pact ↔ Glossary ↔ Rules ↔ Guides ↔ Implementation; keep links working and up‑to‑date in the same change.
