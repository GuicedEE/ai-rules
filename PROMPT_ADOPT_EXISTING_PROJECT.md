# 🔄 Starter Prompt — Adopt Rules Repository in an Existing Project

Paste this prompt into your AI tool to migrate an existing repository to the Rules Repository methodology. The AI will analyze the repo, add the Rules Repository submodule, establish Pact → Rules → Guides → Implementation, and refactor docs to the modular, forward-only model.

Supported: JetBrains AI (Junie), GitHub Copilot Chat, Cursor, ChatGPT, Claude, Roo, Codex.

---

## 0) Provide Inputs
Fill before running.

- Repository URL / local path: <REPO_URL_OR_PATH>
- Org and project name: <ORG_NAME> / <PROJECT_NAME>
- Short description: <ONE_LINE_DESCRIPTION>
- License (if missing or to change): <LICENSE>

- Detected/Chosen tech topics (tick):
  - Backend Reactive:
    - [ ] Vert.x 5
    - [ ] Hibernate Reactive 7
  - Backend (Spring MVC):
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
  - Backend Reactive (GuicedEE):
    - [ ] Core
    - [ ] Web
    - [ ] Rest
    - [ ] Persistence
    - [ ] RabbitMQ
    - [ ] Cerial
    - [ ] OpenAPI
    - [ ] Sockets
    - Note: Dependencies — if Core is selected, also select Vert.x 5; if Persistence is selected, also select Hibernate Reactive 7
  - Security (Reactive):
    - [ ] Vert.x Web Auth/JWT/OAuth2
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
    - [ ] Jacoco (coverage gates — ./generative/platform/testing/jacoco.rules.md)
    - [ ] SonarQube (quality gates — ./generative/platform/testing/sonarqube.rules.md)
    - [ ] Java Micro Harness (integration harness — ./generative/platform/testing/java-micro-harness.rules.md)
    - [ ] Cypress (UI E2E — ./generative/platform/testing/cypress.rules.md)
    - [ ] BrowserStack (cross-browser cloud — ./generative/platform/testing/browserstack.rules.md)
  - Fluent API Strategy (choose exactly one):
    - [ ] CRTP
    - [ ] Builder pattern (Lombok @Builder/manual)
  - Frontend (Standard):
    - [ ] Web Components
  - Frameworks (JWebMP):
    - [ ] Core
    - [ ] WebAwesome
  - Frontend (Reactive):
    - Angular (choose exactly one)
      - [ ] Angular 17
      - [ ] Angular 19
      - [ ] Angular 20
    - Other frameworks
      - [ ] React
      - [ ] Next.js
  - Frontend (Angular Plugins):
    - [ ] Angular Awesome
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
  - Database:
    - [ ] PostgreSQL
    - [ ] MySQL
    - [ ] Other: <DB_OTHER>
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
- Architecture:
  - [ ] Monolith
  - [ ] Microservices
  - [ ] Micro Frontends
  - [ ] DDD
  - [ ] TDD (docs-first, test-first)
  - [ ] BDD (docs-first, executable specs)
- AI engine used:
  - [ ] JetBrains Junie
  - [ ] GitHub Copilot
  - [ ] Cursor
  - [ ] ChatGPT
  - [ ] Claude
  - [ ] Roo
  - [ ] Codex
- Level of change:
  - [x] Forward-only (default)
  - [ ] Conservative (only if explicitly required)

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

## Documentation-First, Stage-Gated Workflow (Mandatory)

- This repository enforces a documentation-first, stage-gated process for all AI systems (Junie, Copilot, Cursor, ChatGPT, Claude, Roo, Codex).
- The AI MUST NOT write or modify source code until documentation phases are completed and explicitly approved by the user.

Stage 1 — Architecture & Foundations (Docs only)
- Deliver:
  - PACT draft/updates; architecture overview; C4 or ADRs where appropriate
  - Sequence diagrams for key flows; async/system flow diagrams
  - Data flow diagrams; threat model summary and trust boundaries
  - Dependency/integration map (internal/external services)
  - Glossary composition plan (topic-first, precedence and anchors)
- Output format: Markdown docs placed in host docs (outside rules/), with links to enterprise rules indexes.
- STOP: Request explicit user approval to proceed to Stage 2.

Stage 2 — Guides & Design Validation (Docs only)
- Deliver:
  - RULES mapping to selected stacks; GUIDES with “how to apply”
  - API surface sketches and contracts (OpenAPI, types) where applicable
  - UI flows/wireframes (if applicable) and component mapping
  - Migration notes, test strategy outline, acceptance criteria
- STOP: Request explicit user approval to proceed to Stage 3.

