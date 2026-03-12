---
name: jwebmp-vertx
description: Portable connector between JWebMP and Vert.x 5 powered by GuicedEE. Provides automatic page routing, AJAX event pipeline, data component servlet, CSS endpoint, site-loader script, WebSocket broadcasting via event bus, user-agent detection, and call-scope integration. Use when working with JWebMP Vert.x integration, HTTP routing, AJAX handling, WebSocket communication, or building reactive web applications with JWebMP.
metadata:
  short-description: JWebMP Vert.x 5 integration
---

# JWebMP Vert.x

Portable connector between JWebMP and Vert.x 5, powered by GuicedEE.

## Core Features

- **Automatic Page Routing** — `@PageConfiguration` classes auto-registered
- **AJAX Event Pipeline** — Fully reactive request handling
- **Data Component Servlet** — Serves `IDataComponent` as JSON
- **CSS Endpoint** — On-demand CSS rendering
- **Site-Loader Script** — JS bootstrap template
- **WebSocket Broadcasting** — Event bus bridge (direct or STOMP)
- **User-Agent Detection** — Per call-scope via UADetector
- **Call-Scope Integration** — Every handler enters `CallScope`

## Quick Start

### 1. Annotate a Page

```java
@PageConfiguration(url = "/")
public class HomePage extends Page<HomePage> { }
```

### 2. Start GuicedEE

```java
IGuiceContext.instance().inject();
// Routes registered automatically
```

### 3. Routes Created

- `GET /` — serves `HomePage`
- `GET /jwscr` — site-loader script
- `POST /jwajax` — AJAX event receiver
- `GET /jwdata` — data component endpoint
- `GET /jwcss` — CSS endpoint

## HTTP Routes

| Route | Method | Handler | Purpose |
|---|---|---|---|
| `@PageConfiguration.url()` | GET | `configurePageServlet` | Renders annotated `IPage` as HTML |
| `/jwajax` | POST | `configureAjaxReceiveServlet` | Processes AJAX event calls |
| `/jwdata` | GET | `configureDataServlet` | Serves `IDataComponent` JSON |
| `/jwcss` | GET | `configureCSSServlet` | Renders page-level CSS |
| `/jwscr` | GET | `configureInternalDataServlet` | Serves site-loader JS |

## Request Lifecycle

```
HTTP Request
 └─ Vert.x Router
     └─ Route handler
         └─ CallScope enter
             ├─ CallScopeProperties populated
             │  ├─ RoutingContext
             │  ├─ HttpServerRequest
             │  ├─ HttpServerResponse
             │  └─ Stream ID
             ├─ Handler logic (render/AJAX/data/CSS/script)
             └─ CallScope exit
```

## AJAX Flow (Reactive)

```
POST /jwajax
 └─ bodyHandler (event loop)
     ├─ Deserialize AjaxCall from JSON
     ├─ Resolve event class → IEvent
     ├─ Run AjaxCallInterceptors
     └─ triggerEvent.fireEvent(call, response) → Uni
         ├─ onItem  → write JSON response
         └─ onFailure → structured error JSON
```

### AJAX Example

```java
public class ButtonClickEvent extends OnClickAdapter {
    @Override
    public void onClick(AjaxCall<?> call, AjaxResponse<?> response) {
        // Process event
        String param = call.getParameters().get("key");

        // Update DOM
        response.addComponent(new Div<>().setText("Result: " + param));
    }
}
```

## WebSocket Broadcasting

Two `IGuicedWebSocket` implementations:

### Direct Event Bus

```java
public class VertXEventBusBridgeIWebSocket implements IGuicedWebSocket {
    @Override
    public void broadcastMessage(String groupName, Object message) {
        vertx.eventBus().publish(groupName, message);
    }
}
```

### STOMP Event Bus (Default)

```java
public class VertXStompEventBusBridgeIWebSocket implements IGuicedWebSocket {
    @Override
    public void broadcastMessage(String groupName, Object message) {
        vertx.eventBus().publish("/toStomp/" + groupName, message);
    }
}
```

Bound by default in `JWebMPVertxBinder`.

## User-Agent Detection

Call-scoped `ReadableUserAgent`:

```java
@Inject
private ReadableUserAgent userAgent;

public void process() {
    String browser = userAgent.getName();
    String version = userAgent.getVersionNumber().toVersionString();
    String os = userAgent.getOperatingSystem().getName();
}
```

## Data Components

Serve dynamic data as JSON:

