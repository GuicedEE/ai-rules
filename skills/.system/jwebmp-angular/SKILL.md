---
name: jwebmp-angular
description: Generates Angular 21 TypeScript projects from JWebMP annotations and serves SPAs via Vert.x with STOMP/WebSocket bridging. Provides @NgApp, @NgComponent, @NgRoutable, @NgDataService annotations, TypeScript code generation, reactive messaging, Angular control-flow components, and WebSocket group management. Use when working with JWebMP Angular integration, TypeScript generation, Angular components, STOMP/WebSocket communication, or building Angular 21 applications with JWebMP.
metadata:
  short-description: Angular 21 integration and TypeScript generation
---

# JWebMP Angular Plugin

Angular 21 TypeScript project generation and SPA hosting with STOMP/WebSocket bridge for JWebMP.

## Core Features

- **TypeScript code generation** from Java annotations
- **SPA hosting** via Vert.x with static asset serving
- **STOMP/WebSocket bridge** for real-time communication
- **Reactive message processing** with event bus integration
- **Angular control-flow components** (@if, @for, @let)
- **Routing module** with @NgRoutable support
- **Environment module** for configuration

## Quick Start

### 1. Define an Angular App

```java
@NgApp(value = "my-app", bootComponent = AppComponent.class)
public class MyApp extends NGApplication<MyApp> { }
```

### 2. Create Boot Component

```java
@NgComponent("app-root")
public class AppComponent extends DivSimple<AppComponent>
        implements INgComponent<AppComponent> { }
```

### 3. Add Routable Pages

```java
@NgRoutable(path = "dashboard", parent = {AppComponent.class})
@NgComponent("app-dashboard")
public class DashboardPage extends DivSimple<DashboardPage>
        implements INgComponent<DashboardPage> { }
```

### 4. Enable TypeScript Generation

```bash
export JWEBMP_PROCESS_ANGULAR_TS=true
# Or
mvn verify -Djwebmp.process.angular.ts=true
```

### 5. Start Application

```java
IGuiceContext.instance();
// → TypeScript generated to ~/.jwebmp/<appName>/
// → Vert.x serves dist at configured routes
// → STOMP/WebSocket bridge live at /eventbus
```

## TypeScript Compiler Pipeline

```
TypeScriptCompiler
 ├── AngularAppSetup        → Scaffolds angular.json, package.json, tsconfig
 ├── DependencyManager      → Resolves @TsDependency / @TsDevDependency
 ├── ComponentProcessor     → Processes INgComponent, INgDirective, INgDataService
 ├── AngularModuleProcessor → Generates boot module, routing module
 ├── TypeScriptCodeGenerator → Renders .ts files from annotations
 ├── AssetManager           → Copies @NgAsset, @NgScript, @NgStyleSheet
 └── TypeScriptCodeValidator → Validates generated output
```

## Annotations

### @NgApp

```java
@NgApp(value = "my-app", bootComponent = AppComponent.class)
public class MyApp extends NGApplication<MyApp> { }
```

### @NgComponent

```java
@NgComponent("app-header")
public class HeaderComponent implements INgComponent<HeaderComponent> {
    @Override
    public String render() {
        return "<header><h1>My App</h1></header>";
    }
}
```

### @NgRoutable

```java
@NgRoutable(path = "users", parent = {AppComponent.class})
@NgComponent("app-users")
public class UsersPage implements INgComponent<UsersPage> { }
```

### @NgDataService

```java
@NgDataService
public class UserService implements INgDataService<UserService> {
    @Override
    public Object getData(AjaxCall<?> call, AjaxResponse<?> response) {
        return userRepository.findAll();
    }
}
```

## STOMP/WebSocket Communication

### WebSocket Bridge Flow

```
Angular Client (STOMP)
 └─ ws://host/eventbus
     ├─ SEND /toBus/incoming    → Event bus consumer
     │   ├─ Deserialize WebSocketMessageReceiver
     │   ├─ Dispatch to IWebSocketMessageReceiver (ajax/data/dataSend)
     │   ├─ Run in CallScope (WebSocket)
     │   └─ Reply via event bus:
     │       ├─ dataReturns → publish to per-key addresses
     │       ├─ sessionStorage → publish to "SessionStorage"
     │       └─ localStorage → publish to "LocalStorage"
     └─ SUBSCRIBE /toStomp/*   ← Server pushes via StompEventBusPublisher
```

