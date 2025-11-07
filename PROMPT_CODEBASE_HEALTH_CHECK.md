# 🩺 Starter Prompt — Codebase Health Check and Standards Compliance

Use this prompt to perform a full repository health check, assess compliance against the enterprise RulesRepository, detect gaps and deviations, and generate a prioritized remediation plan with proposed diffs. Supports use in owner mode (this repository) and host projects that consume it as a submodule.

Supported: JetBrains AI (Junie), GitHub Copilot Chat, Cursor, ChatGPT, Claude, Roo.

---

## 0) Provide Inputs
Fill before running.

- Repository URL / local path: <REPO_URL_OR_PATH>
- Org and project name: <ORG_NAME> / <PROJECT_NAME>
- Short description: <ONE_LINE_DESCRIPTION>
- License (if missing or to change): <LICENSE>
- Scope focus (tick all that apply):
  - Backend Reactive: [ ] Vert.x 5  [ ] Hibernate Reactive 7
  - Backend Reactive (GuicedEE): Core [ ] Web [ ] Rest [ ] Persistence [ ] RabbitMQ [ ] Cerial [ ] OpenAPI [ ] Sockets [ ] (Dependencies: if Core → also select Vert.x 5; if Persistence → also select Hibernate Reactive 7)
  - Structural: [ ] MapStruct  [ ] Lombok  [ ] Logging  [ ] JSpecify
  - Fluent API Strategy (choose exactly one): [ ] CRTP (generic self-type; implied for GuicedEE and JWebMP)  [ ] Builder pattern (Lombok @Builder/manual). Only one may be selected; if GuicedEE or JWebMP is present, CRTP is enforced.
  - Frontend (Standard): [ ] Web Components
  - Frontend (Reactive): Angular (choose exactly one) [ ] Angular 17  [ ] Angular 19  [ ] Angular 20  [ ] React  [ ] Next.js
  - Frontend (Angular Plugins): [ ] Angular Awesome (Angular 19+ plugin)
  - Frameworks (JWebMP): Core [ ] WebAwesome [ ]
  - Platform: [ ] Observability/Health  [ ] Security & Auth (OIDC/GCP/Firebase/Microsoft)  [ ] Secrets & Env
  - Data: [ ] PostgreSQL  [ ] MySQL  [ ] Other: <DB_OTHER>
- AI engine used: [ ] JetBrains Junie  [ ] GitHub Copilot  [ ] Cursor  [ ] ChatGPT  [ ] Claude  [ ] Roo
- Level of change: [x] Forward-only (default)  [ ] Conservative (only if explicitly required)

Policies (must honor):
- Use Markdown for docs. Follow [RULES.md](rules/RULES.md) sections: 4 (Behavioral), 5 (Technical), Document Modularity Policy, 6 (Forward-Only Change Policy).
- Do NOT place project artifacts inside this submodule. Host projects must keep PACT/RULES/GUIDES/IMPLEMENTATION outside the submodule path.
- Generated artifacts are read-only; do not propose edits to compiled outputs (TS/HTML/site bundles).
- JWebMP: no inline string HTML; render UI with JWebMP components; do not generate separate TS/HTML for missing views.
- PostgreSQL JPMS: do not shade the driver; prefer com.guicedee.services:postgresql and requires org.postgresql.
- Fluent API Strategy: Choose either CRTP or Builder. CRTP is enforced if GuicedEE or JWebMP is present. Align Lombok usage accordingly:
  - If CRTP: do not use @Builder; implement manual CRTP fluent setters returning (J)this with @SuppressWarnings("unchecked") on setters as needed.
  - If Builder: prefer Lombok @Builder or manual builders; do not apply CRTP chaining rules.
- Glossary policy (topic-first): Host GLOSSARY.md must be composed from topic-scoped glossaries for the selected topics. Topic glossaries take precedence over the root glossary; copy only enforced Prompt Language Alignment mappings, and otherwise link to topic files/anchors. Include brief LLM interpretation guidance where relevant (e.g., CRTP vs Builder routing, JSpecify defaults).

