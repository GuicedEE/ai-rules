# Mail Master plugin interaction contract

Mail Master provides reactive SMTP/IMAP transport and user-authorized FSDM mail
ingestion. These are separate boundaries. Transport configuration authenticates
a mail server; persisting a user's mail requires that user's current ActivityMaster
identity and plugin authorization. This contract uses public APIs and does not
require reading implementation files to integrate a host.

## Registration and host activation

Use artifact `com.activity-master:mail-master` with the ActivityMaster BOM and JPMS
module `com.guicedee.activitymaster.mail`. `MailSystem` extends
`MasterDefaultPlugin`; its durable registration name is `Mail Master`. Its declared
dependency is `Activity Master System`, and its security identity belongs under
Plugins. Neither module discovery nor the registration credential grants mailbox access.

Authorized enterprise updates provision plugin taxonomy at 1010, forward built-in
conversion at 1020 and Mail taxonomy at 1500. `MailMasterInstall` also provisions
the catalogue when the module is added later. Conversion retains existing IDs and
mail records, retires the old System credential and grants no user access.

Before ingestion, use `PluginService` to install Mail's catalogue registration
on the authorized involved party and obtain each user's explicit consent to its
Activity Master System dependency. Administrator denial of that dependency blocks
ingestion. An organisation's installation never consents for its members. See the
[plugin interaction contract](scoped-plugins.md) for the complete management API.

The host binds `MailIdentityProvider` to verified server authentication:

```java
bind(MailIdentityProvider.class).to(HostMailIdentityProvider.class);
```

`HostMailIdentityProvider` is a consuming-host implementation. Its `current()`
returns a fresh `Uni<MailIdentity>` for the current request or authorized job.
The default `MailIdentityProvider.Deny` fails with `SecurityException`.

`MailIdentity(partyId, enterpriseId, identityToken, installationPartyId)` is
immutable. The three-argument constructor uses the acting user's party as the
installation party. All fields are required. `identityToken` is the user's
ActivityMaster identifying credential, not a SecurityToken row ID, plugin token,
SMTP password or bearer string. `user()` returns its `PluginModels.Identity`;
`tokens()` returns that identifying credential in an array. Bind the credential
to the verified organic party and enterprise server-side. Resolve an organisation
installation through current host authorization, not mail headers or request IDs.

## Public ingestion API

`IMailFsdmService<?>` exposes two top-level overloads, both returning `Uni<UUID>`
for the committed mail Event:

```java
ingest(MailMessage message, String mailboxOwnerEmail,
       MailDirection direction, String enterpriseName)

ingest(MailMessage message, String mailboxOwnerEmail,
       MailDirection direction, String enterpriseName, MailIdentity identity)
```

The four-argument overload resolves `MailIdentityProvider.current()` on subscription.
The five-argument overload accepts a verified identity from trusted host/job code;
it must not be exposed as a browser-deserialized identity. Alternative service
implementations must implement this verified boundary themselves: the interface's
default explicit-identity overload fails with `UnsupportedOperationException`.

`mailboxOwnerEmail` is retained for compatibility and is a label, never ownership
or authentication. The acting user's party UUID determines `MailboxOwner` and
the per-user Mailbox Arrangement. Arbitrary From/To/Cc/Bcc addresses describe
message participants, not the acting user or installation party. Existing
email-keyed legacy mailboxes are not automatically rebound to an authenticated
party by the credential conversion; new ingestion uses the party key.

Example method in a trusted host adapter with an injected `IMailFsdmService<?> mail`:

```java
import com.guicedee.activitymaster.mail.MailIdentity;
import com.guicedee.activitymaster.mail.services.dto.MailMessage;
import com.guicedee.activitymaster.mail.services.enumerations.MailDirection;
import io.smallrye.mutiny.Uni;
import java.util.UUID;

public Uni<UUID> persistInbound(String enterprise, MailMessage parsed,
                               MailIdentity verifiedMailboxUser) {
    return mail.ingest(parsed, null, MailDirection.Inbound,
                       enterprise, verifiedMailboxUser);
}
```

The caller supplies a freshly verified identity and explicit current consent;
this method does not obtain consent implicitly. Returning the Uni preserves
non-blocking composition. The top-level service owns its stateless transaction;
do not wrap ingestion in a second detached domain-write transaction or subscribe
to it merely to return an earlier success response.

## Atomic storage and privacy

Ingestion resolves Mail's enterprise/writer registration, rejects an enterprise
mismatch, then runs `checkBuiltIn` with the user's credential and installation
party before creating data. On one stateless session and transaction it:

1. Resolves the verified user's involved party.
2. Creates `MailReceived` for `Inbound`, or `MailSent` for `Outbound`.
3. Stores one `MailMessage` ResourceItem: HTML body when present, otherwise text,
   encoded as UTF-8 with content-type and message metadata.
4. Resolves sender/recipient party relationships and records direction, message
   ID, subject, folder and whether non-inline attachments exist.
5. Stores each non-inline attachment as a `MailAttachment` ResourceItem and links
   it to the Event. Inline attachments are currently omitted by this pipeline.
6. Creates or uses the user's Mailbox Arrangement, requiring write permission
   for an existing mailbox; more than one matching mailbox denies as ambiguous.
7. Links the message to the mailbox and writes a `mail.ingest` invocation audit.

For newly created Event, body/attachment ResourceItems and mailbox, the implementation
archives initial default grants and writes grants for Administrators and the
actual user. Creation, grants, links and audit commit or roll back together.
The writing registration is Mail Master; its invocation audit targets the declared
Activity Master System dependency. Do not change writer provenance to the actor
or replace the user credential with Mail's technical credential.

The conversion does not rewrite historical mail content or infer ownership from
email addresses. Nor does ingestion add a generic mailbox-reading REST/GraphQL API
or promise whole-message MIME preservation, inline-image storage, duplicate-message
idempotency or provider delivery. Content can be HTML; host presentation owns its
rendering policy. Private ResourceItem grants govern payload reads separately from
catalogue/metadata discovery.

## Granular FSDM helpers and transport jobs

`findOrCreateParty`, `addEmailAlias`, `storeMessageResource` and
`storeAttachmentResource` accept a caller-supplied stateless session, writing
system and identifying tokens. They are lower-level FSDM helpers, not automatic
plugin admission boundaries. Trusted domain code using them must compose current
plugin admission, row permissions, private grants and audit in its own transaction.
Do not expose them as public privileged endpoints or infer consent from an alias.

SMTP/IMAP engines remain host-configured transports. Sending a notification over
the Mail transport alone is not an FSDM mailbox ingestion. A background job that
does persist user mail must re-resolve the current mailbox user's identity and
authorization on each admission. Stored addresses, previous receipts and transport
credentials cannot reactivate removed installations or withdrawn consent. Keep
network exchange outside database transactions; transport failure and ingestion
failure have distinct retry/reconciliation responsibilities.

## Verification

Use PostgreSQL integration coverage for missing host identity, absent installation,
per-user consent, administrator denial, removal, enterprise mismatch, private body
and attachment reads, and rollback. `ForumStorageTest` currently exercises the Mail
FSDM path and built-in migration; Mail's unit suite exercises its transport engine.
The optional local-server integration test skips when SMTP on localhost:25 is
unavailable. A skipped test is no SMTP/IMAP round-trip proof, and database tests do
not prove deployed host authentication, live message delivery or a migration of
legacy mailbox ownership. Build/test each owning module without Maven clean.
