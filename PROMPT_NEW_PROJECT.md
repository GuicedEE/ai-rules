# 🚀 Starter Prompt — New Project Using the Rules Repository

Paste this prompt into your AI tool to bootstrap a new repository aligned to the RulesRepository methodology. The AI will scaffold a modular, forward-only documentation structure (Pact → Rules → Guides → Implementation), set up topic indexes, and generate minimal starter code where requested.

Supported: JetBrains AI (Junie), GitHub Copilot Chat, Cursor, ChatGPT, Claude, Roo.

---

## 0) Provide Inputs
Fill before running.

- Organization: <ORG_NAME>
- Project name: <PROJECT_NAME>
- Short description: <ONE_LINE_DESCRIPTION>
- Repository host + URL: <GIT_HOST>/<REPO_URL>
- License: <LICENSE> (e.g., Apache-2.0)


- Selected tech topics (tick):
  - Backend Reactive: [ ] Vert.x 5  [ ] Hibernate Reactive 7
  - Backend Reactive (GuicedEE) : Core [ ] Web [ ] Rest [ ] Persistence [ ] RabbitMQ [ ] Cerial [ ] OpenAPI [ ] Sockets [ ]  (Dependencies: if Core is selected, also select Vert.x 5; if Persistence is selected, also select Hibernate Reactive 7)
  - Security (Reactive): [ ] Vert.x Web Auth/JWT/OAuth2
  - Security/Auth Providers: [ ] OpenID Connect (generic)  [ ] GCP (IAP/OIDC)  [ ] Firebase Auth  [ ] Microsoft Entra ID (Azure AD)
  - Structural: [ ] MapStruct  [ ] Lombok  [ ] Logging  [ ] JSpecify
  - Fluent API Strategy (choose exactly one): [ ] CRTP (generic self-type; implied for GuicedEE and JWebMP)  [ ] Builder pattern (Lombok @Builder/manual). Only one may be selected; if GuicedEE or JWebMP is selected, CRTP is enforced.
  - Frontend (Standard): [ ] Web Components
  - Frontend (Reactive): Angular (choose exactly one) [ ] Angular 17  [ ] Angular 19  [ ] Angular 20  [ ] React  [ ] Next.js
  - Frontend (Angular Plugins): [ ] Angular Awesome
  - Frameworks (JWebMP) : Core [ ] WebAwesome [ ]
  - Infra/CI: [ ] GitHub Actions  [ ] Terraform  [ ] GCP Cloud Run
  - Database: [ ] PostgreSQL  [ ] MySQL  [ ] Other: <DB_OTHER>
  - Observability/Diagnostics: [ ] Health endpoints  [ ] Tracing  [ ] OpenAPI map  [ ] Wireshark
- Architecture: [ ] Monolith  [ ] Microservices  [ ] Micro Frontends  [ ] DDD
- AI engine used: [ ] JetBrains Junie  [ ] GitHub Copilot  [ ] Cursor  [ ] ChatGPT  [ ] Claude  [ ] Roo
- Level of change: [x] Forward-only (default)  [ ] Conservative (only if explicitly required)

Policies (must honor):
- Use Markdown for docs. Follow [RULES.md](rules/RULES.md) sections: 4 (Behavioral), 5 (Technical), Document Modularity Policy, 6 (Forward-Only Change Policy).
- Do NOT place project-specific docs inside the submodule directory.
- Fluent API Strategy: Choose either CRTP or Builder. CRTP is enforced if GuicedEE or JWebMP is selected. Align Lombok usage accordingly:
  - If CRTP: do not use @Builder; implement manual CRTP fluent setters returning (J)this with @SuppressWarnings("unchecked") as needed.
  - If Builder: prefer Lombok @Builder or manual builders; do not apply CRTP chaining rules.
- Angular version policy: Select exactly one Angular version (17/19/20). Use base + override model:
  - Base — [angular.md](rules/generative/language/angular/angular.md)
  - Overrides — [angular-17.rules.md](rules/generative/language/angular/angular-17.rules.md) | [angular-19.rules.md](rules/generative/language/angular/angular-19.rules.md) | [angular-20.rules.md](rules/generative/language/angular/angular-20.rules.md)
- Angular Plugins policy: Select Angular plugins (e.g., Angular Awesome) from the “Frontend (Angular Plugins)” list. Treat plugins as additive to the chosen Angular version; link to the plugin’s topic index and glossary.
- Glossary policy (topic-first): Compose the host GLOSSARY.md from topic-scoped glossaries for selected topics. Topic glossaries take precedence over the root glossary. Minimize duplication by linking to each topic’s GLOSSARY.md and rules; copy only enforced Prompt Language Alignment mappings (e.g., WebAwesome: WaButton/WaInput).

