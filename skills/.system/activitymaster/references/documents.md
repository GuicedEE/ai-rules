# Documents plugin interaction contract

Document Master is a user-scoped `IMasterPlugin`, never an `IMasterSystem`.
It declares `Activity Master System`. The durable registration ID remains stable;
the credential is typed Plugin under Plugins. It cannot authorize user operations.
The installer creates taxonomy only; it imports no user documents.

## Host binding and admission

Bind `DocumentIdentityProvider.current()` to a verified, call-scoped
`DocumentIdentity(partyId, enterpriseId, context, identityToken, installationPartyId)`.
The four-argument constructor defaults installationPartyId to partyId. Supply a
different installation party only after server-side organization membership and
authority checks. Work context owner is enterpriseId; Personal and Social context
owner is the verified organic party. Request payload IDs do not establish identity.
The default provider denies access.

Before any domain operation, install Document Master for that party and obtain
that user's consent to its Core dependency through `PluginService`. The shared
`DocumentService.actor` boundary checks current installation, dependency consent,
administrator policy and eligible user credential on the caller's stateless
transaction, including reads, downloads and version history. Plugin admission
does not replace system row grants, current bucket membership, context, resource
row security, ownership or ActiveFlag checks. Reinstallation requires fresh consent.

## Service operations

Inject `DocumentApi`; its enterprise argument selects the verified enterprise and
its remaining arguments are domain data. It captures identity once and completes
after the composed stateless transaction. The lower `IDocumentService` API takes
the same caller-owned session, resolved Document registration and identity.

| Operations | Purpose |
|---|---|
| `createBucket`, `findBucket`, `listBuckets`, `members` | Typed bucket Arrangements and current membership |
| `grant`, `revoke` | Owner-controlled READER/EDITOR membership; owner cannot revoke themselves |
| `upload`, `find`, `list`, `download` | Private typed ResourceItems, binary payload and metadata |
| `revise`, `versions`, `version`, `downloadVersion`, `restoreVersion` | Immutable payload versions and optimistic expected-version checks |
| `updateMetadata`, `rate`, `clearRating` | Metadata history and party ratings, retaining resource identity |
| `addToBucket`, `removeFromBucket`, `archive` | Resource membership and effective-date retirement |
| `childBucket`, `attachBucket` | Bucket hierarchy and attachment to an authorized Arrangement |

`DocumentApi.childBucket` and
`attachBucket` accept a remove flag. A parent bucket does not confer membership in
its child. Personal resources remain restricted to their owner. Linking an
existing resource requires its independent row authority.

Upload data is `Upload(filename, contentType, byte[] data, Metadata)`;
metadata is `Metadata(title, categories, labels)`. Revision is
`Revise(expectedVersionId, upload)`; restore uses
`VersionExpectation(expectedVersionId)`. Version IDs identify SCD classification
rows for a stable resource. A stale expected version fails after locking the
resource and leaves no orphan payload. Restoring creates a new revision and keeps
history and ratings. Content results clone binary data.

REST and GraphQL share this API and verified identity boundary. A successful
response includes related writes, security and commit. Downloads and historical
payloads re-check current membership and plugin admission; old version IDs are
never lasting authorization. Use UTF-8 and preserve validated filenames when
building download headers.

## Lifecycle and verification

Core forward update 1030 discovers plugins through their own SPI. Module update
1184 (`DocumentPluginInstall`) also registers/converts Document Master when its
old domain update was already recorded or the module is added later. Domain
updates 1185/1186 provision bucket/resource/version taxonomy with the actual Core
bootstrap credential. Conversion preserves registration IDs and existing data,
retires legacy System credentials and never installs/consents for users.

Run `mvn -f ActivityMaster/documents/pom.xml test` from DevSuite without clean.
The suite covers real PostgreSQL persistence, versions, membership, plugin
removal/reinstallation, administrator denial, HTTP and GraphQL. The optional
performance suite has a separate opt-in; skipped performance tests are not
performance proof. Host authentication and deployment remain host responsibilities.
