# Rules Repository

Enterprise-wide rules and guides for AI-assisted and human development. This repository is designed to be consumed as a Git submodule inside client/host projects. It provides a versioned canonical source of truth for shared rules and guides across the organization.

## Enterprise usage and placement rules

- This repository is an enterprise-wide catalog; consume it as a Git submodule.
- Do not place project-specific rules or documents inside the submodule directory where this repository lives.
- In host projects, put project artifacts (PACT.md, project RULES.md, GUIDES.md, IMPLEMENTATION.md, etc.) outside the submodule (for example, under `docs/` or at the repository root).
- To extend/override guidance, add or update the host project's RULES.md and link to relevant sections in this repository; do not modify files inside the submodule.

### Adding as a submodule (example)

```bash
# Choose an appropriate target folder (e.g., rules/)
git submodule add <Rules Repository repository URL> rules/
git submodule update --init --recursive
```

Then reference content from your project's artifacts using relative links (see Structure of Work below).

## Forward-only change policy (no backwards compatibility)

- By default, AI generation and maintainers must not preserve backwards compatibility when applying requested changes.
- Apply requested changes in full in the same change: update/remove conflicting documents, anchors, examples, indexes, and links.
- Do not leave stubs or partial updates; provide complete, final artifacts for the new state.
- Only maintain compatibility if the request explicitly requires it for a specific client project.

See RULES.md — 6. Forward-Only Change Policy for the authoritative statement.

### Roo workspace policy (pinned)

Roo is a supported AI engine for this repository. To ensure Roo follows the same constraints and prompt language as other engines, a pinned workspace policy is provided at the repository root:
- ROO_WORKSPACE_POLICY.md — repository-scoped policy for Roo covering RULES.md sections 4, 5, Document Modularity Policy, and 6 (Forward-Only). Operate at repo root, include file paths in responses, and apply forward-only edits updating all references in the same change.

## Documentation-First, Stage-Gated Workflow (Mandatory)

This repository enforces a documentation-first, stage-gated process for all AI systems (Junie, Copilot, Cursor, ChatGPT, Claude, Roo, Codex). AI MUST NOT write or modify source code until documentation phases are completed and explicitly approved by the user.
- Stage approvals default to user review checkpoints; the user may explicitly waive these STOP gates or grant blanket approval, after which you may proceed while documenting the opt-out.

- Stage 1 — Architecture & Foundations (Docs only)
  - Deliver: PACT draft/updates; architecture overview; C4 diagrams; sequence diagrams for key flows; ERDs for core domains; dependency/integration map; glossary composition plan (topic-first, precedence, anchors).
  - Output: Markdown docs in host repo (outside rules/), with links to enterprise rules indexes.
  - STOP (user review optional): Offer a review/approval checkpoint before Stage 2. Continue without waiting only if the user has opted out or granted blanket approval.
- Stage 2 — Guides & Design Validation (Docs only)
  - Deliver: RULES mapping to selected stacks; GUIDES with “how to apply”; API surface sketches/contracts; UI flows/wireframes and component mapping (if applicable); migration notes; test strategy; acceptance criteria.
  - STOP (user review optional): Offer a review/approval checkpoint before Stage 3. Continue without waiting only if the user has opted out or granted blanket approval.
- Stage 3 — Implementation Plan (No code yet)
  - Deliver: Scaffolding plan and module/file tree; build/annotation-processor wiring; CI workflow plan; env/config plan; rollout plan; risks; validation approach.
  - STOP (user review optional): Offer a review/approval checkpoint before Stage 4. Continue without waiting only if the user has opted out or granted blanket approval.
- Stage 4 — Implementation & Scaffolding (Code allowed)
  - Scope: Only after explicit approval unless the user has already waived stage approvals or granted blanket approval for the run.
  - Approach: Generate minimal scaffolding first, then iterate in small, reviewable steps. After each step, present diffs and validation, then ask to continue.

