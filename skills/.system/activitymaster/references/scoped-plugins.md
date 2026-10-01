# Scoped ActivityMaster plugins

## Ownership and module boundary

ActivityMaster owns the plugin concept, installations, access groups, behavior
authorization, versioned persistence and audit. Management UI and authenticated
endpoints belong in a separate consuming module. Do not treat their absence as
unfinished ActivityMaster plugin work or add them to core for a concept-only task.
The consuming module resolves the verified actor and calls the service boundary.

In DevSuite, inspect `ActivityMaster/core/docs/scoped-plugins.md` and the
`com.guicedee.activitymaster.fsdm.spaces` package for current contracts.
`ScopedPluginService` borrows the existing ActivityMaster SQL pool; it is stateless.
Keycloak authenticates. Browser party IDs, SPI discovery and plugin metadata do
not establish authority.

An installation is keyed by `(realm, owner_id, provider_id)`. Personal and Social
have separate keys owned by the verified organic involved party; Work remains
owned by the authorized enterprise. Do not fabricate enterprises for people or
reinterpret enterprise IDs as involved-party IDs.

## Access rules

- Keep library-owned Plugin security tokens and the protected security REST
  hierarchy intact. Scoped access groups belong to an installation and do not
  inherit the broad Plugins folder's default privileges.
- Distinguish provider registration, reviewed behaviors, scoped availability,
  installation, current membership, and actor grants. Installation alone grants
  no behavior. A behavior is qualified as `<SystemID>:<behavior>` and must belong
  to the provider's registered system and reviewed catalogue.
- Group grants remain provider-qualified even when multiple plugins share a
  System ID. Never flatten them into unrestricted system grants. Independent
  direct grants and other groups still apply when one group is revoked.
- Personal/Social require exact owner identity. Work requires current membership;
  installation additionally requires administration and `space.install`.
  Group management requires administration and `space.plugins.manage`.

## Service usage

Use `setInstalled` with an expected version (zero creates), `readManagement` to
read editable versions, and `saveGroup` for atomic replacement of group name,
active state, members and behaviors. Omitted memberships/behaviors are revoked.
Existing `SpaceConfigurationService.install` creates only; it cannot reactivate
an existing installation without a version. Installation/group writes are audited.

`availableBehaviors` is a presentation snapshot, never a reusable authorization
credential. Route backend behavior through `execute`, which rechecks current
grants and installation eligibility and holds authority rows through the transaction.
The trusted handler uses the supplied connection and context and must constrain
domain queries by persisted resource ownership. This is not a Java sandbox and
does not scope arbitrary SQL automatically. Background work must reauthorize;
external side effects need an appropriate outbox rather than a network call in
the transaction. Revocation blocks later admissions after it commits; already
admitted work holds its authority until its transaction ends.

## Schema and validation

Apply `space_configuration.sql` then `scoped_plugins.sql` through managed migrations;
both are required by the space services. Do not add startup DDL or assume a live
migration has run. Trusted provisioning owns catalogue review and initial context
and administration grants. Concrete plugin handlers and transports integrate from
their owning modules; they are not automatically intercepted.

Run focused tests from `ActivityMaster/core`, without Maven clean:

```powershell
mvn '-Dtest=ScopedPluginServiceTest,SpacePolicyTest' '-Dmaven.test.failure.ignore=false' test
```

The service tests use disposable PostgreSQL and actual migrations, with minimal
external Party/Enterprise/Systems FK fixtures. Keep cross-owner/Realm/provider,
revocation, stale-version, rollback and denied-handler tests. Distinguish these
checks from a fully provisioned FSDM database or live consuming-module proof.