---

## Documentation-First, Stage-Gated Workflow (Mandatory)

- This repository enforces a documentation-first, stage-gated process for all AI systems (Junie, Copilot, Cursor, ChatGPT, Claude, Roo).
- The AI MUST NOT write or modify source code until documentation phases are completed and explicitly approved by the user.

Stage 1 — Health Check Plan (Docs only)
- Deliver:
  - Scope confirmation and inventory approach
  - Rule/topic mapping plan and evidence collection approach
  - Risks and assumptions
- Output format: Markdown plan in host docs (outside rules/), with links to enterprise rule indexes.
- STOP: Request explicit user approval to proceed to Stage 2.

Stage 2 — Findings & Documentation (Docs only)
- Deliver:
  - Compliance matrix draft with evidence links (no code changes)
  - Documentation fixes proposals (Doc Modularity, link integrity), diffs as text only
  - Risk notes and migration implications (forward-only)
- STOP: Request explicit user approval to proceed to Stage 3.

Stage 3 — Proposed Diffs (No code applied yet)
- Deliver:
  - Single change set proposal with unified diffs
  - Migration notes and validation plan (tests, link checks) for after application
- STOP: Request explicit user approval to proceed to Stage 4.

Stage 4 — Apply Diffs (Code allowed)
- Scope: Only after explicit approval.
- Approach: Apply the single change set; present results, run validations, report outcomes. For further changes, repeat Stage 3/4.

Universal STOP rule
- If approval is not granted, revise docs/findings; do not produce or apply code.
- Each stage must close loops via links: PACT ↔ GLOSSARY ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION.

