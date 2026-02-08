# Agent Workspace Policy

This file is the provider-agnostic entrypoint for agent behavior in this repository.

## Required Context

Before producing outputs, load and pin:

1. `RULES.md` (sections 4, 5, Document Modularity Policy, and 6)
2. `README.md` (owner-mode workflow and navigation)
3. `skills.md` (project skills catalog)
4. `ROO_WORKSPACE_POLICY.md` when Roo is the active engine

## Skill Activation Order

Use this order for skill activation in owner mode:

1. `.claude/skills/rules-repo-conventions/SKILL.md`
2. `.claude/skills/rules-catalog/SKILL.md`
3. Domain routers as needed:
   - `.claude/skills/rules-frontend/SKILL.md`
   - `.claude/skills/rules-backend/SKILL.md`
   - `.claude/skills/rules-data/SKILL.md`
   - `.claude/skills/rules-platform/SKILL.md`
   - `.claude/skills/rules-language/SKILL.md`
   - `.claude/skills/rules-architecture/SKILL.md`

## Non-Negotiable Rules

- Operate in forward-only mode for requested changes.
- Close loops between `PACT ↔ GLOSSARY ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION`.
- Apply documentation-first, stage-gated workflow unless the user explicitly waives stage checkpoints.
- Keep links relative and update all affected references in the same change.

## Catalog Maintenance

When rules files are added/removed/moved, run:

```bash
.claude/skills/rules-catalog/scripts/build-rules-catalog.sh
.claude/skills/rules-catalog/scripts/check-rules-catalog.sh
```

## Provider Adapters

- Claude Code: `.claude/skills/**` + `skills.md`
- GitHub Copilot: `.github/copilot-instructions.md`
- Cursor: `.cursor/rules.md`
- Junie: `.junie/guidelines.md`
- AI Assistant: `.aiassistant/rules/`
- Roo: `ROO_WORKSPACE_POLICY.md`
- Codex CLI: `AGENTS.md` + `RULES.md` + `README.md` + `skills.md`
