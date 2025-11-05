# 🚀 Starter Prompt — New Project Scaffolding with RulesRepository

This is a paste-into-your-AI prompt for creating a brand-new project aligned to the RulesRepository enterprise rules. It scaffolds Pact → Rules → Guides → Implementation, configures the chosen AI engine, and links in the RulesRepository submodule.

Use this prompt with: JetBrains AI (Junie), GitHub Copilot Chat, Cursor, ChatGPT, Claude, Roo.

---

## 0) Provide Inputs
Fill in the fields below before running the prompt.

- Organization: <ORG_NAME>
- Project name: <PROJECT_NAME>
- Short description: <ONE_LINE_DESCRIPTION>
- Repository host + URL: <GIT_HOST>/<REPO_URL>
- License: <LICENSE> (e.g., Apache-2.0)
- Primary languages: <LANGUAGES> (e.g., Java 21, TypeScript)
- Tech stack (tick all that apply):
  - Backend Reactive: [ ] Vert.x 5  [ ] Hibernate Reactive 7
  - Security (Reactive): [ ] Vert.x Web Auth/JWT/OAuth2
  - Security/Auth Providers: [ ] OpenID Connect (generic)  [ ] GCP (IAP/OIDC)  [ ] Firebase Auth  [ ] Microsoft Entra ID (Azure AD)
  - Structural: [ ] MapStruct  [ ] Lombok  [ ] Logging  [ ] JSpecify
  - Frontend (Standard): [ ] Web Components  [ ] JWebMP  [ ] WebAwesome
  - Frontend (Reactive): [ ] Angular 20  [ ] React  [ ] Next.js
  - Infra/CI: [ ] GitHub Actions  [ ] Terraform  [ ] GCP Cloud Run
  - Database: [ ] PostgreSQL  [ ] MySQL  [ ] Other: <DB_OTHER>
  - Observability/Diagnostics: [ ] Health endpoints  [ ] Tracing  [ ] OpenAPI map  [ ] Wireshark
- Architecture: [ ] Monolith  [ ] Microservices  [ ] Micro Frontends  [ ] DDD
- Security: [ ] Keycloak (OIDC) Realm: <REALM>  Issuer: <ISSUER_URL>
- AI engine used: [ ] JetBrains Junie  [ ] GitHub Copilot  [ ] Cursor  [ ] ChatGPT  [ ] Claude  [ ] Roo
- Authors: ["<YOUR_NAME>", "AI"]

Constraints and policies (do not change):
- Use Markdown for docs. Respect RulesRepository RULES.md sections: Behavioral Agreements, Technical Commitments, Document Modularity Policy, and 6. Forward-Only Change Policy (no backwards compatibility).
- Do not place project-specific docs inside the RulesRepository submodule directory.
- Generated artifacts are read-only. Do not propose or perform edits on compiled outputs (e.g., TS/HTML/site bundles). For JWebMP projects specifically, do not generate or reference separate TS/HTML components for missing views; render dialogs/tables directly from Java (cell renderers/components).
- In JWebMP, avoid inline string HTML; express markup using JWebMP components (Div, Paragraph, Span, Table, H1–H6, etc.).
- PostgreSQL (JPMS): Do not shade the driver. Use GuicedEE Services artifacts (com.guicedee.services:postgresql) and require org.postgresql in module-info.java.

---

## 1) Self‑Configure the AI Engine
The AI must configure itself for this workspace before generating files.

- If JetBrains AI (Junie):
  - Load repository context. Pin links to ./RULES.md#4-behavioral-agreements, ./RULES.md#5-technical-commitments, ./RULES.md#document-modularity-policy, ./RULES.md#6-forward-only-change-policy.
  - Adopt forward-only edits. Close loops: PACT ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION.

- If GitHub Copilot Chat:
  - Create a workspace note/pinned message: "Follow repo RULES.md (sections 4,5, Document Modularity, 6). No backwards compatibility. Use submodule model."
  - Prefer conversations scoped to the repository root, include file paths in responses.

- If Cursor:
  - Create .cursor/rules.md with links to RULES.md sections above and a reminder: “No BC, update all references in each change”.
  - Enable Repo Map and include this prompt in the session context.

- If ChatGPT/Claude:
  - Start with system note: "Follow RulesRepository RULES.md sections 4,5, Document Modularity, and 6 (forward-only). Close loops across artifacts."
  - Owner mode (this RulesRepository repository is the active workspace; not used as a submodule):
    - Do not refer to this repository as a submodule.
    - Load and pin ./skills.md; use project-scoped Skills under .claude/skills/.
  - Host project mode (a downstream project consuming these rules):
    - Use this repository as a Git submodule and link to it from host artifacts.
  - For Claude specifically: load and pin ./skills.md; discover project Agent Skills under .claude/skills/ (auto-discovered by Claude Code); acknowledge which Skills are active and apply them throughout generation.

- If Roo:
  - Create a workspace policy note pinned to the repository root summarizing: follow RULES.md sections 4,5, Document Modularity Policy, and 6 (Forward-Only). No backwards compatibility; update all references in the same change.
  - Ensure conversations are scoped to the repository root and include file paths in responses. Confirm repo context is loaded and forward-only mode is enabled.

Outcome: AI confirms it has applied these constraints.

---

## 2) Scaffolding Tasks (Generate and Apply)
Produce the following changes as a single, forward-only change set.

