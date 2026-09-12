#!/usr/bin/env bash
# Inspect, activate and approve Azure resource-role PIM assignments. (Linux/macOS)
#
# PIM activation of Azure RESOURCE roles is plain ARM
# (Microsoft.Authorization/roleAssignmentScheduleRequests), so an ordinary `az login` token is
# used for ARM requests. Activation also resolves the signed-in user via Microsoft Graph
# and stops before writing if that lookup fails (no Graph SDK required).
#
# !! DO NOT CONFUSE THE TWO APPROVAL QUEUES !!
# This covers Azure PIM only. Requests for GROUP MEMBERSHIP (MyAccess / Entra Entitlement
# Management) live in a different system, are invisible here, and `az` cannot read them at all -
# its Graph token has no EntitlementManagement.* scope. See references/access-and-pim.md.
#
# Dependencies: `az` only. No jq. Portable to bash 3.2 (macOS default).
#
# NOTE: the ARM $filter values contain parentheses (asTarget(), asApprover()). On Linux/macOS `az`
# is a python shim so these pass through fine. On Windows `az.cmd` is parsed by cmd, which mangles
# ( ) and fails with "-o was unexpected at this time" - use Get-AzPimStatus.ps1 there.

set -uo pipefail

usage() {
  cat <<'EOF'
Usage: get-az-pim-status.sh [-s SUB] [-r ROLE] [-t HOURS] [-j JUSTIFICATION] [-k TICKET_NUMBER -y TICKET_SYSTEM] [-A|-D|-L|-P]

  -s  Subscription id. Defaults to the current `az account`.
  -r  Role. Default: Contributor
  -t  Requested activation hours (1-24). Default: 4; ARM enforces the policy maximum.
  -j  Justification.
  -k  Ticket number, when required by policy.
  -y  Ticket system, when required by policy.
  -A  Activate (raise a SelfActivate request).
  -D  Deactivate (hand the role back early).
  -L  List activations awaiting ME as approver.
  -P  With -L, approve them.
  -h  Help.

Approvals must be run as the account in the APPROVER group - often a separate privileged
(T1-/admin) identity. A normal account sees an empty queue even when requests exist.
EOF
}

SUB=""; ROLE="Contributor"; HOURS=4; JUST="Operational task"
TICKET_NUMBER=""; TICKET_SYSTEM=""
DO_ACTIVATE=0; DO_DEACTIVATE=0; DO_LIST_APPROVALS=0; DO_APPROVE=0

while getopts ":s:r:t:j:k:y:ADLPh" opt; do
  case "$opt" in
    s) SUB="$OPTARG" ;;
    r) ROLE="$OPTARG" ;;
    t) HOURS="$OPTARG" ;;
    j) JUST="$OPTARG" ;;
    k) TICKET_NUMBER="$OPTARG" ;;
    y) TICKET_SYSTEM="$OPTARG" ;;
    A) DO_ACTIVATE=1 ;;
    D) DO_DEACTIVATE=1 ;;
    L) DO_LIST_APPROVALS=1 ;;
    P) DO_APPROVE=1 ;;
    h) usage; exit 0 ;;
    \?) echo "unknown option -$OPTARG" >&2; usage; exit 2 ;;
    :) echo "option -$OPTARG needs a value" >&2; exit 2 ;;
  esac
done

command -v az >/dev/null 2>&1 || { echo "az CLI not found on PATH" >&2; exit 1; }

# Two traps, both of which silently produce WRONG results. Fixed centrally here:
#
#  1. CRLF. `az` emits CRLF on Windows/Git-bash and on WSL when it resolves az.exe from the Windows
#     PATH. A trailing \r corrupts the status comparisons below: [ "$sst" = "InProgress" ] would
#     never match, so approvals get listed but never actioned - and the run reports success.
#  2. STDIN. Some `az` subcommands READ STDIN, consuming the approval/stage lists mid-loop so only
#     the first item is processed. `</dev/null` fixes every call site at once.
#
# Defined AFTER the check above on purpose - `command -v az` would otherwise match this function.
# Verified on Linux: `set -o pipefail` keeps az's exit code and stderr capture working.
az() { command az "$@" </dev/null | tr -d '\r'; }

