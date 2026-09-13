---
name: activitymaster
description: "Implement ActivityMaster/FSDM services, scope-token security, reactive persistence, and MongoDB JSON resource items."
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

## Workflow references

Read the reference for the task you are working on. Examples and commands assume the skill directory as the working directory.

- [Domain and modules](references/guide-domain-and-modules.md): Core Architecture; Module Structure; Adding a New Module.
- [Transports](references/guide-transports.md): REST API Architecture; GraphQL Architecture; Event Bus Architecture.
- [Security](references/guide-security.md): Security & Token Propagation.
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