## 1) Self‑Configure the AI Engine
- Pin [RULES.md](rules/RULES.md#4-behavioral-agreements), [RULES.md](rules/RULES.md#5-technical-commitments), [RULES.md](rules/RULES.md#document-modularity-policy), [RULES.md](rules/RULES.md#6-forward-only-change-policy). Operate in forward-only mode; update references in the same change.
- Copilot/Cursor: create a workspace note or .cursor/rules.md summarizing constraints.
- ChatGPT/Claude:
  - Start with system note enforcing the above sections. Close loops across artifacts.
  - Owner mode (this repository as active workspace): do not refer to it as a submodule; load and pin ./skills.md if available.
  - Host project mode: use this repository as a submodule and link to it from host artifacts.
- Roo: pin [ROO_WORKSPACE_POLICY.md](rules/ROO_WORKSPACE_POLICY.md) if present; otherwise create it per [README.md](rules/README.md#roo-workspace-policy-pinned).

Language Selection (configure here)
- Languages
  - Java (choose exactly one LTS)
    - [ ] Java 17 LTS
    - [ ] Java 21 LTS
    - [ ] Java 25 LTS
  - Web
    - [ ] TypeScript
      - [ ] Angular (TypeScript)
      - [ ] React (TypeScript)
    - [ ] JavaScript
  - Kotlin
    - [ ] Kotlin
    - [ ] Ktor (requires Kotlin)
  - Other: <OTHER_LANGUAGES>

Language selection → evaluation rules
- If Java 17/21/25 is selected: apply the corresponding LTS rules and build tooling — see [java-17.rules.md](rules/generative/language/java/java-17.rules.md), [java-21.rules.md](rules/generative/language/java/java-21.rules.md), [java-25.rules.md](rules/generative/language/java/java-25.rules.md), plus [build-tooling.md](rules/generative/language/java/build-tooling.md).
- If Web → TypeScript: include [TypeScript rules](rules/generative/language/typescript/README.md); add Angular/React indexes if selected.
- If Kotlin: include [Kotlin rules](rules/generative/language/kotlin/README.md); add Ktor checks if selected.

---

## 2) Health Check Plan (AI must draft first)
Produce a short plan with:
- Inventory: source sets, modules, build tools, CI, env files, docs (PACT, RULES, GUIDES, IMPLEMENTATION, GLOSSARY).
- Applied stacks: detect frameworks present and map to relevant rule indexes under generative/.
- Gaps: missing artifacts, missing indexes, monolithic docs violating Document Modularity, absent topic links.
- Risk notes: any breaking removals per forward-only policy.
When approved, execute as one change set.

---

## 3) Health Check Tasks (Automated + Manual)
Run these tasks; collect findings with severity, evidence, and rule references.

A. Repository Inventory and Structure
- Detect language modules, build system, JPMS usage, packaging, and code owners.
- Host docs placement: verify PACT/RULES/GUIDES/IMPLEMENTATION/GLOSSARY are outside the submodule path per [README.md](rules/README.md#enterprise-usage-and-placement-rules).
- Submodule integrity: confirm rules/ is a Git submodule (host mode) or absent (owner mode).

B. Rule Mapping and Scope Confirmation
- Map detected stacks to indexes:
  - Frontend: [webcomponents](rules/generative/frontend/webcomponents/README.md), [webawesome](rules/generative/frontend/webawesome/README.md), [angular](rules/generative/language/angular/angular17.md), [react](rules/generative/language/react/README.md), [nextjs](rules/generative/frontend/nextjs/README.md).
  - Backend: [hibernate](rules/generative/backend/hibernate/README.md), [vertx](rules/generative/backend/vertx/README.md), [guicedee](rules/generative/backend/guicedee/README.md), [mapstruct](rules/generative/backend/mapstruct/README.md), [lombok](rules/generative/backend/lombok/README.md), [logging](rules/generative/backend/logging/README.md).
  - Platform: [security-auth](rules/generative/platform/security-auth/README.md), [secrets-config](rules/generative/platform/secrets-config/README.md), [observability](rules/generative/platform/observability/README.md).
- For each mapping, enumerate applicable rules and checks.

C. Language and Framework Checks
- Java LTS alignment:
  - Toolchains, compiler flags, modules; ensure selected LTS rules applied; verify [build-tooling.md](rules/generative/language/java/build-tooling.md) alignment.
- JPMS policies:
  - Verify module-info.java requires; PostgreSQL rule: prefer com.guicedee.services:postgresql; ensure requires org.postgresql.
- GuicedEE:
  - Check for conformity to function rules (injection, vertx-web/rest/persistence, sockets, rabbit, cerial, swagger).
- Hibernate Reactive 7:
  - Use of Mutiny; withTransaction patterns; anti-pattern avoidance (no blocking).
- Vert.x 5:
  - Event loop rules; reactive transactions; Postgres client usage; OAuth2; TCP EventBus bridge practices.
- MapStruct / Lombok / Logging / JSpecify:
  - Annotation processor setup; config files; logging policy conformance.
  - Fluent API Strategy compliance:
    - If CRTP selected or implied (GuicedEE/JWebMP present): no Lombok @Builder; CRTP setters exist returning (J)this with @SuppressWarnings("unchecked"); chaining via CRTP only.
    - If Builder selected: Lombok @Builder/manual builders allowed; CRTP-specific chaining not used.
    - Flag conflicts (e.g., Builder found with GuicedEE/JWebMP, or both strategies mixed).
- Kotlin:
  - Language rules; Ktor module shape; coroutines best practices.
- Web Components / WebAwesome:
  - Component usage; Prompt Language Alignment (WaButton, WaInput, WaCluster, WaStack); index links resolve.
- Angular/React/Next.js:
  - Structure, routing, SSR/SSG (Next.js); web components integration (Angular Elements); security.

D. Quality, Security, and Platform
- Testing: unit/integration setup; Testcontainers for DB; coverage gates.
- Security & Auth: OIDC/OAuth flows; token validation; provider-specific configs (GCP/Firebase/Microsoft).
- Secrets & Env: presence and correctness of .env.example per [env-variables.md](rules/generative/platform/secrets-config/env-variables.md).
- Observability: health endpoints, tracing, OpenAPI map; logging configuration.

E. Documentation and Link Integrity
- Document Modularity: split oversized docs; replace monoliths with modular entries; update all references.
- Close loops: PACT ↔ GLOSSARY ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION with bi-directional links per [README.md](rules/README.md#linking-guidance-closing-loops).
- Glossary policy compliance: host GLOSSARY.md links to topic glossaries (topic-first), documents precedence, avoids duplication, and copies only enforced Prompt Language Alignment mappings.
- Resolve all links: check that every referenced path exists; record broken links and missing indexes.

F. CI/CD and Licensing
- CI presence and minimal workflows; secrets list; build/test stages.
- License presence and correctness.

---

## 4) Differences, Evidence, and Remediation
Produce a comprehensive health report with:

1) Compliance Matrix
- Rows: Rule/Topic
- Columns: Evidence (files/lines), Status (Compliant / Gap / Violation), Severity (High/Med/Low), Action, Link to rule.

2) Proposed Diffs
- For each actionable fix, propose precise diffs (one change set) with filenames and unified patches.
- Respect guardrails: do not change compiled outputs; do not move host docs into submodule; update or remove conflicting references in the same change.

3) Risk and Migration Notes
- Note breaking removals caused by forward-only edits; include concise MIGRATION.md content when needed.

4) Prioritized Remediation Plan
- Quick wins (low risk, high value)
- Foundational alignments (toolchains, module setup)
- Feature-area refactors (per framework/topic)
- Documentation and link fixes
- CI/Env/Security follow-ups