# JSON string encoder using bash builtins; includes all JSON control characters.
json_string() {
  local value="$1" char code i
  printf '"'
  for ((i=0; i<${#value}; i++)); do
    char="${value:i:1}"
    case "$char" in
      '"') printf '\\"' ;;
      '\') printf '\\\\' ;;
      *) printf -v code '%d' "'$char"
         if [ "$code" -lt 32 ]; then printf '\\u%04x' "$code"; else printf '%s' "$char"; fi ;;
    esac
  done
  printf '"'
}

arm_list() {
  local url="$1" query="$2" page next
  while [ -n "$url" ] && [ "$url" != None ]; do
    page="$(az rest --method GET --url "$url" --query "$query" -o tsv)" || return 1
    next="$(az rest --method GET --url "$url" --query nextLink -o tsv)" || return 1
    [ -z "$page" ] || printf '%s\n' "$page"
    url="$next"
  done
}

case "$HOURS" in ''|*[!0-9]*) echo 'Hours must be an integer from 1 to 24' >&2; exit 2 ;; esac
[ "${#HOURS}" -le 2 ] && [ "$HOURS" -ge 1 ] && [ "$HOURS" -le 24 ] || exit 2
[ "$DO_ACTIVATE" -eq 0 ] || [ "$DO_DEACTIVATE" -eq 0 ] || { echo 'Choose -A or -D' >&2; exit 2; }
[ "$DO_APPROVE" -eq 0 ] || [ "$DO_LIST_APPROVALS" -eq 1 ] || { echo '-P requires -L' >&2; exit 2; }
if [ "$DO_LIST_APPROVALS" -eq 1 ] && [ $((DO_ACTIVATE+DO_DEACTIVATE)) -gt 0 ]; then exit 2; fi
if [ -z "$SUB" ]; then SUB="$(az account show --query id -o tsv)" || exit 1; fi
[ -n "$SUB" ] || { echo 'No target subscription' >&2; exit 1; }
# Explicit subscription on every account read; the CLI active account is never changed.
SUBNAME="$(az account show --subscription "$SUB" --query name -o tsv)" || exit 1
BASE="https://management.azure.com/subscriptions/${SUB}/providers/Microsoft.Authorization"
API='api-version=2020-10-01'
printf '==> PIM %s (%s)\n' "$SUBNAME" "$SUB"

if [ "$DO_LIST_APPROVALS" -eq 1 ]; then
  AAPI='api-version=2021-01-01-preview'
  ids="$(arm_list "${BASE}/roleAssignmentApprovals?${AAPI}&\$filter=asApprover()" 'value[].id')" || exit 1
  if [ -z "$ids" ]; then printf 'Nothing is awaiting your approval. Verify the approver identity if requests were expected.\n'; exit 0; fi
  failures=0
  while IFS= read -r aid; do
    [ -n "$aid" ] || continue
    stages="$(arm_list "https://management.azure.com${aid}/stages?${AAPI}" 'value[].[id,properties.status,properties.assignedToMe]')" || { failures=$((failures+1)); continue; }
    while IFS= read -r line; do
      [ -n "$line" ] || continue
      sid="$(printf '%s' "$line" | cut -f1)"; status="$(printf '%s' "$line" | cut -f2)"; mine="$(printf '%s' "$line" | cut -f3)"
      printf '  stage=%s status=%s assignedToMe=%s\n' "$sid" "$status" "$mine"
      if [ "$DO_APPROVE" -eq 1 ] && [ "$status" = InProgress ] && { [ "$mine" = true ] || [ "$mine" = True ]; }; then
        body="{\"properties\":{\"reviewResult\":\"Approve\",\"justification\":$(json_string "$JUST")}}"
        if az rest --method PATCH --url "https://management.azure.com${sid}?${AAPI}" --headers 'Content-Type=application/json' --body "$body" -o none; then
          printf '  APPROVED\n'
        else printf '  APPROVE FAILED\n' >&2; failures=$((failures+1)); fi
      fi
    done <<EOF
$stages
EOF
  done <<EOF
