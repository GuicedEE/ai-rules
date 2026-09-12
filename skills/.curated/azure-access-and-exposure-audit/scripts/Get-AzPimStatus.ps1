<#
.SYNOPSIS
    Inspect, activate and approve Azure resource-role PIM assignments from the command line.

.DESCRIPTION
    One tool for the whole PIM loop on Azure RESOURCE roles:
      -Report    (default) what am I eligible for, what is active, what is in flight, what does
                 the policy demand, and can I actually write?
      -Activate  raise a SelfActivate request
      -Deactivate hand the role back early
      -Approvals list activations awaiting ME as an approver (and -Approve to action them)

    PIM activation of Azure RESOURCE roles is plain ARM
    (Microsoft.Authorization/roleAssignmentScheduleRequests), so an ordinary `az login` token is
    enough - no Graph SDK, no extra scopes.

    !! DO NOT CONFUSE THE TWO APPROVAL QUEUES !!
    This script covers Azure PIM only. Requests for GROUP MEMBERSHIP (MyAccess / Entra Entitlement
    Management) live in a completely different system, are invisible here, and `az` cannot read
    them at all - its Graph token has no EntitlementManagement.* scope. See
    references/access-and-pim.md.

.PARAMETER SubscriptionId
    Target subscription. Defaults to the current one.

.PARAMETER Role
    Role to act on. Default 'Contributor'.

.PARAMETER Hours
    Activation duration, clamped to the policy maximum. Default 4.

.PARAMETER Justification
    Business justification (most policies require one).

.EXAMPLE
    ./Get-AzPimStatus.ps1
    ./Get-AzPimStatus.ps1 -Activate -Hours 2 -Justification 'INC123 restart app service'
    ./Get-AzPimStatus.ps1 -Approvals
    ./Get-AzPimStatus.ps1 -Approvals -Approve

.NOTES
    Approvals must be run as the account in the APPROVER group - often a separate privileged
    (`T1-`/admin) identity. Signing in with a normal account shows an empty queue even when
    requests exist.
#>
[CmdletBinding()]
param(
    [string]$SubscriptionId,
    [string]$Role = 'Contributor',
    [ValidateRange(1, 24)][int]$Hours = 4,
    [string]$Justification = 'Operational task',
    [switch]$Activate,
    [switch]$Deactivate,
    [switch]$Approvals,
    [switch]$Approve
)

$ErrorActionPreference = 'Stop'

if (-not $SubscriptionId) { $SubscriptionId = (& az account show -o json | ConvertFrom-Json).id }
& az account set --subscription $SubscriptionId | Out-Null
$acct  = (& az account show -o json | ConvertFrom-Json)
$token = (& az account get-access-token --resource https://management.azure.com --query accessToken -o tsv)
$H     = @{ Authorization = "Bearer $token" }
$scope = "/subscriptions/$SubscriptionId"
$api   = 'api-version=2020-10-01'
$base  = "https://management.azure.com$scope/providers/Microsoft.Authorization"

# Caller object id from the token's `oid` claim - no directory read needed.
$pl = ($token.Split('.')[1]).Replace('_','/').Replace('-','+'); while ($pl.Length % 4) { $pl += '=' }
$oid = ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($pl)) | ConvertFrom-Json).oid

Write-Host "==> PIM  $($acct.name)" -ForegroundColor Cyan
Write-Host "    account: $($acct.user.name)  ($oid)"
Write-Host ""

function Get-Arm { param([string]$Url) return Invoke-RestMethod -Method GET -Uri $Url -Headers $H -ErrorAction Stop }

