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
# Anything not listed cannot be publicly reachable on its own.
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

# NOTE: bare `mktemp` is a GNU extension. BSD/macOS mktemp requires a template or -t, so an
# explicit template is used - bare mktemp fails there and, with no `set -e`, the audit would carry
# on appending to an empty path and report "0 findings" on a subscription it never examined.
RESULTS_FILE="$(mktemp "${TMPDIR:-/tmp}/azexposure.XXXXXX")"
trap 'rm -f "$RESULTS_FILE"' EXIT

emit() { # severity | name | type | verdict | detail
  printf '%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" "$5" >> "$RESULTS_FILE"
}

for sub in $SUBS; do
  az account set --subscription "$sub" >/dev/null 2>&1 || { echo "cannot select subscription $sub" >&2; continue; }
  sub_name="$(az account show --query name -o tsv 2>/dev/null)"
  printf '\n==> %s\n    %s\n' "$sub_name" "$sub"

  for type in $TYPES; do
    apiv="$(api_version_for "$type")"

    ids="$(az resource list --resource-type "$type" --query '[].id' -o tsv 2>/dev/null)"
    [ -n "$ids" ] || continue

    while IFS= read -r id; do
      [ -n "$id" ] || continue
      name="${id##*/}"
      rg="$(printf '%s' "$id" | sed -n 's#.*/resourceGroups/\([^/]*\)/.*#\1#p')"

      case "$type" in

        Microsoft.Network/publicIPAddresses)
          # A public IP is NOT automatically exposure. NAT-gateway / LB-outbound IPs are EGRESS
          # ONLY and accept no inbound connections. Scanners flag these constantly.
          # NOTE the DOUBLE brackets: `--query '[a,b]' -o tsv` emits one value per LINE, so cut -f
          # returns the whole blob and every comparison below is wrong. `[[a,b]]` emits ONE
          # tab-separated row. Verified on Linux.
          row="$(az resource show --ids "$id" --api-version "$apiv" \
                 --query '[[properties.ipAddress, properties.natGateway.id, properties.ipConfiguration.id]]' \
                 -o tsv 2>/dev/null)"
          ip="$(printf '%s' "$row" | cut -f1)"
          natgw="$(printf '%s' "$row" | cut -f2)"
          ipcfg="$(printf '%s' "$row" | cut -f3)"
          if [ -n "$natgw" ] && [ "$natgw" != "None" ]; then
            emit "explained" "$name" "$type" "$ip" "attached to: natGateway (EGRESS ONLY)"
          elif [ -n "$ipcfg" ] && [ "$ipcfg" != "None" ]; then
            emit "info" "$name" "$type" "$ip" "attached to: ipConfiguration"
          else
            emit "info" "$name" "$type" "$ip" "unattached"
          fi
          ;;

        Microsoft.Cdn/profiles)
          # Front Door is public BY DESIGN. What matters is whether a WAF is attached.
          n="$(az rest --method GET \
                 --url "https://management.azure.com${id}/securityPolicies?api-version=${apiv}" \
                 --query 'value[].name' -o tsv 2>/dev/null | grep -c . || true)"
          if [ "${n:-0}" -eq 0 ]; then
            emit "FINDING" "$name" "$type" "WAF policies: 0" "internet-facing edge with NO WAF attached"
          else
            emit "ok" "$name" "$type" "WAF policies: $n" "attached"
          fi
          ;;

        Microsoft.Storage/storageAccounts)
          row="$(az resource show --ids "$id" --api-version "$apiv" \
                 --query '[[properties.publicNetworkAccess, properties.networkAcls.defaultAction, properties.allowBlobPublicAccess]]' \
                 -o tsv 2>/dev/null)"
          pna="$(printf '%s' "$row" | cut -f1)"
          da="$(printf '%s'  "$row" | cut -f2)"
          blob="$(printf '%s' "$row" | cut -f3)"
          detail="networkAcls.defaultAction=$da; allowBlobPublicAccess=$blob"
          if [ "$pna" != "Disabled" ]; then   emit "FINDING" "$name" "$type" "$pna" "$detail"
          elif [ "$da" != "Deny" ]; then      emit "weak-2nd-control" "$name" "$type" "$pna" "$detail"
          else                                emit "ok" "$name" "$type" "$pna" "$detail"; fi
          ;;

        Microsoft.KeyVault/vaults)
          row="$(az resource show --ids "$id" --api-version "$apiv" \
                 --query '[[properties.publicNetworkAccess, properties.networkAcls.defaultAction]]' \
                 -o tsv 2>/dev/null)"
          pna="$(printf '%s' "$row" | cut -f1)"
          da="$(printf '%s'  "$row" | cut -f2)"
          if [ -z "$da" ] || [ "$da" = "None" ]; then detail="networkAcls ABSENT"; da=""
          else detail="networkAcls.defaultAction=$da"; fi
          if [ "$pna" != "Disabled" ]; then   emit "FINDING" "$name" "$type" "$pna" "$detail"
          elif [ "$da" != "Deny" ]; then      emit "weak-2nd-control" "$name" "$type" "$pna" "$detail"
          else                                emit "ok" "$name" "$type" "$pna" "$detail"; fi
          ;;

        Microsoft.Web/sites)
          pna="$(az resource show --ids "$id" --api-version "$apiv" \
                 --query 'properties.publicNetworkAccess' -o tsv 2>/dev/null)"
          [ "$pna" = "Disabled" ] && sev="ok" || sev="FINDING"
          emit "$sev" "$name" "$type" "$pna" "site"
          # A slot inherits the parent's private endpoint but carries its OWN publicNetworkAccess.
          slots="$(az rest --method GET \
                     --url "https://management.azure.com${id}/slots?api-version=${apiv}" \
                     --query 'value[].[name,properties.publicNetworkAccess]' -o tsv 2>/dev/null)"
          if [ -n "$slots" ]; then
            while IFS= read -r sline; do
              [ -n "$sline" ] || continue
              sname="$(printf '%s' "$sline" | cut -f1)"
              spna="$(printf '%s' "$sline" | cut -f2)"
              [ "$spna" = "Disabled" ] && ssev="ok" || ssev="FINDING"
              emit "$ssev" "$sname" "Microsoft.Web/sites/slots" "$spna" "slot inherits parent private endpoint"
            done <<EOF
