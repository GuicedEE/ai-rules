# ActivityMaster plugin architecture and interaction contract

This is the current reusable contract for registering, installing, authorizing,
invoking and upgrading ActivityMaster plugins. The APIs and examples below stand
alone; a consumer does not need a DevSuite checkout to understand the boundary.
Source locations at the end identify implementation ownership when making changes.

## Systems, plugins and modules

A plugin is an ActivityMaster extension with the same service and durable
registration model as a System, but a different security scope. Both have a
`Systems` registration and can own FSDM taxonomy. A System has a `System` identity
under the `Systems` security folder. A plugin has a `Plugin` identity under
`Plugins`, plus a typed catalogue Arrangement. A Maven/JPMS module is packaging;
adding a module or discovering an SPI provider never grants a user access.

Mail, Wallet, Payment, Document, Conversation and Marketplace Master are built-in
plugins. Marketplace Products is a separate product-loading plugin declaring
Core and Marketplace Master; Marketplace consumers need no producer installation.
Plugins use their own lifecycle SPI and cannot implement IMasterSystem or claim
Core's registration/name. Forum Master and Notification Master remain Systems with explicit delegated plugin invocation
support. Do not relabel every feature module as a plugin, or assume every Master
automatically checks delegation.

Plugin credentials identify registrations. They do not impersonate a user or
inherit folder privileges for user-data access. Applicable-token expansion excludes
Plugin identities and stops at Plugin ancestors. Preserve the typed hierarchy and
protected security APIs; bypassing those protections is not plugin installation.

The authenticated host binds the acting user, enterprise, context and initiating
plugin. It owns management UI, authenticated endpoints, approval/consent UX, jobs
and transport bindings. ActivityMaster owns durable registration, installation,
consent, administrator policy, FSDM permissions and persistence. This boundary is
not a Java sandbox: arbitrary code, raw SQL and privileged generic FSDM endpoints
must not be exposed as delegated user APIs.

## Three identifiers with different purposes

| Value | Meaning | Authority source |
|---|---|---|
| Plugin/System registration UUID | Durable capability and writer identity | Reviewed server registration |
| Acting user's identifying credential UUID | Credential used for FSDM authorization | Current verified host authentication |
| Installation party UUID | Party on which this plugin is installed | Authorized server context and current party access |

`PluginModels.Identity(partyId, enterpriseId, identityToken)` carries a live organic
user and their ActivityMaster identifying credential. The credential classification
must be `User` or the canonical account `Identity`. It is neither a
`SecurityTokenID` row primary key nor a Keycloak/host bearer string. Bind credential
and party server-side; checking that each ID exists is not authentication.

`PluginModels.Invocation(pluginId, installationPartyId)` identifies the initiating
extension and the authorized installation. Preserve it across service boundaries,
GraphQL contexts, identity-provider conversions and post/notification composition.
A client-supplied plugin ID does not establish which extension is calling.

Personal and Social contexts use the verified organic party as context owner.
Work uses the authorized enterprise as context owner. Context ownership and plugin
installation ownership are different: an organisation installation is a real
nonorganic InvolvedParty, never an enterprise UUID cast as a party UUID. The host
must verify the user's relationship to an organisation. Installation does not
consent on behalf of members.

Resolve enterprise and writer through `SessionUtils.withActivityMaster`, but pass
the verified user's credential to runtime row and domain checks. The tuple's
technical token, a plugin token or a core bootstrap credential cannot replace it.
Bootstrap credentials are reserved for trusted lifecycle/taxonomy provisioning.

## Catalogue and persistence

`PluginService` lives in `com.guicedee.activitymaster.fsdm.plugins` in the core
artifact `com.activity-master:activity-master`. Its immutable contracts are in
`PluginModels`. Public `register` requires current Administrators membership and
creates/updates a Plugin identity and catalogue. It cannot convert an existing
System registration into a plugin; the trusted forward updater owns that operation.

`Registration(name, title, description, version, icon, screenshots, systems)` has
these constraints:

- Name, title and version are required nonblank strings of at most 150 UTF-16 units.
- Description is required, nonblank and at most 250 units. Text must have valid
  surrogate pairs and no NUL; it is descriptive data, never execution authority.
- `icon` is an optional ResourceItem UUID. `screenshots` is an ordered immutable
  list of up to 20 ResourceItem UUIDs. `systems` is an immutable set of up to 100
  declared target registration UUIDs; null collections become empty collections.
