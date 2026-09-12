#!/usr/bin/env bash
# Set networkAcls/networkRuleSet defaultAction=Deny on storage accounts and Key Vaults. (Linux/macOS)
#
# Closes the SECOND line of defence. `publicNetworkAccess = Disabled` already blocks the public
# endpoint; this makes the ACL deny-by-default too, so a future accidental flip of
# publicNetworkAccess does not immediately expose the resource.
#
# Report-only by default. Pass -A to apply.
#
# ---------------------------------------------------------------------------------------------
# !! CHECK FOR TERRAFORM/IaC DRIFT BEFORE APPLYING !!
# These properties are usually managed by the platform's IaC. This script changes them OUT OF
# BAND. If the module manages network rules, the next apply REVERTS this and the fix belongs in
# the platform module instead. Apply in non-production first, then run a plan and check for drift.
#
# If the storage account is an IaC STATE BACKEND, getting this wrong can lock CI out of its own
# state. `defaultAction=Deny` while publicNetworkAccess is already Disabled should be a no-op for
# runners reaching it over a private endpoint - verify a plan still runs before production.
#
# Requires Contributor on the target scope (PIM-activate first - see get-az-pim-status.sh).
# Reader alone fails with AuthorizationFailed.
#
# Dependencies: `az` only. No jq. Portable to bash 3.2 (macOS default).
#
# NOTE: deliberately NOT using `set -e`. With it, the first failing `az` call aborts the loop
# before the failure is reported and silently skips the remaining targets - a half-failed run then
# looks identical to a successful one. Failures are counted and reported instead.

set -uo pipefail

usage() {
  cat <<'EOF'
Usage: set-az-network-acl-hardening.sh -f TARGETS_TSV [-A]

  -f  TSV file, one target per line, TAB-separated (real tabs, NOT spaces):
        kind<TAB>subscription<TAB>resourceGroup<TAB>name<TAB>label
      kind is 'storage' or 'keyvault'. Lines starting with # are ignored.
  -A  Apply. Without it the script only reports.
  -h  Help.

Generate a targets file safely (avoids hand-typing tabs):
  printf 'storage\t%s\t%s\t%s\t%s\n'  SUB RG NAME   dev  > targets.tsv
  printf 'keyvault\t%s\t%s\t%s\t%s\n' SUB RG KVNAME dev >> targets.tsv
EOF
}

TARGETS=""
APPLY=0

while getopts ":f:Ah" opt; do
  case "$opt" in
    f) TARGETS="$OPTARG" ;;
    A) APPLY=1 ;;
    h) usage; exit 0 ;;
    \?) echo "unknown option -$OPTARG" >&2; usage; exit 2 ;;
    :) echo "option -$OPTARG needs a value" >&2; exit 2 ;;
  esac
done

command -v az >/dev/null 2>&1 || { echo "az CLI not found on PATH" >&2; exit 1; }
[ -n "$TARGETS" ] || { echo "supply -f TARGETS_TSV" >&2; usage; exit 2; }

# Two traps, both of which silently produce WRONG results. Fixed centrally rather than per call:
#
#  1. CRLF. `az` emits CRLF on Windows/Git-bash and on WSL when it resolves az.exe from the Windows
#     PATH. A trailing \r makes [ "$da" = "Deny" ] false for a value that IS "Deny", so an
#     already-compliant resource gets needlessly rewritten.
#  2. STDIN. Some `az` subcommands READ STDIN, consuming this script's targets file mid-loop so
#     only the FIRST target is processed - and the run still reports success. `</dev/null` fixes it.
#
# Defined AFTER the check above on purpose - `command -v az` would otherwise match this function.
# Verified on Linux: pipefail keeps az's exit code AND the 2>&1 stderr capture used below working.
az() { command az "$@" </dev/null | tr -d '\r'; }
[ -f "$TARGETS" ] || { echo "targets file not found: $TARGETS" >&2; exit 1; }

# Fail fast on an empty or space-aligned file. Without this a space-aligned line lands whole in
# $kind, every target is rejected as "unknown kind", and the run looks like a data problem rather
# than a formatting one.
TAB="$(printf '\t')"
if ! grep -v '^[[:space:]]*#' "$TARGETS" | grep -q '[^[:space:]]'; then
  echo "no targets in $TARGETS (file is empty or contains only comments)" >&2
  exit 2
fi
if ! grep -v '^[[:space:]]*#' "$TARGETS" | grep -q "$TAB"; then
  echo "targets file contains no TAB characters: $TARGETS" >&2
  echo "fields must be separated by real tabs, not spaces - see -h for a safe way to write it" >&2
  exit 2
fi

ACCT="$(az account show --query 'user.name' -o tsv 2>/dev/null)"
[ -n "$ACCT" ] || { echo "not logged in - run: az login" >&2; exit 1; }

printf '==> network ACL hardening\n    account : %s\n    mode    : %s\n\n' \
  "$ACCT" "$([ "$APPLY" -eq 1 ] && echo APPLY || echo 'REPORT ONLY')"

