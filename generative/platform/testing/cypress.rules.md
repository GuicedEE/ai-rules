# Cypress E2E Testing Rules

Purpose
- Define canonical usage of Cypress for UI and API regression suites across repositories.
- Harmonize Cypress configuration (TypeScript support, fixtures, env separation) with the Rules Repository’s documentation-first workflow.
- Ensure Cypress runs participate in coverage/quality gates (where relevant) and integrate with BrowserStack or local harnesses.

Scope
- Applies to frontend projects (Angular, React, Next.js, Web Components) and hybrid stacks embedding Cypress for end-to-end validation.
- Covers Cypress 13.x with component and e2e runners.

---

## Project structure
```
webapp/
├── cypress/
│   ├── e2e/
│   ├── fixtures/
│   ├── support/
│   └── tsconfig.json
├── cypress.config.ts
└── package.json
```
Guidelines
- Keep `cypress/` directory at repo root or under the frontend package; avoid scattering tests.
- Use TypeScript config for autocompletion and type-safe custom commands.
- Store test data fixtures as JSON/YAML; keep secrets in environment variables, not fixture files.

## Configuration (`cypress.config.ts`)
```ts
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    baseUrl: process.env.CYPRESS_BASE_URL ?? 'http://localhost:4200',
    specPattern: 'cypress/e2e/**/*.cy.ts',
    supportFile: 'cypress/support/e2e.ts',
    video: true,
    retries: { runMode: 2, openMode: 0 },
    env: {
      apiUrl: process.env.CYPRESS_API_URL,
      featureFlags: process.env.CYPRESS_FEATURE_FLAGS?.split(',') ?? []
    }
  },
  component: {
    devServer: {
      framework: 'angular',
      bundler: 'webpack'
    }
  }
});
```
- Parameterize URLs/env via `CYPRESS_*` variables; provide `.env.example` with placeholders.
- Enable video/screenshots for CI runs; clean them after upload if space constrained.

## Best practices
1. **Test taxonomy**
   - Tag tests with `@smoke`, `@regression`, `@accessibility` via custom tags or environment flags.
   - Keep suites deterministic; no fixed `cy.wait`. Prefer network assertions (`cy.intercept`, `cy.wait('@request')`).

2. **Network stubbing**
   - Use `cy.intercept` for contract verification when backend harness is unavailable.
   - For full-system tests, disable stubs and point to real harness endpoints.

3. **Custom commands**
   - Store login/setup commands in `cypress/support/commands.ts` with TypeScript declaration merging.
   - Document commands in project GUIDES to help AI understand available helpers.

4. **Accessibility**
   - Integrate `cypress-axe` or similar libraries for WCAG assertions; tag tests accordingly.

5. **Reporting**
   - Use Mochawesome/Allure reporters; merge reports per CI job and attach artifacts.

## CI integration
- NPM/Yarn script: `cypress:run` executes `cypress run --config-file cypress.config.ts`.
- GitHub Actions example:
```yaml
- uses: cypress-io/github-action@v6
  with:
    build: npm run build
    start: npm run start:test
    wait-on: 'http://localhost:4200'
    wait-on-timeout: 120
    command-prefix: 'npx' # ensures local binaries
```
- For BrowserStack Cloud runs, set `CYPRESS_CLOUD=true` and run via `browserstack-cypress run` referencing this config (see ./browserstack.rules.md).
- Upload `cypress/videos` and `cypress/screenshots` as artifacts; delete after retention if sensitive.

## Coverage
- When instrumenting with `@cypress/code-coverage`, align output with Jacoco/Sonar pipelines:
  - Use Istanbul instrumentation for frontend coverage; upload LCOV to Sonar via `sonar.javascript.lcov.reportPaths`.
  - Document coverage expectations in RULES.md; avoid skewing backend coverage metrics.

## Parallelization
- Use Cypress Dashboard or BrowserStack parallels to split specs. Label runs with `CYPRESS_BUILD_ID=${CI_JOB_ID}` for traceability.
- Ensure specs are independent; share state via APIs not global variables.

## Security and data hygiene
- Do not embed credentials in tests; use service accounts with limited scope.
- Reset data via API/fixtures after each test to keep suites idempotent.

---

## See also
- Testing & Coverage index — ./README.md
- Glossary — ./GLOSSARY.md
- BrowserStack rules — ./browserstack.rules.md
- Angular/Web Components TDD rules — ../../language/angular/tdd.md, ../../frontend/webcomponents/tdd.md
- Secrets & Config — ../secrets-config/README.md
