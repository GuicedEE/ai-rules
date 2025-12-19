# Configuration and Deployment Rules

Scope: Environment, module registration, logging, and dependency wiring for the Activity Master client library.

Environment and secrets
- Mirror .env.example keys with ../../../platform/secrets-config/env-variables.md; inject via Terraform or CI (GitHub Actions) before runtime.
- Never hardcode credentials; reference environment variables for PostgreSQL, token secrets, and logging toggles.

Module registration
- Include ActivityMasterClientModuleInclusion in GuicedEE bootstrap; ensure IGuiceScanModuleInclusions picks up client services before Vert.x/Hibernate contexts start.
- Align module lifecycle with ./lifecycle.rules.md; document bindings and overrides in IMPLEMENTATION.md.

Logging and observability
- Default to Log4j2 configuration as per ../../../backend/logging/README.md. Avoid alternative logging annotations; prefer @Log4j2 if Lombok is present elsewhere.
- Publish health/readiness endpoints and diagnostics using ../../../platform/observability/README.md guidance; avoid blocking logging appenders in reactive flows.

Build and dependencies
- Declare Maven coordinates only (groupId:artifactId:version) and rely on ../../../language/java/build-tooling.md for plugin wiring.
- Align Hibernate Reactive 7 + Vert.x 5 versions with BOM constraints; do not pin conflicting versions locally without updating RULES/GLOSSARY references.

Deployment and distribution
- Document any JPMS module requirements (e.g., org.postgresql) and avoid shading PostgreSQL drivers per policy.
- Capture release-impacting configuration changes in ./release-notes.md and note them in docs/PROMPT_REFERENCE.md if stacks change.
