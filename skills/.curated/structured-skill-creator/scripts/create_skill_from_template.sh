#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
structure_validate_script="$script_dir/validate_skill_structure.sh"
license_source="$repo_root/LICENSE"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/create_skill_from_template.sh <skill-name> [target-root]

Examples:
  bash scripts/create_skill_from_template.sh api-doc-helper
  bash scripts/create_skill_from_template.sh "API Doc Helper" skills

Notes:
  - Name is normalized to lowercase hyphen-case.
  - target-root defaults to <repo>/skills.
  - Existing skill directories are not overwritten.
EOF
}

normalize_name() {
  local raw="$1"
  echo "$raw" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g'
}

title_case() {
  local hyphen_name="$1"
  echo "$hyphen_name" \
    | tr '-' ' ' \
    | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}'
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

raw_name="$1"
target_root="${2:-$repo_root/skills}"
skill_name="$(normalize_name "$raw_name")"

if [[ -z "$skill_name" ]]; then
  echo "[ERROR] Normalized skill name is empty. Provide a valid skill name."
  exit 1
fi

skill_dir="$target_root/$skill_name"
if [[ -e "$skill_dir" ]]; then
  echo "[ERROR] Skill directory already exists: $skill_dir"
  exit 1
fi

mkdir -p "$skill_dir/agents" "$skill_dir/scripts" "$skill_dir/references" "$skill_dir/assets"

display_name="$(title_case "$skill_name")"
short_description="Create or update ${display_name} skill"
if [[ "${#short_description}" -gt 64 ]]; then
  short_description="${short_description:0:64}"
fi
default_prompt="Use \$${skill_name} to create or update a structured skill."

cat > "$skill_dir/SKILL.md" <<EOF
---
name: $skill_name
description: "Create or update a structured skill with compliant metadata and layout."
---

# $display_name

## Overview

Describe what this skill does and exactly when it should be used.

## Quick start

1. Describe the first action.
2. Describe the second action.
3. Validate outputs before delivery.

## Workflow

### 1) Gather context

- Capture user intent, scope, and constraints.

### 2) Execute

- Perform the core workflow for this skill.

### 3) Validate

- Confirm structure, outputs, and metadata are correct.

## References

- Add reference files under \`references/\` as needed.
EOF

cat > "$skill_dir/agents/openai.yaml" <<EOF
interface:
  display_name: "$display_name"
  short_description: "$short_description"
  default_prompt: "$default_prompt"
EOF

cat > "$skill_dir/references/README-template-guidance.md" <<'EOF'
# Reference Guidance

Use this directory for detailed instructions that should be loaded only when needed.
EOF

cat > "$skill_dir/scripts/example.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "Replace this script with deterministic helpers for your skill."
EOF
chmod +x "$skill_dir/scripts/example.sh"

if [[ -f "$license_source" ]]; then
  cp "$license_source" "$skill_dir/LICENSE.txt"
else
  cat > "$skill_dir/LICENSE.txt" <<'EOF'
No repository license file was found at creation time.
EOF
fi

bash "$structure_validate_script" "$skill_dir"

echo "[PASS] Skill created and validated: $skill_dir"
