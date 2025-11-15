> This document is deprecated. See consolidated DI rules under: ../../frameworks/guicedee/di.rules.md

# GuicedEE Inject Client

## Overview

The GuicedEE Inject Client is a powerful dependency injection framework built on top of Google Guice. It provides a comprehensive set of tools for managing dependencies, scoping, and lifecycle events in Java applications. The framework uses the Service Provider Interface (SPI) pattern extensively to allow for modular and extensible components, and employs the Curiously Recurring Template Pattern (CRTP) for type-safe fluent interfaces.

## Core Concepts

### Dependency Injection

The framework extends Google Guice's dependency injection capabilities with additional features:

1. **Enhanced Injection Context**: The `IGuiceContext` interface provides a centralized access point to the Guice injector with additional functionality.
2. **Lifecycle Management**: Pre-startup and post-startup hooks allow for initialization and configuration before and after the Guice injector is created.
3. **Scoping Mechanism**: Custom scopes like `CallScope` provide context-specific dependency resolution.
4. **Service Discovery**: Automatic discovery and loading of service implementations using Java's ServiceLoader and ClassGraph.

### Service Provider Interface (SPI)

The framework makes extensive use of the SPI pattern to allow for modular and extensible components:

1. **IGuiceProvider**: Provides the Guice context implementation.
2. **IGuiceModule**: Configures the Guice injector with bindings.
3. **IGuicePreStartup**: Executes before the Guice injector is created.
4. **IGuicePostStartup**: Executes after the Guice injector is created.
5. **IOnCallScopeEnter/IOnCallScopeExit**: Hooks for call scope entry and exit.
6. **IJobServiceProvider**: Provides job service implementations.

### Curiously Recurring Template Pattern (CRTP)

The framework uses the CRTP pattern extensively to provide type-safe fluent interfaces:

1. **IEnvironment<J extends IEnvironment<J>>**: Base interface for environment definitions.
2. **IDefaultService<J extends IDefaultService<J>>**: Base interface for service definitions with ordering capabilities.
3. **IGuiceModule<J extends com.google.inject.Module & IGuiceModule<J>>**: Interface for Guice module configuration.
4. **IGuicePreStartup<J extends IGuicePreStartup<J>>**: Interface for pre-startup actions.
5. **IGuicePostStartup<J extends IGuicePostStartup<J>>**: Interface for post-startup actions.

This pattern allows for method chaining with proper return types and type-safe comparisons between services of the same type.

## Key Components

### Core Interfaces

#### IGuiceContext

The central interface for accessing the Guice injector and managing the dependency injection context. It provides methods for:

- Getting instances of classes from the Guice injector
- Managing the lifecycle of the Guice context
- Loading services using ServiceLoader and ClassGraph
- Registering modules for scanning
- Configuring the scanning options

```java
public interface IGuiceContext {
    static IGuiceContext getContext();
    static <T> T get(Class<T> type);
    Injector inject();
    void destroy();
    ScanResult getScanResult();
    // ...
}
```

#### IGuiceModule

Interface for configuring the Guice injector with bindings. Implementations extend Google Guice's AbstractModule and implement this interface.

```java
public interface IGuiceModule<J extends com.google.inject.Module & IGuiceModule<J>>
        extends IDefaultService<J> {
    // Inherits methods from IDefaultService
}
```

#### IGuicePreStartup

Interface for actions that should be performed before the Guice injector is created.

```java
public interface IGuicePreStartup<J extends IGuicePreStartup<J>>
        extends IDefaultService<J> {
    List<Future<Boolean>> onStartup();
    default Integer sortOrder() {
        return 100;
    }
}
```

#### IGuicePostStartup

Interface for actions that should be performed after the Guice injector is created.

```java
public interface IGuicePostStartup<J extends IGuicePostStartup<J>>
        extends IDefaultService<J> {
    List<Future<Boolean>> postLoad();
    default Integer sortOrder() {
        return 50;
    }
    // Utility methods for executing tasks asynchronously
}
```

#### IDefaultService

Base interface for service definitions with ordering capabilities.

```java
public interface IDefaultService<J extends IDefaultService<J>>
        extends Comparable<J>, Comparator<J> {
    default int compare(J o1, J o2);
    default Integer sortOrder();
    default int compareTo(J o);
}
```

### Call Scoping

