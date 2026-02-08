# 🌱 Starter Prompt — New Spring Project Using the Rules Repository

Ask your AI tool to copy this template and align with the Rules Repository. The AI will scaffold a modular, forward-only documentation structure (Pact → Rules → Guides → Implementation), set up topic indexes, and generate minimal Spring Boot starter code where requested.

Supported: Junie, AI Assistant, GitHub Copilot Chat, Cursor, ChatGPT, Claude, Roo, Codex.

---

## 0) Provide Inputs
Fill before running.
Before proceeding with any other steps, register required MCP servers with your assistant (Mermaid MCP is mandatory) and load the config snippet for the selected engine.

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
  - Skill systems (enabled by default):
    - [x] Provider-agnostic Agent workspace policy (`AGENTS.md`)
    - [x] Claude project Skills (`skills.md` + `.claude/skills/`)
    - [x] Provider workspace adapters (`.github/copilot-instructions.md`, `.cursor/rules.md`, `.junie/guidelines.md`, `.aiassistant/rules/`)
  - Note: Select every AI assistant involved and configure prompts/rules for each engine accordingly.
    - Junie reads workspace rules from `.junie/guidelines.md`; create/update it with RULES.md sections 4/5, Document Modularity, 6 (Forward-Only), and the Junie stage-approval exception before running.
    - AI Assistant reads rules from `.aiassistant/rules/`; mirror enforced policies there so IDE prompts stay aligned.
  - Load the MCP configuration/file for each selected engine before continuing (e.g., `.mcp.json` for OpenAI/Cursor, IDE MCP settings for Claude Desktop) so servers are available to the assistant.
- MCP servers to register (Mermaid MCP required; add others as needed): list name/purpose/endpoint/type (Mermaid MCP `https://mcp.mermaidchart.com/mcp` type `http`). Keep secrets out of the repo; reference env var names instead.

- Architecture:
  - [x] Specification-Driven Design (SDD) (mandatory)
  - [x] Documentation-as-Code (mandatory)
  - [ ] Monolith
  - [ ] Microservices
  - [ ] Micro Frontends
  - [ ] DDD
  - [ ] TDD (docs-first, test-first)
  - [ ] BDD (docs-first, executable specs)
- Language and build selection
  - JVM languages (choose one primary):
    - Java (choose exactly one LTS)
      - [ ] Java 17 LTS
      - [ ] Java 21 LTS
      - [ ] Java 25 LTS
    - [ ] Kotlin
  - Build engines
    - [ ] Maven
    - [ ] Gradle (Groovy DSL)
    - [ ] Gradle (Kotlin DSL)
  - Dependency declarations
    - JVM: record artifact coordinates only (groupId:artifactId:version). Use build-tooling rules for plugin or build script scaffolding.

- Selected tech topics (tick):
  - Spring Boot (Servlet stack):
    - [ ] Core MVC/Web
    - [ ] Validation (Bean Validation)
    - [ ] Data JPA (Hibernate ORM)
    - [ ] Security (Spring Security)
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
  - Data:
    - Activity Master:
      - [ ] Core
      - [ ] Client
      - [ ] Cerial
      - [ ] Cerial Client
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
    - [ ] Fluent API Strategy (choose exactly one):
      - [ ] CRTP
      - [ ] Builder pattern (Lombok @Builder/manual)
  - Testing & Coverage:
    - [ ] Jacoco
    - [ ] SonarQube
    - [ ] Java Micro Harness
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
    - OpenAPI Provider (choose one; default = Swagger via springdoc)
      - [ ] Swagger (default)
      - [ ] MicroProfile OpenAPI
      - [ ] Spring OpenAPI
    - Health endpoints default to Spring Actuator: /actuator/health, /actuator/health/ready, /actuator/health/live
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
- Fluent API Strategy: Choose either CRTP or Builder. Align Lombok usage accordingly:
  - If CRTP: do not use @Builder; implement manual CRTP fluent setters returning (J)this with @SuppressWarnings("unchecked") as needed.
  - If Builder: prefer Lombok @Builder or manual builders; do not apply CRTP chaining rules.
