# 🔄 Starter Prompt — Adopt Rules Repository in an Existing Project

Paste this prompt into your AI tool to migrate an existing repository to the Rules Repository methodology. The AI will analyze the repo, add the Rules Repository submodule, establish Pact → Rules → Guides → Implementation, and refactor docs to the modular, forward-only model.

Supported: JetBrains AI (Junie), GitHub Copilot Chat, Cursor, ChatGPT, Claude, Roo.

---

## 0) Provide Inputs
Fill before running.

- Repository URL / local path: <REPO_URL_OR_PATH>
- Org and project name: <ORG_NAME> / <PROJECT_NAME>
- Short description: <ONE_LINE_DESCRIPTION>
- License (if missing or to change): <LICENSE>

- Detected/Chosen tech topics (tick):
  - Backend Reactive: [ ] Vert.x 5  [ ] Hibernate Reactive 7
  - Backend Reactive (GuicedEE) : Core [ ] Web [ ] Rest [ ] Persistence [ ] RabbitMQ [ ] Cerial [ ] OpenAPI [ ] Sockets [ ]  (Dependencies: if Core is selected, also select Vert.x 5; if Persistence is selected, also select Hibernate Reactive 7)
  - Security (Reactive): [ ] Vert.x Web Auth/JWT/OAuth2
  - Security/Auth Providers: [ ] OpenID Connect (generic)  [ ] GCP (IAP/OIDC)  [ ] Firebase Auth  [ ] Microsoft Entra ID (Azure AD)
  - Structural: [ ] MapStruct  [ ] Lombok  [ ] Logging  [ ] JSpecify
  - Fluent API Strategy (choose exactly one): [ ] CRTP (generic self-type; implied for GuicedEE and JWebMP, Lombok used, no @Setter)  [ ] Builder pattern (Lombok @Builder/manual). Only one may be selected; if GuicedEE or JWebMP is selected, CRTP is enforced.
  - Frontend (Standard): [ ] Web Components
  - Frontend Frameworks (JWebMP) : Core [ ] WebAwesome [ ]
  - Frontend (Reactive): Angular (choose exactly one) [ ] Angular 17  [ ] Angular 19  [ ] Angular 20  [ ] React  [ ] Next.js
  - Frontend (Angular Plugins): [ ] Angular Awesome
  - Infra/CI: [ ] GitHub Actions  [ ] Terraform  [ ] GCP Cloud Run
  - Database: [ ] PostgreSQL  [ ] MySQL  [ ] Other: <DB_OTHER>
  - Observability/Diagnostics: [ ] Health endpoints  [ ] Tracing  [ ] OpenAPI map  [ ] Wireshark
- Architecture: [ ] Monolith  [ ] Microservices  [ ] Micro Frontends  [ ] DDD
- AI engine used: [ ] JetBrains Junie  [ ] GitHub Copilot  [ ] Cursor  [ ] ChatGPT  [ ] Claude  [ ] Roo
- Level of change: [x] Forward-only (default)  [ ] Conservative (only if explicitly required)

Policies (must honor):
- Use Markdown for docs. Follow RULES.md sections: 4 (Behavioral), 5 (Technical), Document Modularity Policy, 6 (Forward-Only Change Policy).
- Do NOT place project-specific docs inside the submodule directory.
- Fluent API Strategy: Choose either CRTP or Builder. CRTP is enforced if GuicedEE or JWebMP is selected. Align Lombok usage accordingly:
  - If CRTP: do not use @Builder; implement manual CRTP fluent setters returning (J)this with @SuppressWarnings("unchecked") as needed.
  - If Builder: prefer Lombok @Builder or manual builders; do not apply CRTP chaining rules.
- Angular version policy: Select exactly one Angular version (17/19/20). Migrate docs to base + override model:
  - Base rules — ./generative/language/angular/angular.md
  - Version overrides — ./generative/language/angular/angular-17.rules.md | ./angular-19.rules.md | ./angular-20.rules.md
  - Remove monolithic Angular docs; link to base + selected override; do not mix version APIs in a single project.
