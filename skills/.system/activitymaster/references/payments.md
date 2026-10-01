# Payment Master plugin interaction contract

Payment Master is a reusable provider-neutral plugin. It owns inbound payment
intent orchestration, verified provider reference binding and settlement links.
Wallet Master owns balanced value movements. Host authentication, merchant routes,
concrete gateway SDKs, callback endpoints and reconciliation jobs belong to the
consuming application. This guide is the public integration contract; source
paths below are ownership pointers rather than prerequisites for use.

## Dependencies, installation and identity

Use artifact `com.activity-master:payment-master`, JPMS module
`com.guicedee.activitymaster.payments`, and the ActivityMaster BOM. Wallet Master
is a transitive dependency. The durable registration name is `Payment Master`;
its identity is Plugin-typed under Plugins. Its declared targets are Activity
Master System and Wallet Master. Wallet is itself a built-in plugin declaring
Activity Master System.

Authorized enterprise update 1020 forward-converts built-in identities and
preserves registration IDs/data. Wallet update 1200 and Payment update 1300
provision their catalogues and domain taxonomy, including later-added modules.
They neither run DDL nor grant installation, consent or behavior. Apply the
managed core transactions migration for the financial domain; add no payment tables.

The host installs both Payment and Wallet catalogue registrations on the verified
installation party with `PluginService`. Each user explicitly consents to both
Payment dependencies and Wallet's Core dependency. Payment and Wallet additionally
require their existing provider installation/behavior Events and FSDM permissions.
Administrator denial of Payment's Wallet dependency blocks payment calls even
when Wallet would otherwise allow direct use. See [plugins](scoped-plugins.md)
for those independent authorization layers.

Bind these host SPIs; their default implementations deny:

- `WalletIdentityProvider`: fresh organic actor, enterprise, authorized Realm/context,
  reviewed Wallet provider, user identifying credential and installation party.
- `PaymentHost.route(identity, deposit)`: trusted gateway, merchant, clearing
  arrangement, Payment provider and canonical participant party IDs.
- `PaymentHost.currentActor(attempt)`: re-resolve the initiating user's current
  authenticated/authorized identity for callbacks and jobs, including current
  installation party and revoked access. Stored actor IDs are lookup hints.
- `PaymentGateways.require(gatewayId)`: allowlisted concrete `PaymentGateway`.

`WalletIdentity`'s six-argument constructor includes installationPartyId. Its
four/five-argument compatibility constructors use the actor's party. Credentials
are ActivityMaster identifying UUIDs, never token row IDs, bearer strings,
plugin/System credentials or gateway API keys. Persisted `Actor` contains party,
enterprise, context and Wallet provider attribution, not a credential or proof
of current installation. Organisation consent remains per-user.

## Host API and DTOs

Inject `PaymentApi` for these asynchronous public operations:

| Operation | Contract |
|---|---|
| `start(enterprise, Deposit)` | Resolve current user/route, persist an authorized intent, start idempotent checkout, reauthorize and bind the returned reference |
| `get(enterprise, operationKey)` | Resolve current user and authorized route, return the current readable attempt |
| `confirm(enterprise, gateway, merchant, Callback)` | Verify final provider confirmation, resolve the initiating user again, reauthorize and settle through Wallet |

`Deposit(operationKey, walletId, amount, unit)` carries a stable UUID operation
key, destination Wallet Arrangement, positive decimal-string amount and supported
unit. It carries no actor, merchant, provider or clearing authority. The host's
`Route(gateway, merchant, clearingId, paymentProviderId, merchantPartyId,
providerPartyId)` supplies trusted routing. Gateway and provider names have
different purposes; reviewed provider behavior grants remain system-qualified.

`Started(paymentId, status, checkout)` contains the intent ID and `PENDING` or
`SETTLED`; `Checkout(reference, url)` requires an HTTPS checkout URL. A settled
retry can return no checkout. `Attempt(id, actor, route, deposit, reference,
eventId)` records immutable intent terms and settlement attribution.

