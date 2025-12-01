# 🚀 Starter Prompt — New Project Using the Rules Repository

Ask your AI tool to copy this template and align with the Rules Repository. The AI will scaffold a modular, forward-only documentation structure (Pact → Rules → Guides → Implementation), set up topic indexes, and generate minimal starter code where requested.

Supported: Junie, AI Assistant, GitHub Copilot Chat, Cursor, ChatGPT, Claude, Roo, Codex.

---

## 0) Provide Inputs
Fill before running.

- Organization: <ORG_NAME>
- Project name: <PROJECT_NAME>
- Short description: <ONE_LINE_DESCRIPTION>
- Repository host + URL: <GIT_HOST>/<REPO_URL>
- License: <LICENSE> (e.g., Apache-2.0)

- Stage approvals preference for this run (controls STOP gates)
  - Choose exactly one:
    - [ ] Require explicit approval at each stage (default)
    - [ ] Approvals are optional; proceed with documented defaults if no reply
    - [ ] Blanket approval granted for this run (no STOPs)


- AI engine used:
  - [ ] Junie
  - [ ] GitHub Copilot
  - [ ] Cursor
  - [ ] ChatGPT
  - [ ] Claude
  - [ ] Roo
  - [ ] Codex
  - [ ] AI Assistant
  - Note: Select every AI assistant involved and configure prompts/rules for each engine accordingly.
    - AI Assistant reads rules from `.aiassistant/rules/`; mirror enforced policies there so IDE prompts stay aligned.

- Architecture:
  - [x] Specification-Driven Design (SDD) (mandatory)
  - [x] Documentation-as-Code (mandatory)
  - [ ] Monolith
  - [ ] Microservices
  - [ ] Micro Frontends
  - [ ] DDD
  - [ ] TDD (docs-first, test-first)
  - [ ] BDD (docs-first, executable specs)
- Language selection (configure here)
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
        - [ ] Vue (TypeScript)
          - [ ] Nuxt (TypeScript)
      - [ ] JavaScript
    - Kotlin
      - [ ] Kotlin
      - [ ] Ktor (requires Kotlin)
    - Other: <OTHER_LANGUAGES>
  - Build engines
    - Java/Kotlin builds
      - [ ] Maven
      - [ ] Gradle (Groovy DSL)
      - [ ] Gradle (Kotlin DSL)
      - [ ] Apache Ivy
    - Web builds
      - [ ] npm / package.json scripts
      - [ ] pnpm
      - [ ] yarn
      - [ ] Babel (transpile configuration lives in package.json/babel.config.*)
    - Other build tooling: <OTHER_BUILDS>
  - Dependency declarations
    - JVM: record artifact coordinates only (groupId:artifactId:version). Use build-tooling rules for plugin or build script scaffolding.
    - JavaScript/Web: record package name + version (npm/pnpm/yarn/Babel). Defer script wiring to language/build-topic rules.