- Media must reference live ResourceItems readable by the registration actor.
  Target registrations must be live, in the same enterprise, and have a System
  or Plugin identity. A plugin may declare another plugin, as Payments declares Wallet.

`find` returns `Plugin(id, name, title, description, version, icon, screenshots,
systems)`. Catalogue metadata is not an invocation grant or a media-payload grant;
ResourceItem retrieval still requires its own current permissions.

Persistence reuses secured FSDM entities; there are no plugin-specific SQL tables:

| Concept | FSDM representation |
|---|---|
| Catalogue and metadata | `Plugin Catalog` Arrangement, classifications and ResourceItem links |
| Declared target | `Plugin System Declaration` Event |
| Party installation | `Plugin Installation` Event and party relationship |
| Individual opt-in | `Plugin User Consent` Event tied to current installation and declaration |
| Administrator allowance/denial | `Plugin System Policy` Event |
| Invocation audit | `Plugin Invocation` Event, actor/party/catalogue links, target and operation |

Current effective dates, ActiveFlag access and row grants apply to all of these.
Classification names are scoped by enterprise, writing system and data concept.
Use the existing services and relationship helpers, not parallel permission tables,
browser state or in-memory receipts as durable authority.

## Admission and revocation

Every delegated target invocation requires all six conditions together:

1. A live organic user with their current eligible identifying credential.
2. A live installation on a party the user can currently read.
3. A current declaration of the target registered System or Plugin.
4. That user's explicit consent for this exact current installation/declaration.
5. No administrator denial for this plugin/target at enterprise or party level.
6. The target's ordinary row permissions, context, membership and behavior grants.

Permission decisions always use current backend state, including retries and
background jobs. Availability/catalogue screens and previous successful receipts
are presentation or history, not reusable admission tokens.

| Operation | Caller requirement | Effect |
|---|---|---|
| `register(session, system, identity, registration)` | Current administrator | Registration, metadata and declarations; no installation or consent |
| `find(session, system, identity, pluginId)` | Eligible current user | Catalogue snapshot; no execution or media authority |
| `install(session, system, identity, pluginId, partyId)` | Current write access to installation party | Live installation, returns `Installation(id, pluginId, partyId)` |
| `remove(session, system, identity, pluginId, partyId)` | Current write access to installation party | Ends installation; preserves history |
| `consent(session, system, identity, invocation, targetId, enabled)` | Current user and readable current installation/declaration | Grants or withdraws only that user's consent |
| `setSystemAccess(session, system, identity, pluginId, targetId, partyId, enabled)` | Current administrator | Policy for that party, or enterprise-wide when party is null |
| `check(session, targetSystem, identity, invocation)` | All admission conditions | Authorizes only this target and transaction |
| `checkBuiltIn(session, pluginSystem, identity, partyId)` | Installation plus consent/policy for every declared dependency | Admission to a built-in plugin; an empty dependency set denies |

Enterprise denial overrides party allowance and user consent. Party denial also
blocks that installation. Allowing access removes that policy barrier; it never
creates installation, declaration, consent or target-domain permissions. Withdrawing
consent remains possible while a policy denies the target.

Removing/reinstalling a plugin or removing/reintroducing a declaration requires new
consent. Metadata/version updates that retain declarations do not revoke consent
by themselves. Organisation installation does not replace per-user consent.

All `PluginService` operations, including reads and checks, require an existing
caller-owned `Mutiny.StatelessSession` transaction. Admission holds a shared lock
on the catalogue Arrangement through domain work and commit. Management mutations
take an exclusive lock on that catalogue. Revocation waits for admitted transactions
to finish, then prevents later admissions. Keep domain work on that same session
and keep transactions short; do not split check, mutation and audit across sessions.

Changes archive previous authorization Events and write current versions. Do not
delete historical consent or policy rows to implement revocation. SQL uses current
effective dates rather than cached authorization decisions.

## Management usage

The following adapter methods are independent management actions. Their `actor`
comes from verified server authentication. The host requests explicit user opt-in
before calling `consent`; registration or module discovery must never call it
implicitly. The owning host class supplies the injected `plugins` field.

