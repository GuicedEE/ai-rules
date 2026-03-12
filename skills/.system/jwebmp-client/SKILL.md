---
name: jwebmp-client
description: Client SPI library for JWebMP — defines AJAX pipeline contracts (AjaxCall/AjaxResponse), page contracts (IPage/IPageConfigurator), component model interfaces, and interceptor SPIs. Use when working with JWebMP client interfaces, AJAX interception, page configuration SPIs, component model interfaces, or extending JWebMP with custom interceptors and configurators.
metadata:
  short-description: JWebMP Client SPI and contracts
---

# JWebMP Client

Client SPI library defining contracts, AJAX pipeline, and component model interfaces for JWebMP.

## Core Purpose

Provides **compile-time contracts** and **runtime SPI discovery** for JWebMP ecosystem without circular dependencies. All JWebMP modules program against these interfaces.

## AJAX Pipeline

### AjaxCall & AjaxResponse

Core DTO objects for browser ↔ server communication:

```java
// AjaxCall - Incoming request (CallScope-scoped)
public class AjaxCall<J extends AjaxCall<J>> {
    Map<String, String> getParameters();
    String getEventType();
    String getComponentId();
    HeadersDTO getHeaders();
}

// AjaxResponse - Outgoing response
public class AjaxResponse<J extends AjaxResponse<J>> {
    J addComponent(IComponentHierarchyBase<?, ?> component);
    J addReaction(AjaxResponseReaction<?> reaction);
    Map<String, Object> getDataReturns();
}
```

### Response Components

```java
// DOM update descriptor
public class AjaxComponentUpdates {
    AjaxComponentInsertType insertType;  // replace, append, prepend, etc.
    String htmlContent;
    String componentId;
}

// Client-side reaction
public class AjaxResponseReaction<J> {
    ReactionType reactionType;  // redirect, dialog, etc.
    Object value;
}
```

## Interceptor SPIs

### Three-Level Interception Chain

```java
// 1. Site-level (first page load)
public interface SiteCallIntercepter<J extends SiteCallIntercepter<J>>
        extends IDefaultService<J> {
    void intercept(AjaxCall<?> call, AjaxResponse<?> response);
}

// 2. AJAX event calls
public interface AjaxCallIntercepter<J extends AjaxCallIntercepter<J>>
        extends SiteCallIntercepter<J> {
    // Same intercept() method
}

// 3. Startup data calls
public interface DataCallIntercepter<J extends DataCallIntercepter<J>>
        extends SiteCallIntercepter<J> {
    // Same intercept() method
}
```

### Interceptor Example

```java
public class AuditInterceptor implements AjaxCallIntercepter<AuditInterceptor> {
    @Override
    public void intercept(AjaxCall<?> call, AjaxResponse<?> response) {
        log.info("AJAX event: {}", call.getEventType());
    }

    @Override
    public Integer sortOrder() {
        return 10;  // Lower = earlier
    }
}
```

Register via `module-info.java`:
```java
provides com.jwebmp.interception.services.AjaxCallIntercepter
    with my.app.AuditInterceptor;
```

## Page Contracts

### IPage Interface

```java
public interface IPage<J extends IPage<J>> {
    IBody<?> getBody();
    IHead<?> getHead();
    PageOptions getOptions();
    J addJavaScriptReference(JavascriptReference ref);
    J addCssReference(CSSReference ref);
}
```

### IPageConfigurator SPI

```java
public interface IPageConfigurator<J extends IPageConfigurator<J>>
        extends IDefaultService<J>, IServiceEnablement<J> {
    IPage<?> configure(IPage<?> page);
    Integer sortOrder();  // Determines execution order
}
```

### Example Configurator

```java
public class AnalyticsConfigurator implements IPageConfigurator<AnalyticsConfigurator> {
    @Override
    public IPage<?> configure(IPage<?> page) {
        page.addJavaScriptReference(
            new JavascriptReference("analytics", 1.0, "analytics.js")
        );
        return page;
    }

    @Override
    public Integer sortOrder() {
        return 100;
    }
}
```

