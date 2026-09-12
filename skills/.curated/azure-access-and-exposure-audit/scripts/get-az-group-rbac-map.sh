#!/usr/bin/env bash
# Map AD groups to the Azure RBAC they ACTUALLY grant - active and PIM-eligible. (Linux/macOS)
#
# THIS IS THE HIGHEST-VALUE CHECK IN AN ACCESS INVESTIGATION. Group names lie. A real case: a
# subscription had FIVE `<app> Read/Write/Admins/Member/Lead` groups, and `Write` + `Admins` - the
# two obvious names - carried ZERO RBAC on both subscriptions, active and eligible. Only `Member`
# granted anything. Engineers requested `Write`/`Admins`, got nothing, and their requests never
# appeared in the `Member` approval queue.
#
# Run this BEFORE raising or approving any access request.
#
# Dependencies: `az` only. No jq. Portable to bash 3.2 (macOS default).
#
# NOTE: deliberately NOT using `set -e` - one unreadable group must not abort the whole map.

set -uo pipefail

usage() {
  cat <<'EOF'
Usage: get-az-group-rbac-map.sh -p GROUP_PREFIX [-g GROUP_ID]... [-s SUBSCRIPTION_ID]... [-m]

  -p  Match groups whose displayName starts with this.
  -g  Explicit group object id. Repeatable.
  -s  Subscription id. Repeatable. Defaults to the current `az account`.
  -m  Also list group members.
  -h  Help.

Read-only. Requires `az login` and directory read for the group lookups.
EOF
}

PREFIX=""
GIDS=""
SUBS=""
SHOW_MEMBERS=0

while getopts ":p:g:s:mh" opt; do
  case "$opt" in
    p) PREFIX="$OPTARG" ;;
    g) GIDS="$GIDS $OPTARG" ;;
    s) SUBS="$SUBS $OPTARG" ;;
    m) SHOW_MEMBERS=1 ;;
    h) usage; exit 0 ;;
    \?) echo "unknown option -$OPTARG" >&2; usage; exit 2 ;;
    :) echo "option -$OPTARG needs a value" >&2; exit 2 ;;
  esac
done

command -v az >/dev/null 2>&1 || { echo "az CLI not found on PATH" >&2; exit 1; }
[ -n "$PREFIX" ] || [ -n "${GIDS// /}" ] || { echo "supply -p and/or -g" >&2; usage; exit 2; }

# Two traps, both of which silently produce WRONG access answers. Fixed centrally here:
#
#  1. CRLF. `az` emits CRLF on Windows/Git-bash and on WSL when it resolves az.exe from the Windows
#     PATH. Multi-row `-o tsv` then carries \r on every line, corrupting group names and mangling
#     the joined role lists into an unreadable report.
#  2. STDIN. Some `az` subcommands READ STDIN - `az ad group member list` is one. Inside the
#     `while read` loop below it consumes the group list, so the loop exits after ONE iteration:
#     verified, a 5-group map silently reported only 1 group and looked like a complete answer.
#
# Defined AFTER the check above on purpose - `command -v az` would otherwise match this function.
# Verified on Linux: `set -o pipefail` keeps az's exit code and stderr capture working.
az() { command az "$@" </dev/null | tr -d '\r'; }

# NOTE: bare `mktemp` is a GNU extension. BSD/macOS mktemp requires a template or -t, so an
# explicit template is used - bare mktemp fails there and, with no `set -e`, the script would
# carry on writing to an empty path and silently report nothing.
GROUPS_FILE="$(mktemp "${TMPDIR:-/tmp}/azrbac.XXXXXX")"   # id <TAB> name
DEAD_FILE="$(mktemp "${TMPDIR:-/tmp}/azrbac.XXXXXX")"
trap 'rm -f "$GROUPS_FILE" "$DEAD_FILE"' EXIT

# Join stdin lines with ", ".
# NOT `paste -sd', ' -`: -d takes a LIST of delimiters applied CYCLICALLY, so ", " alternates
# comma and space. Three roles came out as "Reader,Cloud9 PaaS Reader Dotcom Contributor" -
# indistinguishable from a single role name, and role names legitimately contain spaces. That is a
# silently wrong access answer, exactly what this skill exists to prevent.
join_csv() { paste -sd, - | sed 's/,/, /g'; }

