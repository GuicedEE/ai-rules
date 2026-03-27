# Agent Configuration Formats

Complete templates for wiring enterprise skills into each AI agent's native configuration.

In all templates below:
- `{SKILLS_ROOT}` = resolved path to the skills repository relative to the project root (e.g., `rules/skills`, `AIRules/skills`, `~/.codex/skills`).
- `{skill-name}` = the skill directory name (e.g., `guicedee-vertx`, `senior-architect`).
- Replace `{selected-skills}` blocks with the actual selected skills.

---

## Codex CLI — `AGENTS.md`

Place at project root. Codex reads this file automatically.

```markdown
# Agent Workspace Policy

## Required Context

1. `README.md`
2. `{SKILLS_ROOT}/../skills.md` (skills catalog)

## Skill Routing

Load skills in order of relevance to the current task.

### Core (always available)
- `{SKILLS_ROOT}/.curated/git-commit-helper/SKILL.md`
- `{SKILLS_ROOT}/.curated/code-reviewer/SKILL.md`
- `{SKILLS_ROOT}/.curated/systematic-debugging/SKILL.md`

### Stack-specific
{for each selected system skill:}
- `{SKILLS_ROOT}/.system/{skill-name}/SKILL.md`

### On-demand
{for each selected curated skill:}
- `{SKILLS_ROOT}/.curated/{skill-name}/SKILL.md`

## Operating Rules

- Use forward-only edits; update all impacted links in the same change.
- Load skill references/ only when the SKILL.md instructions call for them.
- Prefer library-first implementation using APIs from loaded skills.
```

---

## GitHub Copilot — `.github/copilot-instructions.md`

Place at `.github/copilot-instructions.md`. Copilot reads this for repository-level instructions.

```markdown
# Copilot Instructions

## Project context

{Brief project description — 1-2 sentences from README.md}

## Enterprise skills

This project uses enterprise skills from `{SKILLS_ROOT}/`. When working on tasks that match a skill's domain, load and follow its SKILL.md instructions.

### Core skills (always apply)
- Git commits: `{SKILLS_ROOT}/.curated/git-commit-helper/SKILL.md`
- Code review: `{SKILLS_ROOT}/.curated/code-reviewer/SKILL.md`
- Debugging: `{SKILLS_ROOT}/.curated/systematic-debugging/SKILL.md`

### Stack-specific skills
{for each selected skill:}
- {display_name}: `{SKILLS_ROOT}/.curated|.system/{skill-name}/SKILL.md`

## Coding conventions

- Follow patterns established in the existing codebase.
- When a loaded skill provides API examples, prefer those patterns.
- Use JPMS module-info.java conventions when applicable.
- Prefer reactive patterns (Uni<T>, Vert.x event bus) for async work.
```

---

## Cursor — `.cursor/rules.md`

Place at `.cursor/rules.md`. Cursor reads this for project rules.

```markdown
# Project Rules

## Skills

Enterprise skills are available at `{SKILLS_ROOT}/`. Load the relevant SKILL.md before implementing domain-specific tasks.

### Always loaded
- `{SKILLS_ROOT}/.curated/git-commit-helper/SKILL.md`
- `{SKILLS_ROOT}/.curated/code-reviewer/SKILL.md`

### Load on demand
{for each selected skill:}
- {skill-name}: `{SKILLS_ROOT}/.curated|.system/{skill-name}/SKILL.md` — {short description}

## Rules

- Follow existing code patterns and conventions.
- Use forward-only changes; update all affected files in the same edit.
- Load skill references/ only when SKILL.md instructions require them.
```

---

## JetBrains Junie — `.junie/guidelines.md`

Place at `.junie/guidelines.md`. Junie reads this for project guidelines.

```markdown
# Junie Guidelines

## Skills

Enterprise skills catalog: `{SKILLS_ROOT}/../skills.md`

### Skill routing

Load skills based on the current task scope:

#### Core
- `{SKILLS_ROOT}/.curated/git-commit-helper/SKILL.md`
- `{SKILLS_ROOT}/.curated/code-reviewer/SKILL.md`
- `{SKILLS_ROOT}/.curated/systematic-debugging/SKILL.md`

#### Stack-specific
{for each selected system skill:}
- `{SKILLS_ROOT}/.system/{skill-name}/SKILL.md`

#### On-demand
{for each selected curated skill:}
- `{SKILLS_ROOT}/.curated/{skill-name}/SKILL.md`

## Workflow

- Use documentation-first delivery.
- Treat all stage gates as auto-approved; continue without pauses.
- Record any bypassed gates in the output.
- Apply forward-only edits and keep impacted links updated.
```

---

## JetBrains AI Assistant — `.aiassistant/rules/`

Create numbered rule files in `.aiassistant/rules/`. AI Assistant loads all `*.md` files from this directory.

### `.aiassistant/rules/00-core.md`

```markdown
# Core Rules

## Required Context

1. `README.md`
2. `{SKILLS_ROOT}/../skills.md`

## Commitments

- Use forward-only updates.
- Follow patterns from loaded skills.
- Prefer library-first implementation.
```

### `.aiassistant/rules/10-skills-routing.md`

```markdown
# Skills Routing

## Core skills (always available)
- `{SKILLS_ROOT}/.curated/git-commit-helper/SKILL.md`
- `{SKILLS_ROOT}/.curated/code-reviewer/SKILL.md`
- `{SKILLS_ROOT}/.curated/systematic-debugging/SKILL.md`

## Stack-specific skills
{for each selected system skill:}
- `{SKILLS_ROOT}/.system/{skill-name}/SKILL.md`

## On-demand skills
{for each selected curated skill:}
- `{SKILLS_ROOT}/.curated/{skill-name}/SKILL.md`

## References

- `{SKILLS_ROOT}/../skills.md`
```

---

## Claude (Project Skills) — `.claude/settings.json`

Claude uses `.claude/settings.json` for project config and `.claude/skills/` for skills.

For submodule-based setups, create symlinks or direct file references:

### `.claude/settings.json`

```json
{
  "skills": [
    "{SKILLS_ROOT}/.curated/git-commit-helper",
    "{SKILLS_ROOT}/.curated/code-reviewer",
    "{SKILLS_ROOT}/.curated/systematic-debugging",
    {for each selected skill:}
    "{SKILLS_ROOT}/.curated|.system/{skill-name}"
  ]
}
```

Alternatively, install skills into `.claude/skills/` using the `skill-installer`:

```bash
python {SKILLS_ROOT}/.system/skill-installer/scripts/install-skill-from-defaults.py {skill-name}
```

---

## Roo — `.roo/rules/`

Roo reads markdown rule files from `.roo/rules/`.

### `.roo/rules/00-skills.md`

```markdown
# Enterprise Skills

## Skills catalog

See `{SKILLS_ROOT}/../skills.md` for the full catalog.

## Active skills

### Core
- `{SKILLS_ROOT}/.curated/git-commit-helper/SKILL.md`
- `{SKILLS_ROOT}/.curated/code-reviewer/SKILL.md`
- `{SKILLS_ROOT}/.curated/systematic-debugging/SKILL.md`

### Stack-specific
{for each selected skill:}
- `{SKILLS_ROOT}/.curated|.system/{skill-name}/SKILL.md`

## Rules

- Load SKILL.md before implementing domain-specific tasks.
- Follow skill instructions and use referenced APIs.
- Load references/ only when SKILL.md calls for them.
```

