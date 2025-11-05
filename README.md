# RulesRepository

Enterprise-wide rules and guides for AI-assisted and human development. This repository is designed to be consumed as a Git submodule inside client/host projects. It provides a versioned canonical source of truth for shared rules and guides across the organization.

## Enterprise usage and placement rules

- This repository is an enterprise-wide catalog; consume it as a Git submodule.
- Do not place project-specific rules or documents inside the submodule directory where this repository lives.
- In host projects, put project artifacts (PACT.md, project RULES.md, GUIDES.md, IMPLEMENTATION.md, etc.) outside the submodule (for example, under `docs/` or at the repository root).
- To extend/override guidance, add or update the host project's RULES.md and link to relevant sections in this repository; do not modify files inside the submodule.

### Adding as a submodule (example)

```bash
# Choose an appropriate target folder (e.g., rules/)
git submodule add <RulesRepository repository URL> rules/
git submodule update --init --recursive
```

Then reference content from your project's artifacts using relative links (see Structure of Work below).

## Forward-only change policy (no backwards compatibility)

- By default, AI generation and maintainers must not preserve backwards compatibility when applying requested changes.
- Apply requested changes in full in the same change: update/remove conflicting documents, anchors, examples, indexes, and links.
- Do not leave stubs or partial updates; provide complete, final artifacts for the new state.
- Only maintain compatibility if the request explicitly requires it for a specific client project.

See RULES.md — 6. Forward-Only Change Policy for the authoritative statement.

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
| Rules          | Define technical and stylistic standards per domain.| RULES.md           |
| Guides         | Describe the “how” — scaffolding, step-by-step, and process. | GUIDES.md          |
| Implementation | The tangible code, structure, or design output.    | IMPLEMENTATION.md  |

### Client project setup

- PACT.md
  - Create at the host project root or under `docs/`.
  - Establish shared language, ethos, and continuity for the project.
  - You may draw from or link to the template/ideas in `creative/pact.md` within this repository.
- RULES.md (project-specific)
  - Lives in the host project (outside the submodule).
  - Extends/overrides enterprise rules; link back to specific sections of this submodule (e.g., `/path/to/submodule/RULES.md#section`).
- GUIDES.md (+ guide files)
  - Host project guidance on how to apply rules, scaffolding, and processes.
  - Link back to enterprise guides under the submodule's `generative/` directory where relevant.
- IMPLEMENTATION.md
  - Links to concrete code, structures, and design artifacts.
  - Close the loop by linking back to the rule or guide that justified the implementation.

### Linking guidance (closing loops)

- From PACT → RULES: define the language/ethos that informs your standards.
- From RULES → GUIDES: show how to apply each standard with step-by-step guidance.
- From GUIDES → IMPLEMENTATION: link to the code and design produced.
- From IMPLEMENTATION → back-links: reference the guide and rule that informed the solution.

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
- “React overview” → generative/frontend/react/react-overview.md
- “Web Components in React” → generative/frontend/react/react-web-components.md
- “Next.js overview” → generative/frontend/nextjs/nextjs-overview.md
- “Next.js SSR vs SSG” → generative/frontend/nextjs/nextjs-ssr-ssg.md
- “Next.js security” → generative/frontend/nextjs/nextjs-security.md
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


## Claude Agent Skills (project-scoped)

Claude Code auto-discovers Agent Skills from three sources:
- Personal: ~/.claude/skills/
- Project: .claude/skills/ (this repository includes one for conventions)
- Plugins: bundled with installed plugins

In this repository, we provide a project Skill to help Claude apply the RulesRepository conventions automatically:
- .claude/skills/rules-repo-conventions/SKILL.md

Owner mode (this repository is the active workspace; not used as a submodule):
- Do not refer to this repository as a submodule.
- Claude should load ./skills.md and use project-scoped Skills under .claude/skills/.
- Apply forward-only edits and close loops (Pact ↔ Rules ↔ Guides ↔ Implementation).

Host project mode (downstream projects that consume these rules):
- Use this repository as a Git submodule and link back to it from host artifacts (PACT, RULES, GUIDES, IMPLEMENTATION).

Usage tips:
- Ask: "What Skills are available?" to list discovered Skills.
- Inspect a Skill: open .claude/skills/rules-repo-conventions/SKILL.md
- Claude should load ./skills.md and acknowledge active project Skills when operating in this repo context.

Notes:
- Keep Skills focused; use lowercase-hyphen names and valid YAML frontmatter.
- Prefer relative links and forward-only changes, consistent with RULES.md.
