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
    [string]$TicketNumber,
    [string]$TicketSystem,
    [switch]$Activate,
    [switch]$Deactivate,
    [switch]$Approvals,
    [switch]$Approve
)

$ErrorActionPreference = 'Stop'

function Invoke-AzChecked {
    $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try {
        $out = & az @args 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Azure CLI failed: $out" }
        return ($out | Out-String).Trim()
    } finally { $ErrorActionPreference = $prev }
}
if ($Activate -and $Deactivate) { throw 'Choose -Activate or -Deactivate' }
if ($Approve -and -not $Approvals) { throw '-Approve requires -Approvals' }
if ($Approvals -and ($Activate -or $Deactivate)) { throw 'Approval and activation modes are separate' }
if (-not $SubscriptionId) { $SubscriptionId = (Invoke-AzChecked account show -o json | ConvertFrom-Json).id }
if (-not $SubscriptionId) { throw 'No target subscription' }
$acct = Invoke-AzChecked account show --subscription $SubscriptionId -o json | ConvertFrom-Json
$token = Invoke-AzChecked account get-access-token --subscription $SubscriptionId --resource https://management.azure.com --query accessToken -o tsv
$H     = @{ Authorization = "Bearer $token" }
$scope = "/subscriptions/$SubscriptionId"
$api   = 'api-version=2020-10-01'
$base  = "https://management.azure.com$scope/providers/Microsoft.Authorization"

# Caller object id from the token's `oid` claim - no directory read needed.
$pl = ($token.Split('.')[1]).Replace('_','/').Replace('-','+'); while ($pl.Length % 4) { $pl += '=' }
$oid = ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($pl)) | ConvertFrom-Json).oid

if (-not $oid) { throw 'ARM token has no oid claim; cannot identify the principal' }

Write-Host "==> PIM  $($acct.name)" -ForegroundColor Cyan
Write-Host "    account: $($acct.user.name)  ($oid)"
Write-Host ""

function Get-Arm { param([string]$Url) return Invoke-RestMethod -Method GET -Uri $Url -Headers $H -ErrorAction Stop }

function Get-ArmList {
    param([string]$Url)
    do {
        $page = Get-Arm $Url
        if ($null -eq $page.value) { throw "ARM list has no value collection: $Url" }
        $page.value
        $Url = $page.nextLink
    } while ($Url)
}

# ---------------- approvals mode ----------------
if ($Approvals) {
    # NOTE: the approvals collection needs the preview api-version; 2020-10-01 returns 404 here.
    $aapi = 'api-version=2021-01-01-preview'
    $list = @()
    try {
        $u = "$base/roleAssignmentApprovals" + "?$aapi" + '&$filter=asApprover()'
        $list = @(Get-ArmList $u)
    } catch {
        Write-Host "Could not read approvals: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    if ($list.Count -eq 0) {
        Write-Host "Nothing is awaiting your approval." -ForegroundColor Yellow
        Write-Host "  * Are you signed in as the APPROVER account (often a separate T1-/admin identity)?" -ForegroundColor DarkGray
        Write-Host "  * Group-membership requests do NOT appear here - that is MyAccess, a different system." -ForegroundColor DarkGray
        return
    }
    foreach ($a in $list) {
        $stages = @(Get-ArmList "https://management.azure.com$($a.id)/stages`?$aapi")
        Write-Host "  approvalId: $($a.id)"
        foreach ($s in $stages) {
            Write-Host "     stage=$($s.id) status=$($s.properties.status) assignedToMe=$($s.properties.assignedToMe)"
            if ($Approve -and $s.properties.status -eq 'InProgress' -and $s.properties.assignedToMe -eq $true) {
                $body = @{ properties = @{ reviewResult = 'Approve'; justification = $Justification } } | ConvertTo-Json -Depth 5
                Invoke-RestMethod -Method PATCH -Uri "https://management.azure.com$($s.id)`?$aapi" `
                    -Headers $H -ContentType 'application/json' -Body $body | Out-Null
                Write-Host "     APPROVED" -ForegroundColor Green
            }
        }
    }
    if (-not $Approve) { Write-Host ""; Write-Host "Read-only. Re-run with -Approve to action." -ForegroundColor Yellow }
    return
}

# ---------------- report ----------------
$elig = @(Get-ArmList ("$base/roleEligibilityScheduleInstances" + "?$api" + '&$filter=asTarget()'))
Write-Host "--- Eligible to activate ---" -ForegroundColor Cyan
if ($elig.Count -eq 0) {
    Write-Host "  none." -ForegroundColor Yellow
    Write-Host "  If you were just added to a group, refresh the token: az logout; az login" -ForegroundColor DarkGray
} else {
    foreach ($e in $elig) { Write-Host ("  * {0,-30} via {1}" -f $e.properties.expandedProperties.roleDefinition.displayName, $e.properties.memberType) }
}

$act = @(Get-ArmList ("$base/roleAssignmentScheduleInstances" + "?$api" + '&$filter=asTarget()'))
Write-Host ""
Write-Host "--- Active right now ---" -ForegroundColor Cyan
foreach ($a in $act) {
    $end = if ($a.properties.endDateTime) { " until $($a.properties.endDateTime)" } else { '' }
    Write-Host ("  {0,-30} [{1}]{2}" -f $a.properties.expandedProperties.roleDefinition.displayName, $a.properties.assignmentType, $end)
}

try {
    $reqs = @(Get-ArmList ("$base/roleAssignmentScheduleRequests" + "?$api" + '&$filter=asTarget()'))
    $pending = @($reqs | Where-Object { $_.properties.status -notin @('Provisioned','Revoked','Canceled','Denied') })
    if ($pending.Count) {
        Write-Host ""
        Write-Host "--- In flight ---" -ForegroundColor Cyan
        foreach ($p in $pending) {
            Write-Host ("  {0}  status={1}  created={2}" -f $p.properties.expandedProperties.roleDefinition.displayName, $p.properties.status, $p.properties.createdOn) -ForegroundColor Yellow
        }
        Write-Host "  PendingApproval means an APPROVER must action it - see -Approvals." -ForegroundColor DarkGray
    }
} catch { throw "Cannot read PIM state or policy: $($_.Exception.Message)" }

$targets = @($elig | Where-Object { $_.properties.expandedProperties.roleDefinition.displayName -eq $Role })
if ($targets.Count -gt 1) { throw 'Multiple eligible assignments match; inspect role and scope before activation' }
$target = $targets | Select-Object -First 1
if (-not $target) {
    Write-Host ""
    Write-Host "Role '$Role' is not in your eligible set - nothing further to do." -ForegroundColor Yellow
    if ($Activate -or $Deactivate) { exit 1 }
    return
}
$roleDefId = $target.properties.roleDefinitionId

# governing policy
$maxHours = $Hours; $needs = @()
try {
    $paUrl = "$base/roleManagementPolicyAssignments" + "?$api" + '&$filter=' + [uri]::EscapeDataString("roleDefinitionId eq '$roleDefId'")
    $pa = @(Get-ArmList $paUrl) | Select-Object -First 1
    if (-not $pa) { throw 'No governing policy assignment returned' }
    if ($pa) {
        $policy = Get-Arm "https://management.azure.com$($pa.properties.policyId)?$api"
        Write-Host ""
        Write-Host "--- Policy for '$Role' ---" -ForegroundColor Cyan
        foreach ($r in @($policy.properties.rules)) {
            switch ($r.id) {
                'Expiration_EndUser_Assignment' { $maxHours = [System.Xml.XmlConvert]::ToTimeSpan($r.maximumDuration).TotalHours; Write-Host "  max duration      : $($r.maximumDuration)" }
                'Enablement_EndUser_Assignment' { $needs = @($r.enabledRules); Write-Host "  required          : $(if($needs.Count){$needs -join ', '}else{'nothing'})" }
                'Approval_EndUser_Assignment'   { Write-Host "  approval required : $([bool]$r.setting.isApprovalRequired)" }
            }
        }
    }
} catch { throw "Cannot read PIM state or policy: $($_.Exception.Message)" }
$duration = [TimeSpan]::FromHours([Math]::Min([double]$Hours, [double]$maxHours))

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
        expiration    = @{ type = 'AfterDuration'; duration = [System.Xml.XmlConvert]::ToString($duration) }
    }
    $props.linkedRoleEligibilityScheduleId = $target.properties.roleEligibilityScheduleId
    if ($needs -contains 'Ticketing' -and ([string]::IsNullOrWhiteSpace($TicketNumber) -or [string]::IsNullOrWhiteSpace($TicketSystem))) {
        throw 'Policy requires -TicketNumber and -TicketSystem'
    }
    if ($TicketNumber -and $TicketSystem) { $props.ticketInfo = @{ ticketNumber = $TicketNumber; ticketSystem = $TicketSystem } }
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
    try { $d = (New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd() } catch { $d = '' }
    Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
    if ($d) { Write-Host "  $d" -ForegroundColor Red }
    Write-Host "  RoleAssignmentRequestPolicyValidationFailed -> justification/ticket/MFA missing or duration too long" -ForegroundColor DarkGray
    Write-Host "  MfaRule / interaction_required             -> re-authenticate: az login" -ForegroundColor DarkGray
    Write-Host "  RoleAssignmentExists                       -> already active" -ForegroundColor DarkGray
    exit 1
}