- Selected tech topics (tick):
  - Fluent API Strategy (choose exactly one):
    - [ ] CRTP
    - [ ] Builder pattern (Lombok @Builder/manual)
  - Backend Reactive:
    - Core stacks:
      - [ ] Vert.x 5
      - [ ] Hibernate Reactive 7
    - Quarkus:
      - [ ] Core project setup
      - [ ] RESTEasy Reactive APIs
      - [ ] Persistence (Hibernate/Panache)
      - [ ] Reactive messaging
      - [ ] Security/OIDC
      - [ ] Dev Services & local tooling
      - [ ] Native build & packaging
      - [ ] Testing strategy
      - Note: Quarkus currently embeds Vert.x 4 under the hood; select Vert.x 5 only if directly building on the Vert.x APIs.
    - GuicedEE:
      - [ ] Core
      - [ ] Client
      - [ ] Web
      - [ ] WebSocket
      - [ ] Rest
      - [ ] Persistence
      - [ ] RabbitMQ
      - [ ] Cerial
      - [ ] OpenAPI
      - Note: If Core is selected, also select Vert.x 5 and include GuicedEE Vert.x Bridge rules (rules/generative/backend/guicedee/vertx/README.md); if Persistence is selected, also select Hibernate Reactive 7 and link rules/generative/backend/guicedee/persistence/README.md.
    - Databases:
      - [ ] PostgreSQL
      - [ ] MySQL
      - [ ] DB2
      - [ ] Oracle
      - [ ] MSSQL
      - [ ] SQL Client templates
      - [ ] MongoDB
      - [ ] Redis
      - [ ] Cassandra
    - Security (Reactive):
      - [ ] Vert.x Web Auth/JWT/OAuth2
  - Backend:
    - Spring MVC:
      - [ ] Core MVC/Web
      - [ ] Validation (Bean Validation)
      - [ ] Data JPA (Hibernate ORM)
      - [ ] Security (non-reactive)
      - [ ] Actuator (ops endpoints)
      - [ ] OpenAPI (springdoc)
      - [ ] Micrometer/Tracing (OTel exporters optional)
      - [ ] Caching
      - [ ] Scheduling & Async
      - [ ] Batch
      - [ ] Mail
      - [ ] Messaging
      - Database migrations:
        - [ ] Flyway
        - [ ] Liquibase
      - [ ] Testing
      - [ ] Packaging & Deployment
      - Reference: ./generative/backend/spring/overview-setup.md
    - JDBC Databases:
      - [ ] PostgreSQL
      - [ ] MySQL
      - [ ] Oracle
      - [ ] MSSQL
      - [ ] MariaDB
      - [ ] IBM DB2
      - [ ] SQLite
      - [ ] Other: <DB_OTHER>
  - Security/Auth Providers:
    - [ ] OpenID Connect (generic)
    - [ ] GCP (IAP/OIDC)
    - [ ] Firebase Auth
    - [ ] Microsoft Entra ID (Azure AD)
  - Structural:
    - [ ] MapStruct
    - [ ] Lombok
    - [ ] Logging
    - [ ] JSpecify
  - Testing & Coverage:
    - [ ] Jacoco
    - [ ] SonarQube
    - [ ] Java Micro Harness
    - [ ] Cypress
    - [ ] BrowserStack
  - Frontend (Standard):
    - [ ] Web Components
  - Frontend (Reactive):
    - Angular (choose exactly one)
      - [ ] Angular 17
      - [ ] Angular 19
      - [ ] Angular 20
    - Other frameworks
      - [ ] React
        - [ ] Next.js
      - [ ] Vue
        - [ ] Nuxt
  - Frontend (Angular Plugins):
    - [ ] Angular Awesome
  - Frameworks (JWebMP):
    - [ ] Core
    - [ ] Client
    - [ ] TypeScript
    - [ ] WebAwesome
  - CI/CD Providers:
    - [ ] GitHub Actions
    - [ ] GitLab CI
    - [ ] Jenkins
    - [ ] TeamCity
    - [ ] Google Cloud Build
    - [ ] Azure Pipelines
    - [ ] AWS CodeBuild/CodePipeline
  - Infra/Deploy:
    - [ ] Terraform
    - [ ] GCP Cloud Run
  - Observability/Diagnostics:
    - [ ] Health endpoints
    - [ ] Tracing
    - [ ] OpenAPI
    - [ ] Wireshark
    - OpenAPI Provider (choose one; default = Swagger)
      - [x] Swagger (default)
      - [ ] MicroProfile OpenAPI
      - [ ] Springdoc OpenAPI (Spring Boot)
    - Health endpoints default to MicroProfile: /health, /health/ready, /health/live (Spring Actuator endpoints supported but not default)
- Level of change:
  - [x] Forward-only (default)
  - [ ] Conservative (only if explicitly required)

Policies (must honor):
- Reset the AI context before running this template—act as if this is the first prompt for the project and do not reuse prior session memory.
- Treat all existing repository documentation as out-of-date; never rely on it as a source of truth. When executing this template, reference only the current checked-in code/config you observe.
- Honor the selected Java LTS exactly; do not substitute another version. If Java 25 is selected, plan and generate for Java 25 everywhere.
- Use Markdown for docs. Follow [RULES.md](rules/RULES.md) sections: 4 (Behavioral), 5 (Technical), Document Modularity Policy, 6 (Forward-Only Change Policy).
- Do NOT place project-specific docs inside the submodule directory.
- Logging policy: Default to Log4j2; wire logging/config/examples against Log4j2. If Lombok is selected, use Lombok's `@Log4j2` annotation (avoid other Lombok logging annotations).
- Fluent API Strategy: Choose either CRTP or Builder. CRTP is enforced if GuicedEE or JWebMP is selected. Align Lombok usage accordingly:
  - If CRTP: do not use @Builder; implement manual CRTP fluent setters returning (J)this with @SuppressWarnings("unchecked") as needed.
  - If Builder: prefer Lombok @Builder or manual builders; do not apply CRTP chaining rules.