if [ -n "$PREFIX" ]; then
  az ad group list --filter "startswith(displayName,'${PREFIX}')" \
     --query '[].[id,displayName]' -o tsv 2>/dev/null >> "$GROUPS_FILE"
fi
for gid in $GIDS; do
  nm="$(az ad group show --group "$gid" --query displayName -o tsv 2>/dev/null)"
  [ -n "$nm" ] || nm="(unreadable)"
  printf '%s\t%s\n' "$gid" "$nm" >> "$GROUPS_FILE"
done

sort -u -o "$GROUPS_FILE" "$GROUPS_FILE"
gcount="$(grep -c . "$GROUPS_FILE" || true)"
[ "${gcount:-0}" -gt 0 ] || { echo "No groups matched." >&2; exit 1; }

printf '==> Groups discovered: %s\n' "$gcount"
while IFS="	" read -r id nm; do
  [ -n "$id" ] || continue
  printf '    %-45s %s\n' "$nm" "$id"
done < "$GROUPS_FILE"

if [ -z "${SUBS// /}" ]; then
  SUBS="$(az account show --query id -o tsv 2>/dev/null)"
  [ -n "$SUBS" ] || { echo "not logged in - run: az login" >&2; exit 1; }
fi

printf '\n================ GROUP -> RBAC ================\n'

for sub in $SUBS; do
  az account set --subscription "$sub" >/dev/null 2>&1 || { echo "cannot select $sub" >&2; continue; }
  sub_name="$(az account show --query name -o tsv 2>/dev/null)"
  printf '\n--- %s ---\n' "$sub_name"

  while IFS="	" read -r id nm; do
    [ -n "$id" ] || continue

    # ACTIVE assignments
    active="$(az role assignment list --assignee "$id" --subscription "$sub" \
                --query '[].roleDefinitionName' -o tsv 2>/dev/null | sort -u | join_csv)"
    [ -n "$active" ] || active="(none)"

    # PIM-ELIGIBLE assignments. A group can grant NOTHING active yet be the only route to
    # Contributor. Miss this and the whole picture is wrong.
    # NOTE: the $filter contains parentheses; on Linux/macOS `az` is a python shim so this is fine.
    # On Windows `az.cmd` goes through cmd, which mangles ( ) - use the PowerShell script there.
    elig="$(az rest --method GET \
              --url "https://management.azure.com/subscriptions/${sub}/providers/Microsoft.Authorization/roleEligibilityScheduleInstances?api-version=2020-10-01&\$filter=principalId+eq+'${id}'" \
              --query 'value[].properties.expandedProperties.roleDefinition.displayName' \
              -o tsv 2>/dev/null | sort -u | join_csv)"
    [ -n "$elig" ] || elig="(none)"

    if [ "$active" = "(none)" ] && [ "$elig" = "(none)" ]; then
      flag="[!]"
      printf '%s\n' "$nm" >> "$DEAD_FILE"
    else
      flag="   "
    fi

    printf '%s %s\n' "$flag" "$nm"
    printf '      ACTIVE   : %s\n' "$active"
    printf '      ELIGIBLE : %s\n' "$elig"

    if [ "$SHOW_MEMBERS" -eq 1 ]; then
      mem="$(az ad group member list --group "$id" --query '[].userPrincipalName' -o tsv 2>/dev/null | join_csv)"
      mc="$(printf '%s' "$mem" | tr ',' '\n' | grep -c . || true)"
      printf '      MEMBERS(%s): %s\n' "${mc:-0}" "$mem"
    fi
  done < "$GROUPS_FILE"
done

if [ -s "$DEAD_FILE" ]; then
  printf '\n[!] These groups grant NOTHING (no active, no eligible RBAC):\n'
  sort -u "$DEAD_FILE" | while IFS= read -r d; do printf '      %s\n' "$d"; done
  cat <<'EOF'
    Requesting them achieves nothing and their requests will not appear in the
    approval queue of the group that DOES grant access. Confirm which group a
    pending request actually targeted before hunting for it.
EOF
fi

exit 0
