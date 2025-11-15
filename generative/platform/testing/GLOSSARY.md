# Testing & Coverage Glossary

| Term | Definition | LLM Guidance |
| --- | --- | --- |
| Jacoco coverage gate | Enforced minimum instruction coverage (default 80%) generated from Jacoco XML reports across Maven/Gradle builds. | Always reference `./jacoco.rules.md` for wiring; require XML reports (not `.exec`) and fail builds on gate violations. |
| Jacoco aggregate tasks | Gradle or Maven tasks that merge multiple exec/xml files into a single report before CI uploads. | Invoke `jacocoAggregate`/`jacocoVerifyAll` or `jacoco:merge`/`jacoco:check` before packaging so SonarQube can consume combined coverage. |
| SonarQube quality gate | Centralized pass/fail condition covering coverage, duplication, bugs, and security hotspots. | Configure gates in SonarQube UI and block merges when `sonarQualityGate == FAILED`; do not override thresholds locally. |
| `sonar-project.properties` | Canonical scanner configuration file defining project key, sources/tests, binaries, coverage files, and modules. | Always commit at repo root, reference via `-Dproject.settings=sonar-project.properties`, and keep module blocks aligned with real paths. |
| `sonar.modules` | Properties file entry enumerating submodules for multi-module repos. | Provide one entry per submodule (`moduleA,moduleB`) and set `<module>.sonar.projectBaseDir`, sources, tests, binaries, and coverage paths per module. |
| Sonar token (`SONAR_TOKEN`) | Personal access or service account token used by scanners to authenticate. | Store in CI secrets; never commit or echo in logs; pass via env var when running `sonar:sonar`/`sonar-scanner`. |
| Java Micro Harness | Repository-local harness modules that spin up targeted adapters (HTTP, messaging, DB) for integration flows without full platform deployments. | Keep harness modules in the same build, run via dedicated Gradle/Maven tasks, and feed their coverage/quality data into Jacoco/Sonar gates. |
| BrowserStack Automate | Managed cloud grid for running automated browser tests across OS/browser combinations. | Configure builds via `browserstack.yml`/CLI, inject credentials via env vars, and archive logs/videos in CI; see `./browserstack.rules.md`. |
| Cypress | JavaScript-based E2E and component testing framework commonly used with modern frontends. | Centralize config in `cypress.config.ts`, run via CI workflows (local or BrowserStack Cloud), and integrate artifacts/coverage per `./cypress.rules.md`. |

See also
- Topic index — ./README.md
- Jacoco coverage rules — ./jacoco.rules.md
- SonarQube rules — ./sonarqube.rules.md
