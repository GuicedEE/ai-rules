# JWebMP Typescript Client — Rules Index

Scope
- How to apply JWebMP Angular TypeScript metadata rules for Ng* annotations, scanning, configuration, and render helpers that emit build-time TS for Angular 20.
- Forward-only, docs-first, CRTP fluent API; Log4j2 logging via Lombok `@Log4j2`; Java 25 + Maven.

Modules
- Annotations & contracts — `annotations.rules.md`
- Scanning & runtime wiring — `scanning-runtime.rules.md`
- Configuration & rendering — `configuration-rendering.rules.md`
- Service interfaces & templates — `interfaces.rules.md`
- Testing & validation — `testing.rules.md`
- CI/CD & releases — `ci-cd-release.rules.md`
- Glossary — `GLOSSARY.md`

Cross-links (enterprise topics)
- Language: `../../language/java/java-25.rules.md`, `../../language/angular/README.md`, `../../language/angular/angular-20.rules.md`, `../../language/typescript/README.md`
- Frameworks: `../README.md` (JWebMP index), `../client/README.md` (JWebMP Client), `../../backend/guicedee/client/README.md`, `../../backend/fluent-api/README.md`, `../../backend/jspecify/README.md`
- Logging: `../../backend/logging/README.md`
- CI/CD: `../../platform/ci-cd/README.md`, `../../platform/ci-cd/providers/github-actions.md`
- Secrets/config: `../../platform/secrets-config/env-variables.md`

Rules of engagement
- Generated TypeScript is a build artifact; never edit outputs directly—change Java annotations and rerun.
- No inline HTML strings in Java; compose markup with JWebMP components.
- CRTP is mandatory; avoid builders in fluent setters/configuration types.
- Keep host docs outside `rules/`; link back to `docs/PROMPT_REFERENCE.md` and `docs/architecture/` diagrams for context.
