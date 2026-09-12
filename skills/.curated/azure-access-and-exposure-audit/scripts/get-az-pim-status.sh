#!/usr/bin/env bash
# Inspect, activate and approve Azure resource-role PIM assignments. (Linux/macOS)
#
# PIM activation of Azure RESOURCE roles is plain ARM
# (Microsoft.Authorization/roleAssignmentScheduleRequests), so an ordinary `az login` token is
# enough - no Graph SDK, no extra scopes.
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
Usage: get-az-pim-status.sh [-s SUB] [-r ROLE] [-t HOURS] [-j JUSTIFICATION] [-A|-D|-L|-P]

  -s  Subscription id. Defaults to the current `az account`.
  -r  Role. Default: Contributor
  -t  Activation hours (clamped to policy max). Default: 4
  -j  Justification.
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
DO_ACTIVATE=0; DO_DEACTIVATE=0; DO_LIST_APPROVALS=0; DO_APPROVE=0

while getopts ":s:r:t:j:ADLPh" opt; do
  case "$opt" in
    s) SUB="$OPTARG" ;;
    r) ROLE="$OPTARG" ;;
    t) HOURS="$OPTARG" ;;
    j) JUST="$OPTARG" ;;
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

[ -n "$SUB" ] || SUB="$(az account show --query id -o tsv 2>/dev/null)"
[ -n "$SUB" ] || { echo "not logged in - run: az login" >&2; exit 1; }
az account set --subscription "$SUB" >/dev/null 2>&1

ACCT="$(az account show --query 'user.name' -o tsv 2>/dev/null)"
SUBNAME="$(az account show --query name -o tsv 2>/dev/null)"
OID="$(az ad signed-in-user show --query id -o tsv 2>/dev/null)"

BASE="https://management.azure.com/subscriptions/${SUB}/providers/Microsoft.Authorization"
API="api-version=2020-10-01"

printf '==> PIM  %s\n    account: %s  (%s)\n\n' "$SUBNAME" "$ACCT" "${OID:-unknown}"

# ---------------- approvals mode ----------------
if [ "$DO_LIST_APPROVALS" -eq 1 ]; then
  AAPI="api-version=2021-01-01-preview"   # 2020-10-01 returns 404 for this collection
  ids="$(az rest --method GET \
           --url "${BASE}/roleAssignmentApprovals?${AAPI}&\$filter=asApprover()" \
           --query 'value[].id' -o tsv 2>/dev/null)"
  if [ -z "$ids" ]; then
    cat <<'EOF'
Nothing is awaiting your approval.
  * Are you signed in as the APPROVER account (often a separate T1-/admin identity)?
  * Group-membership requests do NOT appear here - that is MyAccess, a different system.
EOF
    exit 0
  fi
  while IFS= read -r aid; do
    [ -n "$aid" ] || continue
    printf '  approvalId: %s\n' "$aid"
    stages="$(az rest --method GET \
                --url "https://management.azure.com${aid}/stages?${AAPI}" \
                --query 'value[].[id,status]' -o tsv 2>/dev/null)"
    while IFS= read -r sline; do
      [ -n "$sline" ] || continue
      sid="$(printf '%s' "$sline" | cut -f1)"
      sst="$(printf '%s' "$sline" | cut -f2)"
      printf '     stage=%s status=%s\n' "$sid" "$sst"
      if [ "$DO_APPROVE" -eq 1 ] && [ "$sst" = "InProgress" ]; then
        body="{\"properties\":{\"reviewResult\":\"Approve\",\"justification\":\"${JUST}\"}}"
        if az rest --method PATCH \
             --url "https://management.azure.com${aid}/stages/${sid}?${AAPI}" \
             --headers "Content-Type=application/json" \
             --body "$body" >/dev/null 2>&1; then
          printf '     APPROVED\n'
        else
          printf '     APPROVE FAILED\n' >&2
        fi
      fi
    done <<EOF
$stages
EOF
  done <<EOF
$ids
EOF
  [ "$DO_APPROVE" -eq 1 ] || printf '\nRead-only. Re-run with -P to action.\n'
  exit 0
fi

# ---------------- report ----------------
printf -- '--- Eligible to activate ---\n'
elig="$(az rest --method GET --url "${BASE}/roleEligibilityScheduleInstances?${API}&\$filter=asTarget()" \
          --query 'value[].[properties.expandedProperties.roleDefinition.displayName,properties.memberType]' \
          -o tsv 2>/dev/null)"
if [ -z "$elig" ]; then
  printf '  none.\n  If you were just added to a group, refresh the token: az logout; az login\n'
else
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    printf '  * %-30s via %s\n' "$(printf '%s' "$l" | cut -f1)" "$(printf '%s' "$l" | cut -f2)"
  done <<EOF
