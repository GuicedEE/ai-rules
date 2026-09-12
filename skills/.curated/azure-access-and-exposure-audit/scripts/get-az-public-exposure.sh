#!/usr/bin/env bash
# Report the REAL public-network exposure of an Azure subscription. (Linux/macOS)
#
# WHY NOT RESOURCE GRAPH: `resources | project properties.publicNetworkAccess` returns EMPTY
# STRINGS for App Services, Key Vaults and storage accounts - ARG's cached projection does not
# populate that property for those types. Reporting from ARG produces a false "not disabled" for
# every one of them. ARG is fine for INVENTORY, never for the exposure verdict.
#
# WHY NOT `az resource show` OVER EVERYTHING: enumerating a whole subscription sequentially times
# out. Filtering to the ~17 exposure-carrying types below keeps it to a handful of calls.
#
# Dependencies: `az` only. No jq, no curl - all parsing uses `az --query ... -o tsv`.
# Portable to bash 3.2 (macOS default): no associative arrays, no mapfile.
#
# NOTE: deliberately NOT using `set -e`. A failed lookup on one resource must not abort the whole
# audit - that is the bash equivalent of the PowerShell $ErrorActionPreference='Stop' trap, where a
# loop dies mid-run and a half-finished audit looks complete.

set -uo pipefail

usage() {
  cat <<'EOF'
Usage: get-az-public-exposure.sh [-s SUBSCRIPTION_ID]... [-a] [-c CSV_PATH]

  -s  Subscription id. Repeatable. Defaults to the current `az account`.
  -a  Also list resources that are already compliant.
  -c  Write findings to this CSV path as well.
  -h  Help.

Read-only. Requires `az login` with at least Reader on the target subscriptions.
EOF
}

SUBS=""
SHOW_ALL=0
CSV_PATH=""

while getopts ":s:ac:h" opt; do
  case "$opt" in
    s) SUBS="$SUBS $OPTARG" ;;
    a) SHOW_ALL=1 ;;
    c) CSV_PATH="$OPTARG" ;;
    h) usage; exit 0 ;;
    \?) echo "unknown option -$OPTARG" >&2; usage; exit 2 ;;
    :) echo "option -$OPTARG needs a value" >&2; exit 2 ;;
  esac
done

command -v az >/dev/null 2>&1 || { echo "az CLI not found on PATH" >&2; exit 1; }

# Two traps, both of which silently produce WRONG audit verdicts. Fixed centrally here rather than
# at ~10 call sites:
#
#  1. CRLF. `az` emits CRLF on Windows/Git-bash and on WSL when it resolves az.exe from the Windows
#     PATH. A trailing \r makes [ "$pna" != "Disabled" ] TRUE for a value that IS "Disabled", so a
#     compliant resource is reported as a FINDING.
#  2. STDIN. Some `az` subcommands READ STDIN. Inside a `while read` loop that consumes the loop's
#     input, so the loop exits after ONE iteration - verified: a 5-group map reported only 1 group
#     and looked like a complete result. `</dev/null` is the fix.
#
# Defined AFTER the check above on purpose - `command -v az` would otherwise match this function.
# Verified on Linux: `set -o pipefail` keeps az's exit code and stderr capture working.
az() { command az "$@" </dev/null | tr -d '\r'; }

if [ -z "${SUBS// /}" ]; then
  SUBS="$(az account show --query id -o tsv 2>/dev/null)"
  [ -n "$SUBS" ] || { echo "not logged in - run: az login" >&2; exit 1; }
fi

# Types that can carry inbound public exposure, with the api-version that exposes the property.
# Bounded inventory; other resource types require a separate assessment.
TYPES="
Microsoft.Web/sites
Microsoft.KeyVault/vaults
Microsoft.Storage/storageAccounts
Microsoft.Sql/servers
Microsoft.DBforPostgreSQL/flexibleServers
Microsoft.DBforMySQL/flexibleServers
Microsoft.DocumentDB/databaseAccounts
Microsoft.ContainerRegistry/registries
Microsoft.Cache/Redis
Microsoft.ServiceBus/namespaces
Microsoft.EventHub/namespaces
Microsoft.CognitiveServices/accounts
Microsoft.Search/searchServices
Microsoft.ContainerService/managedClusters
Microsoft.AppConfiguration/configurationStores
Microsoft.Network/publicIPAddresses
Microsoft.Cdn/profiles
"

