# Skill Compliance Checklist

Use this checklist when creating or updating skills under `skills/`.

## Required structure

- `SKILL.md` with valid YAML frontmatter.
- `agents/openai.yaml` with interface metadata.
- `LICENSE.txt` (copied from the repository root license when available).

## Optional structure

- `scripts/` for deterministic helpers.
- `references/` for load-on-demand docs.
- `assets/` for output resources.

## Frontmatter requirements (`SKILL.md`)

- Must include:
  - `name`
  - `description`
- Allowed extra keys (template-compatible):
  - `metadata`
  - `license`
  - `allowed-tools`

## `openai.yaml` requirements

- `interface.display_name`
- `interface.short_description`
- `interface.default_prompt`
- `default_prompt` should explicitly mention `$<skill-name>`.

## Content quality rules

- Keep `SKILL.md` concise and procedural.
- Put detailed, variant-specific docs in `references/`.
- Keep examples realistic and directly runnable.
- Avoid unrelated helper docs in the skill root.

## Disallowed root files

- `README.md`
- `INSTALLATION_GUIDE.md`
- `QUICK_REFERENCE.md`
- `CHANGELOG.md`

## Validation commands

```bash
bash skills/.curated/structured-skill-creator/scripts/validate_skill_structure.sh <skill-dir>
```