`Callback(body, headers)` preserves exact bytes and signature headers; it clones
body bytes and has a redacted `toString`. Do not deserialize it as a trusted paid
flag. `Confirmation(paymentId, merchant, reference, amount, unit)` may only be
produced by the configured gateway after authenticating final provider confirmation.
The lower `IPaymentService` methods `prepare`, `get`, `bind` and `confirm` use the
caller's stateless transaction, resolved Payment system and verified identity/route.

Example method in a host adapter with injected `PaymentApi payments`:

```java
import com.guicedee.activitymaster.payments.PaymentModels;
import io.smallrye.mutiny.Uni;
import java.util.UUID;

public Uni<PaymentModels.Started> beginDeposit(String enterprise,
        UUID retryKey, UUID authorizedWalletId, String amount, String unit) {
    return payments.start(enterprise,
            new PaymentModels.Deposit(retryKey, authorizedWalletId, amount, unit));
}
```

The bound identity and route providers establish authority; an input wallet ID
is only the requested destination. Wallet/Payment check row permissions themselves.
Keep the same retry key and terms after a timeout or crash. Return/await the Uni
instead of acknowledging detached database work.

## Callback and recovery contract

Choose callback gateway/merchant from server configuration. Retain raw request
bytes and signature headers, enforce host transport limits, and acknowledge only
after `confirm` succeeds. A redirect or browser success message never credits a
wallet. A callback route's M2M trust does not replace the initiating user's FSDM
authority. There is no permissive generic verifier or automatic polling job.

`PaymentGateway.start(attempt)` uses the immutable intent ID as the provider's
idempotency key. Provider calls occur after the intent transaction commits.
`verify(merchant, callback)` verifies authenticity, intended merchant, timestamp/
replay rules, final successful capture/settlement, original intent, exact amount
and unit, and a stable provider reference; query the provider when required.
Return a Confirmation only after those checks. Pending, failed, cancelled and
unverified results cannot settle.

The service claims gateway/merchant/reference durably, serializes retries with
transaction advisory locks and prevents a provider reference crediting two intents.
Callback can precede checkout binding; both bind the same immutable reference.
The wallet movement key derives from the intent ID, never a delivery ID. Settlement
and balanced Wallet posting commit or roll back together. Reads and retries,
including already settled confirmations, recheck current user/plugin/provider/row
access. Do not reactivate authority from a persisted attempt or old receipt.

Network failure is an unknown provider outcome. The committed PENDING intent is
durable recovery work; retry idempotently and reconcile through an authorized host
job. Revocation after capture can block credit and require operational reconciliation
or refund; it never justifies a System-credential bypass. This API's implemented
scope is fully confirmed inbound payments, with no currency conversion or fee
netting. Payouts, refunds, partial captures and chargebacks need separate workflows;
do not invent legacy `processPayment`/`refundPayment` APIs or payment entity tables.

## FSDM ownership and verification

Payment attempts are typed Events. State, operation keys and external references
are concept-scoped classifications. Actor, merchant and processor use involved-party
links; destination and clearing use Event-to-Arrangement links. Settlement links
the Payment Event to the Wallet movement Event. Payment writes retain Payment's
writer ID; Wallet settlement retains Wallet's ID. There is one authoritative
balance ledger, the posted core transaction entries, never a Payment balance column.

Validate provider contracts with `PaymentContractTest` and production EntityAssist
flows on disposable PostgreSQL with `PaymentIntegrationTest`. Cover disabled
Payment-to-Wallet access, current consent/grants, private rows, retries, duplicate
references, callback-before-checkout, revoked settled replay, concurrent spend and
settlement rollback. These tests do not prove a deployed host identity binding,
real gateway signatures or live monetary settlement.

For tuning, measure production SQL with `EXPLAIN (ANALYZE, BUFFERS)` and query
statistics at representative tenant/history sizes; include admission, reference
claim and settlement. Preserve authorization/lock order and measure before changing
indexes. In DevSuite, the implementation owner is `ActivityMaster/payments`;
`docs/query-performance.md` describes the local profiling harness and its limits.
