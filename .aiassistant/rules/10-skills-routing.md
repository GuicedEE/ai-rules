# AI Assistant Skill Routing

Use the same skill graph used by Claude Agent Skills.

## Activation Sequence

1. `.claude/skills/rules-repo-conventions/SKILL.md`
2. `.claude/skills/rules-catalog/SKILL.md`
3. Domain router skills from `skills.md`

## Fallback Behavior (Mandatory)

- If the runtime reports no matching session skill, do not stop at that result.
- Open the required skill files from `skills.md` directly and continue routing.
- Do not end with a "no session skill matched, direct implementation used" decision.
- Keep implementation library-first: use selected-topic concrete library APIs/SPI contracts before adding new interfaces.

## References

- Rules summary: `.claude/skills/rules-catalog/references/rules-summary.md`
- Rule inventory: `.claude/skills/rules-catalog/references/rules-inventory.md`
- Topic README map: `.claude/skills/rules-catalog/references/topic-readmes.md`

## Maintenance Commands

```bash
.claude/skills/rules-catalog/scripts/build-rules-catalog.sh
.claude/skills/rules-catalog/scripts/check-rules-catalog.sh
```
