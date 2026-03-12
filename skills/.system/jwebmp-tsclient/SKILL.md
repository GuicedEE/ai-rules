---
name: jwebmp-tsclient
description: TypeScript client generation for JWebMP plugins. Provides annotations and utilities for generating TypeScript interfaces, components, services, and modules from Java code. Supports @TsDependency, @TsDevDependency, @NgComponent, @NgDataService annotations. Use when creating JWebMP plugins that generate TypeScript code, defining npm dependencies, or building Angular-integrated components.
metadata:
  short-description: TypeScript code generation utilities
---

# JWebMP TypeScript Client

TypeScript client generation for JWebMP plugins.

## Core Features

- **TypeScript Generation** — Generate .ts from Java annotations
- **NPM Dependencies** — Declare dependencies via annotations
- **Component Generation** — Auto-generate Angular components
- **Service Generation** — Auto-generate Angular services

## Annotations

### @TsDependency

Declare npm runtime dependencies:

```java
@TsDependency(value = "@angular/core", version = "^20.0.0")
@TsDependency(value = "rxjs", version = "^7.8.0")
public class MyComponent { }
```

### @TsDevDependency

Declare npm dev dependencies:

```java
@TsDevDependency(value = "@types/node", version = "^20.0.0")
@TsDevDependency(value = "typescript", version = "^5.0.0")
public class MyPlugin { }
```

### @NgComponent

Mark class for Angular component generation:

```java
@NgComponent("my-component")
public class MyComponent implements INgComponent<MyComponent> {
    @Override
    public String render() {
        return "<div>My Component</div>";
    }
}
```

### @NgDataService

Mark class for Angular service generation:

```java
@NgDataService
public class MyService implements INgDataService<MyService> {
    @Override
    public Object getData(AjaxCall<?> call, AjaxResponse<?> response) {
        return fetchData();
    }
}
```

## Interfaces

### INgComponent

```java
public interface INgComponent<J extends INgComponent<J>> {
    String render();
    default void configure(IComponentHierarchyBase<?, ?> component) { }
}
```

### INgDataService

```java
public interface INgDataService<J extends INgDataService<J>> {
    Object getData(AjaxCall<?> call, AjaxResponse<?> response);
    default void receiveData(AjaxCall<?> call, AjaxResponse<?> response) { }
}
```

### INgDirective

```java
public interface INgDirective<J extends INgDirective<J>> {
    String getSelector();
    Map<String, String> getInputs();
    Map<String, String> getOutputs();
}
```

## TypeScript Generation

Plugin automatically generates:
- Component .ts files
- Service .ts files
- Module declarations
- package.json dependencies
- tsconfig.json

## JPMS Module

```java
module com.jwebmp.core.base.angular.client {
    requires transitive com.jwebmp.client;

    exports com.jwebmp.core.base.angular.client;
    exports com.jwebmp.core.base.angular.client.annotations;
    exports com.jwebmp.core.base.angular.client.services;
}
```

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>tsclient</artifactId>
</dependency>
```

## References

- Module: `com.jwebmp.core.base.angular.client`
- Java: 25+
- TypeScript: 5.x
- License: Apache 2.0
