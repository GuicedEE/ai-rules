# Skills Catalog

This is the pinned project skills catalog for owner mode in this repository.
Provider-agnostic agent entrypoint: `AGENTS.md`.

## Load Order

1. `.claude/skills/rules-repo-conventions/SKILL.md`
2. `.claude/skills/rules-catalog/SKILL.md`
3. One or more domain router skills based on task scope.

## Project Skills

- `rules-repo-conventions`  
  Path: `.claude/skills/rules-repo-conventions/SKILL.md`  
  Use for repository-wide behavior, forward-only edits, and Pact/Rules/Guides/Implementation loop closure.

- `rules-catalog`  
  Path: `.claude/skills/rules-catalog/SKILL.md`  
  Use to discover, inventory, and maintain the full enterprise rules corpus.

- `rules-frontend`  
  Path: `.claude/skills/rules-frontend/SKILL.md`  
  Use for frontend rule routing (`jwebmp`, `webawesome`, `angular-awesome`, `webcomponents`, `nextjs`, `nuxt`).

- `rules-backend`  
  Path: `.claude/skills/rules-backend/SKILL.md`  
  Use for backend rule routing (`guicedee`, `quarkus`, `vertx`, `hibernate`, `mapstruct`, `lombok`, `spring`, `security-reactive`).

- `rules-data`  
  Path: `.claude/skills/rules-data/SKILL.md`  
  Use for data-layer and Activity Master rule routing (`activity-master`, `database`, `entityassist`).

- `rules-platform`  
  Path: `.claude/skills/rules-platform/SKILL.md`  
  Use for platform and operations routing (`ci-cd`, `observability`, `secrets-config`, `security-auth`, `testing`).

- `rules-language`  
  Path: `.claude/skills/rules-language/SKILL.md`  
  Use for language/framework guidance (`java`, `kotlin`, `typescript`, `angular`, `react`, `vue`).

- `rules-architecture`  
  Path: `.claude/skills/rules-architecture/SKILL.md`  
  Use for architecture and methodology routing (`ddd`, `microfronts`, `tdd`, `bdd`).

## Comprehensive Rule Inventory

Generated references are maintained under `.claude/skills/rules-catalog/references/`:

- `rules-summary.md`
- `rules-inventory.md`
- `topic-readmes.md`

Regenerate after structural/content updates:

```bash
.claude/skills/rules-catalog/scripts/build-rules-catalog.sh
```

Validate generated references are current:

```bash
.claude/skills/rules-catalog/scripts/check-rules-catalog.sh
```
