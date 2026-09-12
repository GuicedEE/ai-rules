#!/usr/bin/env bash
# Final gate. Safe to keep - re-run after any change to the .sh scripts.
#   Linux/macOS : ./run-checks.sh
#   Windows     : wsl -e bash ./run-checks.sh      (NOT Git Bash - see SKILL.md)
cd "$(dirname "$0")" || exit 1
SCRIPTS="get-az-public-exposure.sh get-az-group-rbac-map.sh get-az-pim-status.sh set-az-network-acl-hardening.sh"
fail=0
ok(){  printf '  OK    %s\n' "$1"; }
bad(){ printf '  FAIL  %s\n' "$1"; fail=1; }

echo "== syntax =="
for f in $SCRIPTS; do bash -n "$f" 2>/dev/null && ok "$f" || bad "$f"; done

echo "== encoding (LF, no BOM, shebang, final newline) =="
CR=$(printf '\r')
for f in $SCRIPTS; do
  m=""
  grep -q "$CR" "$f" && m="$m CRLF"
  [ "$(head -c3 "$f" | od -An -tx1 | tr -d ' \n' | cut -c1-6)" = "efbbbf" ] && m="$m BOM"
  head -1 "$f" | grep -q '^#!/usr/bin/env bash' || m="$m no-shebang"
  [ "$(tail -c1 "$f" | od -An -tx1 | tr -d ' \n')" = "0a" ] || m="$m no-final-LF"
  [ -z "$m" ] && ok "$f" || bad "$f:$m"
done

echo "== az wrapper present, and defined AFTER the command -v az check =="
for f in $SCRIPTS; do
  c=$(grep -n 'command -v az' "$f" | head -1 | cut -d: -f1)
  w=$(grep -n '^az() { command az' "$f" | head -1 | cut -d: -f1)
  if [ -n "$c" ] && [ -n "$w" ] && [ "$w" -gt "$c" ]; then ok "$f (L$c -> L$w)"; else bad "$f (check=$c wrapper=$w)"; fi
  grep -q '^az() { command az "\$@" </dev/null | tr -d' "$f" || bad "$f wrapper missing </dev/null or tr"
done

echo "== no single-bracket tsv projections (they emit one value per LINE) =="
if grep -n "query '\[properties\.\|query '\[publicNetworkAccess" $SCRIPTS 2>/dev/null; then
  bad "single-bracket [a,b] tsv query present - use [[a,b]]"
else ok "all multi-value tsv queries use [[...]]"; fi

echo "== no cyclic-delimiter paste in code =="
for f in $SCRIPTS; do sed 's/#.*//' "$f" | grep -q "paste -sd'..'" && bad "$f" ; done
ok "none"

echo "== no bare mktemp =="
grep -q 'mktemp)' $SCRIPTS 2>/dev/null && bad "bare mktemp" || ok "all templated"

echo "== bash 3.2 safe (macOS) =="
for f in $SCRIPTS; do
  sed 's/#.*//' "$f" | grep -qE 'mapfile|readarray|declare -A|local -A|\$\{[A-Za-z_][A-Za-z_0-9]*\^|&>>' && bad "$f"
done
ok "no bash 4+ constructs"

echo "== helper functions are defined =="
grep -q '^join_csv()' get-az-group-rbac-map.sh && ok "join_csv" || bad "join_csv undefined"
grep -q '^emit()' get-az-public-exposure.sh && ok "emit" || bad "emit undefined"
grep -q '^api_version_for()' get-az-public-exposure.sh && ok "api_version_for" || bad "api_version_for undefined"

echo "== usage / bad-option exit codes =="
for f in $SCRIPTS; do
  bash "$f" -h >/dev/null 2>&1 || bad "$f -h != 0"
  bash "$f" -Z >/dev/null 2>&1; [ $? -eq 2 ] || bad "$f -Z != 2"
done
ok "all"

echo
echo "RESULT: $([ $fail -eq 0 ] && echo PASS || echo FAIL)"
exit $fail