$elig
EOF
fi

printf -- '\n--- Active right now ---\n'
az rest --method GET --url "${BASE}/roleAssignmentScheduleInstances?${API}&\$filter=asTarget()" \
  --query 'value[].[properties.expandedProperties.roleDefinition.displayName,properties.assignmentType,properties.endDateTime]' \
  -o tsv 2>/dev/null | while IFS= read -r l; do
    [ -n "$l" ] || continue
    printf '  %-30s [%s] %s\n' "$(printf '%s' "$l" | cut -f1)" "$(printf '%s' "$l" | cut -f2)" "$(printf '%s' "$l" | cut -f3)"
  done

pending="$(az rest --method GET --url "${BASE}/roleAssignmentScheduleRequests?${API}&\$filter=asTarget()" \
             --query "value[?properties.status!='Provisioned' && properties.status!='Revoked' && properties.status!='Canceled' && properties.status!='Denied'].[properties.expandedProperties.roleDefinition.displayName,properties.status,properties.createdOn]" \
             -o tsv 2>/dev/null)"
if [ -n "$pending" ]; then
  printf -- '\n--- In flight ---\n'
  printf '%s\n' "$pending" | while IFS= read -r l; do
    [ -n "$l" ] || continue
    printf '  %s  status=%s  created=%s\n' "$(printf '%s' "$l" | cut -f1)" "$(printf '%s' "$l" | cut -f2)" "$(printf '%s' "$l" | cut -f3)"
  done
  printf '  PendingApproval means an APPROVER must action it - see -L.\n'
fi

ROLEDEF="$(az rest --method GET --url "${BASE}/roleEligibilityScheduleInstances?${API}&\$filter=asTarget()" \
             --query "value[?properties.expandedProperties.roleDefinition.displayName=='${ROLE}'].properties.roleDefinitionId | [0]" \
             -o tsv 2>/dev/null)"
ELIGID="$(az rest --method GET --url "${BASE}/roleEligibilityScheduleInstances?${API}&\$filter=asTarget()" \
             --query "value[?properties.expandedProperties.roleDefinition.displayName=='${ROLE}'].properties.roleEligibilityScheduleId | [0]" \
             -o tsv 2>/dev/null)"

if [ -z "$ROLEDEF" ] || [ "$ROLEDEF" = "None" ]; then
  printf '\nRole "%s" is not in your eligible set - nothing further to do.\n' "$ROLE"
  exit 0
fi

if [ "$DO_ACTIVATE" -eq 0 ] && [ "$DO_DEACTIVATE" -eq 0 ]; then
  printf '\nREAD-ONLY. To activate:\n  %s -A -t %s -j "<why>"\n' "$(basename "$0")" "$HOURS"
  exit 0
fi

if [ "$DO_DEACTIVATE" -eq 1 ]; then
  REQTYPE="SelfDeactivate"
  BODY="{\"properties\":{\"principalId\":\"${OID}\",\"roleDefinitionId\":\"${ROLEDEF}\",\"requestType\":\"${REQTYPE}\",\"justification\":\"${JUST}\"}}"
else
  REQTYPE="SelfActivate"
  START="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  BODY="{\"properties\":{\"principalId\":\"${OID}\",\"roleDefinitionId\":\"${ROLEDEF}\",\"requestType\":\"${REQTYPE}\",\"justification\":\"${JUST}\",\"linkedRoleEligibilityScheduleId\":\"${ELIGID}\",\"scheduleInfo\":{\"startDateTime\":\"${START}\",\"expiration\":{\"type\":\"AfterDuration\",\"duration\":\"PT${HOURS}H\"}}}}"
fi

REQID="$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen 2>/dev/null || date +%s%N)"
printf '\n--- %s "%s" ---\n' "$REQTYPE" "$ROLE"

out="$(az rest --method PUT \
        --url "${BASE}/roleAssignmentScheduleRequests/${REQID}?${API}" \
        --headers "Content-Type=application/json" \
        --body "$BODY" --query 'properties.status' -o tsv 2>&1)"
rc=$?
if [ $rc -eq 0 ]; then
  printf '  status: %s\n' "$out"
  case "$out" in
    *Approval*) printf '  Awaiting an approver. They run: %s -L -P\n  (as the APPROVER identity - often a separate T1-/admin account)\n' "$(basename "$0")" ;;
  esac
else
  printf '  FAILED: %s\n' "$out" >&2
  cat >&2 <<'EOF'
  RoleAssignmentRequestPolicyValidationFailed -> justification/ticket/MFA missing or duration too long
  MfaRule / interaction_required             -> re-authenticate: az login
  RoleAssignmentExists                       -> already active
EOF
  exit 1
fi
exit 0
