# GuicedVertxWeb Package Structure Guidelines

This document outlines the recommended package structure and usage guidelines for the GuicedVertxWeb module, designed to provide a robust HTTP/HTTPS server implementation using Vert.x Web.

## Table of Contents

1. [Overview](#overview)
2. [Package Structure](#package-structure)
3. [SPI Implementation](#spi-implementation)
   - [Creating SPI Interfaces](#creating-spi-interfaces)
   - [Implementing SPI Interfaces](#implementing-spi-interfaces)
   - [Registering SPI Implementations](#registering-spi-implementations)
4. [Module Configuration](#module-configuration)
   - [module-info.java](#module-infojava)
   - [Transitive Dependencies](#transitive-dependencies)
   - [META-INF/services](#meta-infservices)
5. [Lifecycle Management](#lifecycle-management)
   - [Startup Sequence](#startup-sequence)
   - [Shutdown Sequence](#shutdown-sequence)
6. [HTTP/HTTPS Server Configuration](#httphttps-server-configuration)
   - [Default Configuration](#default-configuration)
   - [Environment Variables](#environment-variables)
   - [SSL/TLS Configuration](#ssltls-configuration)
7. [Router Configuration](#router-configuration)
   - [Default Router Setup](#default-router-setup)
   - [Adding Routes](#adding-routes)
   - [Request Handling](#request-handling)
8. [Common Use Cases](#common-use-cases)
   - [REST API Implementation](#rest-api-implementation)
   - [Static Content Serving](#static-content-serving)
   - [WebSocket Support](#websocket-support)
   - [File Uploads](#file-uploads)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

## Overview

GuicedVertxWeb is a module that provides HTTP/HTTPS server capabilities for GuicedEE applications using Vert.x Web. It integrates with the GuicedInjection framework to provide dependency injection and lifecycle management for web server components.

The module automatically sets up and configures an HTTP and/or HTTPS server based on environment variables, and provides extension points through SPI interfaces to customize the server, server options, and router.

## Package Structure

The GuicedVertxWeb module follows a modular package structure that separates concerns and promotes maintainability. Here's the recommended package structure:

```
com.guicedee.vertx.web
├── core                  # Core web server components
│   └── WebServerModule.java  # Guice module for web server
├── spi                   # Service Provider Interfaces
│   ├── VertxHttpServerConfigurator.java        # SPI for HTTP server configuration
│   ├── VertxHttpServerOptionsConfigurator.java # SPI for HTTP server options
│   └── VertxRouterConfigurator.java            # SPI for router configuration
├── handlers              # Request handlers
│   ├── DefaultErrorHandler.java  # Default error handler
│   └── SecurityHandler.java      # Security-related handlers
├── routes                # Route definitions
│   ├── ApiRoutes.java    # API route definitions
│   └── StaticRoutes.java # Static content route definitions
└── util                  # Utility classes
```

## SPI Implementation

### Creating SPI Interfaces

GuicedVertxWeb provides three main SPI interfaces for extending and customizing the web server:

1. **VertxHttpServerOptionsConfigurator**: Customizes the HttpServerOptions before the server is created
2. **VertxHttpServerConfigurator**: Customizes the HttpServer after it's created but before it starts listening
3. **VertxRouterConfigurator**: Customizes the Router before it's set as the request handler

These interfaces follow a consistent pattern and provide extension points at different stages of the web server initialization process.

Example:

```java
package com.guicedee.vertx.web.spi;

import io.vertx.ext.web.Router;

@FunctionalInterface
public interface VertxRouterConfigurator
{
    Router builder(Router builder);
}
```

### Implementing SPI Interfaces

Implementations of these SPI interfaces should follow these guidelines:

1. Place implementations in a separate package or module
2. Name implementations clearly, typically ending with "Impl" or a descriptive term
3. Implement only the methods defined in the interface
4. Use field injection for dependencies to maintain proper encapsulation
5. Keep implementations stateless when possible

Example implementation of VertxRouterConfigurator:

```java
package com.example.web.routes;

import com.guicedee.vertx.web.spi.VertxRouterConfigurator;
import io.vertx.ext.web.Router;

public class ApiRoutesConfigurator implements VertxRouterConfigurator
{
    @Override
    public Router builder(Router router)
    {
        // Add API routes
        router.get("/api/users").handler(this::handleGetUsers);
        router.post("/api/users").handler(this::handleCreateUser);

        return router;
    }

    private void handleGetUsers(io.vertx.ext.web.RoutingContext ctx)
    {
        // Handle GET /api/users request
        ctx.response()
           .putHeader("content-type", "application/json")
           .end("[{\"id\":1,\"name\":\"User 1\"},{\"id\":2,\"name\":\"User 2\"}]");
    }

    private void handleCreateUser(io.vertx.ext.web.RoutingContext ctx)
    {
        // Handle POST /api/users request
        ctx.response()
           .putHeader("content-type", "application/json")
           .end("{\"id\":3,\"name\":\"New User\"}");
    }
}
```

### Registering SPI Implementations

SPI implementations can be registered using both the Java Module System and the META-INF/services mechanism:

#### Using the Java Module System:

In your `module-info.java` file:

```java
module com.example.web {
    requires com.guicedee.vertx.web;

    provides com.guicedee.vertx.web.spi.VertxRouterConfigurator 
        with com.example.web.routes.ApiRoutesConfigurator;
}
```

#### Using META-INF/services:

Create a file at `META-INF/services/com.guicedee.vertx.web.spi.VertxRouterConfigurator` with the content:

```
com.example.web.routes.ApiRoutesConfigurator
```

## Module Configuration

### module-info.java

The `module-info.java` file for a module that uses GuicedVertxWeb should follow these guidelines:

1. Require the GuicedVertxWeb module
2. Use the SPI interfaces provided by GuicedVertxWeb
3. Provide implementations of the SPI interfaces as needed
4. **Do not** specify `uses com.guicedee.guicedinjection.interfaces.IGuiceModule` as this is already handled by the GuicedInjection library

Example:

```java
module com.example.web {
    requires com.guicedee.vertx.web;

    uses com.guicedee.vertx.web.spi.VertxRouterConfigurator;

    provides com.guicedee.vertx.web.spi.VertxRouterConfigurator 
        with com.example.web.routes.ApiRoutesConfigurator;

    // Do NOT include this line:
    // uses com.guicedee.guicedinjection.interfaces.IGuiceModule;
}
```

> **Important Note**: The GuicedInjection library already includes `uses com.guicedee.guicedinjection.interfaces.IGuiceModule` in its module-info.java file. Since your module will require GuicedInjection (directly or transitively), you should not specify this "uses" directive in your own module-info.java file. The GuicedInjection library will automatically discover and load all IGuiceModule implementations.

### Transitive Dependencies

GuicedVertxWeb includes several transitive dependencies that are automatically available to modules that depend on it. This means you don't need to explicitly declare these dependencies in your module-info.java file.

The following modules are transitive dependencies of GuicedVertxWeb:

```java
// Transitive dependencies in GuicedVertxWeb
requires transitive com.guicedee.vertx;
requires transitive io.vertx.web;
requires transitive io.vertx.core;
```

When you include `requires com.guicedee.vertx.web` in your module-info.java file, these dependencies are automatically available to your module without needing to declare them explicitly.

#### Recommendation for Java Clients

When creating Java modules that use GuicedVertxWeb and want to expose its functionality to their own consumers, it is recommended to use `requires transitive` instead of just `requires`:

```java
// Recommended approach for modules that expose GuicedVertxWeb functionality
requires transitive com.guicedee.vertx.web;
```

This ensures that your module's consumers will also have access to GuicedVertxWeb and its transitive dependencies without having to explicitly require them.

### META-INF/services

The META-INF/services mechanism can be used alongside or instead of the Java Module System for registering SPI implementations. Follow these guidelines:

1. Create a file in the `META-INF/services` directory with the fully qualified name of the SPI interface
2. Add the fully qualified name of each implementation on a separate line
3. Ensure the file is included in your JAR file

Example:

File: `META-INF/services/com.guicedee.vertx.web.spi.VertxRouterConfigurator`
```
com.example.web.routes.ApiRoutesConfigurator
```

## Lifecycle Management

### Startup Sequence

The GuicedVertxWeb module integrates with the GuicedInjection lifecycle management system. The web server is started during the post-startup phase by the `VertxWebServerPostStartup` class, which implements `IGuicePostStartup`.

The startup sequence is as follows:

1. The core GuicedInjection framework initializes
2. The Vert.x instance is created and configured during the pre-startup phase
3. The `VertxWebServerPostStartup` service is executed as part of the post-startup phase
4. HTTP/HTTPS server options are configured
5. HTTP and/or HTTPS servers are created based on environment variables
6. Server configurators are applied
7. The router is created and configured
8. Router configurators are applied
9. The router is set as the request handler for all servers
10. The servers start listening on the configured ports

### Shutdown Sequence

The shutdown sequence is handled by the GuicedInjection framework. The Vert.x instance, including the HTTP/HTTPS servers, is closed during the pre-destroy phase.

## HTTP/HTTPS Server Configuration

### Default Configuration

By default, GuicedVertxWeb configures the HTTP server with the following options:

- Compression enabled with level 9
- TCP keep-alive enabled
- Maximum header size: 65536 bytes
- Maximum chunk size: 65536 bytes
- Maximum form attribute size: 65536 bytes
- Maximum form fields: unlimited (-1)

These default settings can be customized by implementing the `VertxHttpServerOptionsConfigurator` interface.

### Environment Variables

GuicedVertxWeb uses the following environment variables to configure the HTTP/HTTPS server:

- `HTTP_ENABLED`: Whether to enable the HTTP server (default: `true`)
- `HTTP_PORT`: The port for the HTTP server (default: `8080`)
- `HTTPS_ENABLED`: Whether to enable the HTTPS server (default: `false`)
- `HTTPS_PORT`: The port for the HTTPS server (default: `443`)
- `HTTPS_KEYSTORE`: The path to the keystore file for SSL/TLS
- `HTTPS_KEYSTORE_PASSWORD`: The password for the keystore

Example:

```
HTTP_ENABLED=true
HTTP_PORT=8080
HTTPS_ENABLED=true
HTTPS_PORT=8443
HTTPS_KEYSTORE=keystore.jks
HTTPS_KEYSTORE_PASSWORD=changeit
```

### SSL/TLS Configuration

GuicedVertxWeb supports both JKS and PKCS#12 (PFX) keystores for SSL/TLS configuration. The keystore type is determined by the file extension of the `HTTPS_KEYSTORE` environment variable:

- `.jks`: JKS keystore
- `.pfx`, `.p12`, `.p8`: PKCS#12 keystore

Example JKS configuration:

```java
serverOptions
    .setKeyCertOptions(new JksOptions()
        .setPassword(Environment.getSystemPropertyOrEnvironment("HTTPS_KEYSTORE_PASSWORD", "changeit"))
        .setPath(Environment.getSystemPropertyOrEnvironment("HTTPS_KEYSTORE", "keystore.jks")));
```

Example PKCS#12 configuration:

```java
serverOptions
    .setKeyCertOptions(new PfxOptions()
        .setPassword(Environment.getSystemPropertyOrEnvironment("HTTPS_KEYSTORE_PASSWORD", ""))
        .setPath(Environment.getSystemPropertyOrEnvironment("HTTPS_KEYSTORE", "keystore.pfx")));
```

## Router Configuration

### Default Router Setup

GuicedVertxWeb creates a default Router with the following configuration:

- BodyHandler configured to handle request bodies
- Uploads directory set to "uploads"
- Uploaded files are automatically deleted when the request ends

```java
Router router = Router.router(vertx);
router.route().handler(BodyHandler.create().setUploadsDirectory("uploads").setDeleteUploadedFilesOnEnd(true));
```

### Adding Routes

Routes can be added to the router by implementing the `VertxRouterConfigurator` interface. This interface allows you to add route handlers for different HTTP methods and paths.

Example:

```java
public class ApiRoutesConfigurator implements VertxRouterConfigurator
{
    @Override
    public Router builder(Router router)
    {
        // Add API routes
        router.get("/api/users").handler(this::handleGetUsers);
        router.post("/api/users").handler(this::handleCreateUser);

        return router;
    }

    // Handler methods...
}
```

### Request Handling

Request handling in GuicedVertxWeb follows the Vert.x Web approach, using the `RoutingContext` to access request information and send responses.

Example:

```java
private void handleGetUsers(io.vertx.ext.web.RoutingContext ctx)
{
    // Access request parameters
    String limit = ctx.request().getParam("limit");

    // Send JSON response
    ctx.response()
       .putHeader("content-type", "application/json")
       .end("[{\"id\":1,\"name\":\"User 1\"},{\"id\":2,\"name\":\"User 2\"}]");
}
```

## Common Use Cases

### REST API Implementation

GuicedVertxWeb is well-suited for implementing REST APIs. Here's an example of a simple REST API implementation:

```java
public class UserApiConfigurator implements VertxRouterConfigurator
{
    @Inject
    private UserService userService;

    @Override
    public Router builder(Router router)
    {
        // Define API routes
        router.get("/api/users").handler(this::handleGetUsers);
        router.get("/api/users/:id").handler(this::handleGetUser);
        router.post("/api/users").handler(this::handleCreateUser);
        router.put("/api/users/:id").handler(this::handleUpdateUser);
        router.delete("/api/users/:id").handler(this::handleDeleteUser);

        return router;
    }

    private void handleGetUsers(RoutingContext ctx)
    {
        List<User> users = userService.getAllUsers();
        ctx.response()
           .putHeader("content-type", "application/json")
           .end(Json.encode(users));
    }

    // Other handler methods...
}
```

### Static Content Serving

GuicedVertxWeb can serve static content using the `StaticHandler` from Vert.x Web:

```java
public class StaticContentConfigurator implements VertxRouterConfigurator
{
    @Override
    public Router builder(Router router)
    {
        // Serve static content from the "webroot" directory
        router.route("/static/*").handler(StaticHandler.create("webroot"));

        return router;
    }
}
```

### WebSocket Support

GuicedVertxWeb supports WebSockets through the Vert.x WebSocket API:

```java
public class WebSocketConfigurator implements VertxHttpServerConfigurator
{
    @Override
    public HttpServer builder(HttpServer server)
    {
        server.webSocketHandler(ws -> {
            // Handle WebSocket connection
            ws.textMessageHandler(message -> {
                // Handle incoming message
                ws.writeTextMessage("Echo: " + message);
            });
        });

        return server;
    }
}
```

### File Uploads

GuicedVertxWeb supports file uploads through the BodyHandler:

```java
public class FileUploadConfigurator implements VertxRouterConfigurator
{
    @Override
    public Router builder(Router router)
    {
        // Configure file upload route
        router.post("/upload").handler(this::handleFileUpload);

        return router;
    }

    private void handleFileUpload(RoutingContext ctx)
    {
        // Access uploaded files
        Set<FileUpload> uploads = ctx.fileUploads();

        // Process uploads
        for (FileUpload upload : uploads)
        {
            String fileName = upload.fileName();
            String uploadedFileName = upload.uploadedFileName();
            String contentType = upload.contentType();

            // Process the uploaded file
        }

        // Send response
        ctx.response()
           .putHeader("content-type", "application/json")
           .end("{\"status\":\"success\",\"message\":\"Files uploaded successfully\"}");
    }
}
```

## Best Practices

1. **Use SPI Interfaces for Extension**: Use the provided SPI interfaces to extend and customize the web server rather than modifying the core classes.

2. **Organize Routes by Functionality**: Group related routes together in separate `VertxRouterConfigurator` implementations to maintain a clean and organized codebase.

3. **Use Dependency Injection**: Leverage Guice dependency injection to inject services and other dependencies into your route handlers.

4. **Handle Errors Properly**: Implement proper error handling in your route handlers to provide meaningful error responses to clients.

5. **Use Asynchronous APIs**: Leverage Vert.x's asynchronous APIs to handle requests efficiently without blocking threads.

6. **Configure SSL/TLS Properly**: When using HTTPS, ensure that your SSL/TLS configuration is secure and up-to-date.

7. **Validate Input**: Always validate and sanitize input from clients to prevent security vulnerabilities.

8. **Use Content-Type Headers**: Set appropriate Content-Type headers in your responses to ensure clients interpret the data correctly.

9. **Implement CORS When Needed**: If your API will be accessed from web browsers on different domains, implement CORS (Cross-Origin Resource Sharing) support.

10. **Monitor Performance**: Monitor the performance of your web server and optimize as needed.

## Troubleshooting

### Common Issues

1. **Server Won't Start**: Check that the specified ports are available and not in use by other applications.

2. **SSL/TLS Configuration Issues**: Verify that the keystore file exists and the password is correct.

3. **Route Not Matching**: Check the path pattern and HTTP method of your route definitions.

4. **Request Body Not Available**: Ensure that the BodyHandler is configured correctly and applied to the appropriate routes.

5. **CORS Issues**: If clients are experiencing CORS errors, configure a CorsHandler with the appropriate settings.

### Debugging Tips

1. Enable debug logging to see more detailed information:

```
System.setProperty("vertx.logger-delegate-factory-class-name", "io.vertx.core.logging.Log4j2LogDelegateFactory");
System.setProperty("vertx.log-delegate-factory-class-name", "io.vertx.core.logging.Log4j2LogDelegateFactory");
```

2. Use the `VertxHttpServerOptionsConfigurator` to enable additional debugging options:

```java
public class DebugServerOptionsConfigurator implements VertxHttpServerOptionsConfigurator
{
    @Override
    public HttpServerOptions builder(HttpServerOptions options)
    {
        // Enable additional debugging
        options.setLogActivity(true);
        return options;
    }
}
```

3. Add logging to your route handlers to track request processing:

```java
private void handleGetUsers(RoutingContext ctx)
{
    log.debug("Handling GET /api/users request");

    // Process request

    log.debug("Completed GET /api/users request");
}
```

4. Check the Vert.x metrics if enabled:

```java
public class MetricsServerOptionsConfigurator implements VertxHttpServerOptionsConfigurator
{
    @Override
    public HttpServerOptions builder(HttpServerOptions options)
    {
        // Enable metrics
        options.setMetricsEnabled(true);
        return options;
    }
}
```
