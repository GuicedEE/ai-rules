---
name: skill-installer
description: Install Codex skills into $CODEX_HOME/skills from a curated list or a GitHub repo path. Use when a user asks to list installable skills, install a curated skill, or install a skill from another repo (including private repos).
metadata:
  short-description: Install skills from default repos or other GitHub sources
---

# Skill Installer

Helps install skills. Default sources include:
- OpenAI skills: `https://github.com/openai/skills` (`skills/.curated`, and optionally `skills/.system`)
- GuicedEE rules skills: `https://github.com/GuicedEE/ai-rules` (`skills/.curated`, and optionally `skills/.system`)

Users can still provide any other GitHub repo/path.

Use the helper scripts based on the task:
- List skills when the user asks what is available, or if the user uses this skill without specifying what to do. Default listing is `.curated` across both default sources.
- Install by skill name from default sources when the user provides a skill name.
- Install from another repo when the user provides a GitHub repo/path (including private repos).

Install skills with the helper scripts.

## Communication

When listing skills, output approximately as follows, depending on the context of the user's request:
"""
Skills from {repo} ({path}):
1. skill-1
2. skill-2 (already installed)
3. ...
Which ones would you like installed?
"""

After installing a skill, tell the user: "Restart Codex to pick up new skills."

## Scripts

All of these scripts use network, so when running in the sandbox, request escalation when running them.

- `scripts/list-skills.py` (prints skills list with installed annotations)
- `scripts/list-skills.py --format json`
- Example (OpenAI only): `scripts/list-skills.py --source openai`
- Example (include system paths): `scripts/list-skills.py --include-system`
- `scripts/install-skill-from-defaults.py <skill-name> [<skill-name> ...]`
- Example (GuicedEE only): `scripts/install-skill-from-defaults.py --source guicedee <skill-name>`
- Example (curated only): `scripts/install-skill-from-defaults.py --curated-only <skill-name>`
- `scripts/install-skill-from-github.py --repo <owner>/<repo> --path <path/to/skill> [<path/to/skill> ...]`
- `scripts/install-skill-from-github.py --url https://github.com/<owner>/<repo>/tree/<ref>/<path>`
- Example (experimental skill): `scripts/install-skill-from-github.py --repo openai/skills --path skills/.experimental/<skill-name>`

## Behavior and Options

- Defaults to direct download for public GitHub repos.
- If download fails with auth/permission errors, falls back to git sparse checkout.
- Aborts if the destination skill directory already exists.
- Installs into `$CODEX_HOME/skills/<skill-name>` (defaults to `~/.codex/skills`).
- Multiple `--path` values install multiple skills in one run, each named from the path basename unless `--name` is supplied.
- Options: `--ref <ref>`, `--dest <path>`, `--method auto|download|git`.

## Notes

- Default listing is fetched from both:
  - `https://github.com/openai/skills/tree/main/skills/.curated`
  - `https://github.com/GuicedEE/ai-rules/tree/master/skills/.curated`
- Source-specific default refs:
  - `openai/skills` -> `main`
  - `GuicedEE/ai-rules` -> `master`
- Use `--include-system` to include `skills/.system` paths for the selected default sources.
- For `GuicedEE/ai-rules`, the helper scripts also fall back to `.claude/skills` if `skills/.curated` / `skills/.system` are unavailable in the selected ref.
- Private GitHub repos can be accessed via existing git credentials or optional `GITHUB_TOKEN`/`GH_TOKEN` for download.
- Git fallback tries HTTPS first, then SSH.
- Installed annotations come from `$CODEX_HOME/skills`.