api_version_for() {
  case "$1" in
    Microsoft.Web/sites)                        echo "2023-01-01" ;;
    Microsoft.KeyVault/vaults)                  echo "2023-07-01" ;;
    Microsoft.Storage/storageAccounts)          echo "2023-01-01" ;;
    Microsoft.Sql/servers)                      echo "2023-05-01-preview" ;;
    Microsoft.DBforPostgreSQL/flexibleServers)  echo "2023-03-01-preview" ;;
    Microsoft.DBforMySQL/flexibleServers)       echo "2023-06-30" ;;
    Microsoft.DocumentDB/databaseAccounts)      echo "2023-11-15" ;;
    Microsoft.ContainerRegistry/registries)     echo "2023-07-01" ;;
    Microsoft.Cache/Redis)                      echo "2023-08-01" ;;
    Microsoft.ServiceBus/namespaces)            echo "2022-10-01-preview" ;;
    Microsoft.EventHub/namespaces)              echo "2024-01-01" ;;
    Microsoft.CognitiveServices/accounts)       echo "2023-05-01" ;;
    Microsoft.Search/searchServices)            echo "2023-11-01" ;;
    Microsoft.ContainerService/managedClusters) echo "2024-02-01" ;;
    Microsoft.AppConfiguration/configurationStores) echo "2023-03-01" ;;
    Microsoft.Network/publicIPAddresses)        echo "2023-09-01" ;;
    Microsoft.Cdn/profiles)                     echo "2023-05-01" ;;
    *)                                          echo "2021-04-01" ;;
  esac
}

RESULTS_FILE="$(mktemp "${TMPDIR:-/tmp}/azexposure.XXXXXX")" || exit 2
trap 'rm -f "$RESULTS_FILE"' EXIT
failures=0
findings=0
emit() {
  # Include subscription and resource id so repeated names cannot be confused.
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "${4:-(not reported)}" "$5" "$sub" "${id:--}" >> "$RESULTS_FILE"
  [ "$1" != unverifiable ] || failures=$((failures+1))
  [ "$1" != FINDING ] || findings=$((findings+1))
  return 0
}

# Follow list pagination, preserving failure status. A partial list is never a clean result.
arm_list() {
  local url="$1" query="$2" page next
  while [ -n "$url" ] && [ "$url" != None ]; do
    page="$(az rest --method GET --url "$url" --query "$query" -o tsv)" || return 1
    next="$(az rest --method GET --url "$url" --query nextLink -o tsv)" || return 1
    [ -z "$page" ] || printf '%s\n' "$page"
    url="$next"
  done
}

