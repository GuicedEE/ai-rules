# OpenAPI — Platform Rules (Observability)

Purpose
- Organization-wide standards for authoring, publishing, validating, aggregating, and consuming OpenAPI contracts across services.
- Applies to HTTP APIs exposed by backend services and platform shells/gateways. Implementation-specific rules live under their topics and are referenced here.

Scope
- Contract authoring (structure, versioning, error model, security).
- Publication endpoints and discovery (per service and via shells/gateways).
- CI/CD validation and breaking-change gating.
- Aggregation and routing at shells/gateways (optional combined UI).
- Documentation UX posture per environment (dev/test/stage/prod).
- Provider posture: support three providers with a single standard — Swagger (default), MicroProfile OpenAPI, Springdoc OpenAPI.

See also
- Backend (Spring MVC) implementation — ../../backend/spring/openapi-springdoc.md
- Platform Observability index — ./README.md
- Security & Auth — ../security-auth/README.md
- Secrets & Config — ../secrets-config/README.md

Authoring standards (service contracts)
- OpenAPI version: 3.0+ or 3.1 preferred.
- Required top-level sections:
  - info: title, version (SemVer), description, contact, license.
  - servers: prefer relative base (“/”) and delegate absolute env-specific URLs to gateway/runtime.
  - tags: stable grouping by bounded context; keep low-cardinality.
  - paths: HTTP semantics aligned to REST; declare operationId (unique per API).
  - components:
    - schemas: DTOs; reuse via $ref to avoid duplication.
    - securitySchemes: standardize HTTP bearer JWT where applicable (see Security posture).
    - responses/parameters: centralize shared elements where reused.
- Naming and style:
  - Paths use kebab-case; path variables in camelCase: /api/v1/users/{userId}.
  - operationId: verbNoun or nounAction; must be unique within the contract and stable across minor versions.
  - Tag names: PascalCase or kebab-case consistently; reflect bounded contexts.
- Error model:
  - Standardize on RFC 7807 Problem Details. Define a Problem schema and reference it from 4xx/5xx responses.
  - Include stable "type" URIs and "code" fields to enable client routing.
- Pagination/sorting:
  - Prefer explicit query params page (1-based), size (cap ≤ 100), sort ("field,asc|desc").
  - Document defaults and caps; provide a reusable Pageable parameters object if desired.
- Date/time and IDs:
  - Use RFC 3339 timestamps (UTC). IDs as strings unless numeric semantics are required.
- Examples:
  - Provide representative success and error examples for key operations; prefer concise but realistic payloads.

Versioning policy
- Path versioning is mandatory: /api/v1/... (major version in path). Do not embed minor/patch in the path.
- Contract SemVer:
  - MAJOR: breaking changes (remove/rename fields, change semantics, requiredness).
  - MINOR: additive, backward-compatible fields/endpoints.
  - PATCH: docs-only or non-behavioral clarifications.
- Deprecations:
  - Mark deprecated operations and fields; provide removal timeline and replacement guidance.
  - Do not remove within the same major version.

Security posture
- SecuritySchemes:
  - Use HTTP bearer (JWT) unless an alternative is mandated. Name the scheme "bearer-jwt".
  - Document required scopes/authorities per operation using security requirements.
- Documentation endpoints:
  - Dev/Test: Swagger UI may be enabled behind authenticated access.
  - Prod: Disable UI or restrict to ops. /v3 endpoints restricted to trusted principals (CI, internal networks).
- Cross-reference:
  - See ../security-auth/README.md for provider posture and token validation requirements.
  - See ../secrets-config/README.md for management of credentials and endpoints.

Publication and discovery (service level)
- Provider selection (choose one; default = Swagger):
  - Swagger (JAX‑RS/Swagger Core)
    - OpenAPI: /swagger.json (JSON), /swagger.yaml (YAML)
    - UI (when bundled): /swagger-ui/index.html
  - MicroProfile OpenAPI (e.g., SmallRye, Jakarta EE)
    - OpenAPI: /openapi (content negotiation), /openapi.json, /openapi.yaml
    - UI: implementation-specific (vendor provided or external bundle)
  - Springdoc OpenAPI (Spring Boot)
    - OpenAPI: /v3/api-docs (JSON), /v3/api-docs.yaml (YAML)
    - UI: /swagger-ui/index.html
- Health endpoints (default = MicroProfile):
  - MicroProfile Health: /health, /health/ready, /health/live
  - Spring Actuator: /actuator/health, /actuator/ready, /actuator/live
  - JAX‑RS (other stacks): align to MicroProfile unless platform policy dictates otherwise
- Publication requirements
  - Contracts must reflect the running version (info.version) and routes bound to this instance.
  - If using dynamic gating or features, document conditional fields explicitly.

Aggregation and routing (shells/gateways)
- Shell responsibilities (if present):
  - Maintain a registry of mounted services and their OpenAPI URLs, prefixes, and health endpoints.
  - Optionally expose a combined catalog UI; do not mutate service contracts.
- Mounting guidance:
  - Each service contract is mounted under a distinct prefix, aligned with the runtime route (e.g., /api/v1/users → users service).
  - Avoid re-basing servers inside contracts at mount time; prefer external routing configuration.
