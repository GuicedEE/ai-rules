# ActivityMaster enterprise encryption

Read for changes to protected values, encrypted queries, enterprise key provisioning,
rotation, Azure Key Vault integration, or encryption deployment documentation.

## Locate the implementation

Core `fsdm.encryption`: `EnterpriseEncryptionService`, `EnterpriseKeyWrapper`,
`AzureKeyVaultKeyWrapper`, `EnterpriseDataKey`, `EnterpriseKeyStore`, `EnterpriseKeyCache`.
Core `fsdm.api`: `ColumnEncryption`, `EncryptedValuePredicate`.
Project documents: `ActivityMaster/core/docs/enterprise-encryption.md`,
`column-encryption.md`, `sql/enterprise-encryption.sql`.
Tests: `TestEnterpriseEncryption`, `TestColumnEncryption`.

## Boundaries that matter

- Scope DEKs to **enterprise UUID**, not user parties, passwords, names or ambient
  ThreadLocals. Existing scope-token authorization still governs access.
- `Address.Value` and `InvolvedPartyXInvolvedPartyIdentificationType.Value` use the
  codec. Both have their own inherited enterprise FK; do not lazy-fetch the party
  or call a remote KMS from a getter/setter. Party names and password hashing are unchanged.
- Assign enterprise before `setValue`; scope builders with `withEnterprise` before
  `withValue`/`findLink`. Unscoped cross-enterprise identification-value searches are
  not supported in enterprise mode. Do not bypass the format-aware builder with raw SQL.
- `legacy` remains the default write mode, `aes-gcm` preserves deployment-key v1,
  `enterprise` selects tenant-bound v2. Read old formats during migrations; never
  downgrade a configured strong write after missing-key/authentication failures.
- For legacy write rollback with v2 data, retain/prepare enterprise keys and set
  `activitymaster.encryption.enterprise-reads=true` so queries still include v2 tokens.
  Retain deployment secrets and read-key IDs for v1 rows.
- Preserve randomized AES-256-GCM, 96-bit random nonce, 128-bit tag, separate derived
  lookup/encryption keys and authenticated tenant+column+header context. Lookup tokens
  intentionally reveal equality within a tenant/column/key; do not publish an unkeyed
  hash or legacy obfuscation alongside a new encrypted value.

## Key lifecycle and nonblocking execution

`provision(session, enterpriseId)` and `rotate(...)` generate random DEKs and persist
only Azure-wrapped keys and versioned KEK references. These are **trusted in-process
admin methods**, not authorization-enforcing endpoints. Authorize callers and use
their existing transaction. Apply the SQL migration (FK is `dbo.enterprise`); its
partial unique index enforces one active key per enterprise.
The store uses explicit parameterized native SQL, not an automatically scanned JPA
entity: legacy deployments need no key table unless they invoke the service.

After commit, `prepare(session, enterpriseId)` unwraps all retained versions through
`Uni` and publishes a complete ring only after success. Use a fresh preparation session
before protected work, composing inside the appropriate authorized application entry
point. `ensurePrepared` reuses an unexpired ring and is suitable for ordinary entry
points; use `prepare` to force refresh after administration. SessionUtils does not do this
implicitly. Stateless jobs must prepare separately
before starting work; do not nest transactions inside library methods.
The service restores the original Vert.x context after asynchronous KMS completions.
Preserve this boundary: Reactor/HTTP callbacks must not resume Hibernate session work
on their own threads. Regression-test it with deliberately off-context completions.

Entity access only consults the prepared cache. It expires after 15 minutes, holds at
most 256 enterprises and wipes key arrays on eviction. Missing/expired rings fail closed.
Drain writers for rotation; commit, evict/prepare every node, then resume. Retain old
DEKs/KEKs for existing rows and backups. Revocation requires per-node eviction/restart;
this is not a distributed revocation service or automatic bulk migration.
For new enterprises, commit the root record and provision/prepare its key before running
bootstrap steps that write protected values. Provision every served enterprise before
enabling the deployment-wide enterprise write mode.

## Azure constraints

Use `AzureKeyVaultKeyWrapper` with trusted, explicit versioned public-cloud vault URLs
and optional user-assigned managed identity client ID. It uses ManagedIdentityCredential
and RSA-OAEP-256; never replace with a silently permissive developer credential chain.
Stored URLs must match the constructor's allowlist before any SDK call. The operator
provisions the RSA/RSA-HSM KEK, identity, wrap/unwrap RBAC, private networking, purge
protection and backup/restore procedures. Do not claim these are automatically provisioned.

The SDKs are optional downstream dependencies; Azure consumers must include the
declared patched versions and copy core's Reactor/Reactive Streams exclusions to avoid
duplicate module names. The Testcontainers shaded JNA module can also clash with Azure's
original JNA modules on the test module path; validate the application's complete module
graph rather than treating classpath unit tests as JPMS proof.
Environment is for non-secret config; the legacy v1 raw
key resolver intentionally bypasses `.env` logging. Never log DEKs, bearer tokens or
plaintext values. A shared app identity still has access to all keys it may unwrap;
enterprise DEKs alone do not isolate a compromised application process.

## Validation and capacity

Test cross-enterprise rejection even with identical raw DEKs, rotation, failed unwrap,
missing context, legacy reads, tampering, and query grouping. Use fake KMS/mocked DB for
unit tests; separately exercise a real database and Azure managed identity before rollout.
Existing module-path tests can be blocked by `io.smallrye.common.ref`; the classpath
test workaround validates behavior, not JPMS runtime compatibility.

Existing varchar(255) limits remain: v2 uses 32-hex IDs and fits at most 83 UTF-8 payload
bytes. Oversized values throw; do not truncate. Pattern/range/list comparisons are
unsupported. Widening columns, live cloud provisioning, automatic callback preparation,
and in-place KEK rewrapping require additional implementation, not merely documentation.

