---
name: structured-skill-creator
description: Create or update skills under `skills/` with strict compliance to the local structured template and validation workflow.
metadata:
  short-description: Create skills with strict local structure
---

# Structured Skill Creator

## Overview

Use this skill when the user asks to create or update a skill in the repository `skills/` directory and requires strict structure compliance.

This skill enforces:
- Local template-based scaffolding.
- `agents/openai.yaml` metadata alignment.
- Consistent directory and file layout.
- Required validation before delivery.

## Source of truth

- `scripts/create_skill_from_template.sh`
- `scripts/validate_skill_structure.sh`
- `references/skill-compliance-checklist.md`

## Quick start

1. Scaffold a new skill from the template:
   - `bash scripts/create_skill_from_template.sh <skill-name>`
2. Edit content for the requested domain/workflow:
   - `SKILL.md`
   - `references/` and `scripts/` as needed
3. Validate strict compliance:
   - `bash scripts/validate_skill_structure.sh <skill-dir>`
4. Re-run the validator before finalizing after each structural edit.

## Workflow

### 1) Gather required inputs

- Skill name (hyphen-case target name).
- Trigger conditions (when the skill should activate).
- Expected resources (`scripts`, `references`, `assets`).
- Interface metadata (`display_name`, `short_description`, `default_prompt`).

### 2) Scaffold from local template

- Use `scripts/create_skill_from_template.sh` to generate the skill skeleton.
- Add `LICENSE.txt` from the repository root license when available.
- Keep the initial skeleton minimal, then add only task-relevant content.

### 3) Implement skill content

- Keep `SKILL.md` concise and procedural.
- Put detailed domain material in `references/`.
- Put deterministic helpers in `scripts/`.
- Put output resources in `assets/` only when needed.

### 4) Enforce structural compliance

- Run `scripts/validate_skill_structure.sh` on the target skill.
- Reject non-template files in the skill root.
- Ensure `agents/openai.yaml` includes:
  - `interface.display_name`
  - `interface.short_description`
  - `interface.default_prompt` (must mention `$<skill-name>`)

### 5) Final verification

- Run `scripts/validate_skill_structure.sh`.
- Confirm no disallowed files were introduced.
- Confirm examples and references are relative and resolve inside the repository.

## Compliance requirements

- Skill name must be lowercase hyphen-case.
- Frontmatter requires `name` and `description`.
- Root skill files should match template conventions:
  - Required: `SKILL.md`, `agents/openai.yaml`, `LICENSE.txt`
  - Optional: `scripts/`, `references/`, `assets/`
- Do not add extraneous docs such as:
  - `README.md`
  - `INSTALLATION_GUIDE.md`
  - `QUICK_REFERENCE.md`
  - `CHANGELOG.md`

## References

- `references/skill-compliance-checklist.md`