- Example shell registry (YAML):
  ```yaml
  services:
    - name: users
      prefix: /api/v1/users
      openapi: https://users.example.com/v3/api-docs.yaml
      health:  https://users.example.com/actuator/health
    - name: orders
      prefix: /api/v1/orders
      openapi: https://orders.example.com/openapi.yaml
      health:  https://orders.example.com/health
  ```

CI/CD validation (mandatory)
- Contract artifact production:
  - Generate and publish JSON and/or YAML artifacts per build (attach to CI artifacts or push to registry).
  - Name artifacts predictably: <service>-openapi-v<MAJOR>.<MINOR>.<PATCH>.json|yaml.
- Breaking change gates:
  - Compare the PR contract against the base branch using an OpenAPI diff tool; fail on breaking diffs.
  - Document allowed additive changes and the definition of "breaking" in the pipeline.
- Linting:
  - Apply Spectral or equivalent ruleset:
    - info/version present and SemVer, operationId unique, tag presence, schemas referenced, error responses include Problem schema.
    - No orphan schemas; no circular $ref chains; no ambiguous nullable types without explicit schema.
- Sample CI steps (illustrative):
  ```bash
  # Export from running service (provider-aware)
  PROVIDER="${PROVIDER:-swagger}" # swagger | microprofile | springdoc
  case "$PROVIDER" in
    swagger)
      curl -fsSL http://localhost:8080/swagger.json -o build/openapi.json
      ;;
    microprofile)
      curl -fsSL -H "Accept: application/json" http://localhost:8080/openapi -o build/openapi.json
      ;;
    springdoc)
      curl -fsSL http://localhost:8080/v3/api-docs -o build/openapi.json
      ;;
  esac

  # Lint (spectral) and diff (openapi-diff or similar)
  spectral lint build/openapi.json
  openapi-diff --fail-on-diff --fail-on-incompatible base/openapi.json build/openapi.json
  ```

Reuse and component governance
- Shared schemas:
  - Extract common primitives (Error/Problem, Pageable, Money, Address) into components and reuse within the service contract.
  - Avoid duplicating identical schema fragments across operations.
- Consistency:
  - Use consistent enum values and casing across services for shared concepts; document in a shared glossary if mandated by the domain.
- Binary payloads:
  - Prefer JSON; if binary is required, document media types precisely (e.g., application/pdf) and include size constraints.

Documentation UX posture
- Dev/Test:
  - Swagger UI enabled; group APIs with tags and short, task-oriented summaries; include examples.
- Stage/Prod:
  - UI disabled or behind ops-only auth. Contracts accessible to internal tooling only.
  - Provide a catalog (HTML or JSON) listing service names, prefixes, versions, and OpenAPI URLs.

Error model (Problem Details)
- Components (recommended):
  ```yaml
  components:
    schemas:
      Problem:
        type: object
        required: [type, title, status]
        properties:
          type: { type: string, format: uri }
          title: { type: string }
          status: { type: integer, format: int32, minimum: 400, maximum: 599 }
          detail: { type: string }
          instance: { type: string, format: uri }
          code: { type: string, description: "Stable machine-readable code" }
          errors:
            type: array
            items:
              type: object
              properties:
                field: { type: string }
                message: { type: string }
  ```
- Usage:
  - Reference Problem in 4xx/5xx responses; keep "type" stable and resolvable where possible.

Observability alignment
- Correlation:
  - Include correlation/trace IDs in responses/headers; document header conventions (e.g., X-Correlation-Id).
- Deprecation lifecycle:
  - Emit deprecation headers for soon-to-be-removed endpoints; document deprecation in contract "description" fields.
- Health and readiness:
  - Ensure contracts are published only after readiness; coordinate with startup sequencing (./README.md).

Implementation references
- Spring MVC (springdoc) rules — ../../backend/spring/openapi-springdoc.md
  - Endpoints (/v3/api-docs, /v3/api-docs.yaml), grouping, security schemes, examples, CI publishing posture.
- Security & Auth — ../security-auth/README.md
- Secrets & Config — ../secrets-config/README.md

Checklists

Service checklist
- [ ] info.version (SemVer) and servers configured (relative base recommended)
- [ ] SecuritySchemes defined and applied per operation (bearer-jwt or project standard)
- [ ] Problem Details schema provided and referenced by error responses
- [ ] Pagination parameters documented with defaults and caps
- [ ] operationId unique and stable; tags present and consistent
- [ ] Contract published at provider endpoint:
      - Swagger: /swagger.(json|yaml) OR MicroProfile: /openapi(.json|.yaml) OR Springdoc: /v3/api-docs(.yaml);
      health endpoint available (MicroProfile: /health[/ready|/live] OR Spring Actuator: /actuator/health[/ready|/live])
- [ ] CI produces contract artifact; lints and gates breaking changes

Shell/Gateway checklist (if applicable)
- [ ] Registry of mounted services and OpenAPI URLs maintained
- [ ] Optional combined UI; does not mutate contracts
- [ ] Contracts restricted appropriately in prod; UI disabled or behind ops auth
- [ ] Catalog endpoint exposes service name, prefix, version, OpenAPI URL

See also
- Observability — ./README.md
- Security & Auth — ../security-auth/README.md
- Secrets & Config — ../secrets-config/README.md
- Spring MVC OpenAPI — ../../backend/spring/openapi-springdoc.md
