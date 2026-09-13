---
name: azure-access-and-exposure-audit
description: "Audit Azure network exposure and harden ACLs, or diagnose RBAC/PIM access, activation, and approval failures with PowerShell or bash."
---

# Azure access and exposure audit

Two related investigation workflows: **is this exposed?** and **why can't this identity do that?**

Both fail the same way — a plausible but wrong answer, produced fast. Every rule here exists
because it caused a real wrong answer. **Report evidence, not inference.**

## Core rules

1. **Never trust a name.** Not a group name, not a variable name, not a resource name. Enumerate
   what it actually grants or does.
2. **Never trust Resource Graph for a verdict.** It returns empty `publicNetworkAccess` for the
   types that matter most. ARG for inventory, direct ARM GET for the verdict.
3. **Separate "exposed" from "one control deep".** Overstating a hardening task as an exposure
   destroys credibility; understating a real exposure is worse.
4. **Read the module before setting its flag.** `enable_<security-thing> = true` is not
   automatically additive — it can be a kill switch.
5. **State what could not be verified.** An audit with an honest gap beats one with a guess.

## Scripts — pick your platform

Every tool ships in PowerShell and bash. Both report incomplete reads explicitly;
their presentation and PIM policy handling differ as described below.

| Task | Windows (PowerShell 5.1+) | Linux / macOS (bash) |
|---|---|---|
| Exposure audit | `Get-AzPublicExposure.ps1` | `get-az-public-exposure.sh` |
| Group → real RBAC | `Get-AzGroupRbacMap.ps1` | `get-az-group-rbac-map.sh` |
| PIM status / activate / approve | `Get-AzPimStatus.ps1` | `get-az-pim-status.sh` |
| networkAcls hardening | `Set-AzNetworkAclHardening.ps1` | `set-az-network-acl-hardening.sh` |

**Dependencies:** the `.sh` scripts need **only `az`** — no `jq`, no `curl`. All parsing goes
through `az --query ... -o tsv`. They are bash 3.2 compatible, so they run on stock macOS.

```bash
chmod +x scripts/*.sh    # once, after cloning
scripts/run-checks.sh    # regression gate - re-run after ANY change to a .sh script
```

**PowerShell Core (`pwsh`) also runs on Linux/macOS**, so the `.ps1` versions work there too if
preferred — they use only `az`, `Invoke-RestMethod` and built-in cmdlets.

> ⚠️ **Do not run the `.sh` versions under Git Bash on Windows.** Two independent things break, and
> both fail *silently*:
> 1. MSYS rewrites a leading `/subscriptions/...` argument into `C:/Program Files/Git/subscriptions/...`,
>    so every `--ids` lookup fails, stderr is suppressed, and **every resource reports as a FINDING**.
> 2. `az` is `az.cmd`, parsed by `cmd`, which mangles the `( )` in `asTarget()` / `asApprover()` and
>    fails with `-o was unexpected at this time` — which looks like an auth error.
>
> Use the `.ps1` versions on Windows; they call ARM directly with a bearer token. **WSL is fine** and
> is a good place to test the `.sh` variants — it does not rewrite argument paths.

**Verification status:** this revision is checked with PowerShell parsing, bash syntax/help/
argument/encoding checks, and offline CLI/ARM fixtures on Windows PowerShell 5.1 and WSL Ubuntu.
The fixtures exercise read and membership failures, scoped hardening with preserved bypasses,
exposure controls and CSV identities, RBAC scopes, and scoped PIM activation/deactivation bodies.
No live cloud audit, activation, approval, or hardening operation was performed
for this revision. Perform a report-only pass before using these scripts in a new estate.

Run the regression suite from this skill directory with Python 3 and its test-only dependency:

```text
python -m pip install -r tests/requirements.txt
python -B tests/test_audit_scripts.py
```

On Linux/macOS use `python3`. Run on Windows for PowerShell coverage and on Linux/macOS for bash
coverage. The fake transport rejects unrecognized calls and never invokes a live Azure command.