# ---------------- approvals mode ----------------
if ($Approvals) {
    # NOTE: the approvals collection needs the preview api-version; 2020-10-01 returns 404 here.
    $aapi = 'api-version=2021-01-01-preview'
    $list = @()
    try {
        $u = "$base/roleAssignmentApprovals" + "?$aapi" + '&$filter=asApprover()'
        $list = @((Get-Arm $u).value)
    } catch {
        Write-Host "Could not read approvals: $($_.Exception.Message)" -ForegroundColor Red
        return
    }
    if ($list.Count -eq 0) {
        Write-Host "Nothing is awaiting your approval." -ForegroundColor Yellow
        Write-Host "  * Are you signed in as the APPROVER account (often a separate T1-/admin identity)?" -ForegroundColor DarkGray
        Write-Host "  * Group-membership requests do NOT appear here - that is MyAccess, a different system." -ForegroundColor DarkGray
        return
    }
    foreach ($a in $list) {
        $stages = @((Get-Arm "$base/roleAssignmentApprovals/$($a.id)/stages`?$aapi").value)
        Write-Host "  approvalId: $($a.id)"
        foreach ($s in $stages) {
            Write-Host "     stage=$($s.id) status=$($s.status) assignedToMe=$($s.properties.assignedToMe)"
            if ($Approve -and $s.status -eq 'InProgress') {
                $body = @{ properties = @{ reviewResult = 'Approve'; justification = $Justification } } | ConvertTo-Json -Depth 5
                Invoke-RestMethod -Method PATCH -Uri "$base/roleAssignmentApprovals/$($a.id)/stages/$($s.id)`?$aapi" `
                    -Headers $H -ContentType 'application/json' -Body $body | Out-Null
                Write-Host "     APPROVED" -ForegroundColor Green
            }
        }
    }
    if (-not $Approve) { Write-Host ""; Write-Host "Read-only. Re-run with -Approve to action." -ForegroundColor Yellow }
    return
}

# ---------------- report ----------------
$elig = @((Get-Arm ("$base/roleEligibilityScheduleInstances" + "?$api" + '&$filter=asTarget()')).value)
Write-Host "--- Eligible to activate ---" -ForegroundColor Cyan
if ($elig.Count -eq 0) {
    Write-Host "  none." -ForegroundColor Yellow
    Write-Host "  If you were just added to a group, refresh the token: az logout; az login" -ForegroundColor DarkGray
} else {
    foreach ($e in $elig) { Write-Host ("  * {0,-30} via {1}" -f $e.properties.expandedProperties.roleDefinition.displayName, $e.properties.memberType) }
}

$act = @((Get-Arm ("$base/roleAssignmentScheduleInstances" + "?$api" + '&$filter=asTarget()')).value)
Write-Host ""
Write-Host "--- Active right now ---" -ForegroundColor Cyan
foreach ($a in $act) {
    $end = if ($a.properties.endDateTime) { " until $($a.properties.endDateTime)" } else { '' }
    Write-Host ("  {0,-30} [{1}]{2}" -f $a.properties.expandedProperties.roleDefinition.displayName, $a.properties.assignmentType, $end)
}

try {
    $reqs = @((Get-Arm ("$base/roleAssignmentScheduleRequests" + "?$api" + '&$filter=asTarget()')).value)
    $pending = @($reqs | Where-Object { $_.properties.status -notin @('Provisioned','Revoked','Canceled','Denied') })
    if ($pending.Count) {
        Write-Host ""
        Write-Host "--- In flight ---" -ForegroundColor Cyan
        foreach ($p in $pending) {
            Write-Host ("  {0}  status={1}  created={2}" -f $p.properties.expandedProperties.roleDefinition.displayName, $p.properties.status, $p.properties.createdOn) -ForegroundColor Yellow
        }
        Write-Host "  PendingApproval means an APPROVER must action it - see -Approvals." -ForegroundColor DarkGray
    }
} catch { }

$target = $elig | Where-Object { $_.properties.expandedProperties.roleDefinition.displayName -eq $Role } | Select-Object -First 1
if (-not $target) {
    Write-Host ""
    Write-Host "Role '$Role' is not in your eligible set - nothing further to do." -ForegroundColor Yellow
    return
}
$roleDefId = $target.properties.roleDefinitionId

# governing policy
$maxHours = $Hours; $needs = @()
try {
    $paUrl = "$base/roleManagementPolicyAssignments" + "?$api" + '&$filter=' + [uri]::EscapeDataString("roleDefinitionId eq '$roleDefId'")
    $pa = @((Get-Arm $paUrl).value) | Select-Object -First 1
    if ($pa) {
        $policy = Get-Arm "https://management.azure.com$($pa.properties.policyId)?$api"
        Write-Host ""
        Write-Host "--- Policy for '$Role' ---" -ForegroundColor Cyan
        foreach ($r in @($policy.properties.rules)) {
            switch ($r.id) {
                'Expiration_EndUser_Assignment' { if ($r.maximumDuration -match 'PT(\d+)H') { $maxHours = [int]$Matches[1] }; Write-Host "  max duration      : $($r.maximumDuration)" }
                'Enablement_EndUser_Assignment' { $needs = @($r.enabledRules); Write-Host "  required          : $(if($needs.Count){$needs -join ', '}else{'nothing'})" }
                'Approval_EndUser_Assignment'   { Write-Host "  approval required : $([bool]$r.setting.isApprovalRequired)" }
            }
        }
    }
} catch { }
if ($Hours -gt $maxHours) { $Hours = $maxHours }

if (-not $Activate -and -not $Deactivate) {
    Write-Host ""
    Write-Host "READ-ONLY. To activate:" -ForegroundColor Yellow
    Write-Host "  ./Get-AzPimStatus.ps1 -Activate -Hours $Hours -Justification '<why>'" -ForegroundColor Yellow
    return
}

$props = @{
    principalId = $oid; roleDefinitionId = $roleDefId
    requestType = if ($Deactivate) { 'SelfDeactivate' } else { 'SelfActivate' }
    justification = $Justification
}
if (-not $Deactivate) {
    $props.scheduleInfo = @{
        startDateTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        expiration    = @{ type = 'AfterDuration'; duration = "PT${Hours}H" }
    }
    $props.linkedRoleEligibilityScheduleId = $target.properties.roleEligibilityScheduleId
    if ($needs -contains 'Ticketing') { $props.ticketInfo = @{ ticketNumber = 'CHANGE-ME'; ticketSystem = 'Jira' } }
}

$reqId = [guid]::NewGuid().ToString()
Write-Host ""
try {
    $res = Invoke-RestMethod -Method PUT -Headers $H -ContentType 'application/json' `
        -Uri "$base/roleAssignmentScheduleRequests/$reqId`?$api" `
        -Body (@{ properties = $props } | ConvertTo-Json -Depth 6) -ErrorAction Stop
    Write-Host "  status: $($res.properties.status)" -ForegroundColor Green
    if ($res.properties.status -like '*Approval*') {
        Write-Host "  Awaiting an approver. They run: ./Get-AzPimStatus.ps1 -Approvals -Approve" -ForegroundColor Yellow
        Write-Host "  (as the APPROVER identity - often a separate T1-/admin account)" -ForegroundColor DarkGray
    }
} catch {
    $d = ''
    try { $d = (New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd() } catch { }
    Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
    if ($d) { Write-Host "  $d" -ForegroundColor Red }
    Write-Host "  RoleAssignmentRequestPolicyValidationFailed -> justification/ticket/MFA missing or duration too long" -ForegroundColor DarkGray
    Write-Host "  MfaRule / interaction_required             -> re-authenticate: az login" -ForegroundColor DarkGray
    Write-Host "  RoleAssignmentExists                       -> already active" -ForegroundColor DarkGray
}