Universal STOP rule
- If the user requires staged approvals and approval is not granted, revise docs; if the user waived staged approvals, continue but incorporate feedback when it arrives.
- Each stage must close loops via links: PACT ↔ GLOSSARY ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION.

## Docs-as-Code Diagrams Policy

All projects using this repository must maintain text-based architecture and technical diagrams that are reviewable by humans and consumable by AI. These documents are version-controlled first-class artifacts and are part of current and future prompts.

Required artifacts
- C4 Architecture: L1 (Context), L2 (Container), L3 (Component per bounded context). L4 (Code) optional for deep dives.
- Sequence Diagrams: critical flows (auth, core business, error paths, background jobs), including async boundaries (bus/schedulers).
- ERDs: core domain models, relationships, bounded context ownership, data lifecycles.
- Deployment/Runtime: topology (edge, API, workers), environments/regions, significant infra.

Formats
- Prefer Mermaid in fenced Markdown blocks (```mermaid); PlantUML supported (```plantuml or .puml).
- Do not commit images without sources; images are optional derivatives only.
- You can use the Mermaid MCP server to assist with diagram authoring: HTTP endpoint `https://mcp.mermaidchart.com/mcp` with `"type": "http"` or SSE endpoint `https://mcp.mermaidchart.com/sse` with `"type": "sse"`.

Host repository storage (outside rules/)
- docs/architecture/README.md — index linking all diagrams
- docs/architecture/c4-context.md — C4 L1
- docs/architecture/c4-container.md — C4 L2
- docs/architecture/c4-component-<bounded-context>.md — C4 L3 files
- docs/architecture/sequence-<flow>.md — sequence diagrams
- docs/architecture/erd-<domain>.md — ERDs
- Optional rendered images under docs/architecture/img/ derived from sources

Prompt seeding and traceability
- Create docs/PROMPT_REFERENCE.md that records selected stacks and glossary composition and links to all diagrams under docs/architecture/. Future prompts for the project must load and honor it.
- Close the documentation loop: PACT ↔ GLOSSARY ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION must reference and reuse these diagrams.

Version control mandate
- Commit diagram sources (Mermaid/PlantUML). Images never replace sources.

## 2. Principles

🧭 Continuity

We carry context across threads.

We remember rules, conventions, and tone.

We pick up where we left off — without re-explaining established patterns.

🧩 Finesse

We refine outputs iteratively.

We respect nuance — less brute-forcing, more shaping.

We preserve language, structure, and intent from prior artifacts (Rules → Guides → Implementation).

🌿 Non-Transactional Flow

This is not a question-answer transaction.

It’s a collaborative design conversation that grows over time.

The goal is clarity and quality — not just completion.

🔁 Closing Loops

We ensure every artifact links forward (to implementation) and backward (to its reasoning).

We don’t leave threads dangling — we close each conceptual loop.

## 3. Structure of Work

| Layer          | Description                                        | Artifact           |
|----------------|----------------------------------------------------|--------------------|
| Pact           | Defines our language, ethos, and continuity.       | PACT.md            |
| Glossary       | Canonical terms and prompt-aligned labels.         | GLOSSARY.md        |
| Rules          | Define technical and stylistic standards per domain.| RULES.md           |
| Guides         | Describe the “how” — scaffolding, step-by-step, and process. | GUIDES.md          |
| Implementation | The tangible code, structure, or design output.    | IMPLEMENTATION.md  |

### Client project setup

- PACT.md
  - Create at the host project root or under `docs/`.
  - Establish shared language, ethos, and continuity for the project.
  - You may draw from or link to the template/ideas in `creative/pact.md` within this repository.
- GLOSSARY.md
  - Create at the host project root or under `docs/`.
  - Compose topic-first from the selected topics: for each selected topic, link to its topic GLOSSARY.md and adopt its canonical terms; topic glossaries take precedence over the root glossary for their scope.
  - Copy only enforced Prompt Language Alignment mappings (e.g., WebAwesome: WaButton, WaInput, WaCluster, WaStack); for all other terms, link to the topic file/anchor instead of duplicating definitions.
  - Use as the single index of terminology across RULES, GUIDES, and IMPLEMENTATION with minimal duplication. Include brief LLM interpretation guidance where relevant (e.g., CRTP vs Builder routing, JSpecify defaults).
