---
name: rules-catalog
description: Discover and maintain the complete enterprise rules corpus in this repository. Use when asked for a comprehensive rules list, rule taxonomy analysis, skill/rule routing, or exact file-level rule lookup across generative categories.
---

# Rules Catalog

## Instructions
1. Open `../../../../skills.md` and apply the load order.
2. Use `references/rules-summary.md` for counts and high-level distribution.
3. Use `references/topic-readmes.md` to jump to category/topic entry points.
4. Use `references/rules-inventory.md` for exhaustive file-level rule lookup.
5. Route implementation work to one or more domain skills:
   - `../rules-frontend/SKILL.md`
   - `../rules-backend/SKILL.md`
   - `../rules-data/SKILL.md`
   - `../rules-platform/SKILL.md`
   - `../rules-language/SKILL.md`
   - `../rules-architecture/SKILL.md`
6. After adding/removing/moving any rules documentation, regenerate references by running `scripts/build-rules-catalog.sh`.
7. Verify references are not stale by running `scripts/check-rules-catalog.sh`.
8. Verify provider workspace files by running `scripts/check-agent-workspaces.sh`.

## Validation Checklist
- Inventory includes all files matching `*.rules.md`, `*.rules.xml`, and `**/rules/*.md` under `generative/`.
- Topic counts in `rules-summary.md` match `rules-inventory.md`.
- `topic-readmes.md` points to valid README entry points.
- `scripts/check-rules-catalog.sh` returns success.
- `scripts/check-agent-workspaces.sh` returns success.
