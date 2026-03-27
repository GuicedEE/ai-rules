# Git Commit Signing — Signing Methods Reference

## Comparison Matrix

| Feature               | GPG (OpenPGP)              | SSH                            | S/MIME (X.509)              |
|-----------------------|----------------------------|--------------------------------|-----------------------------|
| **Tooling required**  | GnuPG (`gpg`)              | OpenSSH (already installed)    | Certificate from CA/PKI     |
| **Key generation**    | `gpg --full-generate-key`  | `ssh-keygen -t ed25519`        | Issued by corporate CA      |
| **Git config value**  | `gpg.format = openpgp`     | `gpg.format = ssh`             | `gpg.format = x509`         |
| **Signing key**       | Key ID (hex)               | Path to `.pub` file            | Certificate fingerprint     |
| **GitHub verified**   | ✅ Upload public key        | ✅ Upload `.pub` (since 2022)   | ✅ Upload certificate        |
| **GitLab verified**   | ✅                          | ✅ (since 15.7)                 | ✅                           |
| **Bitbucket verified**| ✅                          | ❌ (not yet supported)          | ❌                           |
| **Web of trust**      | Yes (PGP model)            | No                             | Yes (CA hierarchy)          |
| **Windows support**   | Gpg4win                    | Win32-OpenSSH / Git for Windows| Windows cert store           |
| **macOS support**     | Homebrew `gnupg`           | Built-in                       | Keychain Access              |
| **Best for**          | Open-source, cross-platform| Personal/small-team            | Enterprise / regulated       |

## GPG (OpenPGP) — Detailed Setup

### Generate a key
```bash
gpg --full-generate-key
# Choose: RSA and RSA, 4096 bits, email must match git user.email
```

### Find your key ID
```bash
gpg --list-secret-keys --keyid-format=long
# Output example:
# sec   rsa4096/3AA5C34371567BD2 2026-01-01 [SC]
#       Key ID is: 3AA5C34371567BD2
```

### Export your public key (to upload to GitHub/GitLab)
```bash
gpg --armor --export 3AA5C34371234567 > ~/.ssh/id_rsa.pub
```

### Configure git
```bash
git config --local gpg.format    openpgp
git config --local user.signingkey 3AA5C34371567BD2
git config --local commit.gpgsign true
```

### Windows: Gpg4win + GPG Agent
On Windows, install [Gpg4win](https://gpg4win.org/) and configure:
```bash
git config --local gpg.program "C:/Program Files/GnuPG/bin/gpg.exe"
```

### Troubleshooting GPG
| Problem | Solution |
|---------|----------|
| `gpg: signing failed: No secret key` | Key ID doesn't match or key expired. Run `gpg --list-secret-keys`. |
| `gpg: signing failed: Inappropriate ioctl for device` | Set `export GPG_TTY=$(tty)` in your shell profile. |
| `error: gpg failed to sign the data` | Check `gpg.program` path is correct. Try `echo "test" \| gpg --clearsign`. |
| Agent caching expired | Restart agent: `gpgconf --kill gpg-agent` then retry. |
| Windows pinentry not appearing | Install Gpg4win and ensure pinentry is in PATH. |

---

## SSH Signing — Detailed Setup

> Requires Git ≥ 2.34.0

### Generate a key (if needed)
```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

### Configure git
```bash
git config --local gpg.format     ssh
git config --local user.signingkey ~/.ssh/id_ed25519.pub   # PUBLIC key path
git config --local commit.gpgsign true
```

### Allowed signers (for verification)
Git needs an `allowed_signers` file to verify SSH signatures:
```bash
# Create the file
mkdir -p ~/.config/git
echo "you@example.com $(cat ~/.ssh/id_ed25519.pub)" >> ~/.config/git/allowed_signers
git config --local gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
```

Format: `<email> <key-type> <public-key>` — one entry per line.

### Upload to GitHub
Copy your **public** key and add it at:
**GitHub → Settings → SSH and GPG keys → New SSH key → Key type: Signing Key**

### Using SSH agent
If your key is passphrase-protected, make sure `ssh-agent` is running:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

On Windows (Win32-OpenSSH):
```powershell
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
ssh-add ~\.ssh\id_ed25519
```

### Troubleshooting SSH signing
| Problem | Solution |
|---------|----------|
| `error: Load key ... No such file or directory` | Path in `user.signingkey` is wrong or key doesn't exist. |
| `error: ssh-keygen -Y sign is not available` | Git version is too old (< 2.34). Upgrade git. |
| Signature shows as "unverified" on GitHub | Upload the **same** public key as a **Signing Key** (not just auth). |
| `error: Couldn't find key in agent` | Run `ssh-add` to load the key into the agent. |
| Windows: ssh-agent not running | Start the `OpenSSH Authentication Agent` service. |

---

## S/MIME (X.509) — Detailed Setup

Used in enterprises with a PKI / certificate authority.

### Configure git
```bash
git config --local gpg.format     x509
git config --local user.signingkey <certificate-fingerprint>
git config --local commit.gpgsign true
```

### Find your certificate
```bash
# macOS
security find-identity -v -p codesigning

# Windows (PowerShell)
Get-ChildItem Cert:\CurrentUser\My | Format-Table Subject, Thumbprint

# Linux (using gpgsm)
gpgsm --list-keys
```

### Troubleshooting S/MIME
| Problem | Solution |
|---------|----------|
| Certificate not found | Verify it's installed in the correct store (Current User → Personal). |
| Certificate chain untrusted | Import the CA's root/intermediate certificates. |
| Expired certificate | Request a new one from your CA. |

---

## Multi-Identity Patterns

### Pattern 1: `includeIf` (recommended for directory-based separation)

```gitconfig
# ~/.gitconfig
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work

[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal
```

Each included file sets `user.name`, `user.email`, `user.signingkey`, `gpg.format`, and `commit.gpgsign`.

### Pattern 2: Per-repo `.git/config` (this skill's default approach)

Best when repos aren't neatly organized by directory. Use the `configure_signing.sh` script each time you clone a new repo.

### Pattern 3: Git hooks for enforcement

Add a `pre-commit` hook that verifies the identity matches expectations:

```bash
#!/bin/bash
# .git/hooks/pre-commit
EXPECTED_EMAIL="you@company.com"
ACTUAL_EMAIL=$(git config user.email)
if [[ "$ACTUAL_EMAIL" != "$EXPECTED_EMAIL" ]]; then
  echo "ERROR: user.email is '$ACTUAL_EMAIL', expected '$EXPECTED_EMAIL'"
  exit 1
fi
```

---

## Verifying Signatures

```bash
# Verify last commit
git log --show-signature -1

# Verify a specific commit
git verify-commit <commit-hash>

# Verify a tag
git verify-tag <tag-name>

# Show signature status in log (one-line)
git log --format='%H %G? %GS' -5
# G = Good, B = Bad, U = Untrusted, N = No signature, E = Error
```

---

## Platform Registration Checklist

- [ ] **GitHub**: Settings → SSH and GPG keys → add public key (GPG armor / SSH .pub)
- [ ] **GitLab**: Preferences → GPG Keys or SSH Keys → paste public key
- [ ] **Bitbucket**: Personal settings → GPG keys (SSH signing not supported yet)
- [ ] **Azure DevOps**: Relies on GPG; upload via `gpg --export --armor` to repo policies