Stage 3 — Implementation Plan (No code yet)
- Deliver:
  - Scaffolding plan and module/file tree
  - Build/annotation-processor wiring, CI workflow plan, env/config plan
  - Rollout plan (phased), risk items, validation approach
- STOP: Request explicit user approval to proceed to Stage 4.

Stage 4 — Implementation & Scaffolding (Code allowed)
- Scope: Only after explicit approval.
- Approach: Generate minimal scaffolding first, then iterate in small, reviewable steps. After each step, present diffs and validation, then ask to continue.

Universal STOP rule
- If approval is not granted, revise docs; do not produce code.
- Each stage must close loops via links: PACT ↔ GLOSSARY ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION.

## 1) Self‑Configure the AI Engine
- Pin ./RULES.md anchors (sections above). Operate in forward-only mode: remove/replace legacy docs as needed; update all references.
- For Copilot/Cursor: create a workspace note or .cursor/rules.md summarizing these constraints.
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
     - rules/generative/platform/ci-cd/README.md
       - If CI/CD Providers are selected, also link provider docs:
         - GitHub Actions — rules/generative/platform/ci-cd/providers/github-actions.md
         - GitLab CI — rules/generative/platform/ci-cd/providers/gitlab-ci.md
         - Jenkins — rules/generative/platform/ci-cd/providers/jenkins.md
         - TeamCity — rules/generative/platform/ci-cd/providers/teamcity.md
         - Google Cloud Build — rules/generative/platform/ci-cd/providers/google-cloud-build.md
         - Azure Pipelines — rules/generative/platform/ci-cd/providers/azure-pipelines.md
         - AWS CodeBuild/CodePipeline — rules/generative/platform/ci-cd/providers/aws-codebuild-codepipeline.md
     - rules/generative/platform/observability/README.md
     - rules/generative/architecture/README.md
     - rules/generative/architecture/tdd/README.md
     - rules/generative/architecture/bdd/README.md
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
- [ ] Stage 1 (Architecture & Foundations) docs produced and user-approved (STOP gate passed)
- [ ] Stage 2 (Guides & Design Validation) docs produced and user-approved (STOP gate passed)
- [ ] Stage 3 (Implementation Plan) produced and user-approved (STOP gate passed)
- [ ] Stage 4 (Code/Scaffolding) executed only after explicit approval; diffs presented with validation and links
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

## 6) AI Response Format (Stage-Gated)
1) Stage N deliverables (docs or plans only until Stage 4), with file paths and working links
2) Open questions, decisions required, risks
3) STOP — Request explicit approval to proceed to Stage N+1
   - Required approval phrasing: “APPROVED Stage N → Stage N+1”
4) If approved, provide next-stage plan; if not, revise and re-submit Stage N

End of prompt.
## Diagrams and Docs-as-Code Policy (Mandatory)

Purpose
- When adopting the Rules Repository, the existing system must be documented with architecture diagrams and technical flows that are reviewable by humans and consumable by AI.
- These documents are version-controlled first-class artifacts, referenced by this and future prompts for the project.

Required artifacts (Docs-as-Code)
- C4 Architecture Diagrams (text-based)
  - Level 1 (Context): system context and external dependencies
  - Level 2 (Container): major containers/services and responsibilities
  - Level 3 (Component): key components within each container (per bounded context)
  - Optional Level 4 (Code): for deep drill-down where necessary
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
  - Optional rendered images under docs/architecture/img/ derived from sources; do not commit images without sources
- Version control mandate
  - Commit all diagram sources (Mermaid/PlantUML). Images never replace sources.

Adoption specifics (reverse-engineering)
- Inventory the current system, produce C4 L1/L2 from code/services/deploy manifests.
- Establish at least one L3 for a critical bounded context and two key sequence diagrams.
- Draft initial ERD for the core domain from schema/migrations.
- Link all artifacts from docs/architecture/README.md for discoverability.

Prompt seeding and traceability
- Create docs/PROMPT_REFERENCE.md that:
  - Records selected stacks (languages/frameworks/plugins) and glossary composition (topic-first precedence)
  - Links to all diagrams under docs/architecture/
  - Is referenced by future prompts for this project; AI must load and honor it
- Close the documentation loop: PACT ↔ GLOSSARY ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION must reference and reuse these diagrams.

Stage-gates alignment (reinforced)
- Stage 1 (Architecture & Foundations) must produce:
  - C4 L1/L2 and initial L3 for critical bounded contexts
  - Sequence diagrams for at least two key flows
  - Initial ERD for the core domain
  - docs/architecture/README.md and docs/PROMPT_REFERENCE.md
- Stage 2 may refine/extend diagrams; Stage 3/4 must not proceed without Stage 1/2 approval.

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
- These documents are part of all present and future prompts for this project and must remain under version control. Any AI system acting on this repository must load and respect them before proposing or generating code.