---

## 5) Output Checklist
- [ ] Stage 1 (Health Check Plan) produced and user-approved (STOP gate passed)
- [ ] Stage 2 (Findings & Documentation) produced and user-approved (STOP gate passed)
- [ ] Stage 3 (Proposed Diffs) produced and user-approved (STOP gate passed)
- [ ] Stage 4 (Apply Diffs) executed only after explicit approval; results validated with links and evidence
- [ ] Inventory and rule mapping completed
- [ ] Compliance matrix produced with links and evidence
- [ ] Proposed diffs prepared (single forward-only change set)
- [ ] Risk and migration notes drafted
- [ ] Remediation plan prioritized
- [ ] Link integrity report completed
- [ ] Fluent API Strategy declared/detected (CRTP vs Builder) and aligned across RULES/GLOSSARY/implementation; violations flagged
- [ ] Glossary policy validated (topic-first composition, precedence documented, minimal duplication, enforced mappings copied)
- [ ] All references point to correct topic indexes under generative/

---

## 6) Guardrails
- Apply [Forward-Only Change Policy](rules/RULES.md#6-forward-only-change-policy) fully; no compatibility shims/anchors.
- Keep host project artifacts outside the submodule; do not commit them under rules/.
- Do not modify compiled/generated outputs.
- JWebMP policy: express UI via components; changes originate from Java sources for generators.
- Close loops: ensure backward/forward links between artifacts.

---

## 7) AI Response Format (Stage-Gated)
Reply in this structure:

1) Stage N deliverables (docs or plans only until Stage 4), with file paths and working links
2) Open questions, decisions required, risks
3) STOP — Request explicit approval to proceed to Stage N+1
   - Required approval phrasing: “APPROVED Stage N → Stage N+1”
4) If approved, provide next-stage plan; if not, revise and re-submit Stage N

End of prompt.

---

## 0a) Starting Prompt Reference (Required)

Capture the original starter prompt and host doc roots so compliance can be checked against the intended scope.

