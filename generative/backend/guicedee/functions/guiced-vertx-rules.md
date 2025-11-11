# GuicedVertx Package Structure Guidelines

This document outlines the recommended package structure for the GuicedVertx module, designed to align with modern JDK 24 practices and provide a logical organization of components.

## Package Structure

The GuicedVertx module should be organized into the following package structure:

```
com.guicedee.vertx
├── core                  # Core Vert.x integration components
│   ├── VertX.java        # Main Vert.x configuration annotation
│   └── VertXModule.java  # Guice module for Vert.x integration
├── lifecycle             # Lifecycle management components
│   ├── VertXPreStartup.java  # Initialization of Vert.x
│   └── VertXPostStartup.java # Cleanup of Vert.x
├── eventbus              # Event bus related components
│   ├── publisher         # Event publishers
│   │   └── VertxEventPublisher.java  # Class for publishing events
│   ├── registry          # Event registration and management
│   │   └── VertxEventRegistry.java  # Registry for events
│   └── model             # Event models and definitions
│       ├── VertxEventDefinition.java  # Event definition
│       └── VertxEventOptions.java     # Event options
├── config                # Configuration components
│   ├── VertxConfigurator.java        # Interface for configuring Vert.x
│   ├── ClusterVertxConfigurator.java # Cluster configuration
│   └── options           # Configuration options
│       ├── AddressResolverOptions.java  # DNS options
│       ├── EventBusOptions.java         # Event bus options
│       ├── FileSystemOptions.java       # File system options
│       └── MetricsOptions.java          # Metrics options
└── verticle              # Verticle related components
    ├── Verticle.java          # Base verticle class
    ├── VerticleBuilder.java   # Builder for verticles
    └── VerticleStartup.java   # Verticle startup interface
```

## Migration Guidelines

When migrating existing code to this new structure:

1. Move classes to their appropriate packages based on functionality
2. Update import statements in all affected files
3. Ensure module-info.java exports the new packages
4. Update any service provider configurations in META-INF/services
5. For event consumers, only the @VertxEventDefinition annotation is required:
   - Methods or classes with @VertxEventDefinition will be automatically registered as event consumers
   - The method should accept a Message<?> parameter or a parameter matching the event type
   - No additional annotations or interfaces are required

## Rationale

This package structure provides several benefits:

1. **Logical Grouping**: Classes are grouped by their functional area, making the codebase easier to navigate
2. **Separation of Concerns**: Clear separation between different aspects of the Vert.x integration
3. **Scalability**: Structure allows for future expansion with minimal disruption
4. **Discoverability**: Developers can quickly find related components
5. **Alignment with JDK 24**: Follows modern Java module system practices

## Examples

### Event Consumer Example

```java
package com.guicedee.vertx.eventbus.consumer;

import com.guicedee.vertx.VertxEventDefinition;
import io.vertx.core.eventbus.Message;

@VertxEventDefinition("user.event.address")
public class UserEventConsumer {
    //or per method @VertxEventDefinition("user.event.address")
    public void consume(Message<UserEvent> message) {
        // Handle user event
    }
}
```

### Multiple Event Consumer Example

```java
package com.guicedee.vertx.eventbus.consumer;

import com.guicedee.vertx.VertxEventDefinition;
import io.vertx.core.eventbus.Message;

public class UserEventConsumer {
    @VertxEventDefinition("user.event.address.scenario1")
    public void consume(Message<UserEvent> message) {
        // Handle user event
    }

    @VertxEventDefinition("user.event.address.scenario2")
    public void consume(Message<UserEventTwo> message) {
        // Handle user event
    }
}
```

### Verticle Example

```java
package com.guicedee.vertx.verticle;

import io.vertx.core.AbstractVerticle;

public class ApiVerticle extends AbstractVerticle {
    @Override
    public void start() {
        // Start verticle
    }
}
```

## SPI Implementation

The GuicedVertx module follows the same SPI (Service Provider Interface) pattern as the core GuicedInjection framework. This section outlines how to create, implement, and register SPIs in the GuicedVertx module.

### Creating SPI Interfaces

SPI interfaces for Vert.x should be placed in the `com.guicedee.vertx.spi` package and should follow these guidelines:

1. Use a descriptive name that clearly indicates its purpose in the Vert.x context
2. Extend appropriate marker interfaces when needed (e.g., `IGuicePreStartup`, `IGuiceModule`)
3. Keep the interface focused on a single responsibility related to Vert.x functionality
4. Document the interface thoroughly with Javadoc

Example:

```java
package com.guicedee.vertx.spi;

import com.guicedee.guicedinjection.interfaces.IGuicePreStartup;

/**
 * Interface for components that need to perform Vert.x-specific actions before the application starts.
 */
public interface VertxPreStartup<J extends VertxPreStartup<J>> extends IGuicePreStartup<J> {
    /**
     * Performs Vert.x-specific pre-startup actions.
     */
    @Override
    void onStartup();
}
```

### Implementing SPI Interfaces

Implementations of Vert.x SPI interfaces should follow these guidelines:

1. Place implementations in an `impl` subpackage or in a separate module
2. Name implementations clearly, typically ending with "Impl" or a descriptive term
3. Implement only the methods defined in the interface
4. Use field injection for dependencies to maintain proper encapsulation
5. Keep implementations stateless when possible

