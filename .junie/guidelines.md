# Junie Guidelines (Pinned)

Apply `AGENTS.md` as canonical policy for this repository.

## Required Rules Anchors

- `RULES.md` section 4 (Behavioral Agreements)
- `RULES.md` section 5 (Technical Commitments)
- `RULES.md` Document Modularity Policy
- `RULES.md` section 6 (Forward-Only Change Policy)

## Workflow Rules

- Use documentation-first, stage-gated delivery by default.
- Offer stage checkpoints unless user explicitly waives them.
- If user waives approvals, continue and document the opt-out.

## Skills and Routing

- Load `skills.md`.
- Start with conventions + catalog skills, then domain routers.
- Use `.claude/skills/rules-catalog/references/` for authoritative lookup.

## Maintenance

After rule changes, run:

```bash
.claude/skills/rules-catalog/scripts/build-rules-catalog.sh
.claude/skills/rules-catalog/scripts/check-rules-catalog.sh
```
