# JWebMP Angular — Testing and Coverage

Scope
- JVM-side validation of generation and hosting; guidance for frontend/browser tests.

Testing layers
- Unit: JUnit Jupiter for generators (route resolution, import mapping, flag handling). Use CRTP-friendly assertions; keep Log4j2 test logging minimal.
- Coverage: Jacoco per ../../../platform/testing/jacoco.rules.md; enforce coverage on generation utilities and routing/build config emitters.
- Harness: Java Micro Harness for lightweight runtime checks; avoid long-lived Vert.x instances in unit scope.
- Integration (planned): BrowserStack for Angular 20 dist runtime; align with ../../../platform/testing/browserstack.rules.md.

CI expectations
- Run `mvn verify` with Jacoco reporting; keep builds reproducible (Java 25, Maven).
- For BrowserStack or E2E jobs, ensure dist assets are built externally before running tests; do not rebuild Angular inside this module unless explicitly configured.

Do/Don’t
- Do test flag gating (`JWEBMP_PROCESS_ANGULAR_TS`) and error paths for missing routes/components.
- Do validate STOMP message dispatch and AjaxResponse shaping in integration tests (can be mocked).
- Don’t assert on generated file contents beyond contract-level expectations; treat generated outputs as ephemeral.

See also
- Overview — ./overview.rules.md
- Hosting/messaging — ./hosting-messaging.rules.md
- Platform testing index — ../../../platform/testing/README.md
- Java Micro Harness — ../../../platform/testing/java-micro-harness.rules.md
- BrowserStack — ../../../platform/testing/browserstack.rules.md
