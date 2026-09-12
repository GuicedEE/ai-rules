# Azure access investigations — the two queues, and why group names lie

- [Diagnosis order](#diagnosis-order)
- [The two approval queues](#the-two-approval-queues)
- [Group names lie](#group-names-lie)
- [Group ownership decides who can approve](#group-ownership-decides-who-can-approve)
- [Active vs eligible](#active-vs-eligible)
- [Escalation template](#escalation-template)

## Diagnosis order

When someone "cannot do X" or "raised a request nobody can find", work in this order. Each step is
cheap and rules out a whole class of cause.

1. **What does the failing operation actually need?** Read the ARM error — it names the exact
   action (`Microsoft.Storage/storageAccounts/write`) and scope. Do not guess the role.
2. **What does the person hold right now?** Active *and* eligible — they are different things.
3. **What do the candidate groups actually grant?** Run `Get-AzGroupRbacMap.ps1`. **Do this before
   raising or approving anything.** Names are not evidence.
4. **Which group did the request actually target?** A request against a group that grants nothing
   never appears in the queue of the group that does.
5. **Which queue is it in?** PIM and MyAccess are unrelated systems (below).
6. **Who can approve it?** Group owners vs an approver group vs a Groups Administrator.

## The two approval queues

The single most common source of "I approved it but nothing happened" / "I can't see their request".

| | **Group membership** | **PIM role activation** |
|---|---|---|
| System | Entra **Entitlement Management** (MyAccess) | Azure **PIM** (ARM) |
| Grants | membership of an AD group | a role, time-boxed |
| Approve at | `https://myaccess.microsoft.com/<tenant>#/access-requests` | Portal → PIM → Approve requests |
| API | Microsoft Graph `identityGovernance/entitlementManagement` (**beta**) | ARM `roleAssignmentScheduleRequests` |
| Works with `az`? | **No** | **Yes** |
| Script here | *(needs Graph SDK)* | `Get-AzPimStatus.ps1 -Approvals` |

### `az` can never approve a group-membership request

The Azure CLI's Graph token comes from the fixed first-party CLI app, whose delegated scopes do
**not** include `EntitlementManagement.*` and cannot be extended. Every call returns:

```
403 Valid permissions not present. User needs one of the following permissions for this action :
    EntitlementManagement.ReadWrite.All, EntitlementManagement.Read.All
```

Use the Microsoft Graph PowerShell SDK (`Connect-MgGraph -Scopes EntitlementManagement.ReadWrite.All`)
or the portal. The approvals collection lives on **beta** — `v1.0` has no `assignmentApprovals`
segment.

### Approvals usually need a different identity

Approver groups typically contain a **privileged/admin account** (`T1-…`, `admin-…`), not the
engineer's normal account. Signing in with the normal account shows an **empty queue even when
requests exist** — which reads exactly like "there is nothing to approve". Always confirm which
identity is actually in the approver group.

## Group names lie

**Enumerate what a group grants. Never infer it from the name.**

Real case: a subscription had five `<app> Read / Write / Admins / Member / Lead` groups.

| Group | Active | Eligible |
|---|---|---|
| `Read` | `Reader` | — |
| `Member` | `Reader`, `Cloud9 PaaS Reader` | **`Contributor`, `Key Vault Secrets Officer`** |
| `Lead` | `Reader`, `Cloud9 PaaS Reader` | none (approver only) |
| **`Write`** | **none** | **none** |
| **`Admins`** | **none** | **none** |

`Write` and `Admins` — the two obvious names — carried **zero RBAC on both subscriptions**. Only
`Member` granted anything. Engineers naturally requested `Write`/`Admins`, received nothing, and
their requests never surfaced in the `Member` approval queue. One engineer was in `Read` + `Write`
+ `Admins` — three groups — and still held only `Reader`.

Symptoms that point straight here:
- "I requested access and nothing happened."
- "I can't find their request to approve."
- Someone is in several plausibly-named groups and still gets `AuthorizationFailed`.

Also note: an "admin"-sounding group may be an **approver** group that grants the holder nothing
extra. Being in it without the group that carries the eligibility is a deadlock — the classic
version is an empty `Member` group and a sole `Lead` member with nothing to approve.

## Group ownership decides who can approve

A **direct group-join request routes to the group's OWNERS**. A group with **no owners** has no
approver — the request is orphaned and nobody in the tenant can action it. Check owners early:

```powershell
az ad group owner list --group <id> --query '[].userPrincipalName' -o tsv
```

Zero owners + a pending join request = the request will never be approved. The fix is a **Groups
Administrator**, and the durable fix is to grant ownership to the team lead.

Note that Azure **`Contributor` does not help**: group membership is **Entra, not ARM**. Attempting
it returns `403 Authorization_RequestDenied`.

## Active vs eligible

- **Active** — the role is in force now. `az role assignment list`.
- **Eligible (PIM)** — the holder may *activate* it, subject to policy. Invisible to
  `az role assignment list`; read `roleEligibilityScheduleInstances`.

A group granting nothing active can still be the **only** route to `Contributor`. Reporting only
active assignments produces a confidently wrong answer.

Activation policy commonly requires **MFA + justification + approval**, and is time-boxed
(often max 8h). `PendingApproval` means it is waiting on a human — it is not a failure.

Token refresh rules, which trip people up:

| Change | Fresh token needed? | Why |
|---|---|---|
| Joining a group | **Yes** (`az logout; az login`) | membership rides in the token's `groups` claim |
| Activating a PIM role | **No** | ARM evaluates RBAC per request |

## Escalation template

When the answer is "a platform admin must do it", make the ticket self-contained:

- The **exact** ARM action and scope from the error.
- **Object ids**, not just display names (names drift; ids do not).
- Both the **mail** address and the Entra **sign-in UPN** — they usually differ.
- What was already tried and the verbatim failure.
- Whether self-service is genuinely available — **verify, do not assume**. Claiming "they can
  self-serve" when they cannot de-prioritises the ticket and strands the team.
- The durable fix (grant ownership) alongside the immediate one (add these members).
