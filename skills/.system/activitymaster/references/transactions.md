# Wallet Master and FSDM transactions

This is the Wallet and transaction interaction contract. For plugin admission,
use the adjacent [plugin contract](scoped-plugins.md); for provider settlement use
[Payments](payments.md). Implementation ownership is ActivityMaster core transactions
and the standalone Wallet module; consumers need no source checkout for this contract.

## Built-in plugin admission

Wallet Master has a Plugin identity under Plugins and declares Activity Master
System. Its durable registration ID and existing arrangements survive the forward
1020 conversion; its old System credential is retired. The host installs Wallet's
catalogue registration on an authorized involved party and obtains each user's
explicit consent to the Core dependency through `PluginService`.

Every Wallet operation checks this current installation, dependency consent and
administrator policy before normal provider behavior and FSDM row permissions.
These are independent gates: a scoped `wallet.*` grant does not install the catalogue
or provide dependency consent, and catalogue consent does not grant `wallet.post`.
An organisation installation still needs each user's consent. Retries and background
jobs reauthorize; an old receipt and the Wallet Plugin credential grant no use.

Wallets are FSDM Arrangements of type `Wallet`, related to involved parties by
`ArrangementXInvolvedParty`. One party may participate in several wallet
Arrangements. `Wallet Clearing` is an Arrangement type for external sources or
sinks. Do not add a parallel wallet account table.

An FSDM Event records the business action and links to affected Arrangements
through `EventXArrangement`; EventType and classifications describe transfers,
deposits, withdrawals and reversals. `transactions.transaction_type` defines
the low-level debit/credit sign. Every `transactions.entry` belongs to one
parent Event and one Arrangement. Each Event balances by unit at commit. A
reversal is another Event with compensating entries. Posted history is immutable.

The posted entries are authoritative for balance. Wallet Arrangements cannot
overdraw; concurrent postings lock Arrangements before checking funds. A
classification on an Arrangement may cache balance or other summary metrics,
but it is derived and must never authorize spending. Provision FSDM types,
classifications, relationships and row security through their existing stateless
services and the managed transactions migration.

`WalletSystemInstall` is the `ISystemUpdate` seeder at unique sort order 1200.
It installs Wallet and Wallet Clearing arrangement types, Transaction Event,
debit/credit transaction types, Event action classifications and Arrangement
projection classifications per enterprise. The global concept is core-owned;
no ProductType is needed until a product is linked to this flow. Apply the managed
`transactions.sql` migration before running enterprise updates; do not turn
the update into a schema migration or create wallet-owned tables.

`Transaction`, `TransactionType`, and `TransactionXTransactionType` are
EntityAssist-backed ActivityMaster warehouse entities, with corresponding
Warehouse security entities. Use `TransactionService.post(session, call, ...)`
within the caller's `withStatelessTransaction`; persist entries, classified
relationships and security rows on that same session. Keep all DDL in
`ActivityMaster/core/src/main/resources/db/transactions.sql`.

Use the standard classified relationship family: `TransactionXInvolvedParty`,
`TransactionXResourceItem`, `TransactionXArrangement`, `TransactionXEvent`,
`TransactionXProduct`, `TransactionXAddress`, `TransactionXGeography`,
`TransactionXRules`, `TransactionXTransaction`, and `TransactionXClassification`.
Each extends the existing warehouse relationship base and has its own security
entity/table. Classifications express roles (payer/payee/cashier, POS device,
purchase agreement). One accounting arrangement owns the amount; contextual
arrangement links must not duplicate the balance. The parent Event groups the
business action; do not introduce a separate `TransactionPosting` aggregate.
Retry keys live on transaction entries. Posting persists the actor, accounting
arrangement and parent Event relationships. Wallet installation seeds these
roles plus payer/payee/cashier, POS device, purchase agreement and purchased
product roles. Other contextual links are created by consuming domain flows
using stateless EntityAssist builders and current row authorization.

`TransactionService` checks the reviewed, provider-qualified scoped plugin
behavior, current actor, FSDM Event, Arrangement type, enterprise, party
relationship and Event-to-Arrangement links. Its required host Authority must
check current FSDM token/domain access on the same connection. The verified host identity establishes the actor; system discovery grants no wallet behavior. Use a write-capable ActivityMaster connection for domain persistence.

## Standalone wallet and host identity

Wallet Master owns its standalone REST/GraphQL adapters and service binder;
management UI remains host-owned. Use artifact `com.activity-master:wallet-master`
and JPMS module `com.guicedee.activitymaster.wallet`. The public host contract is
included here. Implementation source lives under
`ActivityMaster/wallet/src/main/java/com/guicedee/activitymaster/wallet/`:

- `WalletModule` binds `IWalletService` using the existing domain binder pattern.
- `WalletApi` is the shared transport gateway; it resolves current identity and
  uses `SessionUtils.withActivityMaster`, checking the resolved enterprise.
- `WalletIdentityProvider` is the host integration SPI; its default denies calls.
- `WalletAuthority` implements the current FSDM row permission checks.
- `rest/WalletRestService` and `graphql/WalletGraphQLSchemaProvider` expose the
  service without adding authentication or detached persistence callbacks.

The host owns authentication and binds `WalletIdentityProvider` to its verified
request context. Obtain a fresh identity per call; never retain it in a shared
singleton or derive actor, scope or credentials from request body/GraphQL fields.
`WalletIdentity` carries party, enterprise, context, identifying token, reviewed
provider ID and installationPartyId. The four-argument constructor defaults the
provider to `wallet`; four/five-argument constructors use the actor's party as
installation party. The six-argument constructor accepts the host-verified
organisation installation party. Work context
ownership must match the enterprise; Personal/Social ownership matches the party.
The identifying token is an ActivityMaster credential, not a `SecurityTokenID`
row key or host bearer string. Resolve it through `ISecurityTokenService`
before creating security links. System tuple credentials must not replace it
for user authorization.

