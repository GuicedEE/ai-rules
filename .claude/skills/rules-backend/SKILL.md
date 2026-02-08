---
name: rules-backend
description: Route and apply backend and server-side rules across enterprise frameworks. Use for quarkus, vertx, hibernate, guicedee, mapstruct, lombok, spring, jspecify, security-reactive, and fluent-api rule selection.
---

# Backend Rules Router

## Instructions
1. Start from `../../../../generative/backend/README.md`.
2. Choose the backend framework/topic matching the target codebase.
3. Use `../rules-catalog/references/rules-inventory.md` to resolve exact `*.rules.*` files or `rules/` paths.
4. Cross-link backend choices with platform/security/testing topics when relevant.
5. If scope includes GuicedEE MCP servers, load `../../../../generative/backend/guicedee/mcp/README.md` and all linked topic modules before code generation.
6. Enforce library-first implementation: prefer concrete APIs/SPI contracts from selected backend libraries before creating new interfaces.
7. Create new interfaces only when a required extension point is missing from selected libraries or explicitly requested by the user.

## Primary Backend Topics
- `../../../../generative/backend/guicedee/README.md`
- `../../../../generative/backend/quarkus/README.md`
- `../../../../generative/backend/vertx/README.md`
- `../../../../generative/backend/hibernate/README.md`
- `../../../../generative/backend/mapstruct/README.md`
- `../../../../generative/backend/lombok/README.md`
- `../../../../generative/backend/security-reactive/README.md`
- `../../../../generative/backend/fluent-api/README.md`
- `../../../../generative/backend/spring/README.md`
- `../../../../generative/backend/jspecify/README.md`
