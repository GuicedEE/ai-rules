# Usage Examples — JWebMP Client

Reference snippets for applying the JWebMP Client rules. Adapt to your library code; keep host-project specifics outside `rules/`.

## CRTP component composition
```java
Div<?> root = new Div<>().add(new Paragraph<>().setText("Hello JWebMP"));
root.addClass("page-shell");
```

## AJAX interception (call scope)
```java
public final class AuditAjaxInterceptor implements AjaxCallIntercepter<AjaxCall> {
    @Override
    public void intercept(AjaxCall call) {
        // validate request before handlers run
        if (!call.isValid()) {
            call.getResponse().setResponseText("invalid");
        }
    }
}
// Register via ServiceLoader key provided by the client interception binder.
```

## Rendering with resource references
```java
Div<?> card = new Div<>()
        .addClass("card")
        .add(new Heading<>(3).setText("Title"))
        .add(new Paragraph<>().setText("Body copy"));
card.addJavascriptReference(new JavascriptReference("card.js", 1.0, "/js/card.js"));
card.addCSSReference(new CSSReference("card.css", 1.0, "/css/card.css"));
```

## Mutiny + Vert.x interop (non-blocking)
```java
public Uni<AjaxResponse> handleAsync(AjaxCall call) {
    return Uni.createFrom().item(call)
        .onItem().transform(c -> c.getResponse().setResponseText("ok"));
}
```

## Logging (Log4j2, redacted)
```java
private static final Logger LOG = LogManager.getLogger(MyComponent.class);

void onEvent(AjaxCall call) {
    LOG.debug("ajax event id={}", call.getId()); // avoid logging payload/PII
}
```
