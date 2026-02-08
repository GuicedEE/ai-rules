# Copilot Workspace Instructions

Apply `AGENTS.md` as canonical policy for this repository.

## Required Inputs

- `RULES.md` sections 4, 5, Document Modularity Policy, and 6
- `README.md`
- `skills.md`
- `.claude/skills/rules-catalog/references/rules-summary.md` when navigating rule coverage

## Routing

- Always start with `.claude/skills/rules-repo-conventions/SKILL.md` and `.claude/skills/rules-catalog/SKILL.md`.
- Route topic work through the domain skills listed in `skills.md`.
- If skills are not auto-discovered, open these skill files directly and continue routing; do not switch to unguided/direct implementation.
- Keep implementation library-first: prefer concrete APIs/SPI contracts from selected topic rules before adding new interfaces.

## Change Policy

- Use documentation-first, stage-gated workflow unless explicitly waived.
- Apply forward-only edits and update all impacted links in the same change.
- After rules updates, run:
  - `.claude/skills/rules-catalog/scripts/build-rules-catalog.sh`
  - `.claude/skills/rules-catalog/scripts/check-rules-catalog.sh`
