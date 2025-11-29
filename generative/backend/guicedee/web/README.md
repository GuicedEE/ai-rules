# GuicedEE Vert.x Web Rules

This directory contains the authoritative rules and guidelines for developing HTTP/HTTPS server implementations using **GuicedEE** with **Vert.x 5 Web**.

## Overview

GuicedEE Vert.x Web provides a bootstrapper module that integrates Vert.x Web into the GuicedEE ecosystem, enabling declarative configuration and extension through Service Provider Interfaces (SPI). It supports:

- HTTP and/or HTTPS server creation with TLS/keystore configuration
- SPI-driven customization of server options, server instance, and router
- GuiceEE dependency injection within configurators
- Environment-based configuration (`.env` / system properties)
- Jackson JSON codec integration via GuiceEE services
- Request body handling and file uploads with automatic cleanup

## Rules Index

- **[guiced-vertx-web-rules.md](guiced-vertx-web-rules.md)** — Core package structure, SPI patterns, lifecycle, HTTP/HTTPS configuration, router setup, common use cases, best practices, and troubleshooting.
- **[GLOSSARY.md](GLOSSARY.md)** — Term precedence and definitions specific to GuicedEE Vert.x Web.

## Quick Links to Related Enterprise Topics

- GuicedEE Core: [rules/generative/backend/guicedee/README.md](../README.md)
- GuicedEE Vert.x Bridge: [rules/generative/backend/guicedee/vertx/README.md](../vertx/README.md)
- Vert.x 5 Core: [rules/generative/backend/vertx/README.md](../../vertx/README.md)
- CRTP Fluent APIs: [rules/generative/backend/fluent-api/crtp.rules.md](../../fluent-api/crtp.rules.md)
- JSpecify Nullness: [rules/generative/backend/jspecify/README.md](../../jspecify/README.md)
- Java 25 LTS: [rules/generative/language/java/java-25.rules.md](../../../language/java/java-25.rules.md)
- GitHub Actions CI/CD: [rules/generative/platform/ci-cd/providers/github-actions.md](../../../../platform/ci-cd/providers/github-actions.md)
- Secrets & Environment: [rules/generative/platform/secrets-config/env-variables.md](../../../../platform/secrets-config/env-variables.md)

## Key Conventions

- **CRTP Fluent APIs:** Fluent setters return `(J)this`; avoid Lombok `@Builder`.
- **SPI Naming:** Keep configurator interfaces aligned to JPMS service declarations (`VertxRouterConfigurator`, `VertxHttpServerConfigurator`, `VertxHttpServerOptionsConfigurator`).
- **Nullness:** Apply JSpecify annotations to public APIs; default non-null unless specified.
- **Module System:** Declare `uses` and `provides` in `module-info.java` for all SPI implementations and consumers.
- **Environment Variables:** Mirror configuration in `.env.example`; no secrets in code or version control.

## Glossary Precedence

Topic glossaries override host definitions in this order:

1. [rules/generative/backend/guicedee/web/GLOSSARY.md](GLOSSARY.md) — GuicedEE Vert.x Web terms
2. [rules/generative/backend/guicedee/GLOSSARY.md](../GLOSSARY.md) — GuicedEE platform
3. [rules/generative/backend/guicedee/vertx/GLOSSARY.md](../vertx/GLOSSARY.md) — GuicedEE Vert.x Bridge
4. [rules/generative/backend/vertx/README.md](../../vertx/README.md) — Vert.x core
5. [rules/generative/backend/fluent-api/GLOSSARY.md](../../fluent-api/GLOSSARY.md) — CRTP patterns
6. [rules/GLOSSARY.md](../../../../GLOSSARY.md) — General/shared

## Approval Status & Collaboration

- **Stage:** Forward-only (breaking changes allowed; no legacy anchors)
- **Pact:** Documented in host project `PACT.md`
- **Traceability:** Close loops: PACT ↔ RULES ↔ GUIDES ↔ IMPLEMENTATION ↔ Diagrams

## Document Modularity Policy

- Host project docs stay at the repo root or `docs/`; rules stay inside this `rules/` submodule.
- When altering SPI surfaces or router wiring, update `docs/architecture/` and `IMPLEMENTATION.md` in the host project.
- Reference this rules directory from host RULES.md, GUIDES.md, and docs.

## Contribution & Maintenance

When updating GuicedEE Vert.x Web rules:

1. Ensure all links resolve to modular topic files (not monoliths).
2. Close loops: every change in rules must be reflected in host `GUIDES.md` and `IMPLEMENTATION.md`.
3. Respect forward-only: remove obsolete docs in the same change set; update all references.
4. Validate against [rules/RULES.md](../../../../RULES.md) sections 4, 5, Document Modularity, and 6.

---

**Last Updated:** November 2025  
**Repository:** GuicedEE/GuicedVertxWeb (`com.guicedee.vertx.web`)  
**License:** See root `LICENSE` file
