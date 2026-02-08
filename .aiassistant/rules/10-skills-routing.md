# AI Assistant Skill Routing

Use the same skill graph used by Claude Agent Skills.

## Activation Sequence

1. `.claude/skills/rules-repo-conventions/SKILL.md`
2. `.claude/skills/rules-catalog/SKILL.md`
3. Domain router skills from `skills.md`

## References

- Rules summary: `.claude/skills/rules-catalog/references/rules-summary.md`
- Rule inventory: `.claude/skills/rules-catalog/references/rules-inventory.md`
- Topic README map: `.claude/skills/rules-catalog/references/topic-readmes.md`

## Maintenance Commands

```bash
.claude/skills/rules-catalog/scripts/build-rules-catalog.sh
.claude/skills/rules-catalog/scripts/check-rules-catalog.sh
```
