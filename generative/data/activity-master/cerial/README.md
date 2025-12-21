# Activity Master — Cerial (Topic Index)

Scope
- Serial port configuration and lifecycle addon for Activity Master. Provides APIs to register COM ports as resource items, apply classifications, emit events, and retrieve connections with Mutiny reactive flows and GuicedEE DI.

Quick links
- Glossary — `GLOSSARY.md`
- Architecture — `architecture/README.md`
- Rules: `rules/api.rules.md`, `rules/configuration.rules.md`, `rules/lifecycle.rules.md`, `rules/events.rules.md`, `rules/testing.rules.md`
- Related topics: Activity Master Core/Client — `../core/README.md`, `../client/README.md`; Activity Master Cerial Client — `../cerial-client/README.md`; GuicedEE Cerial (lower-level hardware) — `../../../backend/guicedee/cerial/README.md`; Vert.x 5 — `../../../backend/vertx/README.md`; Fluent API (CRTP) — `../../../backend/fluent-api/README.md`; Logging — `../../../backend/logging/README.md`; Lombok — `../../../backend/lombok/README.md`; JSpecify — `../../../backend/jspecify/README.md`; CI/CD — `../../../platform/ci-cd/providers/github-actions.md`; Env/secrets — `../../../platform/secrets-config/env-variables.md`.

Prompt language alignment & glossary
- Use topic-first glossary at `GLOSSARY.md`; host projects should link rather than duplicate definitions. No special component renames beyond CRTP vs Builder routing (CRTP required).
- Classification/event/resource names must follow the enums defined in this topic to keep registry consistency.

Expectations
- Documentation-first, forward-only. Keep rules modular (no monoliths).
- CRTP fluent API only (no builders) and Lombok `@Log4j2` for logging.
- All persistence flows use caller-supplied Mutiny sessions and Activity Master system tokens.
- Dual registration via JPMS `provides` and META-INF/services is required for installers and system providers.
