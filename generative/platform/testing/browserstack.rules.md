# BrowserStack Cross-Browser Testing Rules

Purpose
- Standardize how projects run UI regression suites on BrowserStack (Automate and Live).
- Provide CI-friendly configuration for running Playwright/Cypress/WebDriver suites against BrowserStack grids.
- Keep credentials, build labels, and artifacts consistent across environments.

Scope
- Applies to frontend projects (Angular/Web Components/Next.js) and full-stack repos that execute browser-based tests in CI.
- Coordinates with framework-specific test rules (Angular TDD, Web Components TDD) for actual assertions; this file focuses on BrowserStack plumbing.

---

## Account and authentication
- Create per-environment access keys (e.g., `BROWSERSTACK_USERNAME`, `BROWSERSTACK_ACCESS_KEY`). Store only in secret managers/CI variables.
- Do not embed secrets in source; pass via env vars or `.env.ci` files excluded from VCS.
- Label builds with `BROWSERSTACK_BUILD_NAME` using `${CI_WORKFLOW}-${GIT_SHA}` to keep dashboards searchable.

## Test capability conventions
Define desired capabilities as code (JSON/YAML) and reuse them across suites.
```json
{
  "browser": "Chrome",
  "browser_version": "123.0",
  "os": "Windows",
  "os_version": "11",
  "name": "Checkout smoke",
  "build": "checkout-${GIT_SHA}",
  "browserstack.selenium_version": "4.19.1",
  "browserstack.console": "errors",
  "browserstack.networkLogs": true
}
```
Guidelines
- Explicitly pin browser, version, OS, and display resolution to avoid implicit upgrades breaking suites.
- Enable console/network logs for debugging; archive them as CI artifacts.
- Use BrowserStack local binary only when hitting non-public endpoints; manage lifecycle via CI hooks (start before tests, stop in `finally`).

## CLI scaffolding
- Keep `browserstack.json` (Automate) or `browserstack.yml` (Playwright/Cypress) at repo root to centralize config.
- Example `browserstack.yml` for Playwright:
```yaml
browserstack:
  username: ${BROWSERSTACK_USERNAME}
  access_key: ${BROWSERSTACK_ACCESS_KEY}
  project_name: Checkout Portal
  build_name: checkout-${GIT_SHA}
run_settings:
  cypress_config_file: cypress.config.ts
  npm_dependencies:
    cypress: 13.8.1
    @bahmutov/cypress-esbuild-preprocessor: 2.2.0
  parallels: 5
  browsers:
    - browserstack:chrome@latest:Windows 11
    - browserstack:edge@latest:Windows 11
```
- Use `${ENV_VAR}` placeholders; avoid hardcoding secrets or branch names.

## CI integration
- GitHub Actions: use `browserstack/github-actions/setup-browserstack@v1` to install CLI/local binary, then run `browserstack-cypress run` or `browserstack-playwright run`.
- Jenkins/GitLab: install the CLI via npm (`npm install -g browserstack-cypress-cli`) or binary download; pass env vars securely.
- Always gate merges on BrowserStack job results. Parse CLI exit codes; fail builds on test failure or infrastructure errors.

## Artifacts and reporting
- After each run, fetch:
  - Video recordings
  - Network logs / console logs
  - BrowserStack session URLs
- Attach artifacts to CI for traceability. Include links in pull request comments when feasible.
- Map BrowserStack build names to Sonar/Jacoco build IDs to keep QA + quality gates consistent.

## Local testing / tunnels
- For non-public dev environments, run `BrowserStackLocal` with unique identifiers per job.
- Store the local identifier in env var `BROWSERSTACK_LOCAL_IDENTIFIER` and pass it in capabilities.
- Ensure tunnels stop even on failure (use trap/finally). Do not share tunnels across concurrent jobs.

## Security & compliance
- Keys are secrets: rotate quarterly.
- Restrict project/dashboard access to the required teams.
- When uploading builds, avoid PII in test names or metadata.

---

## See also
- Testing & Coverage index — ./README.md
- Glossary — ./GLOSSARY.md
- Cypress rules — ./cypress.rules.md (if running BrowserStack Cypress CLI)
- Angular/Web Components TDD rules — ../../language/angular/tdd.md, ../../frontend/webcomponents/tdd.md
- CI/CD providers — ../ci-cd/README.md