```java
import com.guicedee.activitymaster.fsdm.client.services.ISystemsService;
import com.guicedee.activitymaster.fsdm.client.services.SessionUtils;
import com.guicedee.activitymaster.fsdm.plugins.PluginModels;
import com.guicedee.activitymaster.fsdm.plugins.PluginService;
import io.smallrye.mutiny.Uni;
import java.util.UUID;

// Field in the host adapter: injected PluginService plugins.
public Uni<PluginModels.Plugin> register(String enterprise,
        PluginModels.Identity actor, PluginModels.Registration request) {
    return SessionUtils.withActivityMaster(enterprise,
            ISystemsService.ActivityMasterSystemName, t ->
            plugins.register(t.getItem1(), t.getItem3(), actor, request));
}

public Uni<PluginModels.Installation> install(String enterprise,
        PluginModels.Identity actor, UUID pluginId, UUID authorizedParty) {
    return SessionUtils.withActivityMaster(enterprise,
            ISystemsService.ActivityMasterSystemName, t ->
            plugins.install(t.getItem1(), t.getItem3(), actor, pluginId, authorizedParty));
}

public Uni<Void> consent(String enterprise, PluginModels.Identity actor,
        PluginModels.Invocation invocation, UUID targetId, boolean enabled) {
    return SessionUtils.withActivityMaster(enterprise,
            ISystemsService.ActivityMasterSystemName, t ->
            plugins.consent(t.getItem1(), t.getItem3(), actor, invocation, targetId, enabled));
}
```

Registration request example, using reviewed target IDs and already authorized
ResourceItems:

```java
new PluginModels.Registration("Case Notes", "Case notes",
        "User-scoped case discussion", "1.0.0", iconResourceId,
        java.util.List.of(screenshotResourceId), java.util.Set.of(forumSystemId));
```

Desired installation/target IDs may be management inputs, but they never establish
actor identity. The host's authenticated endpoint enforces its own enterprise and
organisation binding; the service still performs current FSDM party checks.

## Target integration and provenance

Use `execute(session, targetSystem, identity, invocation, operation, work)` in a
target service. It checks delegation, passes the same identity to `work`, and
audits a successful non-null operation before commit. A null operation means a
read. The callback must check ordinary target permissions and constrain queries
by persisted ownership; `execute` does not rewrite arbitrary SQL.

```java
// Inside the target's existing caller-owned stateless transaction:
return plugins.execute(session, targetSystem, verifiedUser, boundInvocation,
        "case.note.create", user -> domainWork.apply(user));
```

`domainWork` here is a host/domain-supplied `Function<PluginModels.Identity, Uni<T>>`
that uses this same session and performs the target's row/domain authorization.
Alternatively compose `check`, domain work and `audit` on the same transaction.
Audit operation names must be nonblank and at most 150 characters.

The last writing Master owns `OriginalSourceSystemID`, including a call initiated
by a plugin. Mail writes use Mail's registration ID; Payment intent writes use
Payment's ID; Wallet settlement writes use Wallet's ID. An initiator does not
replace the downstream writer ID. Invocation Events record the initiating plugin
separately through catalogue/actor/installation/target relationships.

Generic classified relationship replacement archives the previous version and
inserts a new one when the writer changes, even if the value is unchanged. The
new row carries the current writer ID and predecessor
`OriginalSourceSystemUniqueID`. Do not stamp every downstream row with the
initiating plugin, mutate another writer's relationship in place, or replay an
old user credential as authority.

Forum and Notification identities have an optional fifth `Invocation plugin`
component; their four-argument constructors mean ordinary direct host access.
For delegated calls construct the five-argument identity and preserve it in every
conversion. Forum/Notification services check it when present. `ForumApi` audits
successful writes and composes posts and notification publication atomically.
Low-level callers must compose their own `audit`/`execute`. Mail ingestion also
records an invocation audit. Do not assume automatic initiation auditing or
delegation interception in every other Master; integrate the boundary explicitly.

## Built-in plugin lifecycle

`IMasterPlugin<J>` is an independent SPI extending the ordering/progress contracts,
not `IMasterSystem`. `MasterDefaultPlugin<J>` implements it directly and does not
inherit `MasterDefaultSystem`. A plugin cannot be an ActivityMaster System;
discovery rejects dual-interface registrations. It never substitutes its identity
for an acting user. The existing technical `Systems` row and legacy method names
retain stable registration/provenance IDs without conferring System authority. Implement the name, description,
defaults/progress methods and, when needed, override:

- `getPluginTitle()` (default: system name).
- `getPluginVersion()` (current default: `3.0.0-SNAPSHOT`).
- `getPluginDependencies()` (default: `Activity Master System`).

Use `IMasterPlugin.allPlugins()` and register via the plugin SPI in JPMS and
META-INF/services when supporting classpath hosts. Keep the module's ordinary
binder/scanner/update registrations. Remove obsolete IMasterSystem SPI entries.
Enterprise bootstrap has a separate plugin registration/default phase and plugin
post-startup callbacks; `IMasterSystem.allSystems()` contains only Systems. Metadata/dependencies are catalogue declarations, not grants.