- Starting prompt used (select one or specify):
  - [PROMPT_NEW_PROJECT.md](rules/PROMPT_NEW_PROJECT.md)
  - [PROMPT_ADOPT_EXISTING_PROJECT.md](rules/PROMPT_ADOPT_EXISTING_PROJECT.md)
  - [PROMPT_LIBRARY_RULES_UPDATE.md](rules/PROMPT_LIBRARY_RULES_UPDATE.md)
  - Custom/Other: &lt;DESCRIPTION_OR_LINK_TO_FILE_OR_COMMIT&gt;
- Host docs directories to scan (override defaults if needed):
  - Defaults: ["docs/", "./"] (project root)
  - Additional paths (if any): &lt;ADDITIONAL_PATHS_JSON_ARRAY_OR_SEMICOLON_LIST&gt;
- Saved prompt reference (recommended):
  - Path to a copy of the starting prompt or session export within the repo (if present): &lt;PATH_OR_URL&gt;
  - If none is saved, provide a short summary of selected topics/stacks from the original run.

Note: These inputs enable reconciliation between declared intent (starting prompt selections) and observed implementation.

---

## 3G) Starting Prompt Traceability and Host Overrides (New)

Purpose: Verify that the host project’s declared intent (from its starting prompt) matches actual artifacts and code, and that any overrides to enterprise rules are explicit, justified, and correctly linked.