`WalletAuthority` first checks the built-in Plugin's current installation and
all declared dependency consents/policies, then requires the actor/context to match the verified identity,
read access to the actor's InvolvedParty, write access to the Event, and read
access to an Arrangement for direction zero. Both debit and credit directions
require Arrangement write access. On the same stateless session it checks each
row's enterprise, effective dates and ActiveFlag `allowaccess`. Movement
Arrangement locks and provider authority locks are separate from these row checks;
do not invent static joined-row locks or change their order without measurement.
Preserve current provider-qualified behavior grants in
addition to these row checks: movements require `wallet.post` plus their specific
`wallet.transfer`, `wallet.deposit` or `wallet.withdrawal` behavior. Reads/create
use `wallet.read`/`wallet.create`. Discovery or an old successful receipt grants
no authority, including on retries.

## Public Wallet operations

Inject `WalletApi`; bind `WalletIdentityProvider` to a fresh host implementation
whose default denies. Public methods are `create(enterprise, Create)`,
`balance(enterprise, walletId, unit)`, `history(enterprise, walletId, unit, offset,
limit)`, and `move(enterprise, Action, Movement)`. Lower `IWalletService` methods
use the caller's stateless session, resolved Wallet system and verified identity.

`Create(operationKey)` creates an ordinary Wallet and returns
`Wallet(arrangementId, involvedPartyId)`. `Movement(operationKey, sourceId,
destinationId, amount, unit)` requires distinct arrangement IDs, a stable UUID
retry key, a positive decimal-string amount (up to 30 whole and 8 fractional
digits) and a unit matching `[A-Z][A-Z0-9_]{0,15}`. Actions are `TRANSFER`, `DEPOSIT`
and `WITHDRAWAL`. `Balance` returns arrangement ID, unit and amount string;
`Receipt` returns Event ID, operation key and immutable posting lines. History
is bounded and returns transaction/Event/line/direction/amount/unit attribution.

Example fragment in a host with injected `WalletApi wallet` and current verified
identity binding, after explicit installation, consent and behavior provisioning:

```java
return wallet.move(enterprise, WalletModels.Action.TRANSFER,
        new WalletModels.Movement(stableRetryKey, sourceWallet, destinationWallet,
                                  "12.50", "POINTS"));
```

Both arrangements are checked for current write authority. Public creation never
creates clearing funds implicitly: authorized host provisioning creates Wallet
Clearing Arrangements, deposits debit clearing, and withdrawals credit clearing.
The transport adapters use `/{enterprise}/wallet` REST routes and GraphQL operation
extensions; none authenticates user IDs supplied in request data.

## Atomic persistence and integration pitfalls

Use stateless EntityAssist builders and explicit warehouse security metadata
(enterprise, ActiveFlag and scope groups). Persist restricted security and actor
grants in the same transaction; propagate security failures so everything rolls
back. New wallets/Events grant actor read/write; posted entries and their links
grant actor read access. Do not pass an identifying credential as a security row ID.

Use scalar ID projections and detached ID references for taxonomy/system lookups
where only keys are needed. Hydrating cached entities in the stateless posting
path has caused Hibernate load-stack failures. Scope classification lookups by
data concept, enterprise and system. Effective-date SQL uses
`statement_timestamp()`: transaction-start `now()` can reject an Event or link
whose Java timestamp was assigned later within that same transaction.

Acquire movement Arrangement locks in sorted order before permission checks to
avoid lock upgrades/deadlocks. Advisory transaction locks serialize operation
keys before their deterministic Events exist. Retries recheck current access,
persisted action and complete line data. All entries, Event links and security
must commit together; REST/GraphQL responses await commit. Java service consumers
own the surrounding stateless transaction. Never apply fire-and-forget
relationship persistence to wallet movements.

Public creation makes ordinary Wallet Arrangements. Hosts provision authorized
Wallet Clearing Arrangements; deposits debit clearing and withdrawals credit it.
Use decimal strings in both APIs, and bound history pagination. Preserve JPMS
and META-INF service registrations for the binder, scanner and GraphQL provider.
Wallet contributes operation-root extensions; the shared GraphQL assembler must
support a missing base root without duplicating an existing one.

## Validation

For focused database validation in `ActivityMaster/core`, run without Maven clean:

```powershell
mvn '-Dtest=TransactionServiceTest' '-Dmaven.test.failure.ignore=false' test
```

The fixture uses minimal FSDM tables and a SQL-only test harness for database rules.
WalletIntegrationTest in the wallet module exercises the production stateless
EntityAssist path and REST/GraphQL adapters against PostgreSQL. Live host
authentication integration and production migration validation remain separate.

Run the production wallet integration suite from `ActivityMaster/wallet`:

```powershell
mvn '-Dtest=WalletIntegrationTest' '-Dmaven.test.failure.ignore=false' test
```

Require PostgreSQL/Testcontainers coverage for deposit/transfer/withdrawal,
retries, concurrent spending, rollback, revoked grants, row denial, missing
identity and wrong enterprises. Distinguish REST resource-method and executable
GraphQL tests from HTTP deployment tests. The shared `GuicedEE/graphql`
`GraphQLEndpointTest` covers HTTP operation-root extension composition; neither
suite proves live host authentication. Inspect actual test reports, not just Maven
BUILD SUCCESS, and do not use Maven clean for this workspace.