Example built-in plugin declaration; host identity and domain admission remain
separate from this class:

```java
package example.notes;

import com.guicedee.activitymaster.fsdm.client.services.ISystemsService;
import com.guicedee.activitymaster.fsdm.client.services.administration.MasterDefaultPlugin;
import com.guicedee.activitymaster.fsdm.client.services.builders.warehouse.enterprise.IEnterprise;
import io.smallrye.mutiny.Uni;
import org.hibernate.reactive.mutiny.Mutiny;
import java.util.Set;

public final class NotesPlugin extends MasterDefaultPlugin<NotesPlugin> {
    public String getSystemName() { return "Case Notes Plugin"; }
    public String getSystemDescription() { return "User-scoped case discussion"; }
    public String getPluginTitle() { return "Case notes"; }
    public String getPluginVersion() { return "1.0.0"; }
    public Set<String> getPluginDependencies() {
        return Set.of(ISystemsService.ActivityMasterSystemName, "Forum Master");
    }
    public int totalTasks() { return 0; }
    public Uni<Void> createDefaults(Mutiny.StatelessSession session,
                                    IEnterprise<?, ?> enterprise) {
        return Uni.createFrom().voidItem();
    }
}
```

Include the declared target modules and register the class via the existing SPI,
for example in JPMS:

```java
provides com.guicedee.activitymaster.fsdm.client.services.systems.IMasterPlugin
        with example.notes.NotesPlugin;
opens example.notes to com.google.guice;
```

Preserve the ordinary binder/scanner registrations needed by the module. Supply
an `ISystemUpdate` with a public no-argument constructor and a unique appropriate
`@SortedUpdate` order. Its `update(session, enterprise)` returns `Uni<Boolean>`;
resolve the core System and its actual bootstrap identifying credential, call
`registerBuiltIn` with the plugin, then seed only needed domain taxonomy and
return true. The caller owns the transaction; an update is not handed a token
implicitly. Declared targets must exist before their declarations are validated.
Later-added modules need their own update even when core conversion 1020 has
already run. Runtime code still checks delegation to Forum and uses the user
credential; defining this SPI class installs/consents for nobody.

| Built-in | Declared dependencies | Host identity and additional checks |
|---|---|---|
| Mail Master | Activity Master System | `MailIdentityProvider` or trusted explicit identity; private mailbox writes |
| Wallet Master | Activity Master System | `WalletIdentityProvider`; provider behaviors, context and wallet row permissions |
| Payment Master | Activity Master System, Wallet Master | Fresh Wallet identity and Payment host route; Payment and Wallet admission, provider behaviors and rows |
| Document Master | Activity Master System | DocumentIdentityProvider; current bucket membership, resource authority and version checks |
| Conversation Master | Activity Master System | ConversationIdentityProvider; live context, participants and private message resources |
| Marketplace Master | Activity Master System | MarketplaceIdentityProvider; seller decisions, provider behaviors and row grants |
| Marketplace Products | Activity Master System, Marketplace Master | Separate producer installation/consent; delegates product loading with the same verified user |

Enterprise update 1010 (`PluginInstall`) provisions catalogue and authorization
taxonomy. Update 1020 (`BuiltInPluginsInstall`) converts discovered built-ins
before domain taxonomy updates. New forward update 1030 (`PluginArchitectureInstall`)
also handles enterprises which already recorded 1020. Module forward updates
1174/1184/1187 convert Conversations/Documents/Marketplace and its producer when
the original domain update is already recorded or a module is added later. It prepares newly
added registrations before resolving dependencies, independent of SPI iteration
order. Sort orders are unique lifecycle keys; a new plugin's update must choose
its own appropriate unused order.

`registerBuiltIn(session, coreSystem, bootstrapCredential, extension)` is trusted
lifecycle provisioning. It requires the live core System registration and its
actual identifying bootstrap credential, retains existing capability IDs/data,
archives legacy System credentials and their hierarchy links, and registers
Plugin identities. Public `register` cannot perform this conversion. Each
built-in's domain update also provisions its catalogue so modules added to an
existing enterprise work after the core updates have already been applied.
Provisioning explicitly secures plugin registration rows even when added after
the Core registration pass; stateless writer ActiveFlag must be resolved before
default grants. Repeated provisioning preserves live icons/screenshots and grants no installation
or user consent. Never reactivate the retired broad System credential.