```java
public class UserDataComponent implements IDataComponent {
    @Override
    public Object renderData() {
        return userRepository.findAll();
    }
}
```

Access via: `GET /jwdata?component=UserDataComponent`

## CSS Endpoint

Render page-level CSS on demand:

```java
@PageConfiguration(url = "/dashboard")
public class DashboardPage extends Page<DashboardPage> {
    public DashboardPage() {
        Div<?, ?, ?> container = new Div<>();
        container.getCss()
                 .getBackground().setBackgroundColor$(ColourNames.AliceBlue);
        getBody().add(container);
    }
}
```

Access via: `GET /jwcss?page=DashboardPage`

## Site-Loader Script

Template-driven JS bootstrap at `/jwscr`:

```javascript
var JW_SERVER_ADDRESS = '${serverAddress}';
var JW_PAGE_CLASS = '${pageClass}';
var JW_USER_AGENT = '${userAgent}';
var JW_REFERRER = '${referrer}';
```

## Configuration

| Environment Variable | Default | Purpose |
|---|---|---|
| `BIND_JW_PAGES` | `true` | Enable/disable automatic page routing |

Disable page binding:
```bash
export BIND_JW_PAGES=false
```

## Call-Scope Properties

Every HTTP handler populates:

```java
@Inject
private CallScopeProperties properties;

public void process() {
    RoutingContext ctx = properties.getRoutingContext();
    HttpServerRequest req = properties.getRequest();
    HttpServerResponse res = properties.getResponse();
    String streamId = properties.getStreamId();
}
```

## Jackson Configuration

Vert.x `DatabindCodec` mapper aligned with GuicedEE:
- Quoted field names
- Single-quote tolerance
- Null handling

## Key Classes

- `JWebMPVertx` — Main module + `VertxHttpServerConfigurator`
- `JWebMPVertxBinder` — Binds `ReadableUserAgent`, `IGuicedWebSocket`, Jackson config
- `ReadableUserAgentProvider` — Call-scoped UA parser
- `VertXEventBusBridgeIWebSocket` — Direct event bus broadcasting
- `VertXStompEventBusBridgeIWebSocket` — STOMP-prefixed broadcasting

## JPMS Module

```java
module com.jwebmp.vertx {
    requires transitive com.jwebmp.client;
    requires transitive com.jwebmp.core;
    requires transitive com.guicedee.vertx.web;
    requires transitive com.guicedee.guicedinjection;
    requires transitive com.guicedee.jsonrepresentation;

    provides IGuiceModule with JWebMPVertx, JWebMPVertxBinder;
    provides VertxHttpServerConfigurator with JWebMPVertx;
}
```

## Installation

```xml
<dependency>
  <groupId>com.jwebmp</groupId>
  <artifactId>jwebmp-vertx</artifactId>
</dependency>
```

## Error Handling

### InvalidRequestException

Structured error for invalid AJAX requests:

```json
{
  "error": "Invalid request",
  "message": "Component not found",
  "code": 400
}
```

### Generic Errors

```json
{
  "error": "Internal error",
  "message": "Exception details",
  "code": 500
}
```

## Common Patterns

### Custom Route

```java
public class CustomConfigurator implements VertxRouterConfigurator {
    @Override
    public void configureVertxRouter(Router router) {
        router.get("/api/custom").handler(ctx -> {
            ctx.response()
               .putHeader("Content-Type", "application/json")
               .end("{\"status\":\"ok\"}");
        });
    }
}
```

Register via `module-info.java`:
```java
provides VertxRouterConfigurator with CustomConfigurator;
```

### WebSocket Broadcasting

```java
@Inject
private IGuicedWebSocket webSocket;

public void notifyUsers(String message) {
    webSocket.broadcastMessage("notifications", message);
}
```

### User-Agent Based Logic

```java
@Inject
private ReadableUserAgent userAgent;

public IPage<?> getPage() {
    if (userAgent.getDeviceCategory() == DeviceCategory.SMARTPHONE) {
        return new MobilePage();
    }
    return new DesktopPage();
}
```

## Dependencies

```
com.jwebmp.vertx
 ├── com.jwebmp.client
 ├── com.jwebmp.core
 ├── com.guicedee.vertx.web
 ├── com.guicedee.guicedinjection
 ├── com.guicedee.jsonrepresentation
 ├── io.vertx.core
 ├── io.vertx.web
 └── net.sf.uadetector.core
```

## References

- Module: `com.jwebmp.vertx`
- Vert.x: 5.x
- Java: 25+
- License: Apache 2.0