Scope discovery
- Discover host artifacts across configured roots (outside the submodule path):
  - PACT: PACT.md
  - Glossary: GLOSSARY.md
  - Rules: RULES.md (+ any RULES-*.md or rules/*.md under host docs)
  - Guides: GUIDES.md (+ local modular guides)
  - Implementation: IMPLEMENTATION.md
- Assert placement:
  - All host artifacts must live outside the RulesRepository submodule per [README.md](rules/README.md).
  - If any host-specific docs are detected under the submodule path, flag as violation.

Starting prompt reconciliation
- If a saved copy of the starting prompt exists (new/adopt/library), parse the selected topics/tech to establish the intended scope.
- If not saved, infer selections via repository signals:
  - Build files, module descriptors, dependencies
  - Presence of framework markers (Vert.x, Hibernate Reactive, GuicedEE, Angular/React/Next.js, Web Components/WebAwesome, Kotlin/Ktor)
  - CI, env, and provider configs
- For each selected/intended topic:
  - Verify host RULES.md declares scope and links to corresponding enterprise topic indexes under generative/.
  - Verify host GUIDES.md provides “how to apply” links using glossary-aligned terminology.
  - Verify IMPLEMENTATION.md back-links to guides and uses Glossary terms consistently.

Host overrides audit (Rule Precedence)
- Extract all host RULES.md sections that extend/override enterprise guidance.
- For each override:
  - Confirm rationale is documented and references [Rule Precedence](rules/RULES.md#rule-precedence).
  - Ensure back-links to the enterprise rule(s) being overridden (specific file/section).
  - Check that links resolve and that language remains glossary-aligned.
- Produce an “Overrides vs Enterprise” matrix:
  - Enterprise Rule → Host Override → Rationale → Evidence → Status (Compliant/Violation/Gap) → Links.

Topic guides and guidelines coverage
- Ensure every selected topic (from starting prompt or inference) has:
  - Host RULES linkage to enterprise index
  - Host guide(s) or explicit reference to enterprise guides
  - Implementation back-links
- WebAwesome alignment:
  - Enforce prompt language alignment (WaButton, WaInput, WaCluster, WaStack) across host RULES/GUIDES/IMPLEMENTATION.
- Security/Auth providers:
  - If OIDC/GCP/Firebase/Microsoft selected, verify provider-specific guidance is linked and present in host docs.

Migration and forward-only implications
- If host overrides remove/replace legacy content, ensure MIGRATION.md (or release/upgrade notes) succinctly documents the change per forward-only policy.

Deliverables for this section
- Starting prompt detection summary (source, selections, or inference basis).
- Host artifacts inventory with placement validation.
- Overrides vs Enterprise matrix (with working links/evidence).
- Coverage report for topic guides/guidelines and loop-closure across PACT ↔ GLOSSARY ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION.

---

## 5) Output Checklist (Additions)
- [ ] Starting prompt identified and linked (or inferred with evidence)
- [ ] Host docs directories scanned and validated (outside submodule)
- [ ] Overrides vs Enterprise matrix produced with rationale and links
- [ ] Topic guides/guidelines coverage validated against starting prompt selections
- [ ] MIGRATION notes present where forward-only changes remove/replace legacy content

---

## 7) AI Response Format (Additions)
8) Starting prompt and overrides reconciliation
- Starting prompt source and selected topics (or inference summary)
- Host artifacts placement validation
- Overrides vs Enterprise summary table
- Topic coverage status and loop-closure findings
- Migration/forward-only notes (if applicable)

## Diagrams and Docs-as-Code Policy (Mandatory)

Purpose
- When running a health check against a repository using the Rules Repository, the system’s architecture and key flows must be documented in text-based diagrams that are reviewable by humans and consumable by AI.
- These documents are first-class, version-controlled artifacts and must be referenced by this and future prompts/actions on the project.

Required artifacts (Docs-as-Code)
- C4 Architecture Diagrams (text-based)
  - Level 1 (Context): system context and external dependencies
  - Level 2 (Container): major containers/services and responsibilities
  - Level 3 (Component): key components within each container (per bounded context)
  - Optional Level 4 (Code): deep drill-down when necessary
- Sequence Diagrams
  - Critical flows (auth, business transactions, error paths, background jobs)
  - Include async steps and boundaries (bus, schedulers)
- ERDs (Entity-Relationship Diagrams)
  - Core domain model and relationships
  - Ownership/bounded contexts and data lifecycles
- Deployment/Runtime
  - Topology (edge, API, workers), environments, regions, significant infra

Format and storage (Docs as Code)
- Use text formats that diff well:
  - Mermaid (preferred) in Markdown fenced blocks (```mermaid)
  - PlantUML (.puml) or fenced blocks (```plantuml)
- Storage conventions in host repo (outside rules/):
  - docs/architecture/README.md — architecture index linking all diagrams
  - docs/architecture/c4-context.md — C4 L1
  - docs/architecture/c4-container.md — C4 L2
  - docs/architecture/c4-component-<bounded-context>.md — C4 L3 files
  - docs/architecture/sequence-<flow>.md — sequence diagrams
  - docs/architecture/erd-<domain>.md — ERD diagrams
  - Optional rendered images under docs/architecture/img/ derived from sources; do not commit images without their sources
- Version control mandate
  - Commit all diagram sources (Mermaid/PlantUML). Images must never replace sources.

Prompt seeding and traceability
- Create docs/PROMPT_REFERENCE.md that:
  - Records selected stacks (languages/frameworks/plugins) and glossary composition (topic-first precedence)
  - Links to all diagrams under docs/architecture/
  - Is referenced by future prompts for this project; AI must load and honor it
- Close the documentation loop: PACT ↔ GLOSSARY ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION must reference and reuse these diagrams.

Checklist addendum (Docs & Diagrams)
- [ ] docs/architecture/README.md exists and links all diagrams
- [ ] docs/architecture/c4-context.md committed (Mermaid/PlantUML source)
- [ ] docs/architecture/c4-container.md committed (Mermaid/PlantUML source)
- [ ] docs/architecture/c4-component-*.md committed for critical bounded contexts
- [ ] docs/architecture/sequence-*.md committed for critical flows
- [ ] docs/architecture/erd-*.md committed for core domain(s)
- [ ] docs/PROMPT_REFERENCE.md created with links to the above and selected stacks
- [ ] PACT/RULES/GUIDES/IMPLEMENTATION link to these diagrams (closing the loop)

Note
- These documents form part of all present and future prompts for this project and must remain under version control. Any AI system acting on this repository must load and respect them before proposing or generating code.