- Spring Boot policy: Use Spring Boot 3.x (Servlet stack) with Java LTS; see [overview-setup.md](rules/generative/backend/spring/overview-setup.md) for module layout and dependencies. Prefer BOM-managed versions over ad-hoc pins.
- Glossary policy (topic-first): Compose the host GLOSSARY.md from topic-scoped glossaries for selected topics. Topic glossaries take precedence over the root glossary. Minimize duplication by linking to each topic’s GLOSSARY.md and rules; copy all Prompt Language Alignment mappings (e.g., WebAwesome) if selected elsewhere.

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
- Workspace instruction file requirement (non-optional):
  - If the assistant has filesystem access, it MUST create/update the workspace instruction files on disk before any Stage 1 outputs.
  - If the assistant cannot write files, it MUST output the full file contents in fenced blocks labeled with the target path so the user can paste them.
  - Always create missing parent directories (`.junie/`, `.github/`, `.cursor/`, `.aiassistant/rules/`, `.claude/skills/`) as needed.
- Agent Skills baseline (enabled by default):
  - Ensure `AGENTS.md` exists and is updated as the canonical provider-agnostic policy.
  - Ensure `skills.md` exists and is pinned for skill routing.
  - Ensure `.claude/skills/` is present and includes at least `rules-repo-conventions` and `rules-catalog`.
  - Ensure provider adapter files exist: `.github/copilot-instructions.md`, `.cursor/rules.md`, `.junie/guidelines.md`, `.aiassistant/rules/00-core.md`, `.aiassistant/rules/10-skills-routing.md`.
  - Validate the baseline with `.claude/skills/rules-catalog/scripts/check-agent-workspaces.sh` and `.claude/skills/rules-catalog/scripts/check-rules-catalog.sh`.
- AI workspace files (enabled by default; also verify selected engines):
  - Junie: ensure `.junie/guidelines.md` exists and is updated with RULES.md sections 4/5, Document Modularity, 6 (Forward-Only), and the Junie stage-approval bypass; confirm Junie loads it before generation.
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
  - Load and pin ./AGENTS.md first, then ./skills.md.
  - Start with system note: "Follow Rules Repository RULES.md sections 4,5, Document Modularity, and 6 (forward-only). Close loops across artifacts."
  - Owner mode (this Rules Repository repository is the active workspace; not used as a submodule):
    - Do not refer to this repository as a submodule.
    - Load and pin ./AGENTS.md and ./skills.md; use project-scoped Skills under .claude/skills/.
  - Host project mode (a downstream project adopting these rules):
    - Use this repository as a Git submodule and link to it from host artifacts.
  - For Claude specifically: load and pin ./AGENTS.md and ./skills.md; discover project Agent Skills under .claude/skills/ (auto-discovered by Claude Code); acknowledge which Skills are active and apply them throughout generation.
- For Codex CLI (Codex agent):
  - Load and pin ./AGENTS.md, ./skills.md, and ./RULES.md anchors plus README context; confirm forward-only and Document Modularity constraints are pinned in the Codex CLI workspace.
  - Follow Codex CLI harness instructions: run shell commands with `bash -lc` and explicit `workdir`, prefer `rg` for scans, honor sandbox/approval settings, and use the plan tool for multi-step work.
- For Roo: load and pin [ROO_WORKSPACE_POLICY.md](rules/ROO_WORKSPACE_POLICY.md). If it does not exist, create it with a summary of RULES.md sections 4,5, Document Modularity Policy, and 6 (Forward-Only). Ensure repo-scoped conversations, include file paths in responses, and confirm forward-only mode is enabled. Update all references affected by a change in the same forward-only change set.

Language selection → generation rules
- If Java 17/21/25 is selected:
  - Apply the corresponding LTS rules and toolchains — [java-17.rules.md](rules/generative/language/java/java-17.rules.md), [java-21.rules.md](rules/generative/language/java/java-21.rules.md), [java-25.rules.md](rules/generative/language/java/java-25.rules.md).
  - Include build integration via [build-tooling.md](rules/generative/language/java/build-tooling.md).
- If Kotlin is selected:
  - Include language rules link: [Kotlin README](rules/generative/language/kotlin/README.md).
- Spring Boot (Servlet) selections:
  - Use [Spring overview and setup](rules/generative/backend/spring/overview-setup.md) for module layout, BOM usage, and starter dependencies.
  - For OpenAPI, align to [openapi-springdoc.md](rules/generative/backend/spring/openapi-springdoc.md).
  - For observability and ops endpoints, align to [actuator-observability.md](rules/generative/backend/spring/actuator-observability.md).
  - For data and migrations, align to [data-jpa-transactions.md](rules/generative/backend/spring/data-jpa-transactions.md) and [database-migrations.md](rules/generative/backend/spring/database-migrations.md).

---