$ids
EOF
  [ "$failures" -eq 0 ] || exit 1
  exit 0
fi

elig="$(arm_list "${BASE}/roleEligibilityScheduleInstances?${API}&\$filter=asTarget()" 'value[].[properties.expandedProperties.roleDefinition.displayName,properties.memberType,properties.roleDefinitionId,properties.roleEligibilityScheduleId]')" || exit 1
active="$(arm_list "${BASE}/roleAssignmentScheduleInstances?${API}&\$filter=asTarget()" 'value[].[properties.expandedProperties.roleDefinition.displayName,properties.assignmentType,properties.endDateTime]')" || exit 1
pending="$(arm_list "${BASE}/roleAssignmentScheduleRequests?${API}&\$filter=asTarget()" 'value[].[properties.expandedProperties.roleDefinition.displayName,properties.status,properties.createdOn]')" || exit 1
printf -- '--- Eligible ---\n%s\n--- Active ---\n%s\n--- Requests ---\n%s\n' "${elig:-(none)}" "${active:-(none)}" "${pending:-(none)}"
if [ "$DO_ACTIVATE" -eq 0 ] && [ "$DO_DEACTIVATE" -eq 0 ]; then printf '\nREAD-ONLY. Use -A or -D to request a change.\n'; exit 0; fi

ROLEDEF=''; ELIGID=''; matches=0
while IFS= read -r line; do
  [ -n "$line" ] || continue
  if [ "$(printf '%s' "$line" | cut -f1)" = "$ROLE" ]; then
    matches=$((matches+1))
    ROLEDEF="$(printf '%s' "$line" | cut -f3)"; ELIGID="$(printf '%s' "$line" | cut -f4)"
  fi
done <<EOF
$elig
EOF
[ "$matches" -eq 1 ] && [ -n "$ROLEDEF" ] && [ "$ROLEDEF" != None ] || { echo 'Expected exactly one matching eligible role; inspect role and assignment scope' >&2; exit 1; }
OID="$(az ad signed-in-user show --query id -o tsv)" || { echo 'Cannot identify signed-in user; no PIM request submitted' >&2; exit 1; }
[ -n "$OID" ] && [ "$OID" != None ] || { echo 'Missing principal id; no PIM request submitted' >&2; exit 1; }
props="\"principalId\":$(json_string "$OID"),\"roleDefinitionId\":$(json_string "$ROLEDEF"),\"justification\":$(json_string "$JUST")"
if [ "$DO_DEACTIVATE" -eq 1 ]; then
  props="$props,\"requestType\":\"SelfDeactivate\""
else
  [ -n "$ELIGID" ] && [ "$ELIGID" != None ] || { echo 'Missing eligibility schedule id' >&2; exit 1; }
  if { [ -n "$TICKET_NUMBER" ] && [ -z "$TICKET_SYSTEM" ]; } || { [ -z "$TICKET_NUMBER" ] && [ -n "$TICKET_SYSTEM" ]; }; then echo 'Supply both -k and -y' >&2; exit 2; fi
  if [ -n "$TICKET_NUMBER" ]; then props="$props,\"ticketInfo\":{\"ticketNumber\":$(json_string "$TICKET_NUMBER"),\"ticketSystem\":$(json_string "$TICKET_SYSTEM")}"; fi
  START="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  props="$props,\"requestType\":\"SelfActivate\",\"linkedRoleEligibilityScheduleId\":$(json_string "$ELIGID"),\"scheduleInfo\":{\"startDateTime\":$(json_string "$START"),\"expiration\":{\"type\":\"AfterDuration\",\"duration\":\"PT${HOURS}H\"}}"
fi
BODY="{\"properties\":{$props}}"
REQID="$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen)" || exit 1
if ! out="$(az rest --method PUT --url "${BASE}/roleAssignmentScheduleRequests/${REQID}?${API}" --headers 'Content-Type=application/json' --body "$BODY" --query properties.status -o tsv 2>&1)"; then
  printf 'FAILED: %s\nCheck policy maximum duration, ticket, justification, MFA, and current assignment.\n' "$out" >&2; exit 1
fi
printf 'status: %s\n' "$out"
exit 0
