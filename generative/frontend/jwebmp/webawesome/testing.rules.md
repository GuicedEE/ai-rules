# Testing — WebAwesome (JWebMP Wrapper)

Applies to Java-based tests for Wa* components and the page configurator. Default posture: TDD-first, headless, forward-only; BrowserStack optional.

Coverage targets
- Component rendering: assert attributes/slots rendered by WaButton, WaInput (including number inputs), WaCluster/WaStack gap classes, and tooltip/variant helpers.
- Asset wiring: verify `WebAwesomePageConfigurator` injects CSS with `RequirementsPriority.First`, JS loader as `type="module"` with `Top_Shelf`, and applies theme/body classes from static fields.
- Nullness and CRTP: ensure fluent setters return the concrete type and do not regress to raw `Component`.

Harness guidance
- Use Java Micro Harness (`jwebmp-testlib`) for DOM assertions; avoid editing generated TS/HTML.
- Keep BrowserStack drivers optional via env vars; local runs must succeed without network.
- Add Jacoco-friendly tests; prefer focused assertions instead of screenshot baselines.

See also
- Overview — ./overview.rules.md
- Components — ./button.rules.md, ./input.rules.md#number-input, ./cluster.rules.md, ./stack.rules.md
- Platform testing rules — ../../platform/testing/README.md, ../../platform/testing/java-micro-harness.rules.md, ../../platform/testing/jacoco.rules.md, ../../platform/testing/browserstack.rules.md
