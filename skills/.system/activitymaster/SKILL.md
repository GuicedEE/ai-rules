---
name: activitymaster
description: "Implement ActivityMaster FSDM services and user-scoped plugins, including Mail, Wallet, Payments, Documents, Conversations, Marketplace, security, lifecycle and stateless persistence."
metadata:
  short-description: FSDM enterprise resource management platform
---

# ActivityMaster

Open-source implementation of the Functional Service Data Model (FSDM) for enterprise resource management.

## Service invariants

- For service changes, read the security and practices references below before implementation.
- Resolve context with `SessionUtils.withActivityMaster(...)` and use `Mutiny.StatelessSession`. Runtime user authorization uses the verified actor credential; tuple/plugin/core credentials never substitute for it. Core bootstrap credentials serve trusted lifecycle provisioning only.
- Keep service and REST flows non-blocking with `Uni` composition; preserve the documented worker-thread exception.
- Respect scope-restricted row security and `ActiveFlag` lifecycle rules.
- Resolve classifications with the data-concept-scoped lookup; classification names are not globally unique.
- Use the canonical `Environment` resolver for configuration.
- ActivityMaster owns scoped plugin concepts and persistence; management UI and authenticated plugin endpoints belong in a separate consuming module.
- Country flags use `geo-country-flags`: store images through Image Master and link them to two-letter Geography countries with `CountryFlag` resource relationships. Cache bundled bytes only; resolve current FSDM rows and tokens for access.

