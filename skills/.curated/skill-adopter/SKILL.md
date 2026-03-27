---
name: skill-adopter
description: "Adopt and wire enterprise skills into a target project for the AI agent(s) in use. Scans a project to detect its tech stack and configured AI agents (Codex, Copilot, Cursor, Junie, AI Assistant, Claude, Roo), selects relevant skills from the enterprise skills repository, and generates or updates the agent-native configuration files (AGENTS.md, .github/copilot-instructions.md, .cursor/rules.md, .junie/guidelines.md, .aiassistant/rules/, .cursorrules, .roo/rules). Use when onboarding a project onto enterprise skills, switching AI agents, refreshing stale agent configs, or aligning a project's AI setup with the current skills catalog."
metadata:
  short-description: Adopt enterprise skills into a project for any AI agent
---

# Skill Adopter

Adopt enterprise skills into a target project, wired for the specific AI agent(s) in use.

## When to use

- Onboarding a new or existing project onto the enterprise skills catalog.
- Adding, switching, or updating AI agent configuration in a project.
- Refreshing stale agent configs that reference old paths or removed artifacts.
- Aligning a project with the current skills repository after structural changes.

## Required flow

1. **Detect** — Identify the project's tech stack and active AI agent(s).
2. **Select** — Choose relevant skills from the enterprise catalog.
3. **Generate** — Produce or update agent-native configuration files.
4. **Verify** — Confirm the generated configs reference valid skill paths.

## Step 1: Detect project context

Scan the target project root for:

### Tech stack signals

| Signal | Look for |
|--------|----------|
| Java / Maven | `pom.xml`, `module-info.java` |
| GuicedEE | `com.guicedee` in `pom.xml` or `module-info.java` |
| JWebMP | `com.jwebmp` in `pom.xml` or `module-info.java` |
| EntityAssist | `com.entityassist` in `pom.xml` or `module-info.java` |
| ActivityMaster | `activitymaster` modules in `pom.xml` |
| Angular / TypeScript | `angular.json`, `tsconfig.json`, `package.json` |
| Vert.x | `com.guicedee.vertx` or `io.vertx` in dependencies |
| Terraform | `*.tf` files, `.terraform/` |
| Docker / K8s | `Dockerfile`, `docker-compose.yml`, `k8s/` |
| React / Vue / Next.js | `package.json` framework deps |

### AI agent signals

| Agent | Config location |
|-------|-----------------|
| Codex CLI | `AGENTS.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Cursor | `.cursor/rules.md` or `.cursorrules` |
| JetBrains Junie | `.junie/guidelines.md` |
| JetBrains AI Assistant | `.aiassistant/rules/*.md` |
| Claude (project skills) | `.claude/settings.json`, `.claude/skills/` |
| Roo | `.roo/rules` or `.roomodes` |

If no agent config is found, ask the user which agent(s) they use.

## Step 2: Select relevant skills

Use the enterprise skills catalog (`skills.md` at the repository root, or scan `skills/.curated/` and `skills/.system/` directories) to select skills.

### Automatic selection by stack

| Detected stack | Skills to include |
|----------------|-------------------|
| Any project | `git-commit-helper`, `code-reviewer`, `systematic-debugging` |
| GuicedEE | All `guicedee-*` skills matching detected modules |
| JWebMP | All `jwebmp-*` skills matching detected plugins |
| EntityAssist | `entityassist` |
| ActivityMaster | `activitymaster`, `entityassist` |
| Vert.x | `guicedee-vertx` |
| Terraform | All `terraform-*` skills |
| Frontend (Angular) | `jwebmp-angular` (if JWebMP), `figma` |
| AG Grid | `aggrid`, `jwebmp-aggrid-enterprise` (if JWebMP) |
| Security-sensitive | `security-best-practices`, `security-compliance` |
| CI/CD (GitHub Actions) | `gh-fix-ci`, `gh-address-comments` |

### Interactive refinement

After automatic selection, present the list to the user:

```
Based on your project, I recommend these skills:

Always:
  ✓ git-commit-helper
  ✓ code-reviewer
  ✓ systematic-debugging

Stack-specific:
  ✓ guicedee-inject
  ✓ guicedee-vertx
  ✓ guicedee-persistence
  ✓ entityassist
  ✓ activitymaster

Optional:
  ○ senior-architect
  ○ test-driven-development
  ○ security-best-practices

Add or remove skills? (Enter to accept)
```

## Step 3: Generate agent configuration

Generate the agent-native config files. See `references/agent-config-formats.md` for the complete format reference per agent.

### Submodule path resolution

Determine the skills repository path relative to the project root:

- If the skills repo is a git submodule (e.g., `rules/` or `AIRules/`), use that prefix.
- If skills are installed to `$CODEX_HOME/skills/`, use `~/.codex/skills/` paths.
- If the skills repo is in the same workspace, use the relative path.

All skill references in generated configs must use resolved, valid relative paths.

### Generation rules

1. **One config per agent** — generate only for detected/requested agents.
2. **Skill references use SKILL.md paths** — point to the `SKILL.md` file, not the directory.
3. **Curated vs system** — include both tiers when relevant; label them in the config.
4. **Keep configs idempotent** — re-running the adopter on the same project updates existing configs without duplication.
5. **Preserve user customizations** — if an agent config already exists, merge new skill references; do not overwrite custom rules or instructions.

### Per-agent output summary

| Agent | Output file(s) | Format |
|-------|----------------|--------|
| Codex CLI | `AGENTS.md` | Markdown with skill paths and operating rules |
| GitHub Copilot | `.github/copilot-instructions.md` | Markdown instructions with skill references |
| Cursor | `.cursor/rules.md` | Markdown rules with skill paths |
| Junie | `.junie/guidelines.md` | Markdown guidelines with skill routing |
| AI Assistant | `.aiassistant/rules/*.md` | Numbered rule files with skill routing |
| Claude | `.claude/settings.json` + skill symlinks | JSON config + file references |
| Roo | `.roo/rules/*.md` | Markdown rule files |

## Step 4: Verify

After generation, verify:

1. Every referenced skill path resolves to an existing `SKILL.md` file.
2. No config references old/removed paths (e.g., `.claude/skills/rules-repo-conventions/`).
3. The config file is syntactically valid for the agent.
4. If a `skills.md` exists in the project, it is consistent with the generated configs.

Report any unresolved paths as warnings.

## Refresh mode

When called with "refresh" or "update" intent:

1. Read existing agent config files.
2. Extract currently referenced skill paths.
3. Check each path against the current skills repository structure.
4. Replace broken paths with correct current paths.
5. Add newly relevant skills that were not previously included.
6. Remove references to skills that no longer exist.

## References

- `references/agent-config-formats.md` — complete config format templates for each AI agent.


