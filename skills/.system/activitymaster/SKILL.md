---
name: activitymaster
description: Implement ActivityMaster/FSDM services, conversations, forums, notifications, geography flags via Image Master, SEO, scoped grants, and stateless persistence.
metadata:
  short-description: FSDM enterprise resource management platform
---

# ActivityMaster

Open-source implementation of the Functional Service Data Model (FSDM) for enterprise resource management.

## Service invariants

- For service changes, read the security and practices references below before implementation.
- Resolve system context with `SessionUtils.withActivityMaster(...)` and propagate its tokens.
- Keep service and REST flows non-blocking with `Uni` composition; preserve the documented worker-thread exception.
- Respect scope-restricted row security and `ActiveFlag` lifecycle rules.
- Resolve classifications with the data-concept-scoped lookup; classification names are not globally unique.
- Use the canonical `Environment` resolver for configuration.
- ActivityMaster owns scoped plugin concepts and persistence; management UI and authenticated plugin endpoints belong in a separate consuming module.
- Country flags use `geo-country-flags`: store images through Image Master and link them to two-letter Geography countries with `CountryFlag` resource relationships. Cache bundled bytes only; resolve current FSDM rows and tokens for access.

## Workflow references

Read the reference for the task you are working on. Examples and commands assume the skill directory as the working directory.

- [Geography country flags and Image Master](references/geography-country-flags.md): `CountryFlagCatalog`, code validation, safe caching, FSDM links, installation/backfill, optional country resource SPI and image URLs. Read for country flags or geography-linked image work.

- [Forum Master](references/forums.md): verified host identity, FSDM forums and posts, organic subscriber management, REST usage, and atomic notification publication. Read for forum work.
- [Conversations, notifications, and SEO](references/conversations-notifications-seo.md): current FSDM models, verified identity, scoped grants, delivery, publishing, and SEO routes. Read for these modules.
- [Domain and modules](references/guide-domain-and-modules.md): Core Architecture; Module Structure; Adding a New Module.
- [Profiles and user sessions](references/guide-profiles-and-user-sessions.md): service contracts, profile REST/GraphQL usage, and session transport integration limits.
- [Transports](references/guide-transports.md): REST API Architecture; GraphQL Architecture; Event Bus Architecture.
- [Security](references/guide-security.md): Security & Token Propagation.
- [Scoped plugins](references/scoped-plugins.md): installation ownership, access groups, behavior authorization, versioned management and the consuming-module boundary. Read for plugin concept or access changes.
- [Transactions](references/transactions.md): Wallet Arrangements, parent Events, balanced transaction entries, derived metrics and NE1 authorization. Read for Wallet Master or movement-of-value work.
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
- **JAX-RS REST** — Jakarta REST endpoints with fire-and-forget relationship persistence
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

- Module: `com.guicedee.activitymaster`
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
