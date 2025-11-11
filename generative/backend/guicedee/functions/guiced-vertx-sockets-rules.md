# GuicedVertxSockets Package Structure Guidelines

This document outlines the recommended package structure and usage guidelines for the GuicedVertxSockets module, designed to provide WebSocket functionality for GuicedEE applications using Vert.x.

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
6. [WebSocket Configuration](#websocket-configuration)
   - [Default Configuration](#default-configuration)
   - [Group Management](#group-management)
   - [Message Processing](#message-processing)
7. [Common Use Cases](#common-use-cases)
   - [Creating a WebSocket Server](#creating-a-websocket-server)
   - [Handling WebSocket Messages](#handling-websocket-messages)
   - [Broadcasting Messages](#broadcasting-messages)
   - [Group Management](#group-management-1)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

## Overview

GuicedVertxSockets is a module that provides WebSocket capabilities for GuicedEE applications using Vert.x. It integrates with the GuicedInjection framework to provide dependency injection and lifecycle management for WebSocket components.

The module automatically sets up and configures WebSocket handlers on HTTP servers, and provides extension points through SPI interfaces to customize the WebSocket behavior. It also provides a group-based messaging system that allows for efficient broadcasting of messages to groups of connected clients.

## Package Structure

The GuicedVertxSockets module follows a modular package structure that separates concerns and promotes maintainability. Here's the recommended package structure:

```
com.guicedee.vertx.websockets
├── core                  # Core WebSocket components
│   └── WebSocketModule.java  # Guice module for WebSocket
├── spi                   # Service Provider Interfaces
│   ├── WebSocketConfigurator.java        # SPI for WebSocket configuration
│   └── WebSocketMessageHandler.java      # SPI for message handling
├── handlers              # Message handlers
│   ├── DefaultMessageHandler.java  # Default message handler
│   └── SecurityHandler.java        # Security-related handlers
├── groups                # Group management
│   ├── GroupManager.java  # Group management functionality
│   └── GroupEvent.java    # Group event definitions
└── util                  # Utility classes
```

## SPI Implementation

### Creating SPI Interfaces

GuicedVertxSockets provides several SPI interfaces for extending and customizing the WebSocket functionality:

1. **GuicedWebSocketOnAddToGroup**: Called when a WebSocket is added to a group
2. **GuicedWebSocketOnRemoveFromGroup**: Called when a WebSocket is removed from a group
3. **GuicedWebSocketOnPublish**: Called when a message is published to a group

These interfaces follow a consistent pattern and provide extension points at different stages of the WebSocket lifecycle.

Example:

```java
package com.guicedee.guicedservlets.websockets.services;

import java.util.concurrent.CompletableFuture;

@FunctionalInterface
public interface GuicedWebSocketOnAddToGroup
{
    CompletableFuture<Boolean> onAddToGroup(String groupName);
}
```

### Implementing SPI Interfaces

Implementations of these SPI interfaces should follow these guidelines:

1. Place implementations in a separate package or module
2. Name implementations clearly, typically ending with "Impl" or a descriptive term
3. Implement only the methods defined in the interface
4. Use field injection for dependencies to maintain proper encapsulation
5. Keep implementations stateless when possible

Example implementation of GuicedWebSocketOnAddToGroup:

```java
package com.example.websockets.groups;

import com.google.inject.Inject;
import com.guicedee.guicedservlets.websockets.services.GuicedWebSocketOnAddToGroup;
import com.guicedee.vertx.websockets.VertxSocketHttpWebSocketConfigurator;
import io.vertx.core.http.ServerWebSocket;

import java.util.concurrent.CompletableFuture;

public class CustomGroupAddHandler implements GuicedWebSocketOnAddToGroup
{
    @Inject
    private ServerWebSocket webSocket;

    @Override
    public CompletableFuture<Boolean> onAddToGroup(String groupName)
    {
        // Custom logic before adding to group
        System.out.println("Adding WebSocket to group: " + groupName);

        // Return false to allow the default implementation to run
        CompletableFuture<Boolean> result = new CompletableFuture<>();
        result.complete(false);
        return result;
    }
}
```

### Registering SPI Implementations

SPI implementations can be registered using both the Java Module System and the META-INF/services mechanism:

#### Using the Java Module System:

In your `module-info.java` file:

```java
module com.example.websockets {
    requires com.guicedee.vertx.sockets;

    provides com.guicedee.guicedservlets.websockets.services.GuicedWebSocketOnAddToGroup 
        with com.example.websockets.groups.CustomGroupAddHandler;
}
```

#### Using META-INF/services:

Create a file at `META-INF/services/com.guicedee.guicedservlets.websockets.services.GuicedWebSocketOnAddToGroup` with the content:

```
com.example.websockets.groups.CustomGroupAddHandler
```

## Module Configuration

### module-info.java

The `module-info.java` file for a module that uses GuicedVertxSockets should follow these guidelines:

1. Require the GuicedVertxSockets module
2. Use the SPI interfaces provided by GuicedVertxSockets
3. Provide implementations of the SPI interfaces as needed
4. **Do not** specify `uses com.guicedee.guicedinjection.interfaces.IGuiceModule` as this is already handled by the GuicedInjection library

Example:

```java
module com.example.websockets {
    requires com.guicedee.vertx.sockets;

    uses com.guicedee.guicedservlets.websockets.services.GuicedWebSocketOnAddToGroup;
    uses com.guicedee.guicedservlets.websockets.services.GuicedWebSocketOnRemoveFromGroup;
    uses com.guicedee.guicedservlets.websockets.services.GuicedWebSocketOnPublish;

    provides com.guicedee.guicedservlets.websockets.services.GuicedWebSocketOnAddToGroup 
        with com.example.websockets.groups.CustomGroupAddHandler;

    // Do NOT include this line:
    // uses com.guicedee.guicedinjection.interfaces.IGuiceModule;
}
```

> **Important Note**: The GuicedInjection library already includes `uses com.guicedee.guicedinjection.interfaces.IGuiceModule` in its module-info.java file. Since your module will require GuicedInjection (directly or transitively), you should not specify this "uses" directive in your own module-info.java file. The GuicedInjection library will automatically discover and load all IGuiceModule implementations.

### Transitive Dependencies

GuicedVertxSockets includes several transitive dependencies that are automatically available to modules that depend on it. This means you don't need to explicitly declare these dependencies in your module-info.java file.

The following modules are transitive dependencies of GuicedVertxSockets:

```java
// Transitive dependencies in GuicedVertxSockets
requires transitive com.guicedee.vertx.web;
```

When you include `requires com.guicedee.vertx.sockets` in your module-info.java file, these dependencies are automatically available to your module without needing to declare them explicitly.

#### Recommendation for Java Clients

When creating Java modules that use GuicedVertxSockets and want to expose its functionality to their own consumers, it is recommended to use `requires transitive` instead of just `requires`:

```java
// Recommended approach for modules that expose GuicedVertxSockets functionality
requires transitive com.guicedee.vertx.sockets;
```

This ensures that your module's consumers will also have access to GuicedVertxSockets and its transitive dependencies without having to explicitly require them.

### META-INF/services

The META-INF/services mechanism can be used alongside or instead of the Java Module System for registering SPI implementations. Follow these guidelines:

1. Create a file in the `META-INF/services` directory with the fully qualified name of the SPI interface
2. Add the fully qualified name of each implementation on a separate line
3. Ensure the file is included in your JAR file

Example:

File: `META-INF/services/com.guicedee.guicedservlets.websockets.services.GuicedWebSocketOnAddToGroup`
```
com.example.websockets.groups.CustomGroupAddHandler
```

## Lifecycle Management

### Startup Sequence

The GuicedVertxSockets module integrates with the GuicedInjection lifecycle management system. The WebSocket functionality is initialized during the post-startup phase by the `VertxSocketHttpWebSocketConfigurator` class, which implements `IGuicePostStartup`.

The startup sequence is as follows:

1. The core GuicedInjection framework initializes
2. The Vert.x instance is created and configured during the pre-startup phase
3. The HTTP/HTTPS server is created and configured
4. The `VertxSocketHttpWebSocketConfigurator` service is executed as part of the post-startup phase
5. WebSocket handlers are configured on the HTTP server
6. The "everyone" group is created for broadcasting to all connected clients
7. The server starts listening for WebSocket connections

### Shutdown Sequence

The shutdown sequence is handled by the GuicedInjection framework. The Vert.x instance, including the WebSocket handlers, is closed during the pre-destroy phase.

## WebSocket Configuration

### Default Configuration

By default, GuicedVertxSockets configures the WebSocket handler with the following options:

- WebSocket write handlers are registered
- Messages are processed in a dedicated worker executor
- Call scoping is used to maintain context for WebSocket connections
- WebSocket connections are automatically added to the "everyone" group

These default settings can be customized by implementing the appropriate SPI interfaces.

### Group Management

GuicedVertxSockets provides a group-based messaging system that allows for efficient broadcasting of messages to groups of connected clients. Groups are managed through the following mechanisms:

1. **Group Creation**: Groups are created automatically when a WebSocket is added to a group that doesn't exist
2. **Group Membership**: WebSockets can be added to multiple groups
3. **Group Removal**: WebSockets are automatically removed from groups when they disconnect
4. **Default Groups**: All WebSockets are automatically added to the "everyone" group and to a group with their unique ID

Example:

```java
// Add a WebSocket to a group
guicedWebSocket.addToGroup("chatRoom1");

// Remove a WebSocket from a group
guicedWebSocket.removeFromGroup("chatRoom1");

// Broadcast a message to a group
guicedWebSocket.broadcastMessage("chatRoom1", "Hello, everyone in chatRoom1!");
```

### Message Processing

GuicedVertxSockets processes WebSocket messages using a message-based system with actions:

1. **Message Reception**: Messages are received as JSON strings and parsed into WebSocketMessageReceiver objects
2. **Action Routing**: Messages are routed to registered listeners based on their action
3. **Message Handling**: Listeners process the messages and can send responses
4. **Broadcasting**: Messages can be broadcast to groups of connected clients

Example:

```java
// Register a message listener
IGuicedWebSocket.getMessagesListeners().put("chat", message -> {
    // Process the message
    String text = (String) message.getData();
    System.out.println("Received chat message: " + text);

    // Broadcast the message to a group
    guicedWebSocket.broadcastMessage("chatRoom1", text);
});
```

## Common Use Cases

### Creating a WebSocket Server

GuicedVertxSockets automatically sets up a WebSocket server when the module is included in your application. You don't need to write any additional code to create the server.

### Handling WebSocket Messages

To handle WebSocket messages, you need to register message listeners for specific actions:

```java
// Register a message listener
IGuicedWebSocket.getMessagesListeners().put("chat", message -> {
    // Process the message
    String text = (String) message.getData();
    System.out.println("Received chat message: " + text);

    // You can send a response or broadcast the message
});
```

### Broadcasting Messages

GuicedVertxSockets provides several methods for broadcasting messages:

```java
// Broadcast a message to a specific group
guicedWebSocket.broadcastMessage("chatRoom1", "Hello, everyone in chatRoom1!");

// Broadcast a message to the current WebSocket
guicedWebSocket.broadcastMessage("Hello, just you!");

// Broadcast a message synchronously
guicedWebSocket.broadcastMessageSync("chatRoom1", "Hello, everyone in chatRoom1!");
```

### Group Management

GuicedVertxSockets provides methods for managing WebSocket groups:

```java
// Add a WebSocket to a group
guicedWebSocket.addToGroup("chatRoom1");

// Remove a WebSocket from a group
guicedWebSocket.removeFromGroup("chatRoom1");
```

## Best Practices

1. **Use Actions for Message Routing**: Define clear action names for different types of messages to simplify routing and handling.

2. **Organize Groups Logically**: Create groups based on logical divisions of your application, such as chat rooms, user roles, or features.

3. **Use Dependency Injection**: Leverage Guice dependency injection to inject services and other dependencies into your WebSocket handlers.

4. **Handle Errors Properly**: Implement proper error handling in your message handlers to prevent crashes and provide meaningful error responses.

5. **Use Asynchronous APIs**: Leverage Vert.x's asynchronous APIs to handle WebSocket messages efficiently without blocking threads.

6. **Clean Up Resources**: Ensure that WebSockets are properly removed from groups when they disconnect to prevent memory leaks.

7. **Validate Input**: Always validate and sanitize input from WebSocket clients to prevent security vulnerabilities.

8. **Use JSON for Messages**: Use JSON for message formatting to ensure compatibility with different client platforms.

9. **Implement Security**: Add authentication and authorization checks to your WebSocket handlers to ensure that only authorized users can connect and send messages.

10. **Monitor Performance**: Monitor the performance of your WebSocket server and optimize as needed.

## Troubleshooting

### Common Issues

1. **Connection Refused**: Check that the WebSocket server is running and listening on the expected port.

2. **Authentication Failures**: Verify that the client is sending the correct authentication credentials.

3. **Message Not Received**: Check that the message is properly formatted as a WebSocketMessageReceiver with the correct action.

4. **Group Not Found**: Ensure that the group exists before trying to broadcast to it.

5. **Memory Leaks**: Check for WebSockets that are not properly removed from groups when they disconnect.

### Debugging Tips

1. Enable debug logging to see more detailed information:

```java
System.setProperty("vertx.logger-delegate-factory-class-name", "io.vertx.core.logging.Log4j2LogDelegateFactory");
```

2. Use the `VertxSocketHttpWebSocketConfigurator` to add custom logging:

```java
public class DebugWebSocketConfigurator implements VertxHttpServerConfigurator
{
    @Override
    public HttpServer builder(HttpServer server)
    {
        server.webSocketHandler(ws -> {
            System.out.println("WebSocket connected: " + ws.remoteAddress());
            // Continue with normal handling
        });
        return server;
    }
}
```

3. Add logging to your message handlers:

```java
IGuicedWebSocket.getMessagesListeners().put("chat", message -> {
    System.out.println("Received chat message: " + message.getData());
    // Process the message
});
```

4. Monitor group membership:

```java
System.out.println("Groups: " + VertxSocketHttpWebSocketConfigurator.groupSockets.keySet());
System.out.println("Sockets in group 'chatRoom1': " + VertxSocketHttpWebSocketConfigurator.groupSockets.get("chatRoom1").size());
```
