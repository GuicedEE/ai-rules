# Public exposure audit — method and false positives

- [Method](#method)
- [Types that can carry exposure](#types-that-can-carry-exposure)
- [Verdict rules per type](#verdict-rules-per-type)
- [False positives](#false-positives)
- [Two-control model](#two-control-model)

## Method

1. **Inventory** with Resource Graph or `resources?$filter=resourceType eq '...'`.
2. **Verdict** with a **direct ARM GET on each resource**. Never from Resource Graph.
3. Classify each result as: finding / weak-second-control / explained / compliant.

### Resource Graph cannot give the verdict

`resources | project properties.publicNetworkAccess` returns **empty strings** for App Services,
Key Vaults and storage accounts — ARG's cached projection does not populate that property for those
types. An audit built on ARG reports a false *"not disabled"* for every one of them.

Use ARG for **inventory only**.

### Do not enumerate everything

`az resource show` across a whole subscription times out (100+ resources, sequential). Filter to
the types below first — that is a handful of calls.

## Types that can carry exposure

Anything not in this list cannot be publicly reachable on its own.

| Type | Property that decides it |
|---|---|
| `Microsoft.Web/sites` **and `/slots`** | `properties.publicNetworkAccess` |
| `Microsoft.KeyVault/vaults` | `properties.publicNetworkAccess` + `properties.networkAcls` |
| `Microsoft.Storage/storageAccounts` | `properties.publicNetworkAccess` + `networkAcls.defaultAction` + `allowBlobPublicAccess` |
| `Microsoft.Sql/servers` | `publicNetworkAccess` + firewall rules |
| `Microsoft.DBforPostgreSQL/flexibleServers`, `…MySQL…` | `network.publicNetworkAccess` |
| `Microsoft.DocumentDB/databaseAccounts` | `publicNetworkAccess` + `ipRules` |
| `Microsoft.ContainerRegistry/registries` | `publicNetworkAccess` + `networkRuleSet` |
| `Microsoft.Cache/Redis` | `publicNetworkAccess` |
| `Microsoft.ServiceBus/namespaces`, `Microsoft.EventHub/namespaces` | `publicNetworkAccess` |
| `Microsoft.CognitiveServices/accounts` | `publicNetworkAccess` + `networkAcls` |
| `Microsoft.Search/searchServices` | `publicNetworkAccess` |
| `Microsoft.ContainerService/managedClusters` | `apiServerAccessProfile.enablePrivateCluster` |
| `Microsoft.AppConfiguration/configurationStores` | `publicNetworkAccess` |
| `Microsoft.Network/publicIPAddresses` | **association** — see false positives |
| `Microsoft.Cdn/profiles` | `securityPolicies` (WAF attached?) |

## Verdict rules per type

**Storage / Key Vault** — two independent controls:
- `publicNetworkAccess = Disabled` → not exposed. This **overrides** the ACL.
- `networkAcls.defaultAction` → the second line of defence. `Allow` (or an absent `networkAcls`
  block) is *not* an exposure, but leaves the resource resting on a single control.

**App Service slots** — a slot inherits the parent site's private endpoint, so a scanner reporting
`HasPrivateEndpoint=No / PrivateEndpointCount=0` on a slot is **expected and not a gap**. The slot
carries its **own** `publicNetworkAccess` though — always read it separately via `/slots`.

**Front Door / CDN** — public **by design**; it is the intended ingress. The verdict is not
"is it public" but **"is a WAF attached"** (`GET {profile}/securityPolicies`). Zero security
policies on an internet-facing edge is a real finding.

## False positives

These get flagged by scanners constantly. Have the answer ready.

### Public IPs on NAT gateways are egress

A public IP attached to a **NAT gateway** (or a load balancer outbound rule) provides **outbound
SNAT only** and accepts no inbound connections. It is how private compute reaches external SaaS.
Check `properties.natGateway.id` / `properties.ipConfiguration.id` before calling it exposure.

### `publicNetworkAccess=Disabled` beats an `Allow` ACL

A storage account with `defaultAction=Allow` **and** `publicNetworkAccess=Disabled` is not exposed.
Report it as a weak second control, not an open door — overstating it destroys credibility.

### App Service `ipSecurityRestrictions = Allow:Any`

Moot while `publicNetworkAccess=Disabled` — the only network path is the private endpoint, so there
is no public traffic for the rule to filter. Worth tightening only as defence-in-depth.

### Resources in the same subscription owned by another team

Filter by resource-group naming / tags before reporting. Flag them to that service's owners rather
than assuming they are in scope — and say so explicitly in the report.

## Two-control model

State the distinction plainly in any report, because it decides urgency:

| | Meaning | Urgency |
|---|---|---|
| `publicNetworkAccess = Enabled` + permissive ACL | **Exposed now** | Immediate |
| `publicNetworkAccess = Enabled` + `Deny` ACL | Reachable, filtered | High |
| `publicNetworkAccess = Disabled` + `Allow` ACL | **Not exposed**, one control deep | Medium — defence in depth |
| `publicNetworkAccess = Disabled` + `Deny` ACL | Not exposed, two controls | Compliant |

The Medium row is the one that gets miscommunicated. It is a hardening task, not an incident.