## 2) Project Plan (AI must draft first)
Produce a short plan with:
- Scopes selected (languages, frameworks, structural, platform).
- Initial repository structure (packages, modules), build tool, CI, env files, docs (PACT, RULES, GUIDES, IMPLEMENTATION, GLOSSARY).
- Actions: initialize repo; add Rules Repository submodule; create modular docs; set up Spring Boot skeletons; update links; CI/env alignment.
- Risk notes: any forward-only decisions affecting defaults.

When approved, execute the plan as one change set.

---

## 3) Required Artifacts
1. Initialize repository and add the Rules Repository submodule at rules/ (or docs/rules-repository) and document usage in README.
2. Create PACT.md (root or docs/) starting from [creative/pact.md](rules/creative/pact.md). Fill project details and cross-links.
3. Create root GLOSSARY.md
   - Compose from topic glossaries (topic-first). For each selected topic, link to its topic GLOSSARY.md and adopt its canonical terms; these take precedence over root terms for that scope.
   - Copy only enforced Prompt Language Alignment mappings into the host glossary (e.g., WebAwesome: WaButton/WaInput/WaCluster/WaStack if that topic is in play). For all other terms, link to the topic file/anchor instead of duplicating definitions.
   - Document a “Glossary Precedence Policy”: topic glossaries override root for their scope; the host GLOSSARY.md acts as an index and aggregator with minimal duplication and LLM interpretation guidance (e.g., CRTP vs Builder routing, JSpecify defaults).
4. Create project RULES.md (outside submodule):
   - Declare scope, chosen stacks, plugin selections (if any), and project-specific conventions.
   - Link topic indexes:
     - Backend (Spring Boot, servlet stack) — [README](rules/generative/backend/spring/README.md)
     - Hibernate (ORM/Reactive) — [README](rules/generative/backend/hibernate/README.md)
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
5. Create GUIDES.md with links to chosen modular entries (e.g., Spring MVC REST + validation; Spring Data JPA transactions; Actuator/observability; springdoc/OpenAPI; security flows). Use glossary-aligned terms consistently.
6. Create IMPLEMENTATION.md explaining current modules, code layout, and back-links to guides. Ensure implementation names and labels adhere to GLOSSARY.md.
7. Environment alignment
   - Create .env.example per [env-variables.md](rules/generative/platform/secrets-config/env-variables.md).
8. CI alignments
   - Add/update minimal CI workflows; enumerate required secrets.
9. README updates
   - State adoption of Rules Repository, link submodule path, and link PACT/RULES/GUIDES/IMPLEMENTATION/GLOSSARY. Note Java LTS and Spring Boot selections.
10. AI workspace alignment (enabled by default + selected engines)
    - Agent Skills baseline (default-on):
      - `AGENTS.md`
      - `skills.md` + `.claude/skills/` (ensure `rules-repo-conventions` and `rules-catalog` are active)
    - Junie — `.junie/guidelines.md` with RULES.md sections 4/5, Document Modularity, 6 (Forward-Only), and the Junie stage-approval exception.
    - AI Assistant — `.aiassistant/rules/` with RULES.md sections 4/5, Document Modularity, and Forward-Only.
    - GitHub Copilot — `.github/copilot-instructions.md` (or workspace note) covering the same constraints and STOP-gate policy.
    - Cursor — `.cursor/rules.md` mirroring the same constraints.
    - Roo — [ROO_WORKSPACE_POLICY.md](rules/ROO_WORKSPACE_POLICY.md) present/pinned if Roo is selected.

- WebAwesome prompt language alignment (only if selected)
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
- [ ] Project RULES.md present, linking to enterprise RULES and topic indexes (Spring + structural)
- [ ] Fluent API Strategy declared (CRTP vs Builder) and reflected in RULES.md and GLOSSARY.md; Lombok usage aligned to selection
- [ ] GLOSSARY.md composed topic-first: links to selected topic glossaries; Glossary Precedence Policy documented; minimal duplication; enforced mappings copied
- [ ] GUIDES.md and IMPLEMENTATION.md present with back/forward links
- [ ] .env.example aligned to env-variables.md
- [ ] CI updated/added
- [ ] Spring Boot selections recorded (Java LTS, servlet stack) and links resolve
- [ ] MCP servers configured (config snippet provided), registered for selected assistants (Mermaid MCP for docs/diagrams), and acknowledged in outputs
- [ ] Agent workspace + Claude Skills baseline enabled by default (AGENTS.md, skills.md, .claude/skills/, .github/copilot-instructions.md, .cursor/rules.md, .junie/guidelines.md, .aiassistant/rules/, ROO_WORKSPACE_POLICY.md if Roo)
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
