# Cursor Rules

Apply `AGENTS.md` as canonical policy for this repository.

## Required Inputs

- `RULES.md` sections 4, 5, Document Modularity Policy, and 6
- `README.md`
- `skills.md`
- `.claude/skills/rules-catalog/references/rules-inventory.md` for file-level routing

## Skill Routing

- Start with:
  - `.claude/skills/rules-repo-conventions/SKILL.md`
  - `.claude/skills/rules-catalog/SKILL.md`
- Then activate domain routers from `skills.md`.

## Operational Constraints

- Documentation-first, stage-gated workflow unless waived.
- Forward-only updates; update affected references in the same change.
- Regenerate and verify the rules catalog after structural rule changes.
