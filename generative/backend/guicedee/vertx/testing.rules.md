# Testing & Validation

Validate registry, codecs, and publishers with deterministic tests on Java 25/Maven.

- Unit tests:
  - Cover `VertxEventRegistry` discovery for annotated methods/classes; assert address/payload metadata and consumer counts.
  - Codec round-trip tests using `CodecRegistry` for custom DTOs (encode/decode) to prevent duplicate registration.
  - Publisher tests using `VertxEventPublisher` with a real Vert.x instance; assert send/publish behavior and reply handling.
- Integration tests:
  - Start GuicedEE lifecycle hooks (pre/post startup) in test harnesses; verify bindings exist and verticles deploy.
  - Use Vert.x test context for async assertions; avoid Thread.sleep.
- Tooling:
  - Run `mvn -B -ntp test` (GitHub Actions default). Keep tests hermetic; no external services.
  - Prefer structured logging in tests; avoid reliance on console parsing.
- Coverage of failure modes:
  - Duplicate codec registration should be handled gracefully (log/skip).
  - Invalid payload mapping should surface clear errors (JSON conversion failures).
- Link tests to docs: reference docs/architecture/sequence-publish-consume.md and docs/design-validation.md for acceptance criteria.

See also: generative/backend/vertx/README.md (testing guidance), generative/platform/ci-cd/providers/github-actions.md.