## Component Model Interfaces

11-layer interface hierarchy (CRTP):

```java
IComponentBase                      // ID, name, properties, JSON serialization
 └─ IComponentHierarchyBase        // parent/child tree, CSS/JS references
     └─ IComponentHTMLBase         // tag rendering, text, raw HTML
         └─ IComponentHTMLAttributeBase  // HTML attributes (typed enums)
             └─ IComponentHTMLOptionsBase   // JavaScript options (JavaScriptPart)
                 └─ IComponentStyleBase        // inline CSS via CSS builder
                     └─ IComponentThemeBase        // theme support
                         └─ IComponentDataBindingBase  // data-bind hooks
                             └─ IComponentDependencyBase   // CSS/JS dependency refs
                                 └─ IComponentFeatureBase     // Feature attachment
                                     └─ IComponentEventBase      // Event attachment
```

## Lifecycle SPIs

### Databind / Render Hooks

| SPI | When It Fires |
|---|---|
| `IOnDataBind` | Component's data-bind is processed |
| `IOnDataBindCloak` | Cloaked data-bind components |
| `IOnComponentAdded` | Child added to component |
| `IOnComponentConfigured` | After component configuration |
| `IOnComponentHtmlRender` | During component HTML rendering |
| `IAfterRenderComplete` | After full render completes |
| `IClientVariableWatcher` | Client-side variable changes |

### Render-Ordering SPIs

| SPI | Purpose |
|---|---|
| `RenderBeforeLinks` | Before CSS `<link>` tags |
| `RenderAfterLinks` | After CSS `<link>` tags |
| `RenderBeforeScripts` | Before `<script>` tags |
| `RenderAfterScripts` | After `<script>` tags |
| `RenderBeforeDynamicScripts` | Before dynamic/inline scripts |
| `RenderAfterDynamicScripts` | After dynamic/inline scripts |

### Example Lifecycle Hook

```java
public class ComponentLogger implements IOnComponentAdded<ComponentLogger> {
    @Override
    public void onComponentAdded(IComponentHierarchyBase<?, ?> parent,
                                 IComponentHierarchyBase<?, ?> added) {
        log.info("Added {} to {}", added.getID(), parent.getID());
    }
}
```

## JavaScript Options

### JavaScriptPart Base Class

All component options extend `JavaScriptPart` for JSON serialization:

```java
public class MyComponentOptions extends JavaScriptPart<MyComponentOptions> {
    private String color;
    private Integer size;

    public MyComponentOptions setColor(String color) {
        this.color = color;
        return this;
    }

    public MyComponentOptions setSize(Integer size) {
        this.size = size;
        return this;
    }
}
```

Automatic Jackson serialization to JSON.

## References (CSS/JS)

### CSSReference

```java
public class CSSReference extends WebReference<CSSReference> {
    public CSSReference(String name, Double version, String url) {
        super(name, version, url);
    }
}
```

### JavascriptReference

```java
public class JavascriptReference extends WebReference<JavascriptReference> {
    public JavascriptReference(String name, Double version, String url) {
        super(name, version, url);
    }
}
```

## Annotations

### Plugin/Component Metadata

```java
@ComponentInformation(
    name = "My Component",
    description = "Component description",
    url = "https://example.com"
)
public class MyComponent { }

@PluginInformation(
    pluginName = "My Plugin",
    pluginUniqueName = "my-plugin",
    pluginVersion = "1.0.0"
)
public class MyPlugin { }

@FeatureInformation(
    name = "My Feature",
    description = "Feature description"
)
public class MyFeature { }
```

### Page Configuration

```java
@PageConfiguration(url = "/dashboard")
public class DashboardPage extends Page<DashboardPage> { }
```

## HTML Child Constraints

