#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash scripts/validate_skill_structure.sh <skill-dir>
EOF
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

skill_dir="$1"

if [[ ! -d "$skill_dir" ]]; then
  echo "[ERROR] Skill directory not found: $skill_dir"
  exit 1
fi

failures=0

require_path() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    echo "[FAIL] Missing required path: $path"
    failures=$((failures + 1))
  else
    echo "[OK] $path"
  fi
}

require_text() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if ! rg -q "$pattern" "$file"; then
    echo "[FAIL] Missing $label in $file"
    failures=$((failures + 1))
  else
    echo "[OK] $label in $file"
  fi
}

require_path "$skill_dir/SKILL.md"
require_path "$skill_dir/agents/openai.yaml"
require_path "$skill_dir/LICENSE.txt"

if [[ -f "$skill_dir/SKILL.md" ]]; then
  if ! head -n 1 "$skill_dir/SKILL.md" | rg -q '^---$'; then
    echo "[FAIL] SKILL.md must start with YAML frontmatter"
    failures=$((failures + 1))
  else
    echo "[OK] SKILL.md frontmatter start"
  fi

  require_text '^name:\s*[a-z0-9-]+' "$skill_dir/SKILL.md" "frontmatter name"
  require_text '^description:\s*' "$skill_dir/SKILL.md" "frontmatter description"
fi

if [[ -f "$skill_dir/agents/openai.yaml" ]]; then
  require_text '^interface:' "$skill_dir/agents/openai.yaml" "interface block"
  require_text '^[[:space:]]+display_name:' "$skill_dir/agents/openai.yaml" "interface.display_name"
  require_text '^[[:space:]]+short_description:' "$skill_dir/agents/openai.yaml" "interface.short_description"
  require_text '^[[:space:]]+default_prompt:.*\$[a-z0-9-]+' "$skill_dir/agents/openai.yaml" "interface.default_prompt with skill tag"
fi

for disallowed in README.md INSTALLATION_GUIDE.md QUICK_REFERENCE.md CHANGELOG.md; do
  if [[ -e "$skill_dir/$disallowed" ]]; then
    echo "[FAIL] Disallowed root file present: $skill_dir/$disallowed"
    failures=$((failures + 1))
  fi
done

while IFS= read -r entry; do
  case "$entry" in
    SKILL.md|LICENSE.txt|agents|scripts|references|assets)
      ;;
    *)
      echo "[FAIL] Non-template root entry found: $skill_dir/$entry"
      failures=$((failures + 1))
      ;;
  esac
done < <(find "$skill_dir" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort)

if [[ "$failures" -gt 0 ]]; then
  echo "[FAIL] Skill structure validation failed with $failures issue(s)."
  exit 1
fi

echo "[PASS] Skill structure is compliant with local skill conventions."