$slots
EOF
          fi
          ;;

        *)
          pna="$(az resource show --ids "$id" --api-version "$apiv" \
                 --query 'properties.publicNetworkAccess' -o tsv 2>/dev/null)"
          if [ -z "$pna" ] || [ "$pna" = "None" ]; then emit "info" "$name" "$type" "(not reported)" ""
          elif [ "$pna" = "Disabled" ]; then            emit "ok" "$name" "$type" "$pna" ""
          else                                          emit "FINDING" "$name" "$type" "$pna" ""; fi
          ;;
      esac
    done <<EOF
$ids
EOF
  done
done

# ---------------- report ----------------
printf '\n================ RESULTS ================\n'
for sev in FINDING weak-2nd-control explained info ok; do
  [ "$SHOW_ALL" -eq 0 ] && [ "$sev" = "ok" ] && continue
  rows="$(grep "^${sev}	" "$RESULTS_FILE" 2>/dev/null || true)"
  [ -n "$rows" ] || continue
  count="$(printf '%s\n' "$rows" | grep -c . || true)"
  printf '\n--- %s (%s) ---\n' "$sev" "$count"
  printf '%s\n' "$rows" | while IFS="	" read -r s n t v d; do
    printf '  %-38s %-42s %-12s %s\n' "$n" "$t" "$v" "$d"
  done
done

nf="$(grep -c '^FINDING	'          "$RESULTS_FILE" 2>/dev/null || true)"
nw="$(grep -c '^weak-2nd-control	' "$RESULTS_FILE" 2>/dev/null || true)"
no="$(grep -c '^ok	'               "$RESULTS_FILE" 2>/dev/null || true)"
printf '\nTotals: %s finding(s), %s weak second control, %s compliant.\n' "${nf:-0}" "${nw:-0}" "${no:-0}"

if [ -n "$CSV_PATH" ]; then
  { echo "Severity,Name,Type,Verdict,Detail"
    while IFS="	" read -r s n t v d; do
      printf '"%s","%s","%s","%s","%s"\n' "$s" "$n" "$t" "$v" "$d"
    done < "$RESULTS_FILE"
  } > "$CSV_PATH"
  printf 'CSV written: %s\n' "$CSV_PATH"
fi

[ "${nf:-0}" -gt 0 ] && exit 1
exit 0