## Workflow A — public exposure audit

Use when responding to an exposure finding or auditing an estate.

```powershell
scripts/Get-AzPublicExposure.ps1 -SubscriptionId <sub1>,<sub2> -CsvPath .\exposure.csv
```
```bash
scripts/get-az-public-exposure.sh -s <sub1> -s <sub2> -c ./exposure.csv
```

Enumerates 17 selected resource types and reads each with a direct ARM GET. This is a bounded
configuration audit, not proof of network reachability or exhaustive Azure coverage. Results are
`FINDING`, `weak-2nd-control`, `explained`, `info`, `ok`, or `unverifiable`. Read failures and
unsupported/missing controls remain visible; `info` requires interpretation and is not compliance.
Exit codes: `2` means an incomplete audit, `1` means findings with no incomplete reads, and `0`
means neither. `0` does not certify informational results. CSV output includes subscription and
resource identity. `-a` / `-IncludeCompliant` also shows `ok` results.

Then:

1. **Re-verify every item on the supplied list.** Compliance lists are frequently wrong; say so
   with evidence when they are.
2. **Explain the false positives** rather than silently dropping them — NAT-gateway public IPs are
   egress-only and Front Door is public by design. Assess App Service slots separately; they do
   not share the parent's private endpoint. Record the evidence for the next scan.
3. **Report gaps the list missed.** These are usually the real finding.
4. **Check the edge for a WAF**, not just for "is it public".

Read **[references/public-exposure-audit.md](references/public-exposure-audit.md)** for the type
matrix, per-type verdict rules, the false-positive catalogue and the two-control model.

### Hardening

```powershell
scripts/Set-AzNetworkAclHardening.ps1 -TargetJsonPath .\targets.json          # report
scripts/Set-AzNetworkAclHardening.ps1 -TargetJsonPath .\targets.json -Apply   # change
```
```bash
scripts/set-az-network-acl-hardening.sh -f ./targets.tsv        # report
scripts/set-az-network-acl-hardening.sh -f ./targets.tsv -A     # change
```

PowerShell takes JSON objects
(`{ "Kind": "storage"|"keyvault", "Sub": "...", "Rg": "...", "Name": "...", "Label": "dev" }`);
bash takes the same fields as **tab-separated** lines (`kind<TAB>sub<TAB>rg<TAB>name<TAB>label`,
`#` comments allowed).

The hardening commands change only `defaultAction` to `Deny`; they omit `--bypass` to preserve
the existing Storage or Key Vault bypass configuration in both report and apply modes.

**Before applying:** confirm whether the platform's IaC manages these properties — if it does, the
change belongs in the module or it will be reverted on the next apply. Apply to non-production
first, then run a plan and check for drift. If the storage account is an **IaC state backend**,
verify a plan still runs before touching production.

Before changing an **edge** control (WAF, IP allow-list, deny-all), read
**[references/edge-waf-traps.md](references/edge-waf-traps.md)** — it documents a change that would
have 403'd 100% of production traffic, and the Detection-mode rollout that avoids it.

## Workflow B — access / RBAC / PIM investigation

Use for `AuthorizationFailed`, missing access, or a request nobody can find.

**Start here — it resolves most cases and takes one command:**

```powershell
scripts/Get-AzGroupRbacMap.ps1 -GroupPrefix '<app group prefix>' -SubscriptionId <sub1>,<sub2> -ShowMembers
```
```bash
scripts/get-az-group-rbac-map.sh -p '<app group prefix>' -s <sub1> -s <sub2> -m
```

Maps every matching group to the RBAC it **actually** grants, active **and** PIM-eligible, and
includes the scope of every assignment. Only successful, empty reads are flagged as no assignments
for that group/subscription pair. Failed queries are `UNVERIFIABLE` and return nonzero; do not call
those groups dead. Compare each reported scope with the failing operation's resource scope;
nested groups, deny assignments, conditions, and directory roles need separate evaluation.
Optional member-query failures are reported separately as `MEMBERS: UNVERIFIABLE` and return
nonzero while preserving successfully read RBAC data. Only a successful empty member lookup
reports `MEMBERS(0)`.
In a real case two of five groups — the two most obvious names —
carried zero RBAC on both subscriptions; requests against them never reached the queue of the group
that did grant access.

