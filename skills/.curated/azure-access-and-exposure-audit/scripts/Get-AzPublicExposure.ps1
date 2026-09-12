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
# Anything not in this list cannot be publicly reachable on its own.
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

function Invoke-Arm {
    # Isolates $ErrorActionPreference so a native/HTTP failure reports instead of killing the run.
    param([string]$Uri, [hashtable]$Headers)
    try { return Invoke-RestMethod -Method GET -Uri $Uri -Headers $Headers -ErrorAction Stop }
    catch { return $null }
}

if (-not $SubscriptionId -or $SubscriptionId.Count -eq 0) {
    $cur = (& az account show -o json | ConvertFrom-Json)
    $SubscriptionId = @($cur.id)
}

$findings = New-Object System.Collections.ArrayList

foreach ($sub in $SubscriptionId) {
    & az account set --subscription $sub | Out-Null
    $subName = (& az account show -o json | ConvertFrom-Json).name
    $token = (& az account get-access-token --resource https://management.azure.com --query accessToken -o tsv)
    $H = @{ Authorization = "Bearer $token" }

    Write-Host ""
    Write-Host "==> $subName" -ForegroundColor Cyan
    Write-Host "    $sub" -ForegroundColor DarkGray

    foreach ($type in $TypeMap.Keys) {
        $apiv = $TypeMap[$type]
        $listUri = "https://management.azure.com/subscriptions/$sub/resources?api-version=2021-04-01&`$filter=" +
                   [uri]::EscapeDataString("resourceType eq '$type'")
        $list = Invoke-Arm -Uri $listUri -Headers $H
        if (-not $list) { continue }

        foreach ($r in @($list.value)) {
            $full = Invoke-Arm -Uri "https://management.azure.com$($r.id)?api-version=$apiv" -Headers $H
            if (-not $full) { continue }

            $p = $full.properties
            $verdict = 'unknown'; $detail = ''; $severity = 'info'

            switch -Wildcard ($type) {
                'Microsoft.Network/publicIPAddresses' {
                    # A public IP is NOT automatically exposure. NAT-gateway / LB-outbound IPs are
                    # EGRESS ONLY and accept no inbound connections. Scanners flag these constantly.
                    $assoc = 'unattached'
                    if ($p.ipConfiguration.id)   { $assoc = 'ipConfiguration' }
                    if ($p.natGateway.id)        { $assoc = 'natGateway (EGRESS ONLY)' }
                    $verdict  = $p.ipAddress
                    $detail   = "attached to: $assoc"
                    $severity = if ($assoc -like 'natGateway*') { 'explained' } else { 'info' }
                }
                'Microsoft.Cdn/profiles' {
                    # Front Door is public BY DESIGN. What matters is whether a WAF is attached.
                    $sp = Invoke-Arm -Headers $H -Uri ("https://management.azure.com$($r.id)/securityPolicies?api-version=$apiv")
                    $n  = @($sp.value).Count
                    $verdict  = "WAF security policies: $n"
                    $severity = if ($n -eq 0) { 'FINDING' } else { 'ok' }
                    $detail   = if ($n -eq 0) { 'internet-facing edge with NO WAF attached' } else { (@($sp.value).name -join ', ') }
                }
                'Microsoft.Storage/storageAccounts' {
                    $verdict = $p.publicNetworkAccess
                    $da      = $p.networkAcls.defaultAction
                    $detail  = "networkAcls.defaultAction=$da; allowBlobPublicAccess=$($p.allowBlobPublicAccess)"
                    if ($verdict -ne 'Disabled')      { $severity = 'FINDING' }
                    elseif ($da -ne 'Deny')           { $severity = 'weak-2nd-control' }
                    else                              { $severity = 'ok' }
                }
                'Microsoft.KeyVault/vaults' {
                    $verdict = $p.publicNetworkAccess
                    # @($null).Count returns 1 in PowerShell - null-check BEFORE counting or you
                    # will report a non-existent IP allow-list.
                    $acls    = $p.networkAcls
                    $da      = if ($acls) { $acls.defaultAction } else { $null }
                    $ipCount = if ($acls -and $acls.ipRules) { @($acls.ipRules).Count } else { 0 }
                    $detail  = if ($acls) { "networkAcls.defaultAction=$da; ipRules=$ipCount" } else { 'networkAcls ABSENT' }
                    if ($verdict -ne 'Disabled')      { $severity = 'FINDING' }
                    elseif (-not $acls -or $da -ne 'Deny') { $severity = 'weak-2nd-control' }
                    else                              { $severity = 'ok' }
                }
                'Microsoft.Web/sites' {
                    $verdict  = $p.publicNetworkAccess
                    $detail   = "httpsOnly=$($full.properties.httpsOnly)"
                    $severity = if ($verdict -eq 'Disabled') { 'ok' } else { 'FINDING' }
                    # Slots inherit the parent's private endpoint but carry their OWN
                    # publicNetworkAccess - always check them separately.
                    $slots = Invoke-Arm -Headers $H -Uri ("https://management.azure.com$($r.id)/slots?api-version=$apiv")
                    foreach ($s in @($slots.value)) {
                        $sv = $s.properties.publicNetworkAccess
                        [void]$findings.Add([pscustomobject]@{
                            Subscription = $subName; Type = 'Microsoft.Web/sites/slots'
                            Name = $s.name; ResourceGroup = $r.resourceGroup
                            Verdict = $sv; Detail = 'slot inherits parent private endpoint'
                            Severity = if ($sv -eq 'Disabled') { 'ok' } else { 'FINDING' }
                        })
                    }
                }
                default {
                    $verdict = if ($null -ne $p.publicNetworkAccess) { $p.publicNetworkAccess } else { '(not reported)' }
                    $severity = if ($verdict -eq 'Disabled') { 'ok' } elseif ($verdict -eq '(not reported)') { 'info' } else { 'FINDING' }
                }
            }

            [void]$findings.Add([pscustomobject]@{
                Subscription = $subName; Type = $type; Name = $r.name
                ResourceGroup = $r.resourceGroup; Verdict = $verdict
                Detail = $detail; Severity = $severity
            })
        }
    }
}

$show = if ($IncludeCompliant) { $findings } else { $findings | Where-Object { $_.Severity -ne 'ok' } }

Write-Host ""
Write-Host "================ RESULTS ================" -ForegroundColor Cyan
foreach ($grp in @('FINDING', 'weak-2nd-control', 'explained', 'info', 'ok')) {
    $rows = @($show | Where-Object { $_.Severity -eq $grp })
    if ($rows.Count -eq 0) { continue }
    $colour = switch ($grp) {
        'FINDING'          { 'Red' }
        'weak-2nd-control' { 'Yellow' }
        'explained'        { 'DarkGray' }
        default            { 'Gray' }
    }
    Write-Host ""
    Write-Host "--- $grp ($($rows.Count)) ---" -ForegroundColor $colour
    $rows | Format-Table Name, Type, Verdict, Detail -AutoSize | Out-String | Write-Host
}

Write-Host ""
Write-Host "Totals: $(@($findings | Where-Object {$_.Severity -eq 'FINDING'}).Count) finding(s), " -NoNewline -ForegroundColor Red
Write-Host "$(@($findings | Where-Object {$_.Severity -eq 'weak-2nd-control'}).Count) weak second control, " -NoNewline -ForegroundColor Yellow
Write-Host "$(@($findings | Where-Object {$_.Severity -eq 'ok'}).Count) compliant." -ForegroundColor Green

if ($CsvPath) {
    $findings | Export-Csv -NoTypeInformation -Path $CsvPath
    Write-Host "CSV written: $CsvPath" -ForegroundColor Green
}