- RULES.md (project-specific)
  - Lives in the host project (outside the submodule).
  - Extends/overrides enterprise rules; link back to specific sections of this submodule (e.g., `/path/to/submodule/RULES.md#section`).
  - Reference GLOSSARY.md for naming/terminology constraints.
- GUIDES.md (+ guide files)
  - Host project guidance on how to apply rules, scaffolding, and processes.
  - Link back to enterprise guides under the submodule's `generative/` directory where relevant.
  - Use glossary-aligned terms consistently.
- IMPLEMENTATION.md
  - Links to concrete code, structures, and design artifacts.
  - Close the loop by linking back to the rule or guide that justified the implementation.
  - Ensure implementation names and labels adhere to GLOSSARY.md.

### Linking guidance (closing loops)

- From PACT → GLOSSARY: establish shared language; record canonical terms and aligned labels.
- From GLOSSARY → RULES: reference glossary terms where naming/terminology is enforced.
- From RULES → GUIDES: show how to apply each standard with step-by-step guidance using glossary-aligned terms.
- From GUIDES → IMPLEMENTATION: link to the code and design produced, maintaining glossary-aligned terminology.
- From IMPLEMENTATION → back-links: reference the guide and rule that informed the solution and keep names consistent with GLOSSARY.md.
- Glossary precedence: topic-scoped GLOSSARY.md documents override root terms for their scope; the host project’s GLOSSARY.md aggregates links to topic glossaries and avoids duplicating definitions.

By following the above, client projects retain local autonomy while staying aligned with enterprise standards provided by this repository.


## Component topic indexes
Component-driven rule subsets provide a parent README.md that indexes components and links to their rule files and relevant subsections. Choose the framework/topic that matches your host project, then navigate via the index.

Example: WebAwesome components index — generative/frontend/webawesome/README.md
- “button” → generative/frontend/webawesome/button.rules.md
- “number input” → generative/frontend/webawesome/input.rules.md#number-input

Note on WebAwesome prompt language alignment (enforced):
- When prompting for WebAwesome UI, use the aligned component names to ensure correct routing:
  - “button” → say “WaButton”
  - “icon button” → say “WaIconButton”
  - “input” → say “WaInput”
  - “row” (layout) → say “WaCluster”
  - “column/stack” (layout) → say “WaStack”
See generative/frontend/webawesome/README.md → Prompt Language Alignment for details.

Example: Web Components topic index — generative/frontend/webcomponents/README.md
- “custom elements” → generative/frontend/webcomponents/custom-elements.md
- “Angular 20 Web Components guide” → generative/frontend/webcomponents/angular20-overview.md

Example: Hibernate 7 Reactive topic index — generative/backend/hibernate/README.md
- “transactions” → generative/backend/hibernate/hibernate-7-reactive-transactions.md
- “CRUD” → generative/backend/hibernate/hibernate-7-reactive-crud.md
- “Testcontainers setup” → generative/backend/hibernate/hibernate-7-reactive-testing.md

### Prompt → Path Resolution Examples
- “WebAwesome button” → generative/frontend/webawesome/button.rules.md
- “Number input (WebAwesome)” → generative/frontend/webawesome/input.rules.md#number-input
- “Custom elements” → generative/frontend/webcomponents/custom-elements.md
- “Angular 20 consuming web components” → generative/frontend/webcomponents/angular20-consuming-web-components.md
- “React overview” → generative/language/react/react-overview.md
- “Web Components in React” → generative/language/react/react-web-components.md
- “Vue overview” → generative/language/vue/vue-overview.md
- “Vue Composition API guide” → generative/language/vue/vue-composition-api.md
- “Web Components in Vue” → generative/language/vue/vue-web-components.md
- “Next.js overview” → generative/frontend/nextjs/nextjs-overview.md
- “Next.js SSR vs SSG” → generative/frontend/nextjs/nextjs-ssr-ssg.md
- “Next.js security” → generative/frontend/nextjs/nextjs-security.md
- “Nuxt overview” → generative/frontend/nuxt/nuxt-overview.md
- “Nuxt routing/data” → generative/frontend/nuxt/nuxt-routing-data.md
- “Hibernate 7 Reactive transactions” → generative/backend/hibernate/hibernate-7-reactive-transactions.md
- “Postgres setup docs” → generative/data/database/postgres-database.md