- Angular version policy: Select exactly one Angular version (17/19/20). Use base + override model:
  - Base — [angular.md](rules/generative/language/angular/angular.md)
  - Overrides — [angular-17.rules.md](rules/generative/language/angular/angular-17.rules.md) | [angular-19.rules.md](rules/generative/language/angular/angular-19.rules.md) | [angular-20.rules.md](rules/generative/language/angular/angular-20.rules.md)
- Angular Plugins policy: Select Angular plugins (e.g., Angular Awesome) from the “Frontend (Angular Plugins)” list. Treat plugins as additive to the chosen Angular version; link to the plugin’s topic index and glossary.
- Glossary policy (topic-first): Compose the host GLOSSARY.md from topic-scoped glossaries for selected topics. Topic glossaries take precedence over the root glossary. Minimize duplication by linking to each topic’s GLOSSARY.md and rules; copy all Prompt Language Alignment mappings (e.g., WebAwesome: WaButton/WaInput).

---

## Documentation-First, Stage-Gated Workflow (Mandatory)

- This repository enforces a documentation-first, stage-gated process for all AI systems (Junie, Copilot, Cursor, ChatGPT, Claude, Roo, Codex).
- The AI MUST NOT write or modify source code until documentation phases are completed and explicitly approved by the user.
- Stage approvals default to user review checkpoints; the user may explicitly waive these STOP gates or grant blanket approval, after which you may proceed while documenting the opt-out.
- Junie exception: If Junie is the active AI engine, do not pause for stage approvals; treat each stage as auto-approved while documenting that Junie bypasses STOP gates.

Stage 1 — Architecture & Foundations (Docs only)
- Deliver:
  - PACT draft/updates; architecture overview; C4 or ADRs where appropriate
  - Sequence diagrams for key flows; async/system flow diagrams
  - Data flow diagrams; threat model summary and trust boundaries
  - Dependency/integration map (internal/external services)
  - Glossary composition plan (topic-first, precedence and anchors)
- Output format: Markdown docs placed in host docs (outside rules/), with links to enterprise rules indexes.
- STOP (user review optional): Offer a review/approval checkpoint before Stage 2. Continue without waiting only if the user has opted out or granted blanket approval.

Stage 2 — Guides & Design Validation (Docs only)
- Deliver:
  - RULES mapping to selected stacks; GUIDES with “how to apply”
  - API surface sketches and contracts (OpenAPI, types) where applicable
  - UI flows/wireframes (if applicable) and component mapping
  - Migration notes, test strategy outline, acceptance criteria
- STOP (user review optional): Offer a review/approval checkpoint before Stage 3. Continue without waiting only if the user has opted out or granted blanket approval.

Stage 3 — Implementation Plan (No code yet)
- Deliver:
  - Scaffolding plan and module/file tree
  - Build/annotation-processor wiring, CI workflow plan, env/config plan
  - Rollout plan (phased), risk items, validation approach
- STOP (user review optional): Offer a review/approval checkpoint before Stage 4. Continue without waiting only if the user has opted out or granted blanket approval.

Stage 4 — Implementation & Scaffolding (Code allowed)
- Scope: Only after explicit approval unless the user has already waived stage approvals or granted blanket approval for the run.
- Approach: Generate minimal scaffolding first, then iterate in small, reviewable steps. After each step, present diffs and validation, then ask to continue.

Universal STOP rule
- If the user requires staged approvals and approval is not granted, revise docs; if the user waived staged approvals, continue but be prepared to revise when feedback is provided.
- Each stage must close loops via links: PACT ↔ GLOSSARY ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION.

