<#
.SYNOPSIS
    Set networkAcls/networkRuleSet defaultAction=Deny on storage accounts and Key Vaults.

.DESCRIPTION
    Closes the SECOND line of defence. `publicNetworkAccess = Disabled` already blocks the public
    endpoint; this makes the ACL deny-by-default too, so a future accidental flip of
    publicNetworkAccess does not immediately expose the resource.

    Report-only by default. -Apply makes the change.

.PARAMETER Target
    One or more targets. Each is a hashtable:
        @{ Kind='storage'|'keyvault'; Sub='<subid>'; Rg='<rg>'; Name='<name>'; Label='dev' }

.PARAMETER TargetJsonPath
    Path to a JSON file containing an array of the same objects - easier for larger estates.

.PARAMETER Apply
    Actually make the change.

.EXAMPLE
    ./Set-AzNetworkAclHardening.ps1 -TargetJsonPath .\targets.json
    ./Set-AzNetworkAclHardening.ps1 -TargetJsonPath .\targets.json -Apply

.NOTES
    ---------------------------------------------------------------------------------------------
    !! CHECK FOR TERRAFORM/IaC DRIFT BEFORE APPLYING !!

    These properties are usually managed by the platform's IaC. This script changes them OUT OF
    BAND. If the module manages network rules, the next apply REVERTS this and the fix belongs in
    the platform module instead. Apply in a non-production environment first, then run a plan and
    check for drift on these resources.

    If the storage account is an IaC STATE BACKEND, getting this wrong can lock CI out of its own
    state. `defaultAction=Deny` while publicNetworkAccess is already Disabled should be a no-op
    for runners reaching it over a private endpoint - verify a plan still runs before production.

    Requires Contributor on the target scope (PIM-activate first - see Get-AzPimStatus.ps1).
    Reader alone fails with AuthorizationFailed on Microsoft.Storage/storageAccounts/write and
    Microsoft.KeyVault/vaults/write.
#>
[CmdletBinding()]
param(
    [hashtable[]]$Target,
    [string]$TargetJsonPath,
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'

# az writes to stderr on ANY ARM failure. With $ErrorActionPreference='Stop' PowerShell turns that
# into a TERMINATING error, so the script dies mid-loop BEFORE its own error branch runs - the
# failure is invisible and the remaining targets are silently skipped. A half-failed run then looks
# identical to a successful one. Funnel every az call through this.
# NOTE: basic function using $args on purpose - a param() block with [Parameter()] makes this an
# advanced function and az's `-o` collides with -OutVariable/-OutBuffer ("'o' is ambiguous").
function Invoke-AzSafe {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & az @args 2>&1
        return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($out | Out-String).Trim() }
    } finally { $ErrorActionPreference = $prev }
}

function Format-AzError {
    $t = $args[0]
    if (-not $t) { return '(no output)' }
    $l = (($t -split "`r?`n" | Where-Object { $_ -match '\S' } | Select-Object -First 1)).Trim()
    if ($l.Length -gt 240) { $l = $l.Substring(0,240) + '...' }
    return $l
}

$targets = @()
if ($TargetJsonPath) {
    $targets += (Get-Content $TargetJsonPath -Raw | ConvertFrom-Json)
}
foreach ($t in @($Target)) { if ($t) { $targets += [pscustomobject]$t } }
if ($targets.Count -eq 0) { throw "No targets. Supply -Target or -TargetJsonPath." }

Write-Host "==> network ACL hardening" -ForegroundColor Cyan
Write-Host "    account : $((& az account show -o json | ConvertFrom-Json).user.name)"
Write-Host "    mode    : $(if ($Apply) { 'APPLY' } else { 'REPORT ONLY' })"
Write-Host ""