1. Add Rules Repository as a Git submodule
   - Target path suggestion: rules/ or docs/rules-repository
   - Example:
     - git submodule add <THIS_REPO_URL> rules/
     - git submodule update --init --recursive
   - Document this in README.md under "Enterprise rules submodule".

2. Create core artifacts in the host project (outside submodule)
   - PACT.md — derive from rules/creative/pact.md, substitute fields (project name, authors, date). Keep section mapping to RULES and GUIDES.
   - RULES.md (project-specific) — extend the enterprise RULES:
     - Declare project scope, overrides, chosen stacks.
     - Link to submodule topics you selected (examples below).
   - GUIDES.md — entry index for project guides:
     - Backend picks: link to rules/generative/backend/hibernate/README.md, rules/generative/architecture/ddd/, etc.
     - Frontend picks: link to rules/generative/frontend/react/README.md, rules/generative/frontend/nextjs/README.md, rules/generative/frontend/webcomponents/README.md, or rules/generative/frontend/webawesome/README.md.
   - IMPLEMENTATION.md — describe initial modules, code layout, and back-links to relevant guides.

3. Establish directory structure
   - /docs/ (project docs including PACT.md, RULES.md, GUIDES.md, IMPLEMENTATION.md if you prefer under docs/)
   - /backend/ or /service-<name>/ (if microservices) with src layout
   - /frontend/ (Angular/Web Components) if applicable
   - /infrastructure/terraform/ (optional)
   - Ensure README.md links to each artifact and the submodule.

4. Environment and configuration
   - Copy or reference env variables: rules/generative/platform/secrets-config/env-variables.md
   - Create .env.example aligned with env-variables.md

5. CI/CD (if selected)
   - Add a minimal GitHub Actions workflow (e.g., build/test) and document secrets.

6. Topic-specific link wiring (examples)
  - Web Components
    - rules/generative/frontend/webcomponents/README.md
    - custom-elements.md, shadow-dom.md, html-templates.md, es-modules.md
  - Angular 20 + Web Components
    - angular20-overview.md, angular20-producing-web-components.md, angular20-consuming-web-components.md, microfronts-overview.md
  - React
    - rules/generative/frontend/react/README.md
    - react-overview.md, react-web-components.md, react-ssr-options.md
  - Next.js (App Router)
    - rules/generative/frontend/nextjs/README.md
    - nextjs-overview.md, nextjs-routing-data.md, nextjs-ssr-ssg.md, nextjs-web-components.md, nextjs-security.md
  - Hibernate 7 Reactive
    - rules/generative/backend/hibernate/README.md and modular entries (setup, transactions, CRUD, testing, threading, anti-patterns)
  - WebAwesome components
    - rules/generative/frontend/webawesome/README.md (e.g., button.rules.md, input.rules.md#number-input)
  - Observability
    - rules/generative/platform/observability/README.md
    - health.md, tracing.md, openapi-map.md, wireshark.md

- WebAwesome prompt language alignment (if selected)
  - When prompting, use WebAwesome component names to enforce alignment:
    - “button” → say “WaButton” (see rules/generative/frontend/webawesome/button.rules.md)
    - “icon button” → say “WaIconButton” (see rules/generative/frontend/webawesome/icon-button.rules.md)
    - “input” → say “WaInput” (see rules/generative/frontend/webawesome/input.rules.md)
    - “row” (layout) → say “WaCluster”
    - “column/stack” (layout) → say “WaStack”
  - If a variant has no dedicated file, link to the subsection under the broader rule (e.g., WaInput → #number-input).
  - Security (Reactive)
    - rules/generative/backend/security-reactive/README.md
  - Platform Security & Auth (OIDC/GCP/Firebase/Microsoft)
    - rules/generative/platform/security-auth/README.md
  - Architecture
    - rules/generative/architecture/README.md
    - ddd/README.md, microfronts/README.md
  - Data
    - rules/generative/data/README.md
    - activity-master/README.md

7. Licensing and repo housekeeping
   - Ensure LICENSE is set (<LICENSE>)
   - Add .editorconfig and .gitattributes (optional)

8. README.md (root) — update
   - Project overview, architecture choice, selected tech stack
   - “Structure of Work” table (Pact → Rules → Guides → Implementation)
   - Link to the RulesRepository submodule and to local artifacts

---

## 3) Output Checklist (AI must confirm)
- [ ] Submodule added and referenced in README
- [ ] PACT.md created with project details and cross-links
- [ ] Project RULES.md created referencing enterprise RULES and chosen topics
- [ ] GUIDES.md and IMPLEMENTATION.md created with proper back/forward links
- [ ] Env: .env.example or env notes aligned to rules/generative/platform/secrets-config/env-variables.md
- [ ] CI file added (if selected)
- [ ] README updated with architecture, links, and instructions
- [ ] All links resolve; no files placed inside the submodule directory

---

## 4) Guardrails (Do Not Skip)
- Follow RULES.md → 4. Behavioral Agreements, 5. Technical Commitments, Document Modularity Policy, and 6. Forward-Only Change Policy.
- No backwards compatibility stubs; apply the requested new structure in full.
- Every artifact must link back to its parent layer (close loops).

---

## 5) AI Response Format
When you execute this prompt, reply with:
1) Summary plan (bullet points)
2) Proposed file/diff list
3) Any clarifying questions about inputs
4) Then produce the files and updated README content

End of prompt.