#### CallScoper

Implements Google Guice's Scope interface to provide a custom scoping mechanism for thread-local context.

```java
@Singleton
public class CallScoper implements Scope {
    public void enter();
    public void exit();
    public <T> void seed(Class<T> clazz, T value);
    public <T> Provider<T> scope(final Key<T> key, final Provider<T> unscoped);
    // ...
}
```

#### CallScopeProperties

Holds properties for the call scope, including the source of the call and arbitrary properties.

```java
@CallScope
@Getter
@Setter
@Accessors(chain = true)
public class CallScopeProperties implements Serializable {
    private CallScopeSource source;
    private Map<Object, Object> properties = new HashMap<>();
}
```

#### CallScopeSource

Enum defining the possible sources of call scope entries, including:

- Http
- WebSocket
- RabbitMQ
- Timer
- SerialPort
- Transaction
- Test
- Rest
- WebService
- Startup
- VertXConsumer
- VertXProducer

### Annotations

#### INotEnhanceable

Annotation to mark classes that should not be enhanced by AOP.

```java
@Target({ElementType.TYPE, ElementType.TYPE_USE})
@Retention(RetentionPolicy.RUNTIME)
public @interface INotEnhanceable {
}
```

#### INotInjectable

Annotation to mark classes that should not be injected by Guice.

```java
@Target({ElementType.TYPE, ElementType.TYPE_USE})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
public @interface INotInjectable {
}
```

### Implementation Classes

#### GuicedEEClientModule

Implements IGuiceModule to configure the Guice injector with bindings for the client module.

```java
@Log
public class GuicedEEClientModule extends AbstractModule implements IGuiceModule<GuicedEEClientModule> {
    @Override
    protected void configure() {
        bindScope(CallScope.class, new CallScoper());
    }
}
```

#### GuicedEEClientStartup

Implements IGuicePreStartup to configure the scanning options before the Guice injector is created.

```java
@Log
public class GuicedEEClientStartup implements IGuicePreStartup<GuicedEEClientStartup> {
    @Override
    public List<Future<Boolean>> onStartup() {
        IGuiceContext.instance()
                     .getConfig()
                     .setFieldScanning(true)
                     .setMethodInfo(true)
                     .setIgnoreClassVisibility(true)
                     .setIgnoreMethodVisibility(true)
                     .setIgnoreFieldVisibility(true)
                     .setAnnotationScanning(true);
        return List.of(Future.succeededFuture(true));
    }

    @Override
    public Integer sortOrder() {
        return Integer.MIN_VALUE + 1;
    }
}
```

#### GuicedEEClientPostStartup

Implements IGuicePostStartup to load WebSocket receivers after the Guice injector is created.

```java
public class GuicedEEClientPostStartup implements IGuicePostStartup<GuicedEEClientPostStartup> {
    @Override
    public List<Future<Boolean>> postLoad() {
        IGuicedWebSocket.loadWebSocketReceivers();
        return List.of(Future.succeededFuture(true));
    }

    @Override
    public Integer sortOrder() {
        return Integer.MIN_VALUE + 650;
    }
}
```

## Usage Examples

### Basic Dependency Injection

```java
// Get an instance of a class from the Guice injector
MyService service = IGuiceContext.get(MyService.class);

// Get an instance with a specific annotation
MyService service = IGuiceContext.get(MyService.class, MyAnnotation.class);
```

### Creating a Custom Module

```java
public class MyModule extends AbstractModule implements IGuiceModule<MyModule> {
    @Override
    protected void configure() {
        bind(MyService.class).to(MyServiceImpl.class);
        bind(MyInterface.class).toProvider(MyProvider.class);
    }
}
```

### Creating Pre-Startup and Post-Startup Actions

```java
public class MyPreStartup implements IGuicePreStartup<MyPreStartup> {
    @Override
    public List<Future<Boolean>> onStartup() {
        // Configure something before Guice is initialized
        return List.of(Future.succeededFuture(true));
    }
}

public class MyPostStartup implements IGuicePostStartup<MyPostStartup> {
    @Override
    public List<Future<Boolean>> postLoad() {
        // Do something after Guice is initialized
        return List.of(Future.succeededFuture(true));
    }
}
```

### Using Call Scoping

