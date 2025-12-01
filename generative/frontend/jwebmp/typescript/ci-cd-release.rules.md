# CI/CD & Release Rules

Scope
- Packaging, versioning, and release expectations for the JWebMP Typescript Client library.

Build & tooling
- Java 25 + Maven are mandatory; follow `rules/generative/language/java/build-tooling.md` for plugin wiring.
- CI uses `.github/workflows/maven-package.yml` (GuicedEE shared workflow). Required secrets: `USERNAME`, `USER_TOKEN`, `SONA_USERNAME`, `SONA_PASSWORD`, `GPG_PASSPHRASE`, `GPG_PRIVATE_KEY`.
- Keep `.env.example` aligned with `rules/generative/platform/secrets-config/env-variables.md`—only include keys relevant to this library (logging level, environment, tracing toggle).

Versioning & releases
- Forward-only policy: breaking reorganizations are allowed; document them in `RELEASE_NOTES.md` and update `CHANGELOG.md`.
- Publish to Maven Central only when CI secret set `centralRelease` is true; otherwise perform snapshot builds.
- Record release-impacting changes in `IMPLEMENTATION.md` and link back to diagrams in `docs/architecture/`.

Release notes outline
- Overview of changes (rules/docs reorganizations, new Ng* capabilities).
- Migration guidance (annotation updates, module-info changes, ServiceLoader entries).
- Testing performed (unit/integration) and CI status.
- Dependencies bumped (artifact coordinates only).

See also
- Index — `README.md`
- Testing — `testing.rules.md`
- Secrets/config — `../../platform/secrets-config/env-variables.md`
