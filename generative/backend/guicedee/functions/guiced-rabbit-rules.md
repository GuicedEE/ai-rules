# GuicedRabbit Framework Guidelines

This document provides comprehensive guidelines for using the GuicedRabbit framework, including package structure, configuration, usage patterns, and best practices.

## Table of Contents

1. [Overview](#overview)
2. [Package Structure](#package-structure)
3. [Configuration](#configuration)
   - [Connection Configuration](#connection-configuration)
   - [Exchange Configuration](#exchange-configuration)
   - [Queue Configuration](#queue-configuration)
4. [Message Consumers](#message-consumers)
   - [Creating Consumers](#creating-consumers)
   - [Transacted Consumers](#transacted-consumers)
5. [Message Publishers](#message-publishers)
   - [Creating Publishers](#creating-publishers)
   - [Publishing Messages](#publishing-messages)
6. [Integration with Vert.x](#integration-with-vertx)
7. [Lifecycle Management](#lifecycle-management)
   - [Startup Sequence](#startup-sequence)
   - [Shutdown Sequence](#shutdown-sequence)
8. [Common Use Cases](#common-use-cases)
   - [Simple Messaging](#simple-messaging)
   - [Publish-Subscribe Pattern](#publish-subscribe-pattern)
   - [Request-Reply Pattern](#request-reply-pattern)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

## Overview

GuicedRabbit provides integration with RabbitMQ, a popular message broker, for GuicedEE applications. It leverages Vert.x's RabbitMQ client and integrates with the GuicedInjection framework for dependency injection and lifecycle management.

The framework offers:
- Declarative configuration using annotations
- Automatic discovery and setup of connections, exchanges, queues, consumers, and publishers
- Integration with Vert.x for asynchronous operations
- Support for transactional message processing
- Automatic lifecycle management

## Package Structure

The GuicedRabbit module follows a modular package structure:

```
com.guicedee.rabbit
├── QueueConsumer.java           # Interface for message consumers
├── QueuePublisher.java          # Class for publishing messages
├── RabbitConnectionOptions.java # Annotation for connection configuration
├── QueueExchange.java           # Annotation for exchange configuration
├── QueueDefinition.java         # Annotation for queue configuration
├── QueueOptions.java            # Annotation for detailed queue options
├── implementations              # Implementation classes
│   ├── RabbitMQPreStartup.java  # Discovers and configures resources
│   ├── RabbitPostStartup.java   # Establishes connections and consumers
│   └── RabbitMQModule.java      # Guice module for dependency injection
└── support                      # Support classes
    └── TransactedMessageConsumer.java # Handles transacted message consumption
```

## Configuration

### Connection Configuration

To configure a RabbitMQ connection, use the `@RabbitConnectionOptions` annotation on a class or package:

```
@RabbitConnectionOptions(
    value = "myConnection",
    host = "rabbitmq.example.com",
    port = 5672,
    user = "guest",
    password = "guest",
    virtualHost = "/",
    confirmPublishes = true,
    automaticRecoveryEnabled = true
)
public class MyRabbitConfig {
    // Configuration class
}
```

Key connection options include:
- `value`: Name of the connection (default: "default")
- `host`: RabbitMQ server hostname (default: empty, uses localhost)
- `port`: RabbitMQ server port (default: 0, uses 5672)
- `user`: Username for authentication (default: "guest")
- `password`: Password for authentication (default: "guest")
- `virtualHost`: RabbitMQ virtual host (default: empty, uses "/")
- `confirmPublishes`: Whether to wait for publish confirmations (default: false)
- `automaticRecoveryEnabled`: Whether to automatically recover connections (default: true)
- `reconnectAttempts`: Number of reconnection attempts (default: 0)

### Exchange Configuration

To configure a RabbitMQ exchange, use the `@QueueExchange` annotation on a class or package:

```
@QueueExchange(
    value = "myExchange",
    exchangeType = QueueExchange.ExchangeType.Direct,
    durable = true,
    autoDelete = false,
    createDeadLetter = true
)
public class MyExchangeConfig {
    // Exchange configuration class
}
```

Key exchange options include:
- `value`: Name of the exchange (default: "default")
- `exchangeType`: Type of exchange (Direct, Fanout, Topic, Headers) (default: Direct)
- `durable`: Whether the exchange survives broker restart (default: false)
- `autoDelete`: Whether the exchange is deleted when no longer used (default: false)
- `createDeadLetter`: Whether to create a dead letter exchange (default: false)

### Queue Configuration

To configure a RabbitMQ queue, use the `@QueueDefinition` annotation on a consumer class or publisher field:

```
@QueueDefinition(
    value = "myQueue",
    exchange = "myExchange",
    options = @QueueOptions(
        durable = true,
        autoAck = false,
        transacted = true,
        consumerCount = 2,
        priority = 5
    )
)
public class MyQueueConsumer implements QueueConsumer {
    // Queue consumer implementation
}
```

Key queue options include:
- `value`: Name of the queue (required)
- `exchange`: Name of the exchange to bind to (default: "default")
- `options`: Detailed queue configuration options

The `@QueueOptions` annotation provides detailed configuration:
- `durable`: Whether the queue survives broker restart (default: false)
- `delete`: Whether the queue is deleted when no longer used (default: false)
- `autoAck`: Whether messages are automatically acknowledged (default: false)
- `transacted`: Whether message processing is transactional (default: true)
- `consumerCount`: Number of consumer instances to create (default: 1)
- `priority`: Message priority (default: 0)
- `ttl`: Time-to-live for messages in milliseconds (default: 0, no TTL)
- `singleConsumer`: Whether only one consumer can consume from the queue (default: false)
- `consumerExclusive`: Whether the consumer has exclusive access (default: false)
- `maxInternalQueueSize`: Maximum size of the internal message queue (default: Integer.MAX_VALUE)

## Message Consumers

### Creating Consumers

To create a message consumer, implement the `QueueConsumer` interface and annotate the class with `@QueueDefinition`:

```
@QueueDefinition(
    value = "orderQueue",
    exchange = "orders",
    options = @QueueOptions(
        durable = true,
        autoAck = false
    )
)
public class OrderConsumer implements QueueConsumer {
    @Override
    public void consume(RabbitMQMessage message) {
        // Process the message
        String body = message.body().toString();
        System.out.println("Received order: " + body);
        
        // Process the order...
    }
}
```

The consumer will be automatically discovered, registered, and started when the application starts.

### Transacted Consumers

For transactional message processing, set `transacted = true` in the `@QueueOptions`:

```
@QueueDefinition(
    value = "paymentQueue",
    exchange = "payments",
    options = @QueueOptions(
        durable = true,
        autoAck = false,
        transacted = true
    )
)
public class PaymentConsumer implements QueueConsumer {
    @Override
    public void consume(RabbitMQMessage message) {
        // Process the message within a transaction
        // If an exception is thrown, the message will be rejected
    }
}
```

Transacted consumers use the `TransactedMessageConsumer` class to handle message processing within a transaction context.

## Message Publishers

### Creating Publishers

To create a message publisher, inject a `QueuePublisher` instance with the appropriate name:

```
public class OrderService {
    @Inject
    @Named("orderQueue")
    private QueuePublisher orderPublisher;
    
    // Service methods
}
```

The publisher will be automatically created and configured based on the queue definition.

### Publishing Messages

To publish a message, use the `publish` method:

```
public void createOrder(Order order) {
    // Convert order to JSON or other format
    String orderJson = convertToJson(order);
    
    // Publish the message
    orderPublisher.publish(orderJson);
}
```

If `confirmPublishes` is set to true in the connection options, the publisher will wait for confirmation from the broker before considering the message sent.

## Integration with Vert.x

GuicedRabbit integrates with Vert.x for asynchronous operations:

1. It uses Vert.x's RabbitMQClient for communication with RabbitMQ
2. It leverages Vert.x's event loop for non-blocking operations
3. It uses Vert.x's executeBlocking for message processing to avoid blocking the event loop
4. It integrates with the Vert.x verticle system for proper lifecycle management

## Lifecycle Management

### Startup Sequence

The GuicedRabbit module integrates with the GuicedInjection lifecycle management system:

1. The core GuicedInjection framework initializes
2. The `RabbitMQPreStartup` service is executed to discover and configure resources:
   - Scans for classes with `@RabbitConnectionOptions`, `@QueueExchange`, and `@QueueDefinition` annotations
   - Builds maps of connections, exchanges, queues, consumers, and publishers
3. The Guice injector is built with the `RabbitMQModule`
4. The `RabbitPostStartup` service is executed to establish connections and set up consumers:
   - Creates RabbitMQ clients for each connection
   - Declares exchanges and queues
   - Binds queues to exchanges
   - Sets up consumers for the queues

### Shutdown Sequence

The shutdown sequence ensures proper cleanup of resources:

1. The `IGuicePreDestroy` hooks are executed
2. RabbitMQ connections are closed
3. Resources are cleaned up

## Common Use Cases

### Simple Messaging

For simple one-way messaging:

1. Configure a connection, exchange, and queue
2. Create a consumer to process messages
3. Inject a publisher to send messages

```
// Consumer
@QueueDefinition(value = "notificationQueue", exchange = "notifications")
public class NotificationConsumer implements QueueConsumer {
    @Override
    public void consume(RabbitMQMessage message) {
        String notification = message.body().toString();
        System.out.println("Notification received: " + notification);
    }
}

// Publisher
public class NotificationService {
    @Inject
    @Named("notificationQueue")
    private QueuePublisher notificationPublisher;
    
    public void sendNotification(String message) {
        notificationPublisher.publish(message);
    }
}
```

### Publish-Subscribe Pattern

For publish-subscribe messaging using a fanout exchange:

```
// Exchange configuration
@QueueExchange(
    value = "broadcastExchange",
    exchangeType = QueueExchange.ExchangeType.Fanout
)
public class BroadcastConfig {
}

// First subscriber
@QueueDefinition(value = "subscriber1", exchange = "broadcastExchange")
public class Subscriber1 implements QueueConsumer {
    @Override
    public void consume(RabbitMQMessage message) {
        // Process broadcast message
    }
}

// Second subscriber
@QueueDefinition(value = "subscriber2", exchange = "broadcastExchange")
public class Subscriber2 implements QueueConsumer {
    @Override
    public void consume(RabbitMQMessage message) {
        // Process broadcast message
    }
}

// Publisher
public class BroadcastService {
    @Inject
    @Named("subscriber1") // Any queue bound to the exchange will work
    private QueuePublisher broadcastPublisher;
    
    public void broadcast(String message) {
        broadcastPublisher.publish(message);
    }
}
```

### Request-Reply Pattern

For request-reply messaging:

```
// Request queue consumer
@QueueDefinition(value = "requestQueue", exchange = "requests")
public class RequestConsumer implements QueueConsumer {
    @Inject
    @Named("replyQueue")
    private QueuePublisher replyPublisher;
    
    @Override
    public void consume(RabbitMQMessage message) {
        String request = message.body().toString();
        String response = processRequest(request);
        replyPublisher.publish(response);
    }
}

// Reply queue consumer
@QueueDefinition(value = "replyQueue", exchange = "replies")
public class ReplyConsumer implements QueueConsumer {
    @Override
    public void consume(RabbitMQMessage message) {
        String reply = message.body().toString();
        // Process the reply
    }
}
```

## Best Practices

1. **Use Descriptive Names**: Choose clear, descriptive names for connections, exchanges, and queues to make your code more maintainable.

2. **Configure Durability Appropriately**: Make queues and exchanges durable if message persistence across broker restarts is important.

3. **Handle Exceptions**: Implement proper exception handling in your consumers to prevent message loss.

4. **Use Transacted Consumers**: For operations that require atomicity, use transacted consumers to ensure messages are only acknowledged when processing completes successfully.

5. **Configure Message TTL**: Set appropriate time-to-live values for messages to prevent queue buildup if consumers are offline for extended periods.

6. **Use Dead Letter Exchanges**: Configure dead letter exchanges for queues to capture messages that cannot be processed.

7. **Monitor Queue Sizes**: Keep an eye on queue sizes to detect processing bottlenecks or consumer issues.

8. **Limit Consumer Count**: Configure an appropriate number of consumers based on your application's needs and available resources.

9. **Use Confirmed Publishing**: For critical messages, enable confirmed publishing to ensure delivery.

10. **Organize by Package**: Group related exchanges and queues in the same package to leverage package-level annotations.

## Troubleshooting

### Common Issues

1. **Connection Failures**: If connections to RabbitMQ fail, check:
   - RabbitMQ server is running and accessible
   - Connection details (host, port, credentials) are correct
   - Network connectivity between your application and RabbitMQ

2. **Exchange or Queue Declaration Errors**: If exchange or queue declarations fail, check:
   - Exchange or queue names are valid
   - Exchange types are correct
   - You have sufficient permissions to create exchanges and queues

3. **Message Not Received**: If messages are not being received by consumers, check:
   - The exchange and queue are properly bound
   - The routing key is correct
   - The consumer is properly registered and started
   - Messages are not being rejected due to exceptions

4. **Message Acknowledgment Issues**: If messages are not being acknowledged, check:
   - `autoAck` is set correctly
   - Your consumer is not throwing exceptions
   - For manual acknowledgment, ensure you're calling the appropriate method

### Debugging Tips

1. **Enable Logging**: Set the logging level to DEBUG or TRACE to get more detailed information about RabbitMQ operations.

2. **Use RabbitMQ Management UI**: Access the RabbitMQ Management UI to inspect exchanges, queues, bindings, and messages.

3. **Check Connection Status**: Verify that connections are established and channels are open.

4. **Inspect Message Properties**: Check message properties like content type, delivery mode, and headers to ensure they're set correctly.

5. **Test with Simple Consumers**: Create simple, standalone consumers to verify that messages are being published correctly.