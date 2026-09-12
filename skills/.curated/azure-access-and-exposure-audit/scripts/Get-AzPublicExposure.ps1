<#
.SYNOPSIS
    Report the REAL public-network exposure of an Azure subscription.

.DESCRIPTION
    Enumerates only the resource types that can actually carry public exposure, then reads each one
    with a direct ARM GET and reports the properties that decide exposure.

    WHY NOT RESOURCE GRAPH: `resources | project properties.publicNetworkAccess` returns EMPTY
    STRINGS for App Services, Key Vaults and storage accounts - ARG's cached projection does not
    populate that property for those types. Reporting from ARG produces a false "not disabled" for
    every one of them. ARG is fine for INVENTORY, never for the exposure verdict.

    WHY NOT `az resource show` OVER EVERYTHING: enumerating a whole subscription sequentially times
    out. Filtering to the ~17 exposure-carrying types below keeps it to a handful of calls.

.PARAMETER SubscriptionId
    One or more subscription ids. Defaults to the current `az account` subscription.

.PARAMETER IncludeCompliant
    Also list resources that are already locked down. Default shows only findings + informational.

.PARAMETER CsvPath
    Optional path to also write the findings as CSV.

.EXAMPLE
    ./Get-AzPublicExposure.ps1
    ./Get-AzPublicExposure.ps1 -SubscriptionId aaaa-...,bbbb-... -CsvPath .\exposure.csv

.NOTES
    Read-only. Requires `az login` with at least Reader on the target subscriptions.
#>
[CmdletBinding()]
param(
    [string[]]$SubscriptionId,
    [switch]$IncludeCompliant,
    [string]$CsvPath
)

$ErrorActionPreference = 'Stop'

# Types that can carry inbound public exposure, with the api-version that exposes the property.
# This inventory is bounded; resources outside it require a separate assessment.
$TypeMap = [ordered]@{
    'Microsoft.Web/sites'                                          = '2023-01-01'
    'Microsoft.KeyVault/vaults'                                    = '2023-07-01'
    'Microsoft.Storage/storageAccounts'                            = '2023-01-01'
    'Microsoft.Sql/servers'                                        = '2023-05-01-preview'
    'Microsoft.DBforPostgreSQL/flexibleServers'                    = '2023-03-01-preview'
    'Microsoft.DBforMySQL/flexibleServers'                         = '2023-06-30'
    'Microsoft.DocumentDB/databaseAccounts'                        = '2023-11-15'
    'Microsoft.ContainerRegistry/registries'                       = '2023-07-01'
    'Microsoft.Cache/Redis'                                        = '2023-08-01'
    'Microsoft.ServiceBus/namespaces'                              = '2022-10-01-preview'
    'Microsoft.EventHub/namespaces'                                = '2024-01-01'
    'Microsoft.CognitiveServices/accounts'                         = '2023-05-01'
    'Microsoft.Search/searchServices'                              = '2023-11-01'
    'Microsoft.ContainerService/managedClusters'                   = '2024-02-01'
    'Microsoft.AppConfiguration/configurationStores'               = '2023-03-01'
    'Microsoft.Network/publicIPAddresses'                          = '2023-09-01'
    'Microsoft.Cdn/profiles'                                       = '2023-05-01'
}

function Invoke-AzChecked {
    $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try {
        $out = & az @args 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Azure CLI failed: $out" }
        return ($out | Out-String).Trim()
    } finally { $ErrorActionPreference = $prev }
}

function Get-Arm {
    param([string]$Uri)
    return Invoke-RestMethod -Method GET -Uri $Uri -Headers $H -ErrorAction Stop
}

function Get-ArmList {
    param([string]$Uri)
    do {
        $page = Get-Arm $Uri
        if ($null -eq $page.value) { throw "ARM list has no value collection: $Uri" }
        $page.value
        $Uri = $page.nextLink
    } while ($Uri)
}

function Add-Result {
    param([string]$Severity, [string]$Name, [string]$Type, [string]$Verdict, [string]$Detail, [string]$Id)
    [void]$findings.Add([pscustomobject]@{
        Subscription = $sub; Name = $Name; Type = $Type; ResourceId = $Id
        Severity = $Severity; Verdict = $Verdict; Detail = $Detail
    })
}

if (-not $SubscriptionId) {
    $SubscriptionId = @((Invoke-AzChecked account show -o json | ConvertFrom-Json).id)
    if (-not $SubscriptionId[0]) { throw 'No current subscription. Supply -SubscriptionId.' }
}
$findings = New-Object System.Collections.ArrayList
foreach ($sub in $SubscriptionId) {
    Write-Host "==> $sub"
    try {
        $token = Invoke-AzChecked account get-access-token --subscription $sub --resource https://management.azure.com --query accessToken -o tsv
        if (-not $token) { throw 'No ARM access token returned' }
        $H = @{ Authorization = "Bearer $token" }
    } catch { Add-Result 'unverifiable' $sub 'subscription' 'token failed' $_.Exception.Message ''; continue }
    foreach ($type in $TypeMap.Keys) {
        $apiv = $TypeMap[$type]
        $listUri = "https://management.azure.com/subscriptions/$sub/resources?api-version=2021-04-01&`$filter=" + [uri]::EscapeDataString("resourceType eq '$type'")
        try { $resources = @(Get-ArmList $listUri) }
        catch { Add-Result 'unverifiable' $sub $type 'inventory failed' $_.Exception.Message ''; continue }
        foreach ($r in $resources) {
            try {
                $full = Get-Arm "https://management.azure.com$($r.id)?api-version=$apiv"
                if (-not $full.properties) { throw 'Resource response has no properties' }
                $p = $full.properties; $pna = $p.publicNetworkAccess
                $severity = 'unverifiable'; $verdict = "$pna"; $detail = 'Missing or unsupported network controls'
                switch ($type) {
                    'Microsoft.Network/publicIPAddresses' {
                        $verdict = $p.ipAddress; $severity = 'info'; $detail = 'Association requires inbound rule assessment'
                        if ($p.natGateway.id) { $severity = 'explained'; $detail = 'natGateway (EGRESS ONLY)' }
                    }
                    'Microsoft.Cdn/profiles' {
                        if ($full.sku.name -notin @('Standard_AzureFrontDoor','Premium_AzureFrontDoor')) {
                            $verdict = 'unsupported CDN SKU'; $detail = "SKU=$($full.sku.name); assess CDN endpoint WAF separately"
                        } else {
                            $policies = @(Get-ArmList "https://management.azure.com$($r.id)/securityPolicies?api-version=$apiv")
                            $verdict = "WAF policies: $($policies.Count)"
                            if ($policies.Count -eq 0) { $severity = 'FINDING'; $detail = 'Front Door has no security policy' }
                            else { $severity = 'info'; $detail = 'Policies present; verify domain/path associations and WAF mode' }
                        }
                    }
                    'Microsoft.ContainerService/managedClusters' {
                        $private = $p.apiServerAccessProfile.enablePrivateCluster
                        $verdict = "enablePrivateCluster=$private"
                        if ($private -eq $true) { $severity = 'ok'; $detail = 'Private API server' }
                        elseif ($private -eq $false) {
                            $ranges = @($p.apiServerAccessProfile.authorizedIPRanges | Where-Object { $_ })
                            $severity = if ($ranges.Count -gt 0) { 'info' } else { 'FINDING' }
                            $detail = "Public API server; authorizedIPRanges=$($ranges -join ',')"
                        }
                    }
                    { $_ -in @('Microsoft.Sql/servers','Microsoft.DBforPostgreSQL/flexibleServers','Microsoft.DBforMySQL/flexibleServers') } {
                        if ($type -ne 'Microsoft.Sql/servers') { $pna = $p.network.publicNetworkAccess }
                        $verdict = "$pna"
                        if ($pna -eq 'Disabled') { $severity = 'ok'; $detail = 'Public network access disabled' }
                        elseif ($pna -eq 'Enabled') {
                            $rules = @(Get-ArmList "https://management.azure.com$($r.id)/firewallRules?api-version=$apiv")
                            $wide = @($rules | Where-Object { $_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '255.255.255.255' })
                            $severity = if ($wide.Count) { 'FINDING' } else { 'info' }
                            $detail = "Public endpoint; firewallRules=$($rules.Count); review ranges and service bypasses"
                        }
                    }
                    { $_ -in @('Microsoft.Storage/storageAccounts','Microsoft.KeyVault/vaults','Microsoft.CognitiveServices/accounts','Microsoft.ContainerRegistry/registries') } {
                        $acl = if ($type -eq 'Microsoft.ContainerRegistry/registries') { $p.networkRuleSet } else { $p.networkAcls }
                        $da = $acl.defaultAction
                        $ips = @($acl.ipRules | Where-Object { $_ }).Count
                        $detail = "defaultAction=$da; ipRules=$ips; review allow rules and bypasses"
                        if ($pna -eq 'Disabled') { $severity = if ($da -eq 'Deny') { 'ok' } else { 'weak-2nd-control' } }
                        elseif ($pna -eq 'Enabled') {
                            if ($da -eq 'Allow') { $severity = 'FINDING' }
                            elseif ($da -eq 'Deny') { $severity = 'info' }
                        }
                    }
                    'Microsoft.DocumentDB/databaseAccounts' {
                        $ips = @($p.ipRules | Where-Object { $_ }).Count
                        $detail = "ipRules=$ips; isVirtualNetworkFilterEnabled=$($p.isVirtualNetworkFilterEnabled)"
                        if ($pna -eq 'Disabled') { $severity = 'ok' }
                        elseif ($pna -eq 'Enabled' -and $null -ne $p.isVirtualNetworkFilterEnabled -and $null -ne $p.ipRules) {
                            $severity = if ($ips -gt 0 -or $p.isVirtualNetworkFilterEnabled) { 'info' } else { 'FINDING' }
                        }
                    }
                    'Microsoft.Web/sites' {
                        $severity = if ($pna -eq 'Disabled') { 'ok' } else { 'unverifiable' }
                        $detail = 'Enabled/absent PNA requires site access restriction and private endpoint assessment'
                        try {
                            $slots = @(Get-ArmList "https://management.azure.com$($r.id)/slots?api-version=$apiv")
                            foreach ($slot in $slots) {
                                $sv = $slot.properties.publicNetworkAccess
                                $ss = if ($sv -eq 'Disabled') { 'ok' } else { 'unverifiable' }
                                Add-Result $ss $slot.name 'Microsoft.Web/sites/slots' "$sv" 'Assess slot networking independently of the parent site' $slot.id
                            }
                        } catch { Add-Result 'unverifiable' $r.name 'Microsoft.Web/sites/slots' 'slot inventory failed' $_.Exception.Message $r.id }
                    }
                    default {
                        if ($pna -eq 'Disabled') { $severity = 'ok'; $detail = 'Public network access disabled' }
                        else { $detail = 'Public endpoint requires service-specific firewall/network rule assessment' }
                    }
                }
                Add-Result $severity $r.name $type $verdict $detail $r.id
            } catch { Add-Result 'unverifiable' $r.name $type 'ARM read failed' $_.Exception.Message $r.id }
        }
    }
}
$show = if ($IncludeCompliant) { $findings } else { $findings | Where-Object { $_.Severity -ne 'ok' } }
$show | Format-Table Subscription, Name, Severity, Verdict, Detail -AutoSize | Out-String -Width 300 | Write-Host
$failed = @($findings | Where-Object { $_.Severity -eq 'unverifiable' }).Count
$found = @($findings | Where-Object { $_.Severity -eq 'FINDING' }).Count
Write-Host "Totals: $found finding(s), $failed unverifiable result(s). This is a configuration audit, not a connectivity test."
if ($CsvPath) { $findings | Export-Csv -NoTypeInformation -Path $CsvPath }
if ($failed -gt 0) { exit 2 }
if ($found -gt 0) { exit 1 }
exit 0