---

## 1) Self‑Configure the AI Engine
- Pin [RULES.md](rules/RULES.md#4-behavioral-agreements), [RULES.md](rules/RULES.md#5-technical-commitments), [RULES.md](rules/RULES.md#document-modularity-policy), [RULES.md](rules/RULES.md#6-forward-only-change-policy). Operate in forward-only mode: update all affected references in the same change.
- For Copilot/Cursor: create a workspace note or .cursor/rules.md summarizing these constraints.
- For ChatGPT/Claude:
  - Start with system note: "Follow RulesRepository RULES.md sections 4,5, Document Modularity, and 6 (forward-only). Close loops across artifacts."
  - Owner mode (this RulesRepository repository is the active workspace; not used as a submodule):
    - Do not refer to this repository as a submodule.
    - Load and pin ./skills.md; use project-scoped Skills under .claude/skills/.
  - Host project mode (a downstream project adopting these rules):
    - Use this repository as a Git submodule and link to it from host artifacts.
  - For Claude specifically: load and pin ./skills.md; discover project Agent Skills under .claude/skills/ (auto-discovered by Claude Code); acknowledge which Skills are active and apply them throughout generation.
- For Roo: load and pin [ROO_WORKSPACE_POLICY.md](rules/ROO_WORKSPACE_POLICY.md). If it does not exist, create it with a summary of RULES.md sections 4,5, Document Modularity Policy, and 6 (Forward-Only). Ensure repo-scoped conversations, include file paths in responses, and confirm forward-only mode is enabled. Update all references affected by a change in the same forward-only change set.

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
      - [ ] Next.js (TypeScript)
    - [ ] JavaScript
  - Kotlin
    - [ ] Kotlin
    - [ ] Ktor (requires Kotlin)
  - Other: <OTHER_LANGUAGES>

Language selection → generation rules
- If Java 17/21/25 is selected:
  - Apply the corresponding LTS rules and toolchains — [java-17.rules.md](rules/generative/language/java/java-17.rules.md), [java-21.rules.md](rules/generative/language/java/java-21.rules.md), [java-25.rules.md](rules/generative/language/java/java-25.rules.md).
  - Include build integration via [build-tooling.md](rules/generative/language/java/build-tooling.md).
- If Web → TypeScript is selected:
  - Include language rules link: [TypeScript README](rules/generative/language/typescript/README.md).
  - If Angular is also selected: include [Angular README](rules/generative/language/angular/README.md) and scaffold Angular app structure when requested; enforce a single version override.
  - If React is also selected: include [React README](rules/generative/language/react/README.md) and scaffold when requested.
  - If Next.js is selected: include [Next.js README](rules/generative/frontend/nextjs/README.md) and adhere to App Router guidance.
- If Kotlin is selected:
  - Include language rules link: [Kotlin README](rules/generative/language/kotlin/README.md).
  - If Ktor is also selected, scaffold a minimal Ktor service module and wire guides accordingly.

---

## 2) Project Plan (AI must draft first)
Produce a short plan with:
- Scopes selected (languages, frameworks, plugins, structural, platform).
- Initial repository structure (packages, apps, modules), build tool, CI, env files, docs (PACT, RULES, GUIDES, IMPLEMENTATION, GLOSSARY).
- Actions: initialize repo; add RulesRepository submodule; create modular docs; set up language/framework skeletons; update links; CI/env alignment.
- Risk notes: any forward-only decisions affecting defaults.

When approved, execute the plan as one change set.

---

## 3) Required Artifacts
1. Initialize repository and add the Rules Repository submodule at rules/ (or docs/rules-repository) and document usage in README.
2. Create PACT.md (root or docs/) starting from [creative/pact.md](rules/creative/pact.md). Fill project details and cross-links.
3. Create root GLOSSARY.md
   - Compose from topic glossaries (topic-first). For each selected topic, link to its topic GLOSSARY.md and adopt its canonical terms; these take precedence over root terms for that scope.
   - Copy only enforced Prompt Language Alignment mappings into the host glossary (e.g., WebAwesome names like WaButton/WaInput/WaCluster/WaStack). For all other terms, link to the topic file/anchor instead of duplicating definitions.
   - Document a “Glossary Precedence Policy”: topic glossaries override root for their scope; the host GLOSSARY.md acts as an index and aggregator with minimal duplication and LLM interpretation guidance (e.g., CRTP vs Builder routing, JSpecify defaults).
4. Create project RULES.md (outside submodule):
   - Declare scope, chosen stacks, plugin selections (Angular Plugins), and any project-specific conventions.
   - Link topic indexes:
     - Frontend (Standard):
       - Web Components — [README](rules/generative/frontend/webcomponents/README.md)
       - WebAwesome — [README](rules/generative/frontend/webawesome/README.md)
     - Frontend (Angular):
       - Angular — [README](rules/generative/language/angular/README.md) and exactly one override (17/19/20)
       - Angular Plugins:
         - Angular Awesome — [README](rules/generative/frontend/angular-awesome/README.md), [GLOSSARY](rules/generative/frontend/angular-awesome/GLOSSARY.md)
     - Frontend (React/Next):
       - React — [README](rules/generative/language/react/README.md)
       - Next.js — [README](rules/generative/frontend/nextjs/README.md), [GLOSSARY](rules/generative/frontend/nextjs/GLOSSARY.md)
     - Backend:
       - GuicedEE — [README](rules/generative/backend/guicedee/README.md)
       - Hibernate 7 Reactive — [README](rules/generative/backend/hibernate/README.md)
       - Vert.x — [README](rules/generative/backend/vertx/README.md)
     - Structural:
       - MapStruct — [README](rules/generative/backend/mapstruct/README.md), [GLOSSARY](rules/generative/backend/mapstruct/GLOSSARY.md)
       - Lombok — [README](rules/generative/backend/lombok/README.md), [GLOSSARY](rules/generative/backend/lombok/GLOSSARY.md)
       - JSpecify — [GLOSSARY](rules/generative/backend/jspecify/GLOSSARY.md)
       - Fluent API — [README](rules/generative/backend/fluent-api/README.md)
     - Platform:
       - Observability — [README](rules/generative/platform/observability/README.md)
       - Security & Auth — [README](rules/generative/platform/security-auth/README.md)
       - Secrets & Env — [README](rules/generative/platform/secrets-config/README.md)
5. Create GUIDES.md with links to chosen modular entries (e.g., Hibernate transactions; Web Components custom-elements/shadow-dom; Angular producing/consuming; Angular Awesome component usage; Next.js data fetching). Use glossary-aligned terms consistently.
6. Create IMPLEMENTATION.md explaining current modules, code layout, and back-links to guides. Ensure implementation names and labels adhere to GLOSSARY.md.
7. Environment alignment
   - Create .env.example per [env-variables.md](rules/generative/platform/secrets-config/env-variables.md).
8. CI alignments
   - Add/update minimal GitHub Actions workflows; enumerate required secrets.
9. README updates
   - State adoption of Rules Repository, link submodule path, and link PACT/RULES/GUIDES/IMPLEMENTATION/GLOSSARY. Declare selected Angular version and Angular Plugins (if any).

- WebAwesome prompt language alignment (if selected)
  - When prompting, align terms:
    - “button” → say “WaButton” (see [button.rules.md](rules/generative/frontend/webawesome/button.rules.md))
    - “input” → say “WaInput” (see [input.rules.md](rules/generative/frontend/webawesome/input.rules.md))
    - “row” (layout) → say “WaCluster”
    - “column/stack” (layout) → say “WaStack”
  - If a variant has no dedicated file, link to the subsection under the broader rule.

---

## 4) Output Checklist
- [ ] Repo initialized; submodule added and referenced in README
- [ ] PACT.md present and linked
- [ ] Project RULES.md present, linking to enterprise RULES and topic indexes (including Angular Plugins group where applicable)
- [ ] Fluent API Strategy declared (CRTP vs Builder) and reflected in RULES.md and GLOSSARY.md; Lombok usage aligned to selection
- [ ] GLOSSARY.md composed topic-first: links to selected topic glossaries; Glossary Precedence Policy documented; minimal duplication; enforced mappings copied
- [ ] GUIDES.md and IMPLEMENTATION.md present with back/forward links
- [ ] .env.example aligned to env-variables.md
- [ ] CI updated/added
- [ ] Angular version selected (exactly one) and, if applicable, Angular Plugins listed; all links resolve
- [ ] No project files placed inside the submodule

---

## 5) Guardrails
- Apply Forward-Only Change Policy fully.
- No backwards-compat stubs/anchors.
- Close loops between artifacts (traceability in both directions).
- Do not modify compiled outputs or generated bundles.

---

## 6) AI Response Format
1) Proposed project plan (bullets)
2) Questions (if any)
3) Final diffs/files content
4) Post-scaffold validation notes (link checks and selections summary)

End of prompt.