#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REFERENCES_DIR="$SKILL_DIR/references"
BUILD_SCRIPT="$SCRIPT_DIR/build-rules-catalog.sh"

FILES=(
  "rules-summary.md"
  "rules-inventory.md"
  "topic-readmes.md"
)

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

for file in "${FILES[@]}"; do
  src="$REFERENCES_DIR/$file"
  dst="$TMP_DIR/$file"
  if [[ -f "$src" ]]; then
    cp "$src" "$dst"
  else
    : > "$dst"
  fi
done

"$BUILD_SCRIPT" >/dev/null

stale=0
for file in "${FILES[@]}"; do
  before="$TMP_DIR/$file"
  after="$REFERENCES_DIR/$file"
  if ! cmp -s "$before" "$after"; then
    stale=1
    echo "stale: $file"
  fi
done

if [[ "$stale" -ne 0 ]]; then
  echo "Rules catalog references are stale. Re-run: .claude/skills/rules-catalog/scripts/build-rules-catalog.sh"
  exit 1
fi

echo "Rules catalog references are up to date."