## 1) Self‑Configure the AI Engine
- Pin [RULES.md](rules/RULES.md#4-behavioral-agreements), [RULES.md](rules/RULES.md#5-technical-commitments), [RULES.md](rules/RULES.md#document-modularity-policy), [RULES.md](rules/RULES.md#6-forward-only-change-policy). Operate in forward-only mode: update all affected references in the same change.
- AI workspace files (selected engines):
  - AI Assistant: ensure `.aiassistant/rules/` exists with a pinned summary of RULES.md sections 4/5, Document Modularity, and Forward-Only; keep it synchronized with the host RULES.md.
  - GitHub Copilot: add `.github/copilot-instructions.md` (or workspace note) with the same constraints and STOP-gate policy.
  - Cursor: add `.cursor/rules.md` with the same constraints (may share content with Copilot if both are selected).
- MCP servers (per selected AI engine):
  - If the chosen assistant supports MCP (e.g., Cursor, Claude Desktop, MCP-capable IDEs), register the servers before running the prompt.
  - Always register the Mermaid MCP server for docs/diagrams: HTTP `https://mcp.mermaidchart.com/mcp` (`"type": "http"`) or SSE `https://mcp.mermaidchart.com/sse` (`"type": "sse"`).
  - Provide a minimal MCP config snippet for the selected assistant (e.g., `.mcp.json` or IDE settings) that includes Mermaid and any other required servers; instruct the AI to load it before producing diagrams.
  - Confirm in responses which MCP servers are active so registration aligns with the AI engine selections.
  - Explicitly note when an output/diagram was generated using an MCP server for traceability.
- For ChatGPT/Claude:
  - Start with system note: "Follow Rules Repository RULES.md sections 4,5, Document Modularity, and 6 (forward-only). Close loops across artifacts."
  - Owner mode (this Rules Repository repository is the active workspace; not used as a submodule):
    - Do not refer to this repository as a submodule.
    - Load and pin ./skills.md; use project-scoped Skills under .claude/skills/.
  - Host project mode (a downstream project adopting these rules):
    - Use this repository as a Git submodule and link to it from host artifacts.
  - For Claude specifically: load and pin ./skills.md; discover project Agent Skills under .claude/skills/ (auto-discovered by Claude Code); acknowledge which Skills are active and apply them throughout generation.
- For Codex CLI (Codex agent):
  - Load ./RULES.md anchors plus README context; confirm forward-only and Document Modularity constraints are pinned in the Codex CLI workspace.
  - Follow Codex CLI harness instructions: run shell commands with `bash -lc` and explicit `workdir`, prefer `rg` for scans, honor sandbox/approval settings, and use the plan tool for multi-step work.
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
        - [ ] Vue (TypeScript)
          - [ ] Nuxt (TypeScript)
      - [ ] JavaScript
  - Kotlin
    - [ ] Kotlin
    - [ ] Ktor (requires Kotlin)
  - Other: <OTHER_LANGUAGES>

Language selection → generation rules
- If Java 17/21/25 is selected:
  - Apply the corresponding LTS rules and toolchains — [java-17.rules.md](rules/generative/language/java/java-17.rules.md), [java-21.rules.md](rules/generative/language/java/java-21.rules.md), [java-25.rules.md](rules/generative/language/java/java-25.rules.md).
  - Include build integration via [build-tooling.md](rules/generative/language/java/build-tooling.md).
  - When Maven, Gradle (Groovy/Kotlin DSL), or Apache Ivy is selected, document artifact coordinates only (groupId:artifactId:version) and refer to build-tooling.md for plugin/config wiring.
- If Web → TypeScript is selected:
  - Include language rules link: [TypeScript README](rules/generative/language/typescript/README.md).
  - If Angular is also selected: include [Angular README](rules/generative/language/angular/README.md) and scaffold Angular app structure when requested; enforce a single version override.
  - If React is also selected: include [React README](rules/generative/language/react/README.md) and scaffold when requested.
  - If React → Next.js is selected: include [Next.js README](rules/generative/frontend/nextjs/README.md) and adhere to App Router guidance.
  - If Vue is also selected: include [Vue README](rules/generative/language/vue/README.md) and scaffold when requested.
  - If Vue → Nuxt is selected: include [Nuxt README](rules/generative/frontend/nuxt/README.md) and follow SSR/SSG routing guidance.
  - When npm, pnpm, yarn, or Babel is selected, record package@version requirements only; rely on the TypeScript/JS build guides for configuring bundlers/transpilers.
- If Kotlin is selected:
  - Include language rules link: [Kotlin README](rules/generative/language/kotlin/README.md).
  - If Ktor is also selected, scaffold a minimal Ktor service module and wire guides accordingly.

---

## 2) Project Plan (AI must draft first)
Produce a short plan with:
- Scopes selected (languages, frameworks, plugins, structural, platform).
- Initial repository structure (packages, apps, modules), build tool, CI, env files, docs (PACT, RULES, GUIDES, IMPLEMENTATION, GLOSSARY).
- Actions: initialize repo; add Rules Repository submodule; create modular docs; set up language/framework skeletons; update links; CI/env alignment.
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
       - JWebMP — [README](rules/generative/frontend/jwebmp/README.md)
       - JWebMP Client — [README](rules/generative/frontend/jwebmp/client/README.md)
       - JWebMP TypeScript — [README](rules/generative/frontend/jwebmp/typescript/README.md)
     - Frontend (Angular):
       - Angular — [README](rules/generative/language/angular/README.md) and exactly one override (17/19/20)
       - Angular Plugins:
         - Angular Awesome — [README](rules/generative/frontend/angular-awesome/README.md), [GLOSSARY](rules/generative/frontend/angular-awesome/GLOSSARY.md)
     - Frontend (React/Vue/Next/Nuxt):
       - React — [README](rules/generative/language/react/README.md)
       - Next.js — [README](rules/generative/frontend/nextjs/README.md), [GLOSSARY](rules/generative/frontend/nextjs/GLOSSARY.md)
       - Vue — [README](rules/generative/language/vue/README.md), [GLOSSARY](rules/generative/language/vue/GLOSSARY.md)
       - Nuxt — [README](rules/generative/frontend/nuxt/README.md), [GLOSSARY](rules/generative/frontend/nuxt/GLOSSARY.md)
     - Backend:
       - GuicedEE — [README](rules/generative/backend/guicedee/README.md)
       - GuicedEE Client — [README](rules/generative/backend/guicedee/client/README.md)
      - GuicedEE Vert.x Bridge — [README](rules/generative/backend/guicedee/vertx/README.md) (include when GuicedEE Core is selected)
      - GuicedEE Websockets — [README](rules/generative/backend/guicedee/websockets/README.md)
      - GuicedEE Persistence — [README](rules/generative/backend/guicedee/persistence/README.md)
       - Hibernate (ORM/Reactive) — [README](rules/generative/backend/hibernate/README.md)
       - Vert.x — [README](rules/generative/backend/vertx/README.md)
     - Structural:
       - MapStruct — [README](rules/generative/backend/mapstruct/README.md), [GLOSSARY](rules/generative/backend/mapstruct/GLOSSARY.md)
       - Lombok — [README](rules/generative/backend/lombok/README.md), [GLOSSARY](rules/generative/backend/lombok/GLOSSARY.md)
       - JSpecify — [GLOSSARY](rules/generative/backend/jspecify/GLOSSARY.md)
       - Fluent API — [README](rules/generative/backend/fluent-api/README.md)
     - Architecture:
       - TDD — [README](rules/generative/architecture/tdd/README.md)
       - BDD — [README](rules/generative/architecture/bdd/README.md)
     - Platform:
       - CI/CD — [README](rules/generative/platform/ci-cd/README.md)
         - If selected, also link provider docs:
           - GitHub Actions — [github-actions.md](rules/generative/platform/ci-cd/providers/github-actions.md)
           - GitLab CI — [gitlab-ci.md](rules/generative/platform/ci-cd/providers/gitlab-ci.md)
           - Jenkins — [jenkins.md](rules/generative/platform/ci-cd/providers/jenkins.md)
           - TeamCity — [teamcity.md](rules/generative/platform/ci-cd/providers/teamcity.md)
           - Google Cloud Build — [google-cloud-build.md](rules/generative/platform/ci-cd/providers/google-cloud-build.md)
           - Azure Pipelines — [azure-pipelines.md](rules/generative/platform/ci-cd/providers/azure-pipelines.md)
           - AWS CodeBuild/CodePipeline — [aws-codebuild-codepipeline.md](rules/generative/platform/ci-cd/providers/aws-codebuild-codepipeline.md)
       - Observability — [README](rules/generative/platform/observability/README.md)
       - Security & Auth — [README](rules/generative/platform/security-auth/README.md)
       - Secrets & Env — [README](rules/generative/platform/secrets-config/README.md)
5. Create GUIDES.md with links to chosen modular entries (e.g., Hibernate transactions; Web Components custom-elements/shadow-dom; Angular producing/consuming; Angular Awesome component usage; Next.js or Nuxt data fetching). Use glossary-aligned terms consistently.
6. Create IMPLEMENTATION.md explaining current modules, code layout, and back-links to guides. Ensure implementation names and labels adhere to GLOSSARY.md.
7. Environment alignment
   - Create .env.example per [env-variables.md](rules/generative/platform/secrets-config/env-variables.md).
8. CI alignments
   - Add/update minimal GitHub Actions workflows; enumerate required secrets.
   - If building a GuicedEE library and GitHub Actions is selected, add `.github/workflows/maven-package.yml` pointing at the shared workflow:
      ```yaml
      name: Maven Package
      on:
        workflow_dispatch:
        push:
      jobs:
        GuicedInjection:
          uses: GuicedEE/Workflows/.github/workflows/projects.yml@master
          with:
            baseDir: ''
            name: 'Guiced Injection'
          secrets:
            USERNAME: ${{secrets.USERNAME}}
            USER_TOKEN: ${{secrets.USER_TOKEN}}
            SONA_USERNAME: ${{secrets.SONA_USERNAME}}
            SONA_PASSWORD: ${{secrets.SONA_PASSWORD}}
      ```
9. README updates
   - State adoption of Rules Repository, link submodule path, and link PACT/RULES/GUIDES/IMPLEMENTATION/GLOSSARY. Declare selected Angular version and Angular Plugins (if any).
10. AI workspace alignment (selected engines)
    - AI Assistant — `.aiassistant/rules/` with RULES.md sections 4/5, Document Modularity, and Forward-Only.
    - GitHub Copilot — `.github/copilot-instructions.md` (or workspace note) covering the same constraints and STOP-gate policy.
    - Cursor — `.cursor/rules.md` mirroring the same constraints.
    - Roo — [ROO_WORKSPACE_POLICY.md](rules/ROO_WORKSPACE_POLICY.md) present/pinned if Roo is selected.

- WebAwesome prompt language alignment (if selected)
  - When prompting, align terms:
    - “button” → say “WaButton” (see [button.rules.md](rules/generative/frontend/webawesome/button.rules.md))
    - “input” → say “WaInput” (see [input.rules.md](rules/generative/frontend/webawesome/input.rules.md))
    - “row” (layout) → say “WaCluster”
    - “column/stack” (layout) → say “WaStack”
  - If a variant has no dedicated file, link to the subsection under the broader rule.

---

## 4) Output Checklist
- [ ] Stage 1 (Architecture & Foundations) docs produced; capture user approval if they require the STOP gate
- [ ] Stage 2 (Guides & Design Validation) docs produced; capture user approval if they require the STOP gate
- [ ] Stage 3 (Implementation Plan) produced; capture user approval if they require the STOP gate
- [ ] Stage 4 (Code/Scaffolding) executed only after explicit approval unless the user granted blanket approval; diffs presented with validation and links
- [ ] Repo initialized; submodule added and referenced in README
- [ ] PACT.md present and linked
- [ ] Project RULES.md present, linking to enterprise RULES and topic indexes (including Angular Plugins group where applicable)
- [ ] Fluent API Strategy declared (CRTP vs Builder) and reflected in RULES.md and GLOSSARY.md; Lombok usage aligned to selection
- [ ] GLOSSARY.md composed topic-first: links to selected topic glossaries; Glossary Precedence Policy documented; minimal duplication; enforced mappings copied
- [ ] GUIDES.md and IMPLEMENTATION.md present with back/forward links
- [ ] .env.example aligned to env-variables.md
- [ ] CI updated/added
- [ ] Angular version selected (exactly one) and, if applicable, Angular Plugins listed; all links resolve
- [ ] MCP servers configured (config snippet provided), registered for selected assistants (Mermaid MCP for docs/diagrams), and acknowledged in outputs
- [ ] AI workspace files committed for selected engines (.aiassistant/rules/, .github/copilot-instructions.md, .cursor/rules.md, ROO_WORKSPACE_POLICY.md if Roo)
- [ ] No project files placed inside the submodule

---

## 5) Guardrails
- Apply Forward-Only Change Policy fully.
- No backwards-compat stubs/anchors.
- Close loops between artifacts (traceability in both directions).
- Do not modify compiled outputs or generated bundles.

---

## 6) AI Response Format (Stage-Gated)
1) Stage N deliverables (docs or plans only until Stage 4), with file paths and working links
2) Open questions, decisions required, risks
3) STOP — Render the standardized options block (see Stage Gate Interaction Protocol). Respect the Stage approvals preference from Inputs.
   - If approvals are optional and no reply is received after one reminder, proceed with option 3 and record the default.
   - If explicit approval is required and still no reply after one reminder, stop and summarize how to resume; do not retry more than twice.
   - If blanket approval is set, skip STOP sections but record that the gate was auto-approved by policy.
