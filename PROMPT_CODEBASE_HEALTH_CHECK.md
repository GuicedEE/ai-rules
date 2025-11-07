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
- [ ] Health check plan approved
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

## 7) AI Response Format
Reply in this structure:

1) Health check plan (bullets)
2) Inventory and rule mapping (tables/lists)
3) Compliance matrix (with per-item links/evidence)
4) Proposed diffs and file list
5) Risk/migration notes
6) Prioritized remediation plan
7) Link integrity summary

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
