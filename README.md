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
- “Hibernate 7 Reactive transactions” → generative/backend/hibernate/hibernate-7-reactive-transactions.md
- “Postgres setup docs” → generative/data/database/postgres-database.md

### Platform guides
- Platform category index — generative/platform/README.md
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