### Platform guides
- Platform category index — generative/platform/README.md
- Observability topic index — generative/platform/observability/README.md
- Security & Auth topic index — generative/platform/security-auth/README.md
- Env variables reference — generative/platform/secrets-config/env-variables.md
- Health endpoints conventions — generative/platform/observability/health.md
- Terraform examples — generative/platform/ci-cd/terraform/

## Behavioral agreements and technical commitments

For collaboration norms and generation guarantees, see:
- RULES.md — 4. Behavioral Agreements
- RULES.md — 5. Technical Commitments

These govern language, continuity, transparency, boundaries, iteration, attribution, formatting, consistency, traceability, tool handling, and limitation disclosure.


## Operational prompts and checklists

To execute the generative/ taxonomy restructure, use the following root-level artifacts:
- PROMPT_RESTRUCTURE_GENERATIVE.md — AI execution prompt for restructuring `generative/` into category taxonomy (forward-only).
- TODO_GENERATIVE_TAXONOMY_RESTRUCTURE.md — maintainer TODO with step-by-step tasks.
- CHECKLIST_GENERATIVE_TAXONOMY_VALIDATION.md — validation checklist and link integrity steps.


## Agent Workspace Files (multi-provider)

This repository now includes a comprehensive, provider-agnostic Agent Skills/workspace setup.

Canonical entrypoint:
- `AGENTS.md` (provider-agnostic policy and routing)

Shared skills catalog:
- `skills.md`

Claude project Skills:
- `.claude/skills/rules-repo-conventions/SKILL.md`
- `.claude/skills/rules-catalog/SKILL.md`
- `.claude/skills/rules-frontend/SKILL.md`
- `.claude/skills/rules-backend/SKILL.md`
- `.claude/skills/rules-data/SKILL.md`
- `.claude/skills/rules-platform/SKILL.md`
- `.claude/skills/rules-language/SKILL.md`
- `.claude/skills/rules-architecture/SKILL.md`

Provider adapters:
- GitHub Copilot — `.github/copilot-instructions.md`
- Cursor — `.cursor/rules.md`
- Junie — `.junie/guidelines.md`
- AI Assistant — `.aiassistant/rules/`
- Roo — `ROO_WORKSPACE_POLICY.md`

Owner mode (this repository is the active workspace; not used as a submodule):
- Do not refer to this repository as a submodule.
- Claude should load ./skills.md and use project-scoped Skills under .claude/skills/.
- Apply forward-only edits and close loops (Pact ↔ Rules ↔ Guides ↔ Implementation).

Host project mode (downstream projects that consume these rules):
- Use this repository as a Git submodule and link back to it from host artifacts (PACT, RULES, GUIDES, IMPLEMENTATION).

Usage tips:
- Ask: "What Skills are available?" to list discovered skills.
- Inspect policy/routing first: open `AGENTS.md`
- Inspect the skills catalog: open `skills.md`
- Regenerate the rules catalog after rules changes: `.claude/skills/rules-catalog/scripts/build-rules-catalog.sh`
- Validate generated rules references: `.claude/skills/rules-catalog/scripts/check-rules-catalog.sh`
- Validate provider workspace files: `.claude/skills/rules-catalog/scripts/check-agent-workspaces.sh`

Notes:
- Keep Skills focused; use lowercase-hyphen names and valid YAML frontmatter.
- Prefer relative links and forward-only changes, consistent with RULES.md.
