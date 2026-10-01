# Wallet Master and FSDM transactions

Read `ActivityMaster/core/docs/transactions.md`, `ActivityMaster/wallet/README.md`
and current source before changing wallet or transaction behavior.

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

`TransactionService` checks the reviewed, provider-qualified scoped plugin
behavior, current actor, FSDM Event, Arrangement type, enterprise, party
relationship and Event-to-Arrangement links. Its required host Authority must
check current FSDM token/domain access on the same connection. NE1's Keycloak
binding and M2M assertion establish identity; system discovery grants no wallet
behavior. Do not use NE1's read-only registry pool for domain writes. Management
UI and authenticated endpoints belong in the consuming module.

For focused database validation in `ActivityMaster/core`, run without Maven clean:

```powershell
mvn '-Dtest=TransactionServiceTest,ScopedPluginServiceTest,SpacePolicyTest' '-Dmaven.test.failure.ignore=false' test
```

The fixture uses minimal FSDM tables. Its passing result does not establish a
full canonical deployment, live NE1 integration or applied production migration.