Example:

```java
package com.guicedee.vertx.spi.impl;

import com.guicedee.vertx.spi.VertxPreStartup;
import io.vertx.core.Vertx;

import javax.inject.Inject;

public class DefaultVertxPreStartup<J extends DefaultVertxPreStartup<J>> implements VertxPreStartup<J> {
    @Inject
    private Vertx vertx;

    @Override
    public void onStartup() {
        // Perform Vert.x-specific pre-startup actions
    }
}
```

### Registering SPI Implementations

SPI implementations for Vert.x can be registered using both the Java Module System and the META-INF/services mechanism, just like in the core GuicedInjection framework:

#### Using the Java Module System:

In your `module-info.java` file:

```java
module com.guicedee.vertx {
    requires com.guicedee.guicedinjection;

    provides com.guicedee.vertx.spi.VertxConfigurator 
        with com.guicedee.vertx.spi.impl.DefaultVertxConfigurator;

    // Do NOT include this line:
    // uses com.guicedee.guicedinjection.interfaces.IGuiceModule;
}
```

> **Important Note**: The GuicedInjection library already includes `uses com.guicedee.guicedinjection.interfaces.IGuiceModule` in its module-info.java file. Since your module will require GuicedInjection (directly or transitively), you should not specify this "uses" directive in your own module-info.java file. The GuicedInjection library will automatically discover and load all IGuiceModule implementations.

#### Transitive Dependencies

GuicedVertx includes several transitive dependencies that are automatically available to modules that depend on it. This means you don't need to explicitly declare these dependencies in your module-info.java file.

The following modules are transitive dependencies of GuicedVertx:

```java
// Transitive dependencies in GuicedVertx
requires transitive io.vertx.core;
requires transitive com.guicedee.client;
requires transitive com.guicedee.jsonrepresentation;
requires transitive org.apache.logging.log4j;
requires transitive com.fasterxml.jackson.databind;
requires transitive com.fasterxml.jackson.annotation;
requires transitive com.fasterxml.jackson.core;
requires transitive io.smallrye.mutiny;
requires transitive io.vertx.mutiny;
```

When you include `requires com.guicedee.vertx` in your module-info.java file, these dependencies are automatically available to your module without needing to declare them explicitly.

#### Recommendation for Java Clients

When creating Java modules that use GuicedVertx and want to expose its functionality to their own consumers, it is recommended to use `requires transitive` instead of just `requires`:

```java
// Recommended approach for modules that expose GuicedVertx functionality
requires transitive com.guicedee.vertx;
```

This ensures that your module's consumers will also have access to GuicedVertx and its transitive dependencies without having to explicitly require them.

#### Using META-INF/services:

Create a file at `META-INF/services/com.guicedee.vertx.spi.VertxConfigurator` with the content:

```
com.guicedee.vertx.spi.impl.DefaultVertxConfigurator
```

## Lifecycle Management

The GuicedVertx module integrates with the lifecycle management system of the GuicedInjection framework. This section explains how to hook into the Vert.x-specific lifecycle events.

### Startup Sequence

The Vert.x startup sequence is integrated with the GuicedInjection startup sequence:

1. The core GuicedInjection framework initializes
2. The `VertXPreStartup` service is executed as part of the pre-startup phase
3. The Vert.x instance is created and configured
4. Event consumers are registered
5. Verticles are deployed
6. Post-startup hooks are executed

To hook into this sequence, you can implement the following interfaces:

- `VertxPreStartup`: For actions before Vert.x is initialized
- `VertxConfigurator`: For customizing Vert.x configuration
- `VerticleStartup`: For actions during verticle deployment
- `IGuicePostStartup`: For actions after Vert.x is fully initialized

Example:

```java
package com.guicedee.vertx.lifecycle;

import com.guicedee.vertx.spi.VertxConfigurator;
import io.vertx.core.Vertx;
import io.vertx.core.VertxOptions;

public class CustomVertxConfigurator implements VertxConfigurator<CustomVertxConfigurator> {
    @Override
    public Vertx configure(VertxOptions options) {
        // Customize Vert.x options
        options.setWorkerPoolSize(50);
        return Vertx.vertx(options);
    }
}
```

### Shutdown Sequence

The Vert.x shutdown sequence is also integrated with the GuicedInjection shutdown sequence:

1. The `IGuicePreDestroy` hooks are executed
2. The Vert.x instance is closed
3. Resources are cleaned up

To hook into this sequence, implement the `IGuicePreDestroy` interface:

```java
package com.guicedee.vertx.lifecycle;

import com.guicedee.guicedinjection.interfaces.IGuicePreDestroy;
import com.guicedee.vertx.spi.VertXPreStartup;

public class VertxCleaner implements IGuicePreDestroy<VertxCleaner> {
    @Override
    public void onDestroy() {
        // Close the Vert.x instance
        VertXPreStartup.getVertx().close();
    }
}
```

## Best Practices

1. Place interfaces and their primary implementations in the same package
2. Use subpackages for specialized implementations
3. Keep the public API surface minimal and well-documented
4. Follow Java naming conventions consistently
5. Prefer composition over inheritance where possible
6. Use the SPI mechanism for extending Vert.x functionality
7. Register event consumers using the `@VertxEventDefinition` annotation
8. Leverage the lifecycle hooks for proper resource management
