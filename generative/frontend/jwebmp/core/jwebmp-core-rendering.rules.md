# JWebMP Core Rendering Rules

Overview
- Build pages/components with CRTP types (`Component`, `Page`, HTML element subclasses under `com.jwebmp.core.base.html.*`); avoid inline HTML strings.
- Compose styles with typed CSS builders from `com.jwebmp.core.htmlbuilder.css.*`; prefer class names over inline styles unless APIs require inline output.
- Page-level scripts/styles are injected via `IPageConfigurator` implementations resolved through `JWebMPServicesBindings` (ServiceLoader via Guice).
- Event payloads are deserialized via `JWebMPJacksonModule` (`JacksonEventDeserializer`, `JacksonEventTypeDeserializer`); keep handlers defensive against malformed input.

Usage (Java 25)
```java
Page<?> page = new Page<>("Home");
Div<?, ?, ?> container = new Div<>();
container.add(new Paragraph<>().setText("Welcome"));
page.getBody().add(container);
page.getOptions().setCompatibilityMode(null); // set when IE mode is required
```

Patterns & Guidance
- CRTP setters should return `(J) this` (existing classes follow this); keep subclasses consistent and avoid Lombok builders.
- Register additional configurators via `META-INF/services/com.jwebmp.core.services.IPageConfigurator`; they surface as singleton sets in `JWebMPServicesBindings`.
- For dynamic content, use component APIs (`add`, `addFeature`, `addVariable`) rather than concatenated HTML.
- Use `setTiny(true)` to minimise output when needed and cascade to children.
- Manage page options (title/base/compatibility) through `PageOptions`; avoid ad-hoc script/style insertion outside configurators.

Performance/Constraints
- Configurators must be idempotent; they are resolved once per injector.
- Keep `Page.initialize()` lightweight; interception hooks may wrap the call.
- Respect JPMS exports/opens in `module-info.java` when adding packages; keep reflective access limited to Jackson/Guice openings already declared.

Event Adapters (server-driven events)
- Service interfaces (`IOnClickService`, `IOnChangeService`, etc.) are declared in `module-info.java` `uses` clauses; implementations are discovered via ServiceLoader.
- Adapter classes (e.g., `ClickAdapter` under `com.jwebmp.core.events.*`) are abstract; override their handler method instead of registering a service on the instance.
- Example (server-driven click) — adapters must be concrete classes (top-level or static nested) so Guice/ServiceLoader can instantiate them:
```java
public final class SaveClickAdapter extends ClickAdapter<SaveClickAdapter> {
  public SaveClickAdapter(IComponentHierarchyBase<?, ?> component) {
    super(component);
  }

  @Override
  public Uni<Void> onClick(AjaxCall<?> call, AjaxResponse<?> response) {
    // mutate component state or page model here
    return Uni.createFrom().voidItem();
  }
}

Button<?, ?, ?> button = new Button<>();
button.addEvent(new SaveClickAdapter(button));
```
- Keep handlers idempotent and side-effect aware; they run on the server via the host transport (AJAX/Vert.x bridge). Per-event services (`IOnClickService`) are invoked by the adapter lifecycle (`onCreate`, `onCall`).
- Defensive parsing: event payloads are deserialized by `JWebMPJacksonModule`; validate inputs in the handler before applying state changes.
- Use `addEvent(...)` for server-side adapters; reserve `addFeature(...)` for client-side JavaScript features, which should also be concrete classes (top-level or static nested) when instantiated by Guice.

See also
- Topic index: ./README.md
- Architecture diagrams: docs/architecture/sequence-render.md, docs/architecture/c4-component-rendering.md (host repository)
- Enterprise rules: ../client/README.md