### Built-in Message Receivers

| Receiver | Action | Purpose |
|---|---|---|
| `WebSocketAjaxCallReceiver` | `ajax` | Deserializes AjaxCall, fires event, returns AjaxResponse |
| `WebSocketDataRequestCallReceiver` | `data` | Resolves INgDataService, calls getData() |
| `WebSocketDataSendCallReceiver` | `dataSend` | Resolves INgDataService, calls receiveData() |
| `WSAddToGroupMessageReceiver` | `AddToWebSocketGroup` | Adds session to WebSocket group |
| `WSRemoveFromWebsocketGroupMessageReceiver` | `RemoveFromWebSocketGroup` | Removes session from group |

### STOMP Configuration

| Setting | Value | Notes |
|---|---|---|
| WebSocket path | `/eventbus` | STOMP over WebSocket endpoint |
| Server heartbeat | `10000` ms | Server → client |
| Client heartbeat | `50000` ms | Client → server (lenient for background tabs) |
| Sub-protocols | `v10.stomp`, `v11.stomp`, `v12.stomp` | Advertised on HTTP upgrade |
| Idle timeout | `0` (disabled) | Relies on STOMP heartbeats |

## Angular Control-Flow Components

### NgIf / NgIfElse

```java
NgIf<MyComponent> ifBlock = new NgIf<>(this)
    .setCondition("isLoggedIn")
    .add(new Paragraph<>().setText("Welcome!"));

NgIfElse<MyComponent> ifElse = new NgIfElse<>(this)
    .setCondition("hasData")
    .add(new Div<>().setText("Data loaded"))
    .setElseBlock(new NgElse<>()
        .add(new Div<>().setText("No data")));
```

Renders:
```typescript
@if (isLoggedIn) {
  <p>Welcome!</p>
}

@if (hasData) {
  <div>Data loaded</div>
} @else {
  <div>No data</div>
}
```

### NgFor

```java
NgFor<MyComponent> forLoop = new NgFor<>(this)
    .setIterable("users")
    .setTrackBy("userId")
    .add(new Div<>().setText("{{ user.name }}"));
```

Renders:
```typescript
@for (user of users; track userId) {
  <div>{{ user.name }}</div>
}
```

### NgLet

```java
NgLet<MyComponent> letVar = new NgLet<>(this)
    .setVariable("total")
    .setExpression("calculateTotal()");
```

Renders:
```typescript
@let total = calculateTotal();
```

## Routing

### AngularRoutingModule

Scans @NgRoutable classes and generates route tree:

```java
@NgRoutable(path = "dashboard", parent = {AppComponent.class})
public class DashboardPage { }

@NgRoutable(path = "users", parent = {DashboardPage.class})
public class UsersPage { }

@NgRoutable(path = "profile/:id", parent = {DashboardPage.class})
public class ProfilePage { }
```

Generates:
```typescript
RouterModule.forRoot([
  {
    path: 'dashboard',
    component: DashboardComponent,
    children: [
      { path: 'users', component: UsersComponent },
      { path: 'profile/:id', component: ProfileComponent }
    ]
  }
])
```

### RouterLink Component

```java
RouterLink link = new RouterLink()
    .setRouterLink("/dashboard")
    .setText("Go to Dashboard");

RouterLink paramLink = new RouterLink()
    .setRouterLink("/profile/123")
    .setQueryParams(Map.of("tab", "settings"))
    .setText("View Profile");
```

## Environment Module

```java
EnvironmentModule env = new EnvironmentModule()
    .setOptions(new EnvironmentOptions()
        .setProduction(false)
        .setApiUrl("http://localhost:8080/api")
        .addCustomProperty("featureFlags", Map.of(
            "newUI", true,
            "betaFeatures", false
        )));
```

