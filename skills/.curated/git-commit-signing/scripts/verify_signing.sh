#!/usr/bin/env bash
# verify_signing.sh — Verify that git commit signing is correctly configured
# for the current repository. Performs non-destructive checks.
# Usage: bash verify_signing.sh
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0
WARN_COUNT=0

pass()  { echo -e "  ${GREEN}✔${RESET} $*"; ((PASS++)); }
fail()  { echo -e "  ${RED}✘${RESET} $*"; ((FAIL++)); }
warn()  { echo -e "  ${YELLOW}⚠${RESET} $*"; ((WARN_COUNT++)); }

# ── Guard ───────────────────────────────────────────────────────────────────
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Error: not inside a git repository." >&2
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
echo -e "\n${BOLD}Git Commit Signing — Verify: ${REPO_ROOT}${RESET}\n"

# ── 1. Identity ────────────────────────────────────────────────────────────
echo -e "${CYAN}Identity${RESET}"
NAME=$(git config user.name 2>/dev/null || echo "")
EMAIL=$(git config user.email 2>/dev/null || echo "")
[[ -n "$NAME" ]]  && pass "user.name  = $NAME"  || fail "user.name is not set"
[[ -n "$EMAIL" ]] && pass "user.email = $EMAIL" || fail "user.email is not set"

LOCAL_NAME=$(git config --local user.name 2>/dev/null || echo "")
LOCAL_EMAIL=$(git config --local user.email 2>/dev/null || echo "")
if [[ -n "$LOCAL_NAME" && -n "$LOCAL_EMAIL" ]]; then
  pass "Identity is set at repo level (local)"
else
  warn "Identity is inherited from global/system config — consider setting --local"
fi

# ── 2. Signing config ──────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}Signing configuration${RESET}"
GPG_FORMAT=$(git config gpg.format 2>/dev/null || echo "openpgp")
SIGNING_KEY=$(git config user.signingkey 2>/dev/null || echo "")
COMMIT_SIGN=$(git config commit.gpgsign 2>/dev/null || echo "false")
TAG_SIGN=$(git config tag.gpgsign 2>/dev/null || echo "false")

[[ -n "$SIGNING_KEY" ]] && pass "user.signingkey = $SIGNING_KEY" || fail "user.signingkey is not set"
[[ "$COMMIT_SIGN" == "true" ]] && pass "commit.gpgsign = true" || fail "commit.gpgsign is not enabled"
[[ "$TAG_SIGN" == "true" ]] && pass "tag.gpgsign = true" || warn "tag.gpgsign is not enabled (optional)"

echo "  format: $GPG_FORMAT"

# ── 3. Key availability ────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}Key availability${RESET}"
case "$GPG_FORMAT" in
  openpgp)
    GPG_PROG=$(git config gpg.program 2>/dev/null || echo "gpg")
    if command -v "$GPG_PROG" &>/dev/null; then
      pass "GPG program found: $GPG_PROG"
      if $GPG_PROG --list-secret-keys --keyid-format=long 2>/dev/null | grep -q "$SIGNING_KEY"; then
        pass "Signing key $SIGNING_KEY is present in GPG keyring"
      else
        fail "Signing key $SIGNING_KEY NOT found in GPG keyring"
      fi
    else
      fail "GPG program not found: $GPG_PROG"
    fi
    ;;
  ssh)
    if [[ -f "$SIGNING_KEY" ]]; then
      pass "SSH public key file exists: $SIGNING_KEY"
    else
      fail "SSH public key file not found: $SIGNING_KEY"
    fi

    ALLOWED=$(git config gpg.ssh.allowedSignersFile 2>/dev/null || echo "")
    if [[ -n "$ALLOWED" && -f "$ALLOWED" ]]; then
      pass "Allowed signers file exists: $ALLOWED"
      if grep -q "$EMAIL" "$ALLOWED" 2>/dev/null; then
        pass "Email $EMAIL found in allowed signers"
      else
        warn "Email $EMAIL not found in allowed signers — verification of others' commits may fail"
      fi
    else
      warn "No allowed signers file configured (gpg.ssh.allowedSignersFile)"
    fi
    ;;
  x509)
    [[ -n "$SIGNING_KEY" ]] && pass "S/MIME certificate configured: $SIGNING_KEY" || fail "No certificate configured"
    ;;
  *)
    warn "Unknown gpg.format: $GPG_FORMAT"
    ;;
esac

# ── 4. Recent signed commits ───────────────────────────────────────────────
echo ""
echo -e "${CYAN}Recent commit signatures${RESET}"
if git log --oneline -1 &>/dev/null; then
  LAST_SIG=$(git log --format='%G?' -1 2>/dev/null || echo "N")
  case "$LAST_SIG" in
    G) pass "Last commit has a GOOD signature" ;;
    B) fail "Last commit has a BAD signature" ;;
    U) warn "Last commit signature is good but untrusted" ;;
    X) pass "Last commit has a good signature that has expired" ;;
    Y) warn "Last commit has a good signature made by an expired key" ;;
    R) fail "Last commit has a good signature made by a revoked key" ;;
    E) fail "Last commit signature cannot be checked (missing key)" ;;
    N) warn "Last commit is NOT signed" ;;
    *) warn "Could not determine signature status" ;;
  esac
else
  warn "No commits in this repository yet"
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}── Summary ──${RESET}"
echo -e "  ${GREEN}Passed${RESET}: $PASS  ${RED}Failed${RESET}: $FAIL  ${YELLOW}Warnings${RESET}: $WARN_COUNT"

if [[ $FAIL -gt 0 ]]; then
  echo -e "\n${RED}Signing is NOT fully configured. Fix the failures above.${RESET}"
  exit 1
else
  echo -e "\n${GREEN}Signing looks good!${RESET}"
  exit 0
fi

