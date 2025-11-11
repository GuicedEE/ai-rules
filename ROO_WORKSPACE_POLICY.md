# Roo Workspace Policy (Pinned)

This repository includes a Roo-focused workspace policy so Roo can operate with the same constraints as other supported AI engines.

Follow these constraints at all times:

1) Repository rules to apply
- RULES.md — 4. Behavioral Agreements
- RULES.md — 5. Technical Commitments
- RULES.md — Document Modularity Policy
- RULES.md — 6. Forward-Only Change Policy (no backwards compatibility)

2) Scope and context
- Operate at the repository root context by default.
- Include file paths in responses when referencing or editing files.
- Close loops across artifacts: Pact ↔ Rules ↔ Guides ↔ Implementation.

3) Forward-only mode
- When a change is requested, apply it fully in one forward-only change: update/remove conflicting documents, anchors, examples, indexes, and links in the same change.
- Do not leave stubs or partial updates. Do not preserve backwards compatibility unless explicitly requested by a host project.

4) Submodule usage
- This repository is typically consumed as a Git submodule from host/client projects.
- Do not place host project artifacts inside the submodule folder. Host artifacts (PACT.md, project RULES.md, GUIDES.md, IMPLEMENTATION.md) must live outside the submodule in the host repo.

5) Component topic indexing
- Topic directories (e.g., generative/frontend/webawesome/, webcomponents/, backend/hibernate/, etc.) provide README.md indexes that link to rule files (e.g., button.rules.md, input.rules.md) and important subsections.
- Navigate via the topic index relevant to the selected framework.

Quick links
- RULES.md — ./RULES.md
- WebAwesome index — ./generative/frontend/webawesome/README.md
- Web Components index — ./generative/frontend/webcomponents/README.md
- Hibernate Reactive index — ./generative/backend/hibernate/README.md
- Platform (observability, security/auth, secrets) — ./generative/platform/README.md

Checklist for Roo sessions
- [ ] Confirm repo context loaded (root) and policy applied
- [ ] Use forward-only edits; update all references in the same change
- [ ] Reference or create files with explicit paths
- [ ] Link back to RULES.md sections when adding guidance
- [ ] For component topics, start at the topic README index

Notes
- Generated artifacts are read-only. Do not propose or perform edits on compiled outputs (bundled TS/HTML/site files).
- For JWebMP, avoid inline string HTML; use JWebMP components instead.
