# PowerShell + `az` traps that silently corrupt investigations

Each of these produced a **confidently wrong result** in a real audit, not just an error. They are
dangerous because the output still looks plausible.

- [Silent abort on az stderr](#silent-abort-on-az-stderr)
- [@($null).Count returns 1](#nullcount-returns-1)
- [cmd mangles parentheses](#cmd-mangles-parentheses)
- [Advanced functions steal -o](#advanced-functions-steal--o)
- [Redirected output encoding](#redirected-output-encoding)
- [Stale reads after a script writes a file](#stale-reads-after-a-script-writes-a-file)
- [Bash equivalents](#bash-equivalents)
  — **start here if a tsv field is empty or a verdict looks surprising**

## Silent abort on az stderr

`az` writes to **stderr** on any ARM failure. With `$ErrorActionPreference = 'Stop'`, PowerShell
converts native-command stderr into a **terminating** error, so a loop dies **before** its own
error-handling branch runs. The failure is invisible **and** the remaining targets are skipped —
a half-failed run looks identical to a successful one.

```powershell
# BROKEN - dies before the else, remaining targets never processed
$ErrorActionPreference = 'Stop'
foreach ($t in $targets) {
    & az storage account update -n $t.Name ... -o none
    if ($LASTEXITCODE -eq 0) { "ok" } else { "FAILED" }   # never reached
}
```

Funnel every `az` call through a wrapper that isolates the preference:

```powershell
function Invoke-AzSafe {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & az @args 2>&1
        return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($out | Out-String).Trim() }
    } finally { $ErrorActionPreference = $prev }
}
```

Also **exit non-zero** when any target failed, and never print "applied, now check for drift" on a
run where nothing changed.

## `@($null).Count` returns 1

Wrapping `$null` in an array subexpression yields a **one-element array**.

```powershell
@($null).Count          # 1   <-- not 0
```

This reported `ipRules = 1` on Key Vaults that had **no `networkAcls` block at all**, implying an
IP allow-list that did not exist. Null-check the parent **before** counting:

```powershell
$ipCount = if ($acls -and $acls.ipRules) { @($acls.ipRules).Count } else { 0 }
```

Any script counting ARM sub-arrays needs this.

## cmd mangles parentheses

`az` on Windows is `az.cmd`, so **cmd** parses the arguments. Unquoted `(` `)` break it:

```powershell
az ... --query "length([])"                      # -o was unexpected at this time
az rest --url ".../filterByCurrentUser(on='approver')"   # same
```

That is a **quoting artefact, not an authorization error** — do not chase permissions. Options:
drop `--query` and filter in PowerShell, or call the ARM/Graph REST API directly with a bearer
token (also faster for bulk reads):

```powershell
$token = az account get-access-token --resource https://management.azure.com --query accessToken -o tsv
Invoke-RestMethod -Uri $url -Headers @{ Authorization = "Bearer $token" }
```

## Advanced functions steal `-o`

A `param()` block containing `[Parameter()]` makes a function **advanced**, which adds the common
parameters. Passing `az`'s `-o` through it then fails:

```
Parameter cannot be processed because the parameter name 'o' is ambiguous.
Possible matches include: -OutVariable -OutBuffer.
```

Use a **basic** function with `$args` for passthrough wrappers:

```powershell
function Invoke-AzSafe { $out = & az @args 2>&1; ... }   # no param() block
```

## Redirected output encoding

`command *> file.txt` and `git ... > file.txt` in PowerShell 5.1 write **UTF-16**, which reads back
as text with a NUL between every character and breaks downstream parsing (and `terraform fmt`, if
you redirect a config file that way).

Prefer explicit encoding:

```powershell
& script.ps1 *>&1 | Out-String | Set-Content out.txt -Encoding UTF8
```

## Stale reads after a script writes a file

After a script regenerates a file, an immediate read may return the **previous** contents from a
cache. Verify with the filesystem rather than trusting one read:

```powershell
$f = Get-Item $path
"$($f.LastWriteTime.ToString('o'))  $($f.Length) bytes  $((Get-Content $path).Count) lines"
```

Check the timestamp and line count moved before concluding a generator did not work.

## Bash equivalents

The same class of mistakes, in bash. These matter when writing the `.sh` variants.

### `set -e` is the bash version of the silent-abort trap

`set -e` aborts the whole script on the first non-zero exit, so a loop over targets stops partway
and the summary never prints — exactly the failure described at the top of this file. For
audit/apply loops, **do not use `set -e`**. Count failures explicitly and exit non-zero at the end:

```bash
set -uo pipefail        # NOT -e
failures=0
...
if az ... ; then echo ok; else echo FAILED; failures=$((failures+1)); fi
...
[ "$failures" -gt 0 ] && exit 1
```

### CRLF line endings break the shebang

A `.sh` file authored on Windows and committed with CRLF fails on Linux/macOS with a confusing
`bad interpreter: /usr/bin/env bash^M` or `syntax error near unexpected token`. Enforce LF:

```gitattributes
*.sh text eol=lf
```

Verify before shipping — `file x.sh` should say "ASCII text", **not** "with CRLF line terminators".
A UTF-8 BOM breaks the shebang the same way.

### macOS ships bash 3.2

`/bin/bash` on macOS is 3.2 (2007) for licensing reasons. These are all **bash 4+** and will fail:

`declare -A` (associative arrays), `mapfile` / `readarray`, `${var^^}` / `${var,,}`, `&>>`.

Use a `case` statement instead of an associative array, and `while IFS= read -r` instead of
`mapfile`. Test with `bash --version` on the target, not on the author's machine.

### Parentheses are fine in bash, but only off Windows

The `cmd` mangling above is a **Windows-only** artefact of `az.cmd`. On Linux/macOS `az` is a Python
shim, so `$filter=asTarget()` passes through cleanly and `az rest --url` can be used directly. The
reverse is also true: `.sh` scripts using those filters will fail under Git Bash on Windows, because
they still invoke `az.cmd`. Ship both variants rather than trying to make one cover both.

### `$?` after an assignment

`row="$(az ... 2>&1)"` sets `$?` from the command substitution, so `if [ $? -ne 0 ]` works — but
only if checked **immediately**. Any command in between (even `echo`) resets it. Prefer the direct
form:

```bash
if row="$(az ... 2>&1)"; then ... else ... fi
```