Generates:
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/api',
  featureFlags: {
    newUI: true,
    betaFeatures: false
  }
};
```

## Vert.x Router Wiring

| Route | Method | Handler | Purpose |
|---|---|---|---|
| `/eventbus/*` | WebSocket | STOMP server | WebSocket → STOMP bridge |
| `/assets/*` | GET | StaticHandler | Angular compiled assets (1-year cache) |
| `/{file}.{ext}` | GET | StaticHandler | Root-level static files |
| `/**` (SPA fallback) | GET | `sendFile(index.html)` | Angular Router routes |

## SPI Extension Points

| SPI | Purpose |
|---|---|
| `AngularScanPackages` | Add packages to Angular classpath scan |
| `RenderedAssets` | Provide additional build assets |
| `NpmrcConfigurator` | Customize `.npmrc` file |
| `WebSocketGroupAdd` | Custom logic for WebSocket group joins |
| `TypescriptIndexPageConfigurator` | Customize generated `index.html` |
| `IWebSocketAuthDataProvider` | Provide authentication data for WebSocket |

## Configuration

| Environment Variable | Default | Purpose |
|---|---|---|
| `JWEBMP_PROCESS_ANGULAR_TS` | `false` | Enable/disable TypeScript generation |
| `jwebmp.outputDirectory` | — | Override output directory |
| `jwebmp` | `~` (user home) | Base directory |
| `ENVIRONMENT` | `dev` | Runtime environment hint |
| `PORT` | `8080` | Server port |

## NPM Dependencies

The plugin manages Angular dependencies:

```json
{
  "dependencies": {
    "@angular/core": "^20.0.0",
    "@angular/common": "^20.0.0",
    "@angular/router": "^20.0.0",
    "@angular/forms": "^20.0.0",
    "@stomp/ng2-stompjs": "^latest",
    "rxjs": "^7.8.0"
  }
}
```

## Common Patterns

### Data Service with WebSocket

```java
@NgDataService
public class LiveDataService implements INgDataService<LiveDataService> {
    @Inject
    private DataRepository repository;

    @Override
    public Object getData(AjaxCall<?> call, AjaxResponse<?> response) {
        String entityId = call.getParameters().get("id");
        return repository.findById(entityId);
    }

    @Override
    public void receiveData(AjaxCall<?> call, AjaxResponse<?> response) {
        String data = call.getParameters().get("data");
        repository.save(data);

        // Push update to all clients in group
        StompEventBusPublisher.publish("/toStomp/updates", data);
    }
}
```

### Event Handling

```java
public class ButtonClickEvent extends OnClickAdapter {
    @Override
    public void onClick(AjaxCall<?> call, AjaxResponse<?> response) {
        // Process server-side
        String result = processData();

        // Update UI
        response.addComponent(new Div<>().setText("Result: " + result));

        // Publish to WebSocket group
        StompEventBusPublisher.publish("/toStomp/notifications", result);
    }
}
```

### WebSocket Group Management

```java
@NgComponent("chat-room")
public class ChatRoom implements INgComponent<ChatRoom> {
    @Override
    public void configure(IComponentHierarchyBase<?, ?> component) {
        // Component auto-joins WebSocket group
        component.setAttribute("websocketgroup", "chat-room-1");
    }
}
```

## JPMS Module

```java
module com.jwebmp.core.angular {
    requires transitive com.jwebmp.core.base.angular.client;
    requires transitive com.jwebmp.vertx;
    requires transitive io.vertx.eventbusbridge;
    requires transitive io.vertx.stomp;

    provides IGuicePreStartup with AngularPreStartup;
    provides IGuicePostStartup with AngularTSPostStartup;
    provides IGuiceModule with AngularTSSiteBinder;
    provides VertxRouterConfigurator with AngularTSSiteBinder;
    provides IWebSocketMessageReceiver with
        WebSocketAjaxCallReceiver,
        WebSocketDataRequestCallReceiver,
        WebSocketDataSendCallReceiver,
        WSAddToGroupMessageReceiver,
        WSRemoveFromWebsocketGroupMessageReceiver;
}
```

## Key Classes

- `AngularTSSiteBinder` — Core module + router configuration
- `TypeScriptCompiler` — Orchestrates TS generation
- `NGApplication` — Base class for @NgApp
- `AngularRoutingModule` — Generates RouterModule.forRoot()
- `EnvironmentModule` — Generates environment config
- `StompEventBusPublisher` — Helper for STOMP publishing

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>angular</artifactId>
</dependency>
```

## References

- Module: `com.jwebmp.core.angular`
- Java: 25+
- Angular: 20
- Dependencies: JWebMP Core, Vert.x, STOMP
- License: Apache 2.0

## Build Notes

Plugin generates TypeScript but **does not** run `ng build`. Build separately:

```bash
cd ~/.jwebmp/my-app
npm install
ng build
```

Dist output served automatically by Vert.x.