4) If approval is required and granted, provide the next-stage plan; if not granted, revise and re-submit Stage N; if the user opted out or blanket approval applies, continue with the next-stage plan

End of prompt.
## Diagrams and Docs-as-Code Policy (Mandatory)

Purpose
- All projects using the Rules Repository must be documented with architecture diagrams and technical flows that are reviewable by humans and consumable by AI.
- Documents are version-controlled first-class artifacts and must be referenced by prompts in this project going forward.

Required artifacts (Docs-as-Code)
- C4 Architecture Diagrams (text-based)
  - Level 1 (Context): high-level system context and external dependencies
  - Level 2 (Container): major containers/services and their responsibilities
  - Level 3 (Component): key components within each container (per bounded context)
  - Optional Level 4 (Code): when a component requires deeper drill-down
- Sequence Diagrams
  - Critical user/system flows (auth, key business transactions, error paths)
  - Include async steps and boundaries (message bus, schedulers, background jobs)
- ERDs (Entity-Relationship Diagrams)
  - Core domain model and relationships
  - Note ownership (bounded contexts) and data lifecycles
- Deployment/Runtime
  - Topology where relevant (edge, API, workers), environments, regions

Format and storage (Docs as Code)
- Use text formats that diff well:
  - Mermaid (preferred) in Markdown fenced blocks (```mermaid)
  - Mermaid node names/labels must not contain parentheses `(` or `)`; use plain names without brackets.
  - PlantUML (.puml) or fenced blocks (```plantuml)
  - Mermaid MCP server is available to assist with architecture and diagrams: HTTP endpoint `https://mcp.mermaidchart.com/mcp` with `"type": "http"`; SSE endpoint `https://mcp.mermaidchart.com/sse` with `"type": "sse"`.
