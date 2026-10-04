---
name: jwebmp-angular
description: "Generate Angular apps from JWebMP Java annotations; configure components, routes, services, control flow, and STOMP messaging."
metadata:
  short-description: Angular 21 integration and TypeScript generation
---

# JWebMP Angular Plugin

Angular 21 TypeScript project generation and SPA hosting with STOMP/WebSocket bridge for JWebMP.

## Locale formatting and user preferences

For `@NgLocale`, runtime `LocaleService` selection, pipe bindings, and validation,
read [Locale formatting and user preferences](references/localization.md).

For ClassGraph-discovered library dictionaries, Transloco runtime loading,
application overrides, REST sources, and context reset, read
[Runtime translations](references/translations.md).

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

#### Production vs. development build overrides

`@NgApp` carries **two separate** `NgBuildConfiguration` blocks — `production()`
and `development()` — mapped straight to angular.json's
`build.configurations.production` / `.development`. **Only the block matching
the actual `ng build` invocation is applied.** If your build tooling (e.g. a
`ShellApplication`/CLI wrapper) runs `ng build --configuration=production`,
overrides placed under `development()` are silently ignored — angular.json's
`defaultConfiguration` is commonly `"development"`, so an unqualified
`ng build` with no `--configuration` flag uses `development()` instead, and
`outputHashing`/`optimization` under `production()` never take effect either.
Always confirm which configuration your build actually runs before placing
overrides, and mirror the same block used for cache-busted (`outputHashing`)
production deploys.

```java
@NgApp(value = "my-app", bootComponent = AppComponent.class,
    // Applies only when the build runs `ng build --configuration=production`.
    production = @NgBuildConfiguration(
        outputHashing = NgBuildConfiguration.OutputHashing.ALL,
        budgets = {
            @NgBudget(type = NgBudget.Type.INITIAL, maximumError = "1m"),
            // Raise anyComponentStyle when a component's compiled SCSS legitimately
            // exceeds the CLI default (bundles fonts/icons/large layout rules, etc.).
            @NgBudget(type = NgBudget.Type.ANY_COMPONENT_STYLE,
                maximumWarning = "8kb", maximumError = "24kb")}))
public class MyApp extends NGApplication<MyApp> { }
```

`NgBudget.Type` mirrors Angular CLI budget types: `ALL`, `ALL_SCRIPT`, `ANY`,
`ANY_SCRIPT`, `ANY_COMPONENT_STYLE`, `BUNDLE` (requires `name()`), `INITIAL`.
A "exceeded maximum budget" build error names the offending bundle/component —
raise the matching budget type rather than suppressing optimization.

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

### @NgRestClient

Generate a fully typed, signal-based `@Injectable` Angular REST service from a
single Java class — the REST counterpart to `@NgGraphQL`. Defined in the
`tsclient` plugin (`com.jwebmp.core.base.angular.client.annotations.angular`);
see the **jwebmp-tsclient** skill for the full attribute reference.

```java
@NgRestClient(
    url = "/api/users",
    method = NgRestClient.HttpMethod.GET,
    responseType = User.class,
    responseArray = true,
    cachingEnabled = true,
    pollingEnabled = true)
@NgRestClientHeader(name = "Accept", value = "application/json")
@NgRestClientQueryParam(name = "active", value = "true")
public class UsersClient implements INgRestClient<UsersClient> {}
```

Generates an `@Injectable` HttpClient service exposing `data`/`loading`/`error`/
`success`/`polling` signals, `execute()` / `executeWithBody()`, plus polling,
caching, deduplication, deep-merge, retry, and `NONE/BEARER/BASIC/CUSTOM` auth.

## STOMP/WebSocket Communication

`/toBus/incoming` uses `OwnerLocalCommandIngress` and a local-only request to the socket owner. Replies and GUID-scoped storage responses go directly to that connection's registered subscriptions; ordinary `/toStomp/<group>` publishes retain cluster fan-out. GUIDs are correlation, not identity.

Compose `StompServerHandlerConfigurator` policies before protected ingress. Preserve bounded write queues, the two-second physical socket-close deadline, and idempotent end/close cleanup. Regenerate the Java-authored client, restore listeners before queued commands, and acquire fresh capabilities after reconnect.

Read [Angular STOMP continuity](references/stomp-continuity.md) for the wire diagram, policy SPI contract, receivers, exact limits, storage headers, reconnect requirements, and broadcast example.

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

### Lazy-loaded routes (code splitting)

Set `lazy = true` to emit `loadComponent` instead of a static import, so the Angular
builder splits the page (and dependencies only it uses) into its own `chunk-*.js`:

```java
@NgRoutable(path = "profile", sortOrder = 10, lazy = true)
@NgComponent("app-profile")
public class ProfilePage extends DivSimple<ProfilePage> implements INgComponent<ProfilePage> { }
```

Generates:
```typescript
{ loadComponent: () => import('../../…/ProfilePage/ProfilePage').then(m => m.ProfilePage), path: 'profile' }
```

- Keep the default/first-paint route (usually `path = ""`) eager.
- A chunk is only split out if no other generated file imports the page statically
  (link with `routerLink`/`AngularRoutingModule.applyRoute`, which uses only the path).
- Servers that allow-list assets must serve `chunk-*.js`, and a nonce-based CSP needs
  `'strict-dynamic'` so the nonce-trusted bundles can import chunks.
- Check the build's "Lazy chunk files" table to confirm each page got its own chunk.

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
| `/eventbus` and `/eventbus/*` | WebSocket | STOMP server | Bare endpoint and route upgrade; retain server path validation |
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

See the [data service broadcast example](references/stomp-continuity.md#data-service-with-websocket), including the publisher's Vert.x argument and unprefixed group name.

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

**Production builds need an explicit configuration flag.** A bare `ng build`
resolves to angular.json's `defaultConfiguration` (commonly `"development"`),
which skips `outputHashing`/minification/optimization even if you configured
them under `@NgApp(production = ...)`. For hashed, cache-busted, optimized
output, run:

```bash
ng build --configuration=production
```

Any Java-side production-only checks (e.g. an existence check for a
`/main.js` bundle) must also tolerate hashed filenames like
`main-XYZ123.js` once hashing is enabled.