These plugin concepts need no new database schema or plugin-owned tables.
On Windows, finish local artifact installation and module-path descriptor patches
before running consumers of those JARs. Inspect artifact-copy errors even when
Maven reports BUILD SUCCESS; stop consumers and repeat the affected install before
claiming consumer validation. Keep builds forward-only and never use clean to
work around a locked artifact.
Existing managed FSDM/core transactions migrations remain prerequisites for the
domain using them. Run the authorized enterprise update lifecycle for an existing
enterprise; compile/package success is not proof that its update was applied.

## Provider behaviors are an additional layer

Keep `PluginService` catalogue/party/dependency consent separate from
`FsdmBehaviorAuthority` provider/Realm/action admission. Passing either one does
not grant the other. Provider IDs are reviewed strings such as `wallet` or
`payments`; they are not interchangeable with plugin registration UUIDs, gateway
names or user credentials.

Provider installations are secured Events of type
`<SystemID>:Scoped Provider Installation`. Grants are secured Events of type
`<SystemID>:Scoped Behavior Grant`. Classifications qualify `ScopedProvider`,
`ScopedRealm`, `ScopedOwner` and `ScopedBehavior` by SystemID/data concept; a
qualified `ScopedActor` InvolvedParty link names the acting user. The explicit
behavior value is `<SystemID>:<action>`. Intended users need current row read
permission on these Events. Installation alone grants no behavior; revocation
ends the relevant Event/link's effective period. Keep provider qualification even
when two providers share a SystemID.

Wallet requires `wallet.create`/`wallet.read` as appropriate; movements require
`wallet.post` and `wallet.transfer`, `wallet.deposit` or `wallet.withdrawal`.
Payment requires `payment.create`, `payment.read` or `payment.confirm` and repeats
Wallet admission. Notifications retain `notifications.publish`/`notifications.audit`.
All domain rows still require ordinary permissions and valid context.

The removed `ScopedPluginService`/space SQL model is not the current implementation.
Do not add its old `space_configuration.sql` or `scoped_plugins.sql` to implement
this architecture. Realm-specific domain behavior still uses current secured FSDM.

## Usage and validation boundaries

For concrete usage, the adjacent [Mail](mail.md), [Wallet/transactions](transactions.md),
[Payments](payments.md), [Documents](documents.md), [Marketplace](marketplace.md)
and [Forum](forums.md) contracts supply host bindings and
public operations. External transports run outside the database transaction;
background work re-resolves current user identity and authorization. A SMTP
credential or verified payment signature does not grant access to user FSDM rows.
Await all database writes, links, security and audit before reporting success.

Useful regression cases include typed registration and invalid media/targets,
missing user identity/installation/consent, organisation per-user consent,
enterprise/party policy precedence, revocation and reinstallation, removed and
reintroduced declarations, private row denial, cross-writer replacement, rollback,
concurrent revocation, credential retirement, catalogue media preservation and
adding modules to an existing enterprise. Financial tests must also cover retries,
double-spend prevention and callback settlement rollback.

In DevSuite, focused commands use each module POM and quote PowerShell properties:

```powershell
mvn -f ActivityMaster/forums/pom.xml '-Dtest=ForumStorageTest,CommunicationsGraphQLTest,CommunicationsGraphQLContractTest' test
mvn -f ActivityMaster/wallet/pom.xml '-Dtest=WalletIntegrationTest' test
mvn -f ActivityMaster/payments/pom.xml '-Dtest=PaymentIntegrationTest,PaymentContractTest' test
mvn -f ActivityMaster/mail/pom.xml test
```

Use disposable PostgreSQL/Testcontainers for security/lifecycle/provenance tests.
Inspect test counts and skips, not only Maven exit status. A skipped local SMTP
test proves no transport round trip. These checks do not prove live host identity
bindings, browser consent UX, deployed upgrades or real provider confirmation.
Do not commit, revert or run Maven clean unless the user changes that constraint.
Install dependencies in order and avoid replacing Windows JARs while consumer
tests are using them; repository-copy errors can appear after `BUILD SUCCESS`.

Implementation ownership: client `IMasterPlugin`/`MasterDefaultPlugin`, core
`fsdm.plugins.PluginService`/`PluginModels`/`PluginInstall`/`BuiltInPluginsInstall`,
core `fsdm.transactions.FsdmBehaviorAuthority`, Mail `MailFsdmService`, Wallet
`WalletAuthority`, Payments `PaymentAccess`, and each transport's identity provider.