Then check the identity's own position:

```powershell
scripts/Get-AzPimStatus.ps1 -SubscriptionId <sub>                       # eligible / active / in-flight / policy
scripts/Get-AzPimStatus.ps1 -Activate -Hours 2 -Justification '<why>'   # raise activation
scripts/Get-AzPimStatus.ps1 -Approvals                                  # as the APPROVER identity
scripts/Get-AzPimStatus.ps1 -Approvals -Approve
```
```bash
scripts/get-az-pim-status.sh -s <sub>                 # eligible / active / in-flight / policy
scripts/get-az-pim-status.sh -A -t 2 -j '<why>'       # raise activation
scripts/get-az-pim-status.sh -L                       # as the APPROVER identity
scripts/get-az-pim-status.sh -L -P
```

PowerShell reads the governing policy and clamps duration, including fractional-hour maxima.
Policy lookup and activation requests use the selected eligibility's `properties.scope`, including
resource-group and resource scopes. Deactivation (`-Deactivate` / `-D`) selects an `Activated` assignment
belonging to the caller and sends its `roleAssignmentScheduleId` as `targetRoleAssignmentScheduleId`
at that assignment's scope; it does not require an eligibility record or activation-policy lookup.
Standing `Assigned` instances remain visible in the report but are excluded from deactivation selection.
Supply `-TicketNumber` and `-TicketSystem` when ticketing is required; the script stops before
writing if they are absent. Bash sends the requested `-t` duration and lets ARM enforce the
policy; use `-k` / `-y` for ticket number/system. It returns nonzero on rejection. Bash activation
requires a successful `az ad signed-in-user show` lookup; PowerShell gets the principal from the
ARM token. Approval mode in both variants uses returned full resource IDs and approves only
`InProgress` stages assigned to the current caller. List/read/PATCH failures return nonzero.

Three things to establish early, in order:

- **Which queue?** Group membership (MyAccess / Entitlement Management) and PIM role activation are
  unrelated systems. `az` **cannot** read or approve the former at all.
- **Which identity approves?** Approver groups usually hold a privileged `T1-`/admin account. The
  normal account sees an empty queue even when requests exist.
- **Does the group have owners?** A direct join request routes to group **owners**; with none
  configured nobody can approve it, ever.

Read **[references/access-and-pim.md](references/access-and-pim.md)** for the full diagnosis order,
the queue comparison table, the group-name evidence, ownership rules, active-vs-eligible, and an
escalation template.

## Before writing any script here

Read **[references/powershell-az-traps.md](references/powershell-az-traps.md)** first. It covers
five traps that each produced a *confidently wrong* result:

- `$ErrorActionPreference='Stop'` + `az` stderr → the loop dies silently mid-run and skips targets
- `@($null).Count` returns **1** → phantom IP allow-list rules
- `az.cmd` + cmd parsing → `(` `)` in `--query` fails as `-o was unexpected`, looks like an auth error
- a `param()` block makes a wrapper *advanced* → `az`'s `-o` collides with `-OutVariable`
- `*>` redirection writes UTF-16 → unreadable logs

## Reporting

Write findings so someone can act without re-running anything:

- **Verdict first**, then evidence. If the finding is a false positive, say so in the first line.
- **Quote the live values** that produced the verdict, with the date checked.
- **Separate** action-required from explained-no-action.
- **Say where the fix belongs** — IaC variable vs out-of-band script — and verify the variable
  exists before claiming it does.
- **Record the method**, including what was tried and abandoned. It stops the next person
  repeating a failed approach.
- Track status per item (`applied` / `blocked — waiting on X` / `gated`). "Blocked" with a named
  blocker is a useful result.
