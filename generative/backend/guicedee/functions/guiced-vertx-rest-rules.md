# GuicedVertxRest Package Structure Guidelines

This document outlines the recommended package structure and usage guidelines for the GuicedVertxRest module, designed to provide Jakarta WS (JAX-RS) REST capabilities for GuicedEE applications using Vert.x.

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
6. [REST Configuration](#rest-configuration)
   - [Default Configuration](#default-configuration)
   - [Environment Variables](#environment-variables)
   - [SSL/TLS Configuration](#ssltls-configuration)
7. [Common Use Cases](#common-use-cases)
   - [Creating REST Resources](#creating-rest-resources)
   - [Path Parameters](#path-parameters)
   - [Query Parameters](#query-parameters)
   - [Request Body](#request-body)
   - [Response Handling](#response-handling)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

## Overview

GuicedVertxRest is a module that provides Jakarta WS (JAX-RS) REST capabilities for GuicedEE applications using Vert.x. It integrates with the GuicedInjection framework to provide dependency injection and lifecycle management for REST resources.

The module automatically scans for classes with Jakarta WS annotations, registers them with the Vert.x router, and handles requests by extracting parameters, invoking the appropriate methods, and processing responses. It supports standard JAX-RS annotations such as @Path, @GET, @POST, etc., making it easy to create RESTful APIs using familiar Jakarta WS patterns while leveraging the performance and scalability of Vert.x.

## Package Structure

The GuicedVertxRest module follows a modular package structure that separates concerns and promotes maintainability. Here's the recommended package structure:

```
com.guicedee.guicedservlets.rest
├── implementations           # Implementation classes
│   ├── RestModule.java       # Guice module for REST
│   ├── GuicedRestHttpServerConfigurator.java  # HTTP server configurator
│   └── RestServiceScannerConfig.java  # Scanner configuration
├── pathing                   # Path handling classes
│   ├── JakartaWsScanner.java  # Scanner for Jakarta WS annotations
│   ├── OperationRegistry.java  # Registry for REST operations
│   ├── PathHandler.java       # Handler for path parameters
│   └── HttpMethodHandler.java  # Handler for HTTP methods
├── services                  # Service interfaces and implementations
│   ├── RestInterceptor.java   # Interface for REST interceptors
│   ├── GuicedRestPreStartup.java  # Pre-startup hook
│   └── GuiceRestInjectionProvider.java  # Injection provider
└── util                      # Utility classes
```

## SPI Implementation

### Creating SPI Interfaces

GuicedVertxRest provides several SPI interfaces for extending and customizing the REST functionality:

1. **RestInterceptor**: Intercepts REST requests before and after processing
2. **VertxRouterConfigurator**: Configures the Vert.x router for REST endpoints
3. **VertxHttpServerConfigurator**: Configures the HTTP server for REST
4. **VertxHttpServerOptionsConfigurator**: Configures the HTTP server options for REST

These interfaces follow a consistent pattern and provide extension points at different stages of the REST request lifecycle.

Example:

```java
package com.guicedee.guicedservlets.rest.services;

import io.vertx.core.Future;

public interface RestInterceptor
{
    Future<Boolean> onStart();
    Future<Boolean> onEnd();
}
```

### Implementing SPI Interfaces

Implementations of these SPI interfaces should follow these guidelines:

1. Place implementations in a separate package or module
2. Name implementations clearly, typically ending with "Impl" or a descriptive term
3. Implement only the methods defined in the interface
4. Use field injection for dependencies to maintain proper encapsulation
5. Keep implementations stateless when possible

Example implementation of RestInterceptor:

```java
package com.example.rest.interceptors;

import com.guicedee.guicedservlets.rest.services.RestInterceptor;
import io.vertx.core.Future;

public class LoggingInterceptor implements RestInterceptor
{
    @Override
    public Future<Boolean> onStart()
    {
        // Log the start of the request
        System.out.println("Request started");
        return Future.succeededFuture(true);
    }

    @Override
    public Future<Boolean> onEnd()
    {
        // Log the end of the request
        System.out.println("Request ended");
        return Future.succeededFuture(true);
    }
}
```

### Registering SPI Implementations

SPI implementations can be registered using both the Java Module System and the META-INF/services mechanism:

#### Using the Java Module System:

In your `module-info.java` file:

```java
module com.example.rest {
    requires com.guicedee.rest;

    provides com.guicedee.guicedservlets.rest.services.RestInterceptor 
        with com.example.rest.interceptors.LoggingInterceptor;
}
```

#### Using META-INF/services:

Create a file at `META-INF/services/com.guicedee.guicedservlets.rest.services.RestInterceptor` with the content:

```
com.example.rest.interceptors.LoggingInterceptor
```

## Module Configuration

### module-info.java

The `module-info.java` file for a module that uses GuicedVertxRest should follow these guidelines:

1. Require the GuicedVertxRest module
2. Use the SPI interfaces provided by GuicedVertxRest
3. Provide implementations of the SPI interfaces as needed
4. **Do not** specify `uses com.guicedee.guicedinjection.interfaces.IGuiceModule` as this is already handled by the GuicedInjection library

Example:

```java
module com.example.rest {
    requires com.guicedee.rest;

    uses com.guicedee.guicedservlets.rest.services.RestInterceptor;
    uses com.guicedee.vertx.web.spi.VertxRouterConfigurator;

    provides com.guicedee.guicedservlets.rest.services.RestInterceptor 
        with com.example.rest.interceptors.LoggingInterceptor;

    // Do NOT include this line:
    // uses com.guicedee.guicedinjection.interfaces.IGuiceModule;
}
```

> **Important Note**: The GuicedInjection library already includes `uses com.guicedee.guicedinjection.interfaces.IGuiceModule` in its module-info.java file. Since your module will require GuicedInjection (directly or transitively), you should not specify this "uses" directive in your own module-info.java file. The GuicedInjection library will automatically discover and load all IGuiceModule implementations.

### Transitive Dependencies

GuicedVertxRest includes several transitive dependencies that are automatically available to modules that depend on it. This means you don't need to explicitly declare these dependencies in your module-info.java file.

The following modules are transitive dependencies of GuicedVertxRest:

```java
// Transitive dependencies in GuicedVertxRest
requires transitive com.guicedee.vertx.web;
requires transitive io.vertx.auth.common;
requires transitive jakarta.ws.rs;
```

When you include `requires com.guicedee.rest` in your module-info.java file, these dependencies are automatically available to your module without needing to declare them explicitly.

#### Recommendation for Java Clients

When creating Java modules that use GuicedVertxRest and want to expose its functionality to their own consumers, it is recommended to use `requires transitive` instead of just `requires`:

```java
// Recommended approach for modules that expose GuicedVertxRest functionality
requires transitive com.guicedee.rest;
```

This ensures that your module's consumers will also have access to GuicedVertxRest and its transitive dependencies without having to explicitly require them.

### META-INF/services

The META-INF/services mechanism can be used alongside or instead of the Java Module System for registering SPI implementations. Follow these guidelines:

1. Create a file in the `META-INF/services` directory with the fully qualified name of the SPI interface
2. Add the fully qualified name of each implementation on a separate line
3. Ensure the file is included in your JAR file

Example:

File: `META-INF/services/com.guicedee.guicedservlets.rest.services.RestInterceptor`
```
com.example.rest.interceptors.LoggingInterceptor
```

## Lifecycle Management

### Startup Sequence

The GuicedVertxRest module integrates with the GuicedInjection lifecycle management system. The REST functionality is initialized during the verticle startup phase by the `GuicedRestHttpServerConfigurator` class, which implements `VerticleStartup`.

The startup sequence is as follows:

1. The core GuicedInjection framework initializes
2. The Vert.x instance is created and configured during the pre-startup phase
3. The `GuicedRestPreStartup` service is executed as part of the pre-startup phase
4. The verticle is deployed and the `GuicedRestHttpServerConfigurator` is executed
5. HTTP/HTTPS server options are configured
6. HTTP and/or HTTPS servers are created based on environment variables
7. Server configurators are applied
8. The router is created and configured
9. Router configurators are applied, including the `OperationRegistry` which scans for and registers REST resources
10. The router is set as the request handler for all servers
11. The servers start listening on the configured ports

### Shutdown Sequence

The shutdown sequence is handled by the GuicedInjection framework. The Vert.x instance, including the HTTP/HTTPS servers, is closed during the pre-destroy phase.

## REST Configuration

### Default Configuration

By default, GuicedVertxRest configures the HTTP server with the following options:

- Compression enabled with level 9
- TCP keep-alive enabled
- Maximum header size: 65536 bytes
- Maximum chunk size: 65536 bytes
- Maximum form attribute size: 65536 bytes
- Maximum form fields: unlimited (-1)

These default settings can be customized by implementing the `VertxHttpServerOptionsConfigurator` interface.

### Environment Variables

GuicedVertxRest uses the following environment variables to configure the HTTP/HTTPS server:

- `REST_HTTP_ENABLED`: Whether to enable the HTTP server (default: `true`)
- `REST_HTTP_PORT`: The port for the HTTP server (default: `8080`)
- `REST_HTTPS_ENABLED`: Whether to enable the HTTPS server (default: `false`)
- `REST_HTTPS_PORT`: The port for the HTTPS server (default: `443`)
- `REST_HTTPS_KEYSTORE`: The path to the keystore file for SSL/TLS
- `REST_HTTPS_KEYSTORE_PASSWORD`: The password for the keystore

Example:

```
REST_HTTP_ENABLED=true
REST_HTTP_PORT=8080
REST_HTTPS_ENABLED=true
REST_HTTPS_PORT=8443
REST_HTTPS_KEYSTORE=keystore.jks
REST_HTTPS_KEYSTORE_PASSWORD=changeit
```

### SSL/TLS Configuration

GuicedVertxRest supports both JKS and PKCS#12 (PFX) keystores for SSL/TLS configuration. The keystore type is determined by the file extension of the `REST_HTTPS_KEYSTORE` environment variable:

- `.jks`: JKS keystore
- `.pfx`, `.p12`, `.p8`: PKCS#12 keystore

Example JKS configuration:

```java
httpsOptions.setKeyCertOptions(new JksOptions()
    .setPassword(Environment.getSystemPropertyOrEnvironment("REST_HTTPS_KEYSTORE_PASSWORD", "changeit"))
    .setPath(Environment.getSystemPropertyOrEnvironment("REST_HTTPS_KEYSTORE", "keystore.jks")));
```

Example PKCS#12 configuration:

```java
httpsOptions.setKeyCertOptions(new PfxOptions()
    .setPassword(Environment.getSystemPropertyOrEnvironment("REST_HTTPS_KEYSTORE_PASSWORD", ""))
    .setPath(Environment.getSystemPropertyOrEnvironment("REST_HTTPS_KEYSTORE", "keystore.pfx")));
```

## Common Use Cases

### Creating REST Resources

To create a REST resource, create a class with Jakarta WS annotations:

```java
package com.example.rest.resources;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;

@Path("/users")
public class UserResource
{
    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public List<User> getUsers()
    {
        // Return a list of users
        return userService.getAllUsers();
    }

    @GET
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    public User getUser(@PathParam("id") Long id)
    {
        // Return a user by ID
        return userService.getUserById(id);
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public User createUser(User user)
    {
        // Create a new user
        return userService.createUser(user);
    }

    @PUT
    @Path("/{id}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public User updateUser(@PathParam("id") Long id, User user)
    {
        // Update an existing user
        return userService.updateUser(id, user);
    }

    @DELETE
    @Path("/{id}")
    public void deleteUser(@PathParam("id") Long id)
    {
        // Delete a user
        userService.deleteUser(id);
    }
}
```

### Path Parameters

Path parameters are defined using the `@Path` annotation with a parameter placeholder and extracted using the `@PathParam` annotation:

```java
@GET
@Path("/{id}")
@Produces(MediaType.APPLICATION_JSON)
public User getUser(@PathParam("id") Long id)
{
    // Return a user by ID
    return userService.getUserById(id);
}
```

### Query Parameters

Query parameters are extracted using the `@QueryParam` annotation:

```java
@GET
@Produces(MediaType.APPLICATION_JSON)
public List<User> getUsers(
    @QueryParam("page") @DefaultValue("1") int page,
    @QueryParam("size") @DefaultValue("10") int size)
{
    // Return a paginated list of users
    return userService.getUsers(page, size);
}
```

### Request Body

Request bodies are automatically deserialized to the parameter type:

```java
@POST
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public User createUser(User user)
{
    // Create a new user
    return userService.createUser(user);
}
```

### Response Handling

Responses are automatically serialized from the return value:

```java
@GET
@Produces(MediaType.APPLICATION_JSON)
public List<User> getUsers()
{
    // Return a list of users
    return userService.getAllUsers();
}
```

For more control over the response, use the `Response` class:

```java
@POST
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public Response createUser(User user)
{
    User createdUser = userService.createUser(user);
    return Response.status(Response.Status.CREATED)
                  .entity(createdUser)
                  .build();
}
```

## Best Practices

1. **Use Standard Jakarta WS Annotations**: Use standard Jakarta WS annotations like `@Path`, `@GET`, `@POST`, etc., to define your REST resources and endpoints.

2. **Organize Resources by Functionality**: Group related endpoints together in the same resource class to maintain a clean and organized codebase.

3. **Use Dependency Injection**: Leverage Guice dependency injection to inject services and other dependencies into your resource classes.

4. **Handle Errors Properly**: Implement proper error handling in your resource methods to provide meaningful error responses to clients.

5. **Use Asynchronous APIs**: Leverage Vert.x's asynchronous APIs to handle requests efficiently without blocking threads.

6. **Configure SSL/TLS Properly**: When using HTTPS, ensure that your SSL/TLS configuration is secure and up-to-date.

7. **Validate Input**: Always validate and sanitize input from clients to prevent security vulnerabilities.

8. **Use Content-Type Headers**: Set appropriate Content-Type headers in your responses to ensure clients interpret the data correctly.

9. **Implement CORS When Needed**: If your API will be accessed from web browsers on different domains, implement CORS (Cross-Origin Resource Sharing) support.

10. **Monitor Performance**: Monitor the performance of your REST API and optimize as needed.

## Troubleshooting

### Common Issues

1. **Server Won't Start**: Check that the specified ports are available and not in use by other applications.

2. **SSL/TLS Configuration Issues**: Verify that the keystore file exists and the password is correct.

3. **Route Not Matching**: Check the path pattern and HTTP method of your resource methods.

4. **Request Body Not Available**: Ensure that the BodyHandler is configured correctly and applied to the appropriate routes.

5. **CORS Issues**: If clients are experiencing CORS errors, configure a CorsHandler with the appropriate settings.

### Debugging Tips

1. Enable debug logging to see more detailed information:

```java
System.setProperty("vertx.logger-delegate-factory-class-name", "io.vertx.core.logging.Log4j2LogDelegateFactory");
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

3. Add logging to your resource methods to track request processing:

```java
@GET
@Produces(MediaType.APPLICATION_JSON)
public List<User> getUsers()
{
    log.debug("Handling GET /users request");

    // Process request

    log.debug("Completed GET /users request");
    return userService.getAllUsers();
}
```

4. Use the debug endpoints provided by GuicedVertxRest:

- `/debug`: Returns a simple text response for debugging
- `/rest/hello/world`: Returns a JSON string for debugging
- `/rest/hello/helloObject/world`: Returns a JSON object for debugging
