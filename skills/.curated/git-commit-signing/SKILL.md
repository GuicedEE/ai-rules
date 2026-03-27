---
name: git-commit-signing
description: "Configure and manage git commit signing per repository with the correct user identity and signing method (GPG, SSH, or S/MIME). Use when setting up commit signing for a new repo, switching identities between work/personal projects, troubleshooting signing failures, or enforcing signed commits across a team."
---

# Git Commit Signing

Set up and manage cryptographic commit signing with the right identity for every repository.

## Quick Start

1) **Detect context** — determine the repository remote, associated identity, and preferred signing method.
2) **Configure identity** — set `user.name` and `user.email` at the repo level (not global) to avoid cross-contamination.
3) **Configure signing** — choose GPG, SSH, or S/MIME and point git at the correct key.
4) **Verify** — make a test signed commit or tag and confirm it verifies cleanly.

## Workflow

### 1) Identify the repository context

```bash
# Show current repo remote + identity
git remote -v
git config user.name
git config user.email
git config commit.gpgsign
git config gpg.format
```

Determine from the remote URL whether this is a **personal**, **work**, or **open-source** project and select the matching identity.

### 2) Configure user identity (per-repo)

Always set identity at the **local** (repo) level to prevent leaking the wrong email:

```bash
git config --local user.name  "Your Name"
git config --local user.email "you@example.com"
```

### 3) Enable commit signing

#### Option A — GPG signing (default, widest platform support)

```bash
# List available GPG keys
gpg --list-secret-keys --keyid-format=long

# Configure git to use GPG
git config --local gpg.format openpgp
git config --local user.signingkey <KEY-ID>
git config --local commit.gpgsign true
git config --local tag.gpgsign true

# (Optional) tell git where gpg lives
git config --local gpg.program "gpg"          # Linux/macOS
git config --local gpg.program "gpg.exe"      # Windows — or full path
```

#### Option B — SSH signing (simple, no extra tooling if you already use SSH keys)

```bash
# List available SSH keys
ls -la ~/.ssh/*.pub

# Configure git to use SSH signing
git config --local gpg.format ssh
git config --local user.signingkey ~/.ssh/id_ed25519.pub   # path to your PUBLIC key
git config --local commit.gpgsign true
git config --local tag.gpgsign true

# (Recommended) set allowed-signers for local verification
echo "you@example.com $(cat ~/.ssh/id_ed25519.pub)" >> ~/.config/git/allowed_signers
git config --local gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
```

#### Option C — S/MIME signing (corporate PKI environments)

```bash
git config --local gpg.format x509
git config --local user.signingkey <CERTIFICATE-ID>
git config --local commit.gpgsign true
git config --local tag.gpgsign true
```

### 4) Verify the configuration

```bash
# Create a signed test commit
echo "test" >> .git/signing-test && git add .git/signing-test
git commit --allow-empty -S -m "chore: test commit signing"

# Verify the signature
git log --show-signature -1

# Clean up
git reset --soft HEAD~1
```

### 5) Multi-identity management with includeIf

For developers who contribute to many repos under different identities, use **conditional includes** in `~/.gitconfig`:

```gitconfig
# ~/.gitconfig  (global)
[user]
    name = Default Name
    email = default@example.com

# Work repos live under ~/work/
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work

# Personal repos live under ~/personal/
[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal
```

```gitconfig
# ~/.gitconfig-work
[user]
    name = Work Name
    email = you@company.com
    signingkey = <WORK-KEY-ID>
[commit]
    gpgsign = true
[gpg]
    format = openpgp
```

```gitconfig
# ~/.gitconfig-personal
[user]
    name = Personal Name
    email = you@personal.com
    signingkey = ~/.ssh/id_ed25519.pub
[commit]
    gpgsign = true
[gpg]
    format = ssh
```

## Guardrails

- **Never set signing identity globally** unless you only have one identity — prefer `--local` or `includeIf`.
- **Never commit a private key** — signing keys reference public key paths (SSH) or key IDs (GPG/S/MIME).
- **Pin the GPG/SSH program path** on Windows to avoid PATH issues (`gpg.program` / `gpg.ssh.program`).
- **Test after setup** — always verify with `git log --show-signature -1`.
- **Register your public key** with your forge (GitHub → Settings → SSH and GPG keys, GitLab → User Settings → GPG/SSH Keys).

## Scripts

Configure signing for the current repo interactively:
```bash
bash scripts/configure_signing.sh
```

PowerShell equivalent for Windows:
```powershell
pwsh scripts/configure_signing.ps1
```

Verify that the current repo's signing is working:
```bash
bash scripts/verify_signing.sh
```

## References

- Signing methods comparison and troubleshooting: `references/signing-methods.md`