failures=0
changed=0

# read still populates the final record when EOF arrives without a trailing newline.
while IFS="	" read -r kind sub rg name label || [ -n "${kind:-}${sub:-}${rg:-}${name:-}${label:-}" ]; do
  case "${kind:-}" in ''|\#*) continue ;; esac

  if [ -z "$sub" ] || [ -z "$rg" ] || [ -z "$name" ]; then
    echo "Missing target subscription, resource group, or name" >&2
    failures=$((failures+1)); continue
  fi
  printf -- '--- [%s] %s (%s) ---\n' "${label:-}" "$name" "$kind"

  if [ "$kind" = "storage" ]; then
    # DOUBLE brackets: `--query '[a,b]' -o tsv` emits one value per LINE, so cut -f returns the
    # whole blob and the "already compliant" test never matches. `[[a,b]]` emits ONE tab-separated
    # row. Verified on Linux.
    row="$(az storage account show -n "$name" -g "$rg" --subscription "$sub" \
             --query '[[publicNetworkAccess, networkRuleSet.defaultAction]]' -o tsv 2>&1)"
    if [ $? -ne 0 ]; then
      printf '    CANNOT READ: %s\n' "$(printf '%s' "$row" | head -1)"
      failures=$((failures+1)); continue
    fi
    pna="$(printf '%s' "$row" | cut -f1)"
    da="$(printf '%s'  "$row" | cut -f2)"
    printf '    publicNetworkAccess          = %s\n' "$pna"
    printf '    networkRuleSet.defaultAction = %s   (desired: Deny)\n' "$da"
    if [ "$da" = "Deny" ]; then printf '    already compliant\n'; continue; fi
    if [ "$APPLY" -eq 0 ]; then
      printf '    WOULD RUN: az storage account update -n %s -g %s --subscription %s --default-action Deny\n' "$name" "$rg" "$sub"
      continue
    fi
    if err="$(az storage account update -n "$name" -g "$rg" --subscription "$sub" \
                --default-action Deny -o none 2>&1)"; then
      printf '    set defaultAction=Deny\n'; changed=$((changed+1))
    else
      printf '    FAILED: %s\n' "$(printf '%s' "$err" | head -1)"; failures=$((failures+1))
    fi

  elif [ "$kind" = "keyvault" ]; then
    row="$(az keyvault show -n "$name" -g "$rg" --subscription "$sub" \
             --query '[[properties.publicNetworkAccess, properties.networkAcls.defaultAction]]' -o tsv 2>&1)"
    if [ $? -ne 0 ]; then
      printf '    CANNOT READ: %s\n' "$(printf '%s' "$row" | head -1)"
      failures=$((failures+1)); continue
    fi
    pna="$(printf '%s' "$row" | cut -f1)"
    da="$(printf '%s'  "$row" | cut -f2)"
    printf '    publicNetworkAccess       = %s\n' "$pna"
    if [ -z "$da" ] || [ "$da" = "None" ]; then
      printf '    networkAcls.defaultAction = <networkAcls ABSENT>   (desired: Deny)\n'
    else
      printf '    networkAcls.defaultAction = %s   (desired: Deny)\n' "$da"
    fi
    if [ "$da" = "Deny" ]; then printf '    already compliant\n'; continue; fi
    if [ "$APPLY" -eq 0 ]; then
      printf '    WOULD RUN: az keyvault update -n %s -g %s --subscription %s --default-action Deny\n' "$name" "$rg" "$sub"
      continue
    fi
    if err="$(az keyvault update -n "$name" -g "$rg" --subscription "$sub" \
                --default-action Deny -o none 2>&1)"; then
      printf '    set defaultAction=Deny\n'; changed=$((changed+1))
    else
      printf '    FAILED: %s\n' "$(printf '%s' "$err" | head -1)"; failures=$((failures+1))
    fi

  else
    printf "    unknown kind '%s' - expected 'storage' or 'keyvault'\n" "$kind"
    failures=$((failures+1))
  fi
done < "$TARGETS"

printf '\n'
if [ "$failures" -gt 0 ]; then
  printf '%s target(s) FAILED.\n' "$failures"
  cat <<'EOF'
AuthorizationFailed usually means standing access is Reader only - activate Contributor
via PIM first:  ./get-az-pim-status.sh -A -t 2 -j "<why>"
EOF
fi

if [ "$APPLY" -eq 1 ] && [ "$failures" -eq 0 ]; then
  printf 'Applied (%s changed). Now check for IaC drift before the next environment:\n' "$changed"
  printf '  run a plan and confirm these resources show no changes.\n'
elif [ "$APPLY" -eq 0 ]; then
  printf 'Report only. Re-run with -A to make the changes.\n'
else
  printf 'Resolve the failures above and re-run.\n'
fi

[ "$failures" -gt 0 ] && exit 1
exit 0
