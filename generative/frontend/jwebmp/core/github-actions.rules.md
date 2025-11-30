# GitHub Actions (CI/CD) Rules

Overview
- CI uses the shared workflow `GuicedEE/Workflows/.github/workflows/projects.yml@master` (`.github/workflows/maven-publish.yml`).
- Toolchain: Java 25 + Maven; jobs depend on repository secrets for publishing.
- Extend via workflow inputs rather than duplicating steps locally.

Required secrets (per current workflow)
- `USERNAME`, `USER_TOKEN`
- `SONA_USERNAME`, `SONA_PASSWORD`
- `GPG_PASSPHRASE`, `GPG_PRIVATE_KEY`

Guidance
- Treat `maven-publish.yml` as canonical; add new workflows only for new release channels.
- Use `centralRelease` input to control Maven Central publication (default false).
- Do not commit secrets or sample values; document runtime expectations in README and `.env.example` only.
- Apply forward-only policy: remove obsolete workflows instead of disabling them.

See also
- Topic index: ./README.md
- Enterprise rules: ../../platform/ci-cd/providers/github-actions.md
- Release notes: `RELEASE_NOTES.md` (when present)
