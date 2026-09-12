# Edge / WAF hardening — read the module before setting its flag

- [The near miss](#the-near-miss)
- [Why it happens](#why-it-happens)
- [Safe rollout](#safe-rollout)
- [Generalisation](#generalisation)

## The near miss

An audit found a production Front Door with **zero WAF policies attached** while non-production had
one. The obvious fix — set `enable_frontdoor_waf = true` in shared config so both environments get
a policy — was written, reviewed and staged.

**It would have taken production offline.**

The platform module did not create an *empty* WAF policy. Its custom-rule set **always** appended a
deny-all rule, making the policy an **allow-list**:

```hcl
safelisting_rules = length(var.whitelisted_ips) > 0
                      ? [custom_user_whitelisted_ip_rule, deny_all_rule]
                      : [deny_all_rule]          # <-- always present

deny_all_rule = Block SocketAddr IPMatch ["0.0.0.0/0", "::/0"] @ priority 1000
```

Only traffic matched by a **higher-priority Allow rule** survives. Non-production worked because it
set an IP allow-list. Production deliberately had none (customer-facing), so its only Allow rules
would have come from a CDN-fronting integration — and that integration was **not actually live**
(zero custom domains on the profile). In the default `Prevention` mode the deny-all would have
matched **every** request: a 403 on 100% of traffic.

**Resolution:** enable the WAF in shared config (both environments get a policy, so the compliance
control is satisfied) **and** pin production to `Detection` mode, so rules are evaluated and logged
but not enforced. `Detection` was an existing module variable — no out-of-band portal change.

## Why it happens

A flag named `enable_<security control>` reads as purely additive. It rarely is. Deny-by-default is
the correct design for a WAF — it is only dangerous when the allow-list is empty or the traffic
source you assumed is not actually in front yet.

**Verify all three before enabling any edge control:**

1. **Read the module source.** Find what rules it synthesises, and at what priorities. Do not
   infer behaviour from the variable name.
2. **Confirm against a live example.** Read an environment where it is already on:
   ```powershell
   az resource show --ids <wafPolicyId> `
     --query "{mode:properties.policySettings.mode, rules:properties.customRules.rules[].{n:name,p:priority,a:action}}"
   ```
   A `Block 0.0.0.0/0` rule confirms the allow-list model.
3. **Confirm the assumed ingress is real.** `az afd custom-domain list …` returning `[]` means no
   CDN/proxy is actually fronting the endpoint, so "traffic arrives from the CDN's IP ranges" is
   false and its allow rule protects nothing.

## Safe rollout

1. Enable the policy in **Detection** mode — satisfies "a WAF is attached" with zero traffic impact.
2. Soak for at least one full business cycle. Watch `FrontDoorWebApplicationFirewallLog` for
   would-be blocks on legitimate traffic.
3. Add Allow rules / exclusions for anything legitimate that would have been blocked.
4. Only then switch to `Prevention`.
5. Enable **managed rule sets** as a separate step, soaked the same way — defaults false-positive
   on real payloads.

Record the exact conditions for the flip **inline in the config**, next to the setting. A reviewer
must not have to reconstruct the reasoning.

## Generalisation

Applies well beyond WAFs — any control that switches from implicit-allow to explicit-allow:

- NSG / firewall rules with a deny-all terminator
- Storage / Key Vault `networkAcls.defaultAction = Deny` (safe only if a private path exists — see
  `public-exposure-audit.md`)
- API gateway IP restrictions
- Service-endpoint policies

The test is always the same: **enumerate what is currently reaching the resource, and confirm every
legitimate source matches an Allow rule — before the deny-all becomes effective.**

A control that satisfies a compliance checkbox while blocking real traffic is not a fix. Prefer a
logging/detection mode when the traffic profile is not yet proven.
