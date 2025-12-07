# Testing & Validation — FullCalendar Pro

## Overview
Tests for FullCalendar Pro should follow the TDD-centric, documentation-first approach outlined in `rules/generative/architecture/tdd/README.md`. Focus on the resource/timeline wiring (resource payloads, template toggles, WebSocket listeners) and ensure the Angular event bus subscribers never race ahead of server responses. Jacoco and the Java Micro Harness capture coverage; BrowserStack validates rendered calendars when UI artifacts (TypeScript/Angular) are involved.

## Usage Patterns & Minimal Example
1. Drive the tests through the Java Micro Harness command (`mvn -Ptest` or the harness target defined in `rules/generative/platform/testing/java-micro-harness.rules.md`) and assert that the `FullCalendarProPageConfigurator` registers the component correctly.
2. Use `FullCalendarProTestBase` (create a base fixture if needed) to send mock `AjaxCall` payloads to `InitialResourceEventsReceiver.action()` and assert that `AjaxResponse.addDataResponse()` receives the expected listenerName + payload.
3. Render the Angular component in BrowserStack via the Maven build pipeline that executes `rules/generative/platform/testing/browserstack.rules.md` so resource columns and templates load in the supported browsers.

```java
@Test
void resourceReceiverSuppliesResources() {
    InitialResourceEventsReceiver receiver = new InitialResourceEventsReceiver("listenerResources", MyProCalendar.class);
    AjaxCall<?> call = new AjaxCall<>();
    call.setClassName(MyProCalendar.class.getName());
    call.getUnknownFields().put("listenerName", "listenerResources");
    AjaxResponse<?> response = new AjaxResponse<>();
    Uni<AjaxResponse<?>> result = receiver.action(call, response);
    assertThat(result.await().indefinitely().getData()).isNotEmpty();
}
```

## Inputs / Outputs / Events
- Assert that `listenerName + 'Resources'` responses carry `FullCalendarResourceItemsList` objects even when the channel is registered multiple times; `IGuicedWebSocket.isWebSocketReceiverRegistered(...)` guards help avoid duplicate listeners.
- Monitor the Angular `eventBusService.listen(...)` call in integration tests (via the generated TypeScript) to ensure it unsubscribes in `ngOnDestroy()` and that `handleResourceEvents()` handles both JSON strings and object arrays.
- Jacoco rules (`rules/generative/platform/testing/jacoco.rules.md`) require only the plugin/core classes to be instrumented; exclude generated TypeScript output.

## Styling / Theming Verification
- When tests toggle `enableResourceLabelTemplate`, `enableResourceAreaHeaderTemplate`, or `enableResourceAreaColumnTemplates`, verify that the generated `NgTemplateElement` fragments appear in the DOM nodes described in `docs/architecture/c4-component-fullcalendar-pro.md`.

## Accessibility / Performance Constraints
- Regression tests should simulate large resource sets but throttle them to ensure the JSON serialization and Angular subscription remain performant; keep BrowserStack runs limited to the required browsers listed in the CI plan (`rules/generative/platform/testing/browserstack.rules.md`).

## See also
- `rules/generative/frontend/jwebmp/fullcalendar-pro/events-and-resources.rules.md`
- Testing platform rules: `../../../platform/testing/browserstack.rules.md`, `../../../platform/testing/java-micro-harness.rules.md`, `../../../platform/testing/jacoco.rules.md`
- Architecture: `docs/architecture/sequence-runtime-wiring.md`, `docs/architecture/erd-core-domain.md`
