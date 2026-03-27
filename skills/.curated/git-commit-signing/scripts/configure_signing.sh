#!/usr/bin/env bash
# configure_signing.sh — Interactive git commit signing setup for the current repository.
# Usage: bash configure_signing.sh
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

info()  { echo -e "${CYAN}ℹ ${RESET}$*"; }
ok()    { echo -e "${GREEN}✔ ${RESET}$*"; }
warn()  { echo -e "${YELLOW}⚠ ${RESET}$*"; }

# ── Guard: must be inside a git repo ────────────────────────────────────────
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Error: not inside a git repository." >&2
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
echo -e "\n${BOLD}Git Commit Signing — Configure for: ${REPO_ROOT}${RESET}\n"

# ── Step 1: User identity ──────────────────────────────────────────────────
CURRENT_NAME=$(git config --local user.name 2>/dev/null || git config user.name 2>/dev/null || echo "")
CURRENT_EMAIL=$(git config --local user.email 2>/dev/null || git config user.email 2>/dev/null || echo "")

info "Current identity: ${CURRENT_NAME:-<not set>} <${CURRENT_EMAIL:-<not set>}>"
read -rp "user.name  [${CURRENT_NAME}]: " INPUT_NAME
read -rp "user.email [${CURRENT_EMAIL}]: " INPUT_EMAIL

NAME="${INPUT_NAME:-$CURRENT_NAME}"
EMAIL="${INPUT_EMAIL:-$CURRENT_EMAIL}"

if [[ -z "$NAME" || -z "$EMAIL" ]]; then
  echo "Error: user.name and user.email are required." >&2
  exit 1
fi

git config --local user.name  "$NAME"
git config --local user.email "$EMAIL"
ok "Identity set: $NAME <$EMAIL>"

# ── Step 2: Choose signing method ──────────────────────────────────────────
echo ""
info "Select signing method:"
echo "  1) GPG  (openpgp) — widest platform support"
echo "  2) SSH  — simple, reuses existing SSH keys"
echo "  3) S/MIME (x509) — corporate PKI"
read -rp "Choice [1]: " METHOD_CHOICE

case "${METHOD_CHOICE:-1}" in
  1)
    FORMAT="openpgp"
    info "Available GPG secret keys:"
    gpg --list-secret-keys --keyid-format=long 2>/dev/null || warn "No GPG keys found. Generate one with: gpg --full-generate-key"
    echo ""
    read -rp "Enter GPG key ID (long form): " KEY_ID
    if [[ -z "$KEY_ID" ]]; then
      echo "Error: signing key is required." >&2; exit 1
    fi
    git config --local gpg.format    openpgp
    git config --local user.signingkey "$KEY_ID"

    # Detect gpg program
    if command -v gpg2 &>/dev/null; then
      git config --local gpg.program gpg2
    elif command -v gpg &>/dev/null; then
      git config --local gpg.program gpg
    else
      warn "gpg not found in PATH — set gpg.program manually."
    fi
    ;;
  2)
    FORMAT="ssh"
    info "Available SSH public keys:"
    ls -1 ~/.ssh/*.pub 2>/dev/null || warn "No SSH public keys found in ~/.ssh/"
    echo ""
    read -rp "Path to SSH public key [~/.ssh/id_ed25519.pub]: " SSH_KEY
    SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519.pub}"
    if [[ ! -f "$SSH_KEY" ]]; then
      echo "Error: file not found: $SSH_KEY" >&2; exit 1
    fi
    git config --local gpg.format    ssh
    git config --local user.signingkey "$SSH_KEY"

    # Set up allowed_signers for verification
    ALLOWED_SIGNERS="${HOME}/.config/git/allowed_signers"
    mkdir -p "$(dirname "$ALLOWED_SIGNERS")"
    SIGNER_LINE="$EMAIL $(cat "$SSH_KEY")"
    if ! grep -qF "$SIGNER_LINE" "$ALLOWED_SIGNERS" 2>/dev/null; then
      echo "$SIGNER_LINE" >> "$ALLOWED_SIGNERS"
      ok "Added entry to $ALLOWED_SIGNERS"
    fi
    git config --local gpg.ssh.allowedSignersFile "$ALLOWED_SIGNERS"
    ;;
  3)
    FORMAT="x509"
    read -rp "Enter certificate ID / fingerprint: " CERT_ID
    if [[ -z "$CERT_ID" ]]; then
      echo "Error: certificate ID is required." >&2; exit 1
    fi
    git config --local gpg.format    x509
    git config --local user.signingkey "$CERT_ID"
    ;;
  *)
    echo "Invalid choice." >&2; exit 1
    ;;
esac

# ── Step 3: Enable auto-signing ───────────────────────────────────────────
git config --local commit.gpgsign true
git config --local tag.gpgsign    true
ok "Auto-signing enabled for commits and tags (format: $FORMAT)"

# ── Step 4: Summary ───────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}── Current signing configuration ──${RESET}"
echo "  user.name       = $(git config --local user.name)"
echo "  user.email      = $(git config --local user.email)"
echo "  gpg.format      = $(git config --local gpg.format)"
echo "  user.signingkey = $(git config --local user.signingkey)"
echo "  commit.gpgsign  = $(git config --local commit.gpgsign)"
echo "  tag.gpgsign     = $(git config --local tag.gpgsign)"
echo ""
info "Run 'git commit --allow-empty -S -m \"test signing\"' to verify."