- Storage conventions (host repository, outside rules/):
  - docs/architecture/README.md — architecture index linking all diagrams
  - docs/architecture/c4-context.md — C4 L1
  - docs/architecture/c4-container.md — C4 L2
  - docs/architecture/c4-component-<bounded-context>.md — C4 L3 files
  - docs/architecture/sequence-<flow>.md — sequence diagrams
  - docs/architecture/erd-<domain>.md — ERD diagrams
  - Optional rendered images are stored under docs/architecture/img/ and derived from the text sources; do not commit images without sources
- Version control mandate
  - Commit all diagram sources (Mermaid/PlantUML). Images must never replace sources.

Prompt seeding and traceability
- Create docs/PROMPT_REFERENCE.md that:
  - Records selected stacks (languages/frameworks/plugins) and glossary composition
  - Links to all diagrams under docs/architecture/
  - Is referenced by future prompts for this project; AI must load and honor it
- Close the documentation loop: PACT ↔ GLOSSARY ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION must reference and reuse the diagrams.

Stage-gates alignment (reinforced)
- Stage 1 (Architecture & Foundations) must produce:
  - C4 L1/L2 and at least initial L3 for critical bounded contexts
  - Sequence diagrams for at least two critical flows
  - Initial ERD for the core domain
  - docs/architecture/README.md and docs/PROMPT_REFERENCE.md
- Stage 2 may refine/extend diagrams; Stage 3/4 must not proceed without Stage 1/2 approval when the user requests staged reviews.

Checklist addendum (Docs & Diagrams)
- [ ] docs/architecture/README.md exists and links to all diagrams
- [ ] docs/architecture/c4-context.md committed (Mermaid/PlantUML source)
- [ ] docs/architecture/c4-container.md committed (Mermaid/PlantUML source)
- [ ] docs/architecture/c4-component-*.md committed for critical bounded contexts
- [ ] docs/architecture/sequence-*.md committed for critical flows
- [ ] docs/architecture/erd-*.md committed for core domain(s)
- [ ] docs/PROMPT_REFERENCE.md created with links to the above and selected stacks
- [ ] PACT/RULES/GUIDES/IMPLEMENTATION link to these diagrams (closing the loop)

Note
- These documents form part of all present and future prompts for this project and must always exist under version control. Any AI system acting on this repository must load and respect them before proposing or generating code.
