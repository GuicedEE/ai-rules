# Public exposure audit — method and false positives

- [Method](#method)
- [Types that can carry exposure](#types-that-can-carry-exposure)
- [Verdict rules per type](#verdict-rules-per-type)
- [False positives](#false-positives)
- [Two-control model](#two-control-model)

## Method

1. **Inventory** with Resource Graph or `resources?$filter=resourceType eq '...'`.
2. **Verdict** with a **direct ARM GET on each resource**. Never from Resource Graph.
3. Classify each result as: finding / weak-second-control / explained / info / compliant /
   unverifiable. Failed reads and unsupported controls are unverifiable, never empty/compliant.

### Resource Graph cannot give the verdict

`resources | project properties.publicNetworkAccess` returns **empty strings** for App Services,
Key Vaults and storage accounts — ARG's cached projection does not populate that property for those
types. An audit built on ARG reports a false *"not disabled"* for every one of them.

Use ARG for **inventory only**.

### Do not enumerate everything

`az resource show` across a whole subscription times out (100+ resources, sequential). Filter to
the types below first — that is a handful of calls.

## Types that can carry exposure

This is a bounded inventory of 17 selected types, not an exhaustive list of public Azure services.
Assess resource types outside this list separately.

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

**App Service slots** — assess each slot independently. Do not infer its private endpoint or
public access state from the parent site. Always read the slot via `/slots`; enabled/absent PNA
needs access-restriction and endpoint assessment. The scripts mark that case unverifiable.
See [App Service private endpoints](https://learn.microsoft.com/en-us/azure/app-service/networking/private-endpoint).

**Front Door / CDN** — query `securityPolicies` only for `Standard_AzureFrontDoor` and
`Premium_AzureFrontDoor`. Classic CDN profiles require a separate assessment and are reported as
unsupported. Failed policy reads are unverifiable; a successful empty list is a finding. A
nonempty list is informational: verify its domain/path associations and WAF mode before claiming
protection. See the [Microsoft security policy schema](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/securitypolicies).

**Script coverage** — AKS uses `apiServerAccessProfile.enablePrivateCluster` and reports public
API authorized ranges. PostgreSQL/MySQL use `network.publicNetworkAccess`; their enabled public
endpoints and SQL servers require a successful firewall-rule read. Storage, Key Vault, ACR, and
Cognitive Services inspect their ACL default action; Cosmos inspects IP rules and virtual-network
filtering. A deny ACL or configured allow rules are informational, not proof of compliance.
For other listed services the scripts recognize explicit disabled PNA, but report enabled/absent
PNA as unverifiable until service-specific rules are assessed. Configuration alone does not prove
actual internet reachability.

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
