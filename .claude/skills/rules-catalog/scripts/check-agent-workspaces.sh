#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT_DIR"

REQUIRED_FILES=(
  "AGENTS.md"
  ".github/copilot-instructions.md"
  ".cursor/rules.md"
  ".junie/guidelines.md"
  ".aiassistant/rules/00-core.md"
  ".aiassistant/rules/10-skills-routing.md"
)

missing=0
for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "missing: $file"
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "Agent workspace files are incomplete."
  exit 1
fi

checks=(
  "AGENTS.md|skills.md"
  ".github/copilot-instructions.md|skills.md"
  ".cursor/rules.md|skills.md"
  ".junie/guidelines.md|skills.md"
  ".aiassistant/rules/00-core.md|RULES.md"
  ".aiassistant/rules/10-skills-routing.md|rules-catalog"
)

invalid=0
for entry in "${checks[@]}"; do
  file="${entry%%|*}"
  needle="${entry##*|}"
  if ! rg -q "$needle" "$file"; then
    echo "invalid: $file does not contain '$needle'"
    invalid=1
  fi
done

if [[ "$invalid" -ne 0 ]]; then
  echo "Agent workspace files failed validation."
  exit 1
fi

echo "Agent workspace files are present and valid."