```java
// Enter a call scope
CallScoper scoper = IGuiceContext.get(CallScoper.class);
scoper.enter();
try {
    // Seed a value in the call scope
    CallScopeProperties properties = IGuiceContext.get(CallScopeProperties.class);
    properties.setSource(CallScopeSource.Http);
    properties.getProperties().put("key", "value");

    // Use scoped objects
    MyService service = IGuiceContext.get(MyService.class);
    service.doSomething();
} finally {
    // Exit the call scope
    scoper.exit();
}
```

## Best Practices

1. **Use SPI for Extensions**: Implement the appropriate SPI interfaces (IGuiceModule, IGuicePreStartup, IGuicePostStartup) to extend the framework.
2. **Leverage CRTP**: Use the CRTP pattern for type-safe fluent interfaces in your own components.
3. **Manage Scopes Properly**: Always exit scopes in a finally block to prevent memory leaks.
4. **Order Services Appropriately**: Override the sortOrder() method to control the execution order of services.
5. **Use Annotations Wisely**: Use @INotEnhanceable and @INotInjectable annotations to control how classes are handled by the framework.

## Implementation Steps

### Adding to pom.xml

To use GuicedEE Inject Client in your project, add the following dependency to your pom.xml:

```xml
<dependency>
    <groupId>com.guicedee</groupId>
    <artifactId>guice-inject-client</artifactId>
    <version>${guicedee.version}</version>
</dependency>
```

For dependency management, you can import the GuicedEE BOM:

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.guicedee</groupId>
            <artifactId>guicedee-bom</artifactId>
            <version>${guicedee.version}</version>
            <scope>import</scope>
            <type>pom</type>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### Adding to module-info.java

If you're using Java modules, add the following to your module-info.java:

```java
module your.module.name {
    // Required modules
    requires com.guicedee.client;

    // If you're implementing SPI interfaces
    provides com.guicedee.guicedinjection.interfaces.IGuiceModule with your.package.YourModule;
    provides com.guicedee.guicedinjection.interfaces.IGuicePreStartup with your.package.YourPreStartup;
    provides com.guicedee.guicedinjection.interfaces.IGuicePostStartup with your.package.YourPostStartup;

    // If you're using call scoping
    opens your.package.scoped.classes to com.google.guice;

    // If you're using Jackson serialization
    opens your.package.serialized.classes to com.fasterxml.jackson.databind;
}
```

### Transitive Dependencies

The GuicedEE Inject Client module includes several transitive dependencies that are automatically available to consuming modules:

1. **com.google.guice**: The core Google Guice dependency injection framework
2. **io.github.classgraph**: Used for classpath scanning and service discovery
3. **com.fasterxml.jackson.databind**: Used for JSON serialization and deserialization
4. **io.vertx.core**: Provides the Vert.x core functionality for asynchronous operations

### Non-Required Transitive Dependencies

The following dependencies are included in the GuicedEE Inject Client but are not required to be explicitly included in consuming modules:

1. **org.apache.commons.lang3**: Provides utility classes for common operations
2. **org.apache.logging.log4j**: Logging framework
   - org.apache.logging.log4j.core
   - org.apache.logging.log4j.jul
   - org.apache.logging.log4j.slf4j2.impl
3. **lombok**: Used for reducing boilerplate code (static dependency)
4. **jakarta.inject**: Jakarta EE injection API (static dependency)

If your application requires direct access to these libraries, you may need to add them as explicit dependencies.

## Advanced Usage

### Extended IGuiceContext Functionality

The `IGuiceContext` interface provides several advanced methods that are useful for more complex scenarios:

#### Class Property Checking

```java
// Check if a class should not be enhanced by AOP
boolean notEnhanceable = IGuiceContext.getContext().isNotEnhanceable(MyClass.class);

// Check if a class should not be injected by Guice
boolean notInjectable = IGuiceContext.getContext().isNotInjectable(MyClass.class);

// Check if a class is an entity type (for JPA integration)
boolean isEntity = IGuiceContext.getContext().isEntityType(MyClass.class);
```

#### Service Loading

The framework provides several methods for loading services using Java's ServiceLoader:

```java
// Load services and inject dependencies
Set<MyService> services = IGuiceContext.loaderToSet(ServiceLoader.load(MyService.class));

// Load services without injecting dependencies
Set<MyService> services = IGuiceContext.loaderToSetNoInjection(ServiceLoader.load(MyService.class));

// Load service classes (not instances)
Set<Class<MyService>> serviceClasses = IGuiceContext.loadClassSet(ServiceLoader.load(MyService.class));
```

