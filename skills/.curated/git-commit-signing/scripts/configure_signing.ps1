#Requires -Version 5.1
<#
.SYNOPSIS
    Interactive git commit signing setup for the current repository (Windows/PowerShell).
.DESCRIPTION
    Configures user identity and signing method (GPG, SSH, or S/MIME) at the
    local (per-repo) level so each repository uses the correct credentials.
.EXAMPLE
    pwsh scripts/configure_signing.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info  { param([string]$Msg) Write-Host "ℹ $Msg" -ForegroundColor Cyan }
function Write-Ok    { param([string]$Msg) Write-Host "✔ $Msg" -ForegroundColor Green }
function Write-Warn  { param([string]$Msg) Write-Host "⚠ $Msg" -ForegroundColor Yellow }

# ── Guard: must be inside a git repo ────────────────────────────────────────
$isRepo = git rev-parse --is-inside-work-tree 2>$null
if ($LASTEXITCODE -ne 0 -or $isRepo -ne 'true') {
    Write-Error 'Not inside a git repository.'
    exit 1
}
$repoRoot = git rev-parse --show-toplevel
Write-Host "`nGit Commit Signing — Configure for: $repoRoot`n" -ForegroundColor White

# ── Step 1: User identity ──────────────────────────────────────────────────
$currentName  = git config --local user.name  2>$null
if (-not $currentName) { $currentName = git config user.name 2>$null }
$currentEmail = git config --local user.email 2>$null
if (-not $currentEmail) { $currentEmail = git config user.email 2>$null }

Write-Info "Current identity: $($currentName ?? '<not set>') <$($currentEmail ?? '<not set>')>"

$inputName  = Read-Host "user.name  [$currentName]"
$inputEmail = Read-Host "user.email [$currentEmail]"

$name  = if ($inputName)  { $inputName }  else { $currentName }
$email = if ($inputEmail) { $inputEmail } else { $currentEmail }

if (-not $name -or -not $email) {
    Write-Error 'user.name and user.email are required.'
    exit 1
}

git config --local user.name  $name
git config --local user.email $email
Write-Ok "Identity set: $name <$email>"

# ── Step 2: Choose signing method ──────────────────────────────────────────
Write-Host ''
Write-Info 'Select signing method:'
Write-Host '  1) GPG  (openpgp) — widest platform support'
Write-Host '  2) SSH  — simple, reuses existing SSH keys'
Write-Host '  3) S/MIME (x509) — corporate PKI'
$methodChoice = Read-Host 'Choice [1]'
if (-not $methodChoice) { $methodChoice = '1' }

switch ($methodChoice) {
    '1' {
        $format = 'openpgp'
        Write-Info 'Available GPG secret keys:'
        $gpgExe = Get-Command gpg -ErrorAction SilentlyContinue
        if (-not $gpgExe) {
            $gpgExe = Get-Command gpg.exe -ErrorAction SilentlyContinue
        }
        # Try common Windows install paths
        if (-not $gpgExe) {
            $candidates = @(
                "${env:ProgramFiles}\GnuPG\bin\gpg.exe",
                "${env:ProgramFiles}\Git\usr\bin\gpg.exe",
                "${env:ProgramFiles(x86)}\GnuPG\bin\gpg.exe",
                "${env:LOCALAPPDATA}\GnuPG\bin\gpg.exe"
            )
            foreach ($c in $candidates) {
                if (Test-Path $c) { $gpgExe = $c; break }
            }
        }
        if ($gpgExe) {
            & $gpgExe --list-secret-keys --keyid-format=long 2>$null
            git config --local gpg.program "$($gpgExe)"
        } else {
            Write-Warn 'gpg not found. Install GnuPG or set gpg.program manually.'
        }

        $keyId = Read-Host 'Enter GPG key ID (long form)'
        if (-not $keyId) { Write-Error 'Signing key is required.'; exit 1 }

        git config --local gpg.format     openpgp
        git config --local user.signingkey $keyId
    }
    '2' {
        $format = 'ssh'
        $sshDir = Join-Path $HOME '.ssh'
        Write-Info 'Available SSH public keys:'
        if (Test-Path $sshDir) {
            Get-ChildItem "$sshDir\*.pub" | ForEach-Object { Write-Host "  $_" }
        } else {
            Write-Warn "No .ssh directory found at $sshDir"
        }

        $defaultKey = Join-Path $sshDir 'id_ed25519.pub'
        $sshKey = Read-Host "Path to SSH public key [$defaultKey]"
        if (-not $sshKey) { $sshKey = $defaultKey }
        if (-not (Test-Path $sshKey)) {
            Write-Error "File not found: $sshKey"
            exit 1
        }

        git config --local gpg.format     ssh
        git config --local user.signingkey $sshKey

        # Set up allowed_signers for verification
        $allowedSigners = Join-Path $HOME '.config\git\allowed_signers'
        $parentDir = Split-Path $allowedSigners -Parent
        if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }

        $pubKeyContent = Get-Content $sshKey -Raw
        $signerLine = "$email $pubKeyContent".Trim()
        $existing = if (Test-Path $allowedSigners) { Get-Content $allowedSigners -Raw } else { '' }
        if ($existing -notlike "*$signerLine*") {
            Add-Content -Path $allowedSigners -Value $signerLine
            Write-Ok "Added entry to $allowedSigners"
        }
        git config --local gpg.ssh.allowedSignersFile $allowedSigners
    }
    '3' {
        $format = 'x509'
        $certId = Read-Host 'Enter certificate ID / fingerprint'
        if (-not $certId) { Write-Error 'Certificate ID is required.'; exit 1 }

        git config --local gpg.format     x509
        git config --local user.signingkey $certId
    }
    default {
        Write-Error 'Invalid choice.'
        exit 1
    }
}

# ── Step 3: Enable auto-signing ───────────────────────────────────────────
git config --local commit.gpgsign true
git config --local tag.gpgsign    true
Write-Ok "Auto-signing enabled for commits and tags (format: $format)"

# ── Step 4: Summary ───────────────────────────────────────────────────────
Write-Host ''
Write-Host '── Current signing configuration ──' -ForegroundColor White
Write-Host "  user.name       = $(git config --local user.name)"
Write-Host "  user.email      = $(git config --local user.email)"
Write-Host "  gpg.format      = $(git config --local gpg.format)"
Write-Host "  user.signingkey = $(git config --local user.signingkey)"
Write-Host "  commit.gpgsign  = $(git config --local commit.gpgsign)"
Write-Host "  tag.gpgsign     = $(git config --local tag.gpgsign)"
Write-Host ''
Write-Info "Run 'git commit --allow-empty -S -m `"test signing`"' to verify."

