# GuicedInjection Framework Guidelines

This document provides comprehensive guidelines for using the GuicedInjection framework, including package structure, SPI implementation, module configuration, and best practices.

## Table of Contents

1. [Overview](#overview)
2. [Package Structure](#package-structure)
3. [SPI Implementation](#spi-implementation)
   - [Creating SPI Interfaces](#creating-spi-interfaces)
   - [Implementing SPI Interfaces](#implementing-spi-interfaces)
   - [Registering SPI Implementations](#registering-spi-implementations)
   - [Using CRTP (Curiously Recurring Template Pattern)](#using-crtp-curiously-recurring-template-pattern)
4. [Module Configuration](#module-configuration)
   - [module-info.java](#module-infojava)
   - [META-INF/services](#meta-infservices)
5. [Lifecycle Management](#lifecycle-management)
   - [Startup Sequence](#startup-sequence)
   - [Shutdown Sequence](#shutdown-sequence)
6. [Integration with Vert.x](#integration-with-vertx)
   - [Vert.x Instance Management](#vertx-instance-management)
   - [Verticle Configuration](#verticle-configuration)
   - [Vert.x 5 Migration](#vertx-5-migration)
7. [Common Use Cases](#common-use-cases)
   - [Dependency Injection](#dependency-injection)
   - [Service Discovery](#service-discovery)
   - [Configuration Management](#configuration-management)
   - [Job Management](#job-management)
8. [Best Practices](#best-practices)
9. [Testing with Guice](#testing-with-guice)
10. [Troubleshooting](#troubleshooting)

## Overview

GuicedInjection is a framework that provides dependency injection, service discovery, and lifecycle management capabilities for Java applications. It is built on top of Google Guice and integrates with various technologies such as Vert.x, JPA, and more.

The framework uses Java's Service Provider Interface (SPI) mechanism to enable extensibility and modularity. It also leverages the Java Module System (JPMS) to provide strong encapsulation and explicit dependencies.

## Package Structure

The GuicedInjection framework follows a modular package structure that separates concerns and promotes maintainability. Here's the recommended package structure for modules built with GuicedInjection:

```
com.guicedee.[module]
├── core                  # Core components
│   ├── Module.java       # Main Guice module
│   └── Config.java       # Configuration class
├── spi                   # Service Provider Interfaces
│   ├── ServiceInterface.java  # SPI interface
│   └── impl              # Default implementations
│       └── ServiceImpl.java   # Default implementation
├── annotations           # Annotations for the module
├── lifecycle             # Lifecycle management components
│   ├── PreStartup.java   # Pre-startup hook
│   └── PreDestroy.java   # Pre-destroy hook
└── util                  # Utility classes
```

## SPI Implementation

### Creating SPI Interfaces

SPI interfaces should be placed in the `spi` package and should follow these guidelines:

1. Use a descriptive name that ends with a verb or noun indicating its purpose
2. Extend marker interfaces when appropriate (e.g., `IGuicePreStartup`, `IGuiceModule`)
3. Keep the interface focused on a single responsibility
4. Document the interface thoroughly with Javadoc

Example:

```java
package com.guicedee.module.spi;

import com.guicedee.guicedinjection.interfaces.IGuicePreStartup;

/**
 * Interface for components that need to perform actions before the application starts.
 */
public interface ModulePreStartup<J extends ModulePreStartup<J>> extends IGuicePreStartup<J> {
    /**
     * Performs pre-startup actions for the module.
     */
    @Override
    void onStartup();
}
```

### Implementing SPI Interfaces

Implementations of SPI interfaces should follow these guidelines:

1. Place implementations in an `impl` subpackage or in a separate module
2. Name implementations clearly, typically ending with "Impl" or a descriptive term
3. Implement only the methods defined in the interface
4. Use constructor injection for dependencies to maintain proper encapsulation
5. Keep implementations stateless when possible

Example:

```java
package com.guicedee.module.spi.impl;

import com.guicedee.module.spi.ModulePreStartup;

public class DefaultModulePreStartup<J extends DefaultModulePreStartup<J>> implements ModulePreStartup<J> {
    @Override
    public void onStartup() {
        // Perform pre-startup actions
    }
}
```

### Registering SPI Implementations

SPI implementations can be registered using both the Java Module System and the META-INF/services mechanism. To support deployments and times, the module-info is used. For tests the META-INF/services is used for the support of Jupiter/JUnit or TestNG and the likes:

#### Using the Java Module System:

In your `module-info.java` file:

```java
module com.guicedee.module {
    requires com.guicedee.guicedinjection;

    provides com.guicedee.guicedinjection.interfaces.IGuicePreStartup 
        with com.guicedee.module.spi.impl.DefaultModulePreStartup;
}
```

#### Using META-INF/services:

Create a file at `META-INF/services/com.guicedee.guicedinjection.interfaces.IGuicePreStartup` with the content:

```
com.guicedee.module.spi.impl.DefaultModulePreStartup
```

### Using CRTP (Curiously Recurring Template Pattern)

GuicedInjection uses the Curiously Recurring Template Pattern (CRTP) for many of its interfaces and classes. This pattern involves a class or interface that takes itself as a generic type parameter, typically in the form `<J extends Class<J>>`.

#### Benefits of CRTP

1. **Type-Safe Method Chaining**: Allows for fluent interfaces with proper type safety
2. **Self-Referential Type Information**: Provides access to the derived type from the base type
3. **Compile-Time Polymorphism**: Enables static polymorphism without runtime overhead
4. **Enhanced Builder Pattern**: Facilitates more sophisticated builder patterns

#### Implementing CRTP

When creating interfaces or classes in the GuicedInjection framework, follow these guidelines for CRTP:

1. Use a generic type parameter (typically `J`) that extends the class or interface itself
2. Implement or extend base interfaces that also use CRTP, such as `IDefaultService<J>`
3. Return the generic type `J` from builder-style methods to enable method chaining

Example of an interface using CRTP:

```java
package com.guicedee.module.spi;

import com.guicedee.guicedinjection.interfaces.IDefaultService;

/**
 * Interface for a module service with CRTP pattern.
 */
public interface ModuleService<J extends ModuleService<J>> extends IDefaultService<J> {
    /**
     * Configures the service with a name.
     *
     * @param name the name to configure
     * @return this instance for method chaining
     */
    J withName(String name);

    /**
     * Gets the configured name.
     *
     * @return the name
     */
    String getName();
}
```

Example of a class implementing a CRTP interface:

```java
package com.guicedee.module.spi.impl;

import com.guicedee.module.spi.ModuleService;

public class DefaultModuleService implements ModuleService<DefaultModuleService> {
    private String name;

    @Override
    public DefaultModuleService withName(String name) {
        this.name = name;
        return this;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public int sortOrder() {
        return 10;
    }
}
```

### Available SPI Interfaces

GuicedInjection provides a variety of SPI interfaces that can be implemented to extend and customize the framework's behavior. Here's a comprehensive list of the available SPI interfaces:

#### Lifecycle Management Interfaces

- **IGuicePreStartup**: Executed before the Guice injector is built. Implement this interface to perform initialization tasks before the application starts.
- **IGuicePostStartup**: Executed after the Guice injector is built. Implement this interface to perform tasks that require dependency injection.
- **IGuicePreDestroy**: Executed during the shutdown sequence. Implement this interface to clean up resources before the application shuts down.

#### Module Configuration Interfaces

- **IGuiceModule**: Defines a Guice module that contributes bindings to the injector. Implement this interface to provide custom bindings.
- **IGuiceConfigurator**: Configures the GuiceContext before it's initialized. Implement this interface to customize the configuration of the GuiceContext.
- **IGuiceProvider**: Provides a way to obtain instances of the GuiceContext. Implement this interface to customize how the GuiceContext is provided.

#### Scanning Interfaces

- **IFileContentsScanner**: Scans file contents during the classpath scanning process. Implement this interface to process file contents during scanning.
- **IFileContentsPatternScanner**: Scans file contents using pattern matching. Implement this interface to scan files using custom patterns.
- **IPackageContentsScanner**: Scans package contents during the classpath scanning process. Implement this interface to process package contents during scanning.
- **IPathContentsScanner**: Scans path contents during the classpath scanning process. Implement this interface to process path contents during scanning.
- **IPathContentsRejectListScanner**: Provides a reject list for path contents scanning. Implement this interface to exclude certain paths from scanning.
- **IPackageRejectListScanner**: Provides a reject list for package scanning. Implement this interface to exclude certain packages from scanning.

#### Module and JAR Scanning Interfaces

- **IGuiceScanModuleExclusions**: Provides a list of modules to exclude from scanning. Implement this interface to exclude specific modules from the scanning process.
- **IGuiceScanModuleInclusions**: Provides a list of modules to include in scanning. Implement this interface to include specific modules in the scanning process.
- **IGuiceScanJarExclusions**: Provides a list of JARs to exclude from scanning. Implement this interface to exclude specific JARs from the scanning process.
- **IGuiceScanJarInclusions**: Provides a list of JARs to include in scanning. Implement this interface to include specific JARs in the scanning process.

#### Service Interfaces

- **IJobServiceProvider**: Provides job services for the application. Implement this interface to provide custom job services.
- **Log4JConfigurator**: Configures Log4J for the application. Implement this interface to customize Log4J configuration.

Each of these interfaces can be implemented and registered using either the Java Module System or the META-INF/services mechanism as described in the previous sections.

## Module Configuration

### module-info.java

The `module-info.java` file should be placed at the root of your module's source directory and should follow these guidelines:

1. Use a descriptive name for your module, typically following the base package name
2. Explicitly declare all dependencies using `requires`
3. Use `requires transitive` for dependencies that should be exposed to consumers
4. Export only the packages that are part of your public API using `exports`
5. Open packages that need reflection access using `opens`
6. Declare service providers using `provides ... with ...`
7. Declare service consumers using `uses ...`
8. **Do not** specify `uses com.guicedee.guicedinjection.interfaces.IGuiceModule` as this is already handled by the GuicedInjection library

> **Important Note**: The GuicedInjection library already includes `uses com.guicedee.guicedinjection.interfaces.IGuiceModule` in its module-info.java file. Since your module will require GuicedInjection (directly or transitively), you should not specify this "uses" directive in your own module-info.java file. The GuicedInjection library will automatically discover and load all IGuiceModule implementations.

Example:

```java
module com.guicedee.module {
    // Core dependencies
    requires transitive com.guicedee.guicedinjection;

    // Optional dependencies
    requires static lombok;

    // Exports
    exports com.guicedee.module.core;
    exports com.guicedee.module.spi;

    // Opens for reflection
    opens com.guicedee.module.core to com.google.guice;

    // Service providers
    provides com.guicedee.guicedinjection.interfaces.IGuiceModule 
        with com.guicedee.module.core.Module;
    provides com.guicedee.guicedinjection.interfaces.IGuicePreStartup 
        with com.guicedee.module.spi.impl.DefaultModulePreStartup;

    // Service consumers
    uses com.guicedee.module.spi.ModuleService;
}
```

### Transitive Dependencies

GuicedInjection includes several transitive dependencies that are automatically available to modules that depend on it. This means you don't need to explicitly declare these dependencies in your module-info.java file.

The following modules are transitive dependencies of GuicedInjection:

```java
// Transitive dependencies in GuicedInjection
requires transitive com.guicedee.client;
requires transitive org.apache.commons.lang3;
requires transitive com.guicedee.vertx;
```

When you include `requires com.guicedee.guicedinjection` in your module-info.java file, these dependencies are automatically available to your module without needing to declare them explicitly.

#### Recommendation for Java Clients

When creating Java modules that use GuicedInjection and want to expose its functionality to their own consumers, it is recommended to use `requires transitive` instead of just `requires`:

```java
// Recommended approach for modules that expose GuicedInjection functionality
requires transitive com.guicedee.guicedinjection;
```

This ensures that your module's consumers will also have access to GuicedInjection and its transitive dependencies without having to explicitly require them.

### META-INF/services

The META-INF/services mechanism can be used alongside or instead of the Java Module System for registering SPI implementations. Follow these guidelines:

1. Create a file in the `META-INF/services` directory with the fully qualified name of the SPI interface
2. Add the fully qualified name of each implementation on a separate line
3. Ensure the file is included in your JAR file

Example:

File: `META-INF/services/com.guicedee.guicedinjection.interfaces.IGuicePreStartup`
```
com.guicedee.module.spi.impl.DefaultModulePreStartup
```

## Lifecycle Management

### Startup Sequence

The GuicedInjection framework follows a specific startup sequence:

1. Load configuration
2. Initialize the scanner
3. Load pre-startup services
4. Execute pre-startup hooks
5. Build the Guice injector
6. Load post-startup services
7. Execute post-startup hooks

To hook into this sequence, implement one of the following interfaces:

- `IGuicePreStartup`: Executed before the Guice injector is built
- `IGuicePostStartup`: Executed after the Guice injector is built

Example:

```java
package com.guicedee.module.lifecycle;

import com.guicedee.guicedinjection.interfaces.IGuicePreStartup;

public class ModuleInitializer implements IGuicePreStartup<ModuleInitializer> {
    @Override
    public void onStartup() {
        // Initialize module resources
    }
}
```

### Shutdown Sequence

The GuicedInjection framework also provides a shutdown sequence:

1. Execute pre-destroy hooks
2. Destroy the Guice injector
3. Clean up resources

To hook into this sequence, implement the `IGuicePreDestroy` interface:

```java
package com.guicedee.module.lifecycle;

import com.guicedee.guicedinjection.interfaces.IGuicePreDestroy;

public class ModuleCleaner implements IGuicePreDestroy<ModuleCleaner> {
    @Override
    public void onDestroy() {
        // Clean up module resources
    }
}
```

## Integration with Vert.x

For more detailed guidelines on Vert.x package structure and best practices, please refer to the [GuicedVertx Package Structure Guidelines](guiced-vertx-rules.md).

### Vert.x Instance Management

In GuicedInjection, the Vert.x instance is implicitly loaded and managed by the framework. Clients and consumers of GuicedInjection never need to create the Vert.x instance directly, but instead use it through dependency injection or by accessing it via the `VertXPreStartup` class.

#### How Vert.x is Loaded

The Vert.x instance is initialized during the pre-startup phase by the `VertXPreStartup` class, which implements `IGuicePreStartup`. This class:

1. Creates a singleton Vert.x instance
2. Configures it based on annotations and SPI implementations
3. Registers event consumers
4. Makes the instance available throughout the application

```java
// The Vert.x instance is automatically initialized during startup
// You can access it directly from VertXPreStartup
Vertx vertx = VertXPreStartup.getVertx();
```

#### Configuring Vert.x

Vert.x configuration is handled through SPIs and annotations:

1. **Using Annotations**: Apply configuration annotations to classes in your application:
   - `@VertX`: Core Vert.x configuration
   - `@MetricsOptions`: Metrics configuration
   - `@FileSystemOptions`: File system configuration
   - `@EventBusOptions`: Event bus configuration
   - `@AddressResolverOptions`: DNS resolver configuration

2. **Using SPIs**: Implement the `VertxConfigurator` interface to provide custom configuration:

```java
public class CustomVertxConfigurator implements VertxConfigurator<CustomVertxConfigurator> {
    @Override
    public VertxBuilder builder(VertxBuilder builder) {
        // Apply custom configuration to the builder
        return builder.with(new VertxOptions().setWorkerPoolSize(50));
    }
}
```

#### Using Vert.x in Your Application

There are two main ways to use the Vert.x instance:

1. **Dependency Injection**:
```java
@Inject
private Vertx vertx;
```

2. **Direct Access**:
```java
Vertx vertx = VertXPreStartup.getVertx();
```

#### Execution Order and Dependencies

When working with Vert.x in GuicedInjection, follow these guidelines:

1. **Tasks Before Vert.x Boot**: If you need to perform tasks before Vert.x is initialized, implement `IGuicePreStartup` with a sort order less than `VertXPreStartup` (which has a sort order of `Integer.MIN_VALUE + 50`):

```java
public class BeforeVertxStartup implements IGuicePreStartup<BeforeVertxStartup> {
    @Override
    public void onStartup() {
        // Tasks to perform before Vert.x is initialized
    }

    @Override
    public Integer sortOrder() {
        return Integer.MIN_VALUE + 40; // Lower than VertXPreStartup
    }
}
```

2. **Tasks Requiring Vert.x**: If your pre-startup tasks need to use Vert.x, they should have a sort order higher than `VertXPreStartup`:

```java
public class AfterVertxStartup implements IGuicePreStartup<AfterVertxStartup> {
    @Override
    public void onStartup() {
        // Access Vert.x directly
        Vertx vertx = VertXPreStartup.getVertx();
        // Perform tasks with Vert.x
    }

    @Override
    public Integer sortOrder() {
        return Integer.MIN_VALUE + 60; // Higher than VertXPreStartup
    }
}
```

3. **Other Components**: For other components like post-startups and modules, use dependency injection to access the Vert.x instance:

```java
public class MyModule extends AbstractModule {
    @Inject
    private Vertx vertx;

    @Override
    protected void configure() {
        // Use injected Vert.x instance
    }
}
```

### Verticle Configuration

In GuicedInjection, declaring a verticle is completely optional and not required at all. By default, all activities will load into a default verticle with default configurations.

#### Default Behavior

When no classes are annotated with `@Verticle`, GuicedInjection automatically:

1. Creates a single "global" verticle that handles all functionality
2. Deploys it with default deployment options
3. Loads all registered `VerticleStartup` services
4. Uses a standard global worker pool

This default behavior ensures that your application works seamlessly without requiring explicit verticle configuration.

#### When to Specify Verticles

Verticles should only be specified when explicitly necessary, such as:

1. **Isolation Requirements**: When you need to isolate specific components or services
2. **Custom Threading Models**: When you need specific threading models for different parts of your application
3. **Resource Management**: When you need fine-grained control over worker pools and execution times
4. **High Availability**: When specific components need HA capabilities
5. **Specialized Capabilities**: When you need to limit certain verticles to specific capabilities

#### Using the @Verticle Annotation

When you do need to configure verticles explicitly, GuicedInjection provides the `@Verticle` annotation:

```java
@Verticle(
    threadingModel = ThreadingModel.VIRTUAL_THREAD,
    workerPoolName = "my-worker-pool",
    workerPoolSize = 10,
    capabilities = {Verticle.Capabilities.Rest, Verticle.Capabilities.Web}
)
public class MyVerticle extends AbstractVerticle {
    @Override
    public void start(Promise<Void> startPromise) {
        // Verticle initialization code
    }
}
```

The `@Verticle` annotation supports the following options:

- `threadingModel`: Specifies the threading model (EVENT_LOOP, WORKER, or VIRTUAL_THREAD)
- `defaultInstances`: Number of instances to deploy
- `ha`: Whether high availability is enabled
- `workerPoolName`: Name of the worker pool
- `workerPoolSize`: Size of the worker pool
- `maxWorkerExecuteTime`: Maximum time a worker thread can execute
- `maxWorkerExecuteTimeUnit`: Time unit for maxWorkerExecuteTime
- `capabilities`: Array of capabilities to enable

### Vert.x 5 Migration

When migrating from Vert.x 4 to Vert.x 5, follow these guidelines:

1. Use Future-based APIs instead of callback-based APIs
2. Replace RxJava2 with Mutiny for reactive programming
3. Replace CLI and OpenTracing with Picocli and OpenTelemetry
4. Upgrade HTTP/WebSocket clients to use builder-based patterns
5. Use `Vertx.builder()` to compose the runtime

Example:

```java
// Vert.x 4
Vertx vertx = Vertx.vertx();

// Vert.x 5
Vertx vertx = Vertx.builder().build();
```

## Common Use Cases

### Dependency Injection

GuicedInjection uses Google Guice for dependency injection. Here's how to use it:

```java
// Field injection (preferred approach)
@Inject
private MyService<MyService> service;

// Get an instance from the injector
MyService<MyService> service = GuiceContext.instance().inject(MyService.class);
```

### Service Discovery

GuicedInjection provides service discovery through the centralized SPI mechanism to help and support only one module exposure in module-info:

```java
// Get all implementations of an SPI interface
Set<MyService<MyService>> services = GuiceContext.instance()
    .getLoader(MyService.class, ServiceLoader.load(MyService.class));
```

### Configuration Management

GuicedInjection provides configuration for the classpath scanner and Guice context through the `GuiceConfig` class. Unlike what the name might suggest, it doesn't provide general application configuration management with properties or maps. Instead, it offers boolean flags to control scanning behavior:

```java
// Configure the classpath scanner
GuiceContext.instance().getConfig()
    .setFieldScanning(true)
    .setAnnotationScanning(true)
    .setVerbose(true);
```

### Job Management

GuicedInjection provides a powerful job management system through the `JobService` class, which allows you to create, schedule, and manage asynchronous jobs that run outside the EE context. This is particularly useful for background processing, periodic tasks, and long-running operations.

#### Job Service Overview

The `JobService` class is a singleton that manages thread pools and job execution. It implements `IGuicePreDestroy` to ensure proper cleanup during application shutdown and `IJobService` to provide the core job management functionality.

Key features of the job management system include:

1. **Job Pools**: Logical groupings of related jobs that share resources
2. **One-time Jobs**: Tasks that execute once and complete
3. **Polling Jobs**: Recurring tasks that execute at regular intervals
4. **Virtual Threads**: Utilizes Java's virtual threads for efficient execution
5. **Resource Management**: Automatically cleans up completed jobs and manages thread pools

#### Accessing the Job Service

You can access the `JobService` in two ways:

1. **Direct Access** to the singleton instance:
```java
JobService jobService = JobService.INSTANCE;
```

2. **Dependency Injection** using the `IJobService` interface:
```java
@Inject
private IJobService jobService;
```

#### Creating and Running Jobs

To create and run a one-time job:

```java
// Create a simple job
Runnable job = () -> {
    // Job logic here
    System.out.println("Executing one-time job");
};

// Add the job to a pool named "myJobPool"
jobService.addJob("myJobPool", job);
```

To create and run a recurring job:

```java
// Create a recurring job
Runnable pollingJob = () -> {
    // Job logic here
    System.out.println("Executing recurring job");
};

// Schedule the job to run every 5 minutes
jobService.addPollingJob("myPollingPool", pollingJob, 5, TimeUnit.MINUTES);
```

For jobs that need to return a result:

```java
// Create a callable job
Callable<String> callableJob = () -> {
    // Job logic here
    return "Job completed successfully";
};

// Submit the job and get a Future for the result
Future<String> future = jobService.addTask("myJobPool", callableJob);

// Get the result (blocks until the job completes)
String result = future.get();
```

#### Managing Job Pools

You can customize job pools for specific requirements:

```java
// Create a custom thread pool
ExecutorService customPool = Executors.newVirtualThreadPerTaskExecutor();

// Register the custom pool
jobService.registerJobPool("customJobPool", customPool);

// Set the maximum queue size for a pool
jobService.setMaxQueueCount("customJobPool", 50);
```

#### Waiting for Jobs to Complete

When you need to wait for jobs to complete:

```java
// Wait for all jobs in a pool to complete (with default timeout)
jobService.waitForJob("myJobPool");

// Wait with a custom timeout
jobService.waitForJob("myJobPool", 30, TimeUnit.SECONDS);
```

#### Cleaning Up Resources

The `JobService` automatically cleans up resources during application shutdown, but you can also manually clean up:

```java
// Remove a job pool and wait for its jobs to complete
jobService.removeJob("myJobPool");

// Remove a polling job
jobService.removePollingJob("myPollingPool");
```

#### Best Practices for Job Management

1. **Use Descriptive Pool Names**: Choose meaningful names for job pools to make debugging easier
2. **Limit Job Execution Time**: Keep jobs short-running when possible to avoid blocking resources
3. **Handle Exceptions**: Always handle exceptions within jobs to prevent silent failures
4. **Use Virtual Threads**: Leverage virtual threads for I/O-bound operations
5. **Clean Up Resources**: Remove job pools when they're no longer needed
6. **Monitor Job Queues**: Set appropriate queue sizes to prevent memory issues
7. **Use Timeouts**: Always specify timeouts when waiting for jobs to complete

## Best Practices

1. **Follow the Single Responsibility Principle**: Each class should have a single responsibility
2. **Use Field Injection**: Prefer field injection over constructor injection for better encapsulation
3. **Keep Services Stateless**: Services should be stateless when possible to avoid concurrency issues
4. **Use Interfaces**: Define interfaces for services to promote loose coupling
5. **Document Your Code**: Use Javadoc to document your code, especially SPI interfaces
6. **Use Appropriate Scopes**: Use the appropriate Guice scope for your services (Singleton, RequestScoped, etc.)
7. **Avoid Circular Dependencies**: Design your services to avoid circular dependencies
8. **Use Proper Exception Handling**: Handle exceptions appropriately and provide meaningful error messages
9. **Write Unit Tests**: Write unit tests for your services to ensure they work as expected
10. **Follow Naming Conventions**: Use consistent naming conventions for classes, methods, and packages

## Testing with Guice

### Overriding Bindings in Tests

When writing tests, you may need to override Guice bindings to use test implementations instead of production ones. In GuicedInjection, this is typically done using the META-INF/services mechanism:

1. Create your test implementation of an interface
2. Register it in a META-INF/services file in your test resources directory
3. The test implementation will be discovered and used during testing

Example:

```java
// Test implementation
public class MockUserService implements UserService {
    @Override
    public User getCurrentUser() {
        return new User("test-user");
    }
}
```

File: `src/test/resources/META-INF/services/com.example.UserService`
```
com.example.test.MockUserService
```

This approach allows you to override bindings without modifying your production code.

## Troubleshooting

### Common Issues

1. **Service Not Found**: Ensure your service is properly registered in `module-info.java` and `META-INF/services`
2. **Circular Dependency**: Restructure your code to break the circular dependency
3. **ClassNotFoundException**: Ensure the class is in the classpath and the module is properly declared
4. **NoClassDefFoundError**: Check for missing dependencies or version conflicts
5. **IllegalStateException**: Check for improper initialization or usage of services

### Debugging Tips

1. Enable debug logging to see more detailed information:

```
System.setProperty("guicedee.debug", "true");
```

2. Use the `getScanResult()` method to inspect the classpath:

```
ScanResult scanResult = GuiceContext.instance().getScanResult();
ClassInfoList classes = scanResult.getClassesImplementing("com.guicedee.module.spi.MyService");
```

3. Check the Guice injector for binding errors:

```
try {
    Injector injector = GuiceContext.instance().inject();
} catch (CreationException e) {
    e.getErrorMessages().forEach(System.err::println);
}
```