#### Module Registration

You can register modules programmatically:

```java
// Register a Java module by name
IGuiceContext.getContext().registerModule("my.module.name");

// Register a Guice module instance
IGuiceContext.getContext().registerModule(new MyModule());
```

### Asynchronous Execution with IGuicePostStartup

The `IGuicePostStartup` interface provides utility methods for executing tasks asynchronously:

```java
public class MyPostStartup implements IGuicePostStartup<MyPostStartup> {
    @Override
    public List<Future<Boolean>> postLoad() {
        // Execute a task asynchronously
        Future<Boolean> future = execute(() -> {
            // Do something time-consuming
            return true;
        }, false);

        // Execute a task asynchronously and group it with other tasks
        Future<Boolean> groupedFuture = execute(() -> {
            // Do something time-consuming
            return true;
        }, true);

        // Execute a single task asynchronously
        Future<Boolean> singleFuture = executeSingle(() -> {
            // Do something time-consuming
            return true;
        }, false);

        return List.of(future, groupedFuture, singleFuture);
    }
}
```

### Call Scope Hooks

You can implement hooks for call scope entry and exit:

```java
public class MyCallScopeEnterHook implements IOnCallScopeEnter<MyCallScopeEnterHook> {
    @Override
    public void onScopeEnter(CallScoper scoper) {
        // Do something when a call scope is entered
        System.out.println("Call scope entered");
    }
}

public class MyCallScopeExitHook implements IOnCallScopeExit<MyCallScopeExitHook> {
    @Override
    public void onScopeExit() {
        // Do something when a call scope is exited
        System.out.println("Call scope exited");
    }
}
```

### Custom Scoping

You can create custom scopes by extending the `CallScoper` class:

```java
@Singleton
public class MyCustomScoper extends CallScoper {
    @Override
    public void enter() {
        super.enter();
        // Additional setup for your custom scope
    }

    @Override
    public void exit() {
        // Additional cleanup for your custom scope
        super.exit();
    }
}
```

## Troubleshooting

### Common Issues

#### Circular Dependencies

If you encounter circular dependency issues, consider using provider injection:

```java
public class ServiceA {
    private final Provider<ServiceB> serviceBProvider;

    @Inject
    public ServiceA(Provider<ServiceB> serviceBProvider) {
        this.serviceBProvider = serviceBProvider;
    }

    public void doSomething() {
        ServiceB serviceB = serviceBProvider.get();
        // Use serviceB
    }
}
```

#### ClassNotFoundException during Scanning

If you encounter `ClassNotFoundException` during scanning, it may be due to missing dependencies. Ensure all required dependencies are on the classpath.

#### OutOfScopeException

If you encounter `OutOfScopeException`, it means you're trying to access a scoped object outside of its scope. Ensure you're entering the scope before accessing scoped objects:

```java
CallScoper scoper = IGuiceContext.get(CallScoper.class);
scoper.enter();
try {
    // Access scoped objects here
} finally {
    scoper.exit();
}
```

#### Memory Leaks

If you're experiencing memory leaks, ensure you're exiting scopes properly. Always exit scopes in a finally block to prevent memory leaks.

### Debugging Tips

#### Enable Verbose Logging

You can enable verbose logging to debug issues:

```java
Logger.getLogger("com.guicedee").setLevel(Level.FINE);
```

#### Inspect the Injector

You can inspect the Guice injector to see what bindings are available:

```java
Injector injector = IGuiceContext.getContext().inject();
Map<Key<?>, Binding<?>> bindings = injector.getAllBindings();
for (Map.Entry<Key<?>, Binding<?>> entry : bindings.entrySet()) {
    System.out.println(entry.getKey() + " -> " + entry.getValue());
}
```

## Conclusion

The GuicedEE Inject Client provides a powerful and flexible dependency injection framework built on top of Google Guice. By leveraging SPI for extensibility and CRTP for type safety, it offers a robust solution for managing dependencies in Java applications. The framework's lifecycle hooks, scoping mechanisms, and service discovery capabilities make it suitable for a wide range of applications, from simple command-line tools to complex enterprise systems.
