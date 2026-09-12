<#
.SYNOPSIS
    Map AD groups to the Azure RBAC they ACTUALLY grant - active and PIM-eligible - per subscription.

.DESCRIPTION
    Answers "which group do I actually need?" with evidence instead of naming convention.

    THIS IS THE HIGHEST-VALUE CHECK IN AN ACCESS INVESTIGATION. Group names lie. A real case:
    a subscription had FIVE `<app> Read/Write/Admins/Member/Lead` groups, and `Write` + `Admins`
    - the two obvious names - carried ZERO RBAC on both subscriptions, active and eligible. Only
    `Member` granted anything. Engineers requested `Write`/`Admins`, got nothing, and their
    requests never appeared in the `Member` approval queue. Weeks were lost before anyone
    enumerated what the groups actually granted.

    Run this BEFORE raising or approving any access request.

.PARAMETER GroupPrefix
    Match groups whose displayName starts with this (e.g. 'IT APP AZ DotCom ffretpol').

.PARAMETER GroupId
    Explicit group object ids, instead of / in addition to a prefix search.

.PARAMETER SubscriptionId
    Subscriptions to evaluate. Defaults to the current one.

.PARAMETER ShowMembers
    Also list group members. Slower on large groups.

.EXAMPLE
    ./Get-AzGroupRbacMap.ps1 -GroupPrefix 'IT APP AZ DotCom ffretpol' -SubscriptionId $dev,$prod -ShowMembers

.NOTES
    Read-only. Requires `az login`; directory read for the group lookups.
#>
[CmdletBinding()]
param(
    [string]$GroupPrefix,
    [string[]]$GroupId,
    [string[]]$SubscriptionId,
    [switch]$ShowMembers
)

$ErrorActionPreference = 'Stop'

# az writes to stderr on failure; with EAP=Stop that becomes a TERMINATING error and silently
# kills the loop. Always funnel az through a wrapper that isolates the preference.
# NOTE: basic function using $args on purpose - a param() block with [Parameter()] makes this an
# advanced function, and az's `-o` then collides with -OutVariable/-OutBuffer ("'o' is ambiguous").
function Invoke-AzSafe {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & az @args 2>&1
        return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = @($out | ForEach-Object { "$_" }) }
    } finally { $ErrorActionPreference = $prev }
}

$groups = @()

if ($GroupPrefix) {
    $r = Invoke-AzSafe ad group list --filter "startswith(displayName,'$GroupPrefix')" --query '[].[id,displayName]' -o tsv
    if ($r.ExitCode -ne 0) { throw "Group lookup failed: $($r.Output -join ' ')" }
    foreach ($line in $r.Output) {
        if ($line -notmatch '\S') { continue }
        $p = $line -split "`t"
        if ($p.Count -ge 2) { $groups += [pscustomobject]@{ Id = $p[0].Trim(); Name = $p[1].Trim() } }
    }
}
foreach ($gid in @($GroupId)) {
    if (-not $gid) { continue }
    $r = Invoke-AzSafe ad group show --group $gid --query 'displayName' -o tsv
    $nm = if ($r.ExitCode -eq 0) { ($r.Output -join '').Trim() } else { '(unreadable)' }
    $groups += [pscustomobject]@{ Id = $gid; Name = $nm }
}

$groups = @($groups | Sort-Object Id -Unique)
if ($groups.Count -eq 0) { throw "No groups matched. Check -GroupPrefix / -GroupId." }

Write-Host "==> Groups discovered: $($groups.Count)" -ForegroundColor Cyan
foreach ($g in $groups) { Write-Host "    $($g.Name)   $($g.Id)" }

if (-not $SubscriptionId -or $SubscriptionId.Count -eq 0) {
    $SubscriptionId = @((& az account show -o json | ConvertFrom-Json).id)
}

$rows = New-Object System.Collections.ArrayList
$failures = 0