- Wallet Master owns its service binder and REST/GraphQL adapters. The authenticated host supplies verified identity through `WalletIdentityProvider`; `WalletAuthority` checks current actor and row permissions. Wallet responses await the complete stateless transaction, including relationships and security.
- Conversation Master uses FSDM Arrangements, InvolvedParty links, Events, and private ResourceItems. The host supplies `ConversationIdentityProvider`; `ConversationApi` never accepts actor identity from request data. Require current membership and context for reads, sends, and leave. Read [Conversations](references/feature-modules.md#conversations-module) for the current contract and limits.

## Plugin architecture essentials

- A plugin has its own `IMasterPlugin` SPI and `MasterDefaultPlugin` base; it must
  never implement `IMasterSystem` or inherit `MasterDefaultSystem`. Stable technical
  registration IDs do not grant System authority. Its identity is Plugin under
  Plugins. Mail, Wallet, Payments, Documents, Conversations, Marketplace and
  Marketplace Products are plugins; Forum and Notification retain delegated calls.
- Registration, declaration, party installation, individual consent, administrator
  policy, provider behavior grants and domain row permissions are separate gates.
  Discovery, catalogue metadata and an old receipt grant none of them.
- Bind `PluginModels.Identity` and `Invocation` in the authenticated host. Use a
  live organic user's `User`/canonical `Identity` credential, never a token row ID,
  bearer string or Plugin credential. Keep invocation context through every hop.
- Install only on a real involved party the actor can write. Organisation members
  still need their own consent; enterprise UUIDs and installation party IDs have
  different meanings. Personal/Social context owners are parties; Work is enterprise-owned.
- `PluginService` persists catalogue Arrangements and secured authorization Events.
  Use its current backend decisions; add no parallel plugin/permission tables.
- All service operations need the caller's stateless transaction. Check delegation
  and row/domain permissions, write links/security/audit, then await commit. Shared
  catalogue locks order admission against exclusive management/revocation locks.
- Administrator denial overrides consent. Removing/reinstalling or removing and
  reintroducing a dependency requires fresh consent; metadata-only updates do not.
- Domain provenance belongs to the last writing Master. Cross-writer relationship
  updates archive/replace even equal values and link the predecessor. Record the
  initiating plugin separately rather than stamping it onto downstream writes.
- Built-in updates 1010/1020/1030 provision taxonomy and forward-convert identities
  before domain updates; preserve IDs/data/media and retire legacy System credentials.
  Provisioning never installs for a party or consents for a user.
- Mail ingests with verified `MailIdentity` into private FSDM records atomically.
  Headers/addresses never establish the actor. Payments checks its Core/Wallet
  dependencies and fresh user authorization before Wallet settlement; Wallet keeps
  provider behavior grants, row checks and balanced posting.
- Documents and Conversations check built-in admission even for reads/history.
  Marketplace Products is a separate product-loading plugin declaring Core and
  Marketplace; buyers need only Marketplace's admission and normal row/behavior grants.
- Other Masters need explicit delegation integration before exposing plugin calls.
  Raw SQL and low-level FSDM helpers are not a sandbox or automatic permission filter.

The complete [plugin interaction contract](references/scoped-plugins.md) includes
the current management APIs, usage examples, media constraints, lifecycle and
revocation semantics. Use it for plugin architecture or access changes.

## Workflow references

Use the bundled reference for the task. Interaction contracts are self-contained.
DevSuite build commands run from `C:/Java/DevSuite` unless a module working directory
is stated; skill files can be installed elsewhere without changing these contracts.

- [Geography country flags and Image Master](references/geography-country-flags.md): `CountryFlagCatalog`, code validation, safe caching, FSDM links, installation/backfill, optional country resource SPI and image URLs. Read for country flags or geography-linked image work.

- [Forum Master](references/forums.md): verified host identity, FSDM forums and posts, organic subscriber management, REST usage, and atomic notification publication. Read for forum work.
- [Conversations, notifications, and SEO](references/conversations-notifications-seo.md): current FSDM models, verified identity, scoped grants, delivery, publishing, and SEO routes. Read for these modules.
- [Domain and modules](references/guide-domain-and-modules.md): Core Architecture; Module Structure; Adding a New Module.
- [Profiles and user sessions](references/guide-profiles-and-user-sessions.md): service contracts, profile REST/GraphQL usage, and session transport integration limits.
- [Transports](references/guide-transports.md): REST API Architecture; GraphQL Architecture; Event Bus Architecture.
- [Security](references/guide-security.md): Security & Token Propagation.
- [Plugins](references/scoped-plugins.md): System versus Plugin scope, catalogue, party installation, per-user consent, administrator policy, delegation, provenance, forward conversion and provider behavior layers.
- [Documents plugin](references/documents.md): verified host identity, installation/consent, private buckets, resources, version history and revocation.
- [Marketplace plugins](references/marketplace.md): separate product producer, seller/row/behavior authority, carts, checkout and settlement boundaries.
- [Mail plugin](references/mail.md): verified mailbox identity, ingestion overloads, private atomic FSDM storage, trusted helpers and SMTP/IMAP job boundaries.
- [Transactions](references/transactions.md): Wallet Arrangements, parent Events, balanced transaction entries, derived metrics, WalletAuthority, standalone REST/GraphQL, host identity binding and integration validation. Read for Wallet Master or movement-of-value work.
- [Payments](references/payments.md): reusable host and provider contracts, FSDM payment intents, verified callbacks, atomic wallet settlement and query performance checks. Read for Payment Master work.
- [Enterprise encryption](references/guide-enterprise-encryption.md): per-enterprise DEKs, Azure Key Vault wrapping, preparation, tenant-bound values, legacy compatibility and rotation.
- [Lifecycle](references/guide-lifecycle.md): Lifecycle & Bootstrap; On-Demand Data Loading Pattern; Progress Reporting (IProgressable + SPI monitors).
- [Persistence](references/guide-persistence.md): Quick Start; ActiveFlag Lifecycle; JSON Resource Items (MongoDB Document Store); Reactive Patterns with Mutiny; Database Configuration.
- [Development](references/guide-development.md): Testing with Testcontainers; CRTP Fluent Builders; Configuration & Environment.
- [Practices](references/guide-practices.md): Best Practices; Documentation Structure; Troubleshooting.

## Overview

ActivityMaster is a comprehensive enterprise platform built on:
- **FSDM Domain Services** — Enterprise, Address, Events, Arrangements, ResourceItem, InvolvedParty, Classification, Rules, Products
- **Reactive Persistence** — Hibernate Reactive 7 + PostgreSQL
- **Async Workflows** — Vert.x 5 event-driven architecture
- **GuicedEE DI** — Dependency injection with lifecycle hooks
- **JAX-RS REST** — Jakarta REST adapters; plugin/domain success awaits authorization, relationships, security, audit and commit
- **GraphQL** — SDL-first schema federation via `IGraphQLSchemaProvider` SPI
- **Event Bus** — Vert.x event bus consumers for async operations via `@VertxEventDefinition`
- **Security** — Token propagation, ActiveFlag enforcement, and **flag-driven scope-restricted** (secure-by-default) row security with geography-mirrored scope tokens
- **Modular Design** — 20+ specialized modules

## Installation

```xml
<!-- BOM for version management -->
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.activity-master</groupId>
      <artifactId>activity-master-bom</artifactId>
      <version>${activitymaster.version}</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>

<!-- Core module -->
<dependency>
  <groupId>com.activity-master</groupId>
  <artifactId>activity-master</artifactId>
</dependency>

<!-- Client module -->
<dependency>
  <groupId>com.activity-master</groupId>
  <artifactId>activity-master-client</artifactId>
</dependency>
```

## References

- Core JPMS module: `com.guicedee.activitymaster.fsdm`; client: `com.guicedee.activitymaster.fsdm.client`
- Hibernate Reactive: 7.x
- Vert.x: 5.x
- PostgreSQL: 15+
- GuicedEE: Latest
- Java: 25+
- License: Apache 2.0

**For detailed service documentation:** See [references/fsdm-services.md](references/fsdm-services.md)
**For module details:** See [references/feature-modules.md](references/feature-modules.md)
**For configuration:** See [references/configuration.md](references/configuration.md)
**For enterprise lifecycle:** See [references/enterprise-lifecycle.md](references/enterprise-lifecycle.md)
**For JSON resource items (MongoDB):** See [references/json-resource-items.md](references/json-resource-items.md)