$failures = 0
foreach ($t in $targets) {
    & az account set --subscription $t.Sub | Out-Null
    $label = if ($t.Label) { "[$($t.Label)] " } else { '' }
    Write-Host "--- $label$($t.Name) ($($t.Kind)) ---" -ForegroundColor Cyan

    if ($t.Kind -eq 'storage') {
        $show = Invoke-AzSafe storage account show -n $t.Name -g $t.Rg -o json
        if ($show.ExitCode -ne 0) { Write-Host "    CANNOT READ: $(Format-AzError $show.Output)" -ForegroundColor Red; $failures++; continue }
        $j = $show.Output | ConvertFrom-Json
        Write-Host "    publicNetworkAccess          = $($j.publicNetworkAccess)"
        Write-Host "    networkRuleSet.defaultAction = $($j.networkRuleSet.defaultAction)   (desired: Deny)"
        if ($j.networkRuleSet.defaultAction -eq 'Deny') { Write-Host "    already compliant" -ForegroundColor Green; continue }
        if (-not $Apply) { Write-Host "    WOULD RUN: az storage account update -n $($t.Name) -g $($t.Rg) --default-action Deny --bypass AzureServices" -ForegroundColor Yellow; continue }
        $r = Invoke-AzSafe storage account update -n $t.Name -g $t.Rg --default-action Deny --bypass AzureServices -o none
        if ($r.ExitCode -eq 0) { Write-Host "    set defaultAction=Deny" -ForegroundColor Green }
        else { Write-Host "    FAILED (exit $($r.ExitCode)): $(Format-AzError $r.Output)" -ForegroundColor Red; $failures++ }
    }
    elseif ($t.Kind -eq 'keyvault') {
        $show = Invoke-AzSafe keyvault show -n $t.Name -g $t.Rg -o json
        if ($show.ExitCode -ne 0) { Write-Host "    CANNOT READ: $(Format-AzError $show.Output)" -ForegroundColor Red; $failures++; continue }
        $j = $show.Output | ConvertFrom-Json
        # @($null).Count returns 1 in PowerShell - null-check the ACL block BEFORE counting rules,
        # or you will report an IP allow-list that does not exist.
        $acls = $j.properties.networkAcls
        $da   = if ($acls) { $acls.defaultAction } else { $null }
        Write-Host "    publicNetworkAccess       = $($j.properties.publicNetworkAccess)"
        Write-Host "    networkAcls.defaultAction = $(if ($da) { $da } else { '<networkAcls ABSENT>' })   (desired: Deny)"
        if ($da -eq 'Deny') { Write-Host "    already compliant" -ForegroundColor Green; continue }
        if (-not $Apply) { Write-Host "    WOULD RUN: az keyvault update -n $($t.Name) -g $($t.Rg) --default-action Deny --bypass AzureServices" -ForegroundColor Yellow; continue }
        $r = Invoke-AzSafe keyvault update -n $t.Name -g $t.Rg --default-action Deny --bypass AzureServices -o none
        if ($r.ExitCode -eq 0) { Write-Host "    set defaultAction=Deny" -ForegroundColor Green }
        else { Write-Host "    FAILED (exit $($r.ExitCode)): $(Format-AzError $r.Output)" -ForegroundColor Red; $failures++ }
    }
    else { Write-Host "    unknown Kind '$($t.Kind)' - expected 'storage' or 'keyvault'" -ForegroundColor Red; $failures++ }
}

Write-Host ""
if ($failures -gt 0) {
    Write-Host "$failures target(s) FAILED." -ForegroundColor Red
    Write-Host "AuthorizationFailed usually means standing access is Reader only - activate" -ForegroundColor Yellow
    Write-Host "Contributor via PIM first:  ./Get-AzPimStatus.ps1 -Activate -Hours 2 -Justification '<why>'" -ForegroundColor Yellow
}
if ($Apply -and $failures -eq 0) {
    Write-Host "Applied. Now check for IaC drift before the next environment:" -ForegroundColor Yellow
    Write-Host "  run a plan and confirm these resources show no changes."
} elseif (-not $Apply) {
    Write-Host "Report only. Re-run with -Apply to make the changes." -ForegroundColor Yellow
} else {
    Write-Host "Nothing was changed - resolve the failures above and re-run." -ForegroundColor Yellow
}

exit $(if ($failures -gt 0) { 1 } else { 0 })