foreach ($sub in $SubscriptionId) {
    $subName = $sub
    $tokenResult = Invoke-AzSafe account get-access-token --subscription $sub --resource https://management.azure.com --query accessToken -o tsv
    if ($tokenResult.ExitCode -ne 0) { Write-Host "UNVERIFIABLE subscription $sub : token request failed"; $failures++; continue }
    $token = ($tokenResult.Output -join '').Trim()
    if (-not $token) { Write-Host "UNVERIFIABLE subscription $sub : empty token"; $failures++; continue }
    $H = @{ Authorization = "Bearer $token" }

    foreach ($g in $groups) {
        # ACTIVE assignments
        $a = Invoke-AzSafe role assignment list --assignee $g.Id --subscription $sub --all --include-inherited --query '[].[roleDefinitionName,scope]' -o tsv
        $active = if ($a.ExitCode -eq 0) { @($a.Output | Where-Object { $_ -match '\S' } | Sort-Object -Unique) } else { @() }

        # PIM-ELIGIBLE assignments - a group can grant NOTHING active yet be the only route to
        # Contributor. Miss this and the whole picture is wrong.
        $eligible = @()
        $queryFailed = $a.ExitCode -ne 0
        try {
            $uri = "https://management.azure.com/subscriptions/$sub/providers/Microsoft.Authorization/roleEligibilityScheduleInstances" +
                   "?api-version=2020-10-01&`$filter=" + [uri]::EscapeDataString("principalId eq '$($g.Id)'")
            do {
                $e = Invoke-RestMethod -Uri $uri -Headers $H -ErrorAction Stop
                if ($null -eq $e.value) { throw 'Eligibility response has no value collection' }
                $eligible += @($e.value | ForEach-Object { "$($_.properties.expandedProperties.roleDefinition.displayName) @ $($_.properties.scope)" })
                $uri = $e.nextLink
            } while ($uri)
        } catch { $queryFailed = $true }


        $members = @()
        if ($ShowMembers) {
            $m = Invoke-AzSafe ad group member list --group $g.Id --query '[].userPrincipalName' -o tsv
            if ($m.ExitCode -eq 0) { $members = @($m.Output | Where-Object { $_ -match '\S' }) }
        }

        if ($queryFailed) { $failures++ }
        $grants = if ($queryFailed) { $null } else { $active.Count -gt 0 -or $eligible.Count -gt 0 }

        [void]$rows.Add([pscustomobject]@{
            Subscription = $subName
            Group        = $g.Name
            Active       = if ($active.Count)   { $active -join ', ' }   else { if ($queryFailed) { '(unknown)' } else { '(none)' } }
            Eligible     = if ($eligible.Count) { $eligible -join ', ' } else { if ($queryFailed) { '(unknown)' } else { '(none)' } }
            QueryStatus = if ($queryFailed) { 'UNVERIFIABLE (partial results)' } else { 'complete' }
            GrantsAnything = $grants
            Members      = if ($ShowMembers) { $members.Count } else { $null }
            MemberList   = if ($ShowMembers) { $members -join ', ' } else { $null }
        })
    }
}

Write-Host ""
Write-Host "================ GROUP -> RBAC ================" -ForegroundColor Cyan
foreach ($sub in ($rows.Subscription | Sort-Object -Unique)) {
    Write-Host ""
    Write-Host "--- $sub ---" -ForegroundColor Cyan
    foreach ($r in @($rows | Where-Object { $_.Subscription -eq $sub })) {
        $flag = if ($null -eq $r.GrantsAnything) { '[?]' } elseif ($r.GrantsAnything) { '   ' } else { '[!]' }
        $col  = if ($r.GrantsAnything) { 'Gray' } else { 'Red' }
        Write-Host "$flag $($r.Group) - $($r.QueryStatus)" -ForegroundColor $col
        Write-Host "      ACTIVE   : $($r.Active)"
        Write-Host "      ELIGIBLE : $($r.Eligible)"
        if ($ShowMembers) { Write-Host "      MEMBERS($($r.Members)): $($r.MemberList)" -ForegroundColor DarkGray }
    }
}

$dead = @($rows | Where-Object { $_.GrantsAnything -eq $false } | ForEach-Object { "$($_.Group) in subscription $($_.Subscription)" })
if ($dead.Count) {
    Write-Host ""
    Write-Host "[!] No active or eligible assignments were found for these group/subscription pairs:" -ForegroundColor Red
    foreach ($d in $dead) { Write-Host "      $d" -ForegroundColor Red }
    Write-Host "    Other subscriptions, nested groups, deny assignments, conditions, and directory roles require separate evaluation."
}
if ($failures -gt 0) { exit 1 }
exit 0