for sub in $SUBS; do
  printf '\n==> %s\n' "$sub"
  id=""
  for type in $TYPES; do
    apiv="$(api_version_for "$type")"
    if ! ids="$(az resource list --subscription "$sub" --resource-type "$type" --query '[].id' -o tsv)"; then
      emit unverifiable "$sub" "$type" 'inventory failed' 'Azure resource list failed'; continue
    fi
    while IFS= read -r id; do
      [ -n "$id" ] || continue
      name="${id##*/}"
      # One direct read, with fixed columns. JSON null is rendered as None in TSV.
      query='[[properties.publicNetworkAccess,properties.network.publicNetworkAccess,sku.name,properties.apiServerAccessProfile.enablePrivateCluster,properties.apiServerAccessProfile.authorizedIPRanges,properties.networkAcls.defaultAction,properties.networkRuleSet.defaultAction,properties.ipRules,properties.isVirtualNetworkFilterEnabled,properties.natGateway.id,properties.ipAddress]]'
      if ! row="$(az resource show --ids "$id" --api-version "$apiv" --query "$query" -o tsv)" || [ -z "$row" ]; then
        emit unverifiable "$name" "$type" 'ARM read failed' 'Cannot assess resource controls'; continue
      fi
      pna="$(printf '%s' "$row" | cut -f1)"
      sev=unverifiable; detail='Missing or unsupported network controls'; verdict="$pna"
      case "$type" in
        Microsoft.Network/publicIPAddresses)
          natgw="$(printf '%s' "$row" | cut -f10)"; verdict="$(printf '%s' "$row" | cut -f11)"
          sev=info; detail='Association requires inbound rule assessment'
          if [ -n "$natgw" ] && [ "$natgw" != None ]; then sev=explained; detail='natGateway (EGRESS ONLY)'; fi
          ;;
        Microsoft.Cdn/profiles)
          sku="$(printf '%s' "$row" | cut -f3)"
          case "$sku" in
            Standard_AzureFrontDoor|Premium_AzureFrontDoor)
              if ! policies="$(arm_list "https://management.azure.com${id}/securityPolicies?api-version=${apiv}" 'value[].name')"; then
                emit unverifiable "$name" "$type" 'WAF read failed' 'Cannot enumerate security policies'; continue
              fi
              n="$(printf '%s\n' "$policies" | grep -c . || true)"; verdict="WAF policies: $n"
              if [ "$n" -eq 0 ]; then sev=FINDING; detail='Front Door has no security policy'
              else sev=info; detail='Policies present; verify domain/path associations and WAF mode'; fi
              ;;
            *) verdict='unsupported CDN SKU'; detail="SKU=$sku; assess CDN endpoint WAF separately" ;;
          esac
          ;;
        Microsoft.ContainerService/managedClusters)
          private="$(printf '%s' "$row" | cut -f4)"; ranges="$(printf '%s' "$row" | cut -f5)"
          verdict="enablePrivateCluster=$private"
          case "$private" in
            true|True) sev=ok; detail='Private API server' ;;
            false|False)
              detail="Public API server; authorizedIPRanges=$ranges"
              case "$ranges" in ''|None|'[]') sev=FINDING ;; *) sev=info ;; esac ;;
          esac
          ;;
        Microsoft.Sql/servers|Microsoft.DBforPostgreSQL/flexibleServers|Microsoft.DBforMySQL/flexibleServers)
          [ "$type" = Microsoft.Sql/servers ] || pna="$(printf '%s' "$row" | cut -f2)"
          verdict="$pna"
          if [ "$pna" = Disabled ]; then sev=ok; detail='Public network access disabled'
          elif [ "$pna" = Enabled ]; then
            if ! rules="$(arm_list "https://management.azure.com${id}/firewallRules?api-version=${apiv}" 'value[].[properties.startIpAddress,properties.endIpAddress]')"; then
              emit unverifiable "$name" "$type" 'firewall read failed' 'Cannot assess public endpoint'; continue
            fi
            n="$(printf '%s\n' "$rules" | grep -c . || true)"
            sev=info
            if printf '%s\n' "$rules" | grep -q "^0\.0\.0\.0$(printf '\t')255\.255\.255\.255$"; then sev=FINDING; fi
            detail="Public endpoint; firewallRules=$n; review ranges and service bypasses"
          fi
          ;;
        Microsoft.Storage/storageAccounts|Microsoft.KeyVault/vaults|Microsoft.CognitiveServices/accounts|Microsoft.ContainerRegistry/registries)
          da="$(printf '%s' "$row" | cut -f6)"
          [ "$type" != Microsoft.ContainerRegistry/registries ] || da="$(printf '%s' "$row" | cut -f7)"
          detail="defaultAction=$da; review allow rules and bypasses"
          if [ "$pna" = Disabled ]; then
            if [ "$da" = Deny ]; then sev=ok; else sev=weak-2nd-control; fi
          elif [ "$pna" = Enabled ]; then
            case "$da" in Allow) sev=FINDING ;; Deny) sev=info ;; esac
          fi
          ;;
        Microsoft.DocumentDB/databaseAccounts)
          ips="$(printf '%s' "$row" | cut -f8)"; vnet="$(printf '%s' "$row" | cut -f9)"
          detail="ipRules=$ips; isVirtualNetworkFilterEnabled=$vnet"
          if [ "$pna" = Disabled ]; then sev=ok
          elif [ "$pna" = Enabled ] && [ "$ips" != None ]; then
            case "$vnet" in
              true|True) sev=info ;;
              false|False) if [ "$ips" = '[]' ]; then sev=FINDING; elif [ -n "$ips" ]; then sev=info; fi ;;
            esac
          fi
          ;;
        Microsoft.Web/sites)
          [ "$pna" != Disabled ] || sev=ok
          detail='Enabled/absent PNA requires site access restriction and private endpoint assessment'
          if slots="$(arm_list "https://management.azure.com${id}/slots?api-version=${apiv}" 'value[].[name,properties.publicNetworkAccess]')"; then
            while IFS= read -r slot; do
              [ -n "$slot" ] || continue
              sn="$(printf '%s' "$slot" | cut -f1)"; sp="$(printf '%s' "$slot" | cut -f2)"
              ss=unverifiable; [ "$sp" != Disabled ] || ss=ok
              emit "$ss" "$sn" 'Microsoft.Web/sites/slots' "$sp" 'Assess slot networking independently of the parent site'
            done <<EOF
$slots
EOF
          else emit unverifiable "$name" 'Microsoft.Web/sites/slots' 'slot inventory failed' 'Cannot assess deployment slots'; fi
          ;;
        *)
          if [ "$pna" = Disabled ]; then sev=ok; detail='Public network access disabled'
          else detail='Public endpoint requires service-specific firewall/network rule assessment'; fi
          ;;
      esac
      emit "$sev" "$name" "$type" "$verdict" "$detail"
    done <<EOF
$ids
EOF
  done
done

printf '\nSeverity\tName\tType\tVerdict\tDetail\tSubscription\tResourceId\n'
if [ "$SHOW_ALL" -eq 1 ]; then cat "$RESULTS_FILE"
else grep -v "^ok$(printf '\t')" "$RESULTS_FILE" || true; fi
printf '\nTotals: %s finding(s), %s unverifiable result(s). Configuration audit, not a connectivity test.\n' "$findings" "$failures"
if [ -n "$CSV_PATH" ]; then
  # Quote every field, doubling embedded quotes. TSV fields contain no newlines.
  { echo 'Severity,Name,Type,Verdict,Detail,Subscription,ResourceId'
    while IFS= read -r line; do
      escaped="${line//\"/\"\"}"
      escaped="${escaped//$'\t'/\",\"}"
      printf '"%s"\n' "$escaped"
    done < "$RESULTS_FILE"
  } > "$CSV_PATH" || exit 2
fi
[ "$failures" -eq 0 ] || exit 2
[ "$findings" -eq 0 ] || exit 1
exit 0