- Angular Plugins policy: Select Angular plugins (e.g., Angular Awesome) from the “Frontend (Angular Plugins)” list. Treat plugins as additive to the chosen Angular version; link to the plugin’s topic index and glossary.
- Glossary policy (topic-first): Compose the host GLOSSARY.md from topic-scoped glossaries for all selected topics. Topic glossaries take precedence over the root glossary. Minimize duplication by linking to each topic’s GLOSSARY.md and rules; copy only enforced Prompt Language Alignment mappings (e.g., WebAwesome: WaButton/WaInput).
---

## 1) Self‑Configure the AI Engine
- Pin ./RULES.md anchors (sections above). Operate in forward-only mode: remove/replace legacy docs as needed; update all references.
- For Copilot/Cursor: create a workspace note or .cursor/rules.md summarizing these constraints.
- For ChatGPT/Claude:
  - Start with system note: "Follow RulesRepository RULES.md sections 4,5, Document Modularity, and 6 (forward-only). Close loops across artifacts."
  - Owner mode (this RulesRepository repository is the active workspace; not used as a submodule):
    - Do not refer to this repository as a submodule.
    - Load and pin ./skills.md; use project-scoped Skills under .claude/skills/.
  - Host project mode (a downstream project adopting these rules):
    - Use this repository as a Git submodule and link to it from host artifacts.
  - For Claude specifically: load and pin ./skills.md; discover project Agent Skills under .claude/skills/ (auto-discovered by Claude Code); acknowledge which Skills are active and apply them throughout generation.
- For Roo: load and pin ROO_WORKSPACE_POLICY.md at the repository root. If it does not exist, create it with a summary of RULES.md sections 4,5, Document Modularity Policy, and 6 (Forward-Only). Ensure repo-scoped conversations, include file paths in responses, and confirm forward-only mode is enabled. Update all references affected by a change in the same forward-only change set.

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

Language selection → generation rules
- If Java 17/21/25 is selected:
  - Apply the corresponding LTS rules and toolchains (link to the selected: rules/generative/language/java/java-17.rules.md, rules/generative/language/java/java-21.rules.md, or rules/generative/language/java/java-25.rules.md).
  - Include build integration via rules/generative/language/java/build-tooling.md.
- If Web → TypeScript is selected:
  - Include language rules link: rules/generative/language/typescript/README.md.
  - If Angular is also selected: include rules/generative/language/angular/README.md and scaffold Angular app structure when requested.
  - If React is also selected: include rules/generative/language/react/README.md and scaffold React app structure when requested.
- If Kotlin is selected:
  - Include language rules link: rules/generative/language/kotlin/README.md.
  - If Ktor is also selected, scaffold a minimal Ktor service module and wire guides accordingly.

---

## 2) Migration Plan (AI must draft first)
The AI should begin by producing a short plan with:
- Inventory: existing docs (README, RULES, GUIDES, architecture docs), CI, env files, components.
- Gaps: missing Pact/Rules/Guides/Implementation, outdated monolithic docs, absent indexes.
- Actions: submodule add; create/relocate docs; refactor to modular; update links; CI/env alignment.
- Risk notes: any breaking removals per forward-only policy.

When approved, execute the plan as one change set.

---

## 3) Required Changes
1. Add Rules Repository submodule (rules/ or docs/rules-repository) and document usage in README.
2. Create PACT.md (root or docs/) based on rules/creative/pact.md. Fill project details and cross-links.
3. Create GLOSSARY.md (root or docs/):
   - Compose from topic glossaries (topic-first). For each selected topic, link to its topic GLOSSARY.md and adopt its canonical terms; these take precedence over root terms for that scope.
   - Copy only enforced Prompt Language Alignment mappings into the host glossary (e.g., WebAwesome: WaButton, WaInput, WaCluster, WaStack). For all other terms, link to the topic file/anchor instead of duplicating definitions.
   - Document a “Glossary Precedence Policy”: topic glossaries override root for their scope; the host GLOSSARY.md acts as an index and aggregator with minimal duplication and LLM interpretation guidance (e.g., CRTP vs Builder routing, JSpecify defaults).