Type-safe parent/child relationships:

| Interface | Purpose |
|---|---|
| `GlobalChildren` | Elements accepting any flow/phrasing content |
| `GlobalFeatures` | Global HTML features |
| `HTMLFeatures` | HTML-specific features |
| `FormChildren` | Elements valid inside `<form>` |
| `NoClosingTag` | Void elements (`<br>`, `<img>`) |
| `NoIDTag` | Elements without `id` attribute |
| `NoClassAttribute` | Elements without `class` attribute |

## Exception Types

```java
InvalidRequestException      // Malformed AJAX request
MissingComponentException    // Component not found in tree
NullComponentException       // Null component where required
NoServletFoundException      // No handler for request path
UserSecurityException        // Security violation
```

## Browser/Client Types

```java
Browsers                     // Enum of known browsers
BrowserGroups                // Grouping by engine/vendor
CSSVersions                  // CSS specification levels
HTMLVersions                 // HTML specification levels
HttpMethodTypes              // HTTP methods (GET, POST, etc.)
```

## Configuration

`JWebMPClientConfiguration` enables:

| Setting | Value | Purpose |
|---|---|---|
| `classpathScanning` | `true` | Scan for SPI implementations |
| `annotationScanning` | `true` | Enable annotation discovery |
| `fieldInfo` | `true` | Collect field metadata |
| `methodInfo` | `true` | Collect method metadata |
| `allowPaths` | `true` | Path-based scanning |

## JPMS Module

```java
module com.jwebmp.client {
    requires transitive com.guicedee.client;
    requires transitive com.guicedee.jsonrepresentation;
    requires net.sf.uadetector.core;

    exports com.jwebmp.core.base.ajax;
    exports com.jwebmp.core.base.interfaces;
    exports com.jwebmp.core.services;
    exports com.jwebmp.interception.services;

    provides IGuiceModule with JWebMPClientBinder;
    provides IGuiceConfigurator with JWebMPClientConfiguration;

    uses AjaxCallIntercepter;
    uses DataCallIntercepter;
    uses SiteCallIntercepter;
}
```

## Key Classes

- `AjaxCall` — Incoming AJAX request payload (`CallScope`-scoped)
- `AjaxResponse` — Outgoing AJAX response with updates/reactions
- `JavaScriptPart` — Base for all JSON-serializable options
- `JWebMPClientBinder` — Guice module binding interceptors and AJAX pipeline
- `HeadersDTO` — Typed HTTP header wrapper

## Common Patterns

### Custom Interceptor Chain

```java
// Security interceptor (runs first)
public class SecurityInterceptor implements SiteCallIntercepter<SecurityInterceptor> {
    @Override
    public void intercept(AjaxCall<?> call, AjaxResponse<?> response) {
        if (!authenticated(call)) {
            throw new UserSecurityException("Unauthorized");
        }
    }

    @Override
    public Integer sortOrder() {
        return 1;  // Run early
    }
}

// Logging interceptor (runs later)
public class LoggingInterceptor implements AjaxCallIntercepter<LoggingInterceptor> {
    @Override
    public void intercept(AjaxCall<?> call, AjaxResponse<?> response) {
        log.info("Processing event: {}", call.getEventType());
    }

    @Override
    public Integer sortOrder() {
        return 100;
    }
}
```

### Dynamic Script Provider

```java
public class InlineScript implements ScriptProvider {
    @Override
    public IComponentHierarchyBase<?, ?> produceScript() {
        Script<?> script = new Script<>();
        script.setText("console.log('Dynamic script loaded');");
        return script;
    }
}
```

## Installation

```xml
<dependency>
  <groupId>com.jwebmp</groupId>
  <artifactId>jwebmp-client</artifactId>
</dependency>
```

## References

- Module: `com.jwebmp.client`
- Java: 25+
- Dependencies: GuicedEE Client, Jackson, UADetector
- License: Apache 2.0