4. Create/Update project RULES.md (outside submodule):
   - Declare scope, chosen stacks, and any project-specific conventions.
   - Link to relevant topic indexes:
     - rules/generative/language/react/README.md
     - rules/generative/frontend/nextjs/README.md
     - rules/generative/frontend/webcomponents/README.md
     - rules/generative/frontend/angular-awesome/README.md
     - rules/generative/backend/hibernate/README.md
     - rules/generative/backend/guicedee/README.md
     - If GuicedEE Core is selected: also include rules/generative/backend/vertx/README.md
     - If Backend Reactive (GuicedEE) options are selected: link chosen function rules under rules/generative/backend/guicedee/functions/ (guiced-injection-rules.md, guiced-vertx-web-rules.md, guiced-vertx-rest-rules.md, guiced-vertx-persistence-rules.md, guiced-rabbit-rules.md, guiced-cerial-rules.md, guiced-swagger-openapi-rules.md, guiced-vertx-sockets-rules.md)
     - If GuicedEE Persistence is selected: ensure Hibernate Reactive 7 is selected/linked (rules/generative/backend/hibernate/README.md)
     - rules/generative/backend/security-reactive/README.md
     - rules/generative/frontend/webawesome/README.md
     - If JWebMP with WebAwesome plugin is selected: rules/generative/frontend/jwebmp/jwebmp-webawesome/README.md
     - rules/generative/platform/observability/README.md
     - rules/generative/architecture/README.md
     - rules/generative/platform/security-auth/README.md
   - Reference GLOSSARY.md for naming/terminology alignment.
5. Create/Update GUIDES.md with links to chosen modular entries (e.g., Hibernate transactions, CRUD; Web Components custom-elements/shadow-dom; Angular producing/consuming; WebAwesome Button/Input rules). Use glossary-aligned terms consistently.
6. Create/Update IMPLEMENTATION.md explaining current modules, code layout, and back-links to guides. Ensure implementation names and labels adhere to GLOSSARY.md.
7. Refactor legacy docs to modular model where feasible:
   - Split overly large monoliths into focused docs or replace with links to the submodule’s modular entries (preferred).
   - Remove deprecated/duplicate documents per Forward-Only policy; update all inbound links.
8. Environment alignment
   - Create or update .env.example using rules/generative/platform/secrets-config/env-variables.md as the source of truth.
9. CI alignments
   - Add/update minimal GitHub Actions workflows for build/test and document required secrets.
10. README updates
   - State adoption of Rules Repository, link submodule path, and link PACT/RULES/GUIDES/IMPLEMENTATION/GLOSSARY.

- WebAwesome prompt language alignment (if selected)
  - When prompting, use WebAwesome component names to enforce alignment:
    - “button” → say “WaButton” (see rules/generative/frontend/webawesome/button.rules.md)
    - “icon button” → say “WaIconButton” (see rules/generative/frontend/webawesome/icon-button.rules.md)
    - “input” → say “WaInput” (see rules/generative/frontend/webawesome/input.rules.md)
    - “row” (layout) → say “WaCluster”
    - “column/stack” (layout) → say “WaStack”
  - If a variant has no dedicated file, link to the subsection under the broader rule (e.g., WaInput → #number-input).

---

## 4) Output Checklist
- [ ] Submodule added and referenced in README
- [ ] PACT.md present and linked
- [ ] Project RULES.md present, linking to enterprise RULES and topic indexes
- [ ] Fluent API Strategy declared (CRTP vs Builder) and reflected in RULES.md and GLOSSARY.md; Lombok usage aligned to selection
- [ ] GLOSSARY.md composed topic-first: links to selected topic glossaries; Glossary Precedence Policy documented; minimal duplication; Prompt Language Alignment mappings copied where enforced
- [ ] GUIDES.md and IMPLEMENTATION.md present with back/forward links
- [ ] Monolithic/legacy docs removed or replaced; all references updated
- [ ] .env.example aligned to env-variables.md
- [ ] CI updated/added
- [ ] All links resolve; no project files placed inside the submodule
---

## 5) Guardrails
- Apply Forward-Only Change Policy fully; do not keep legacy stubs/anchors for compatibility.
- Document any risky removals briefly in MIGRATION.md (create if necessary).
- Close loops between artifacts (traceability in both directions).

---

## 6) AI Response Format
1) Proposed migration plan with inventory and diffs
2) Questions (if any)
3) Final diffs/files content
4) Post-migration validation notes (broken links check summary)

End of prompt.