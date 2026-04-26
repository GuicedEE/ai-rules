---
name: guicedee-ibmmq
description: "Annotation-driven IBM MQ integration for GuicedEE with JMS 3.0: @IBMMQConnectionOptions, @IBMMQQueueDefinition, @IBMMQQueueOptions, IBMMQConsumer/IBMMQPublisher injection, JMS ConnectionFactory binding, queue and topic support, durable subscriptions, message selectors, transacted sessions, environment variable overrides, call-scoped message handling, and graceful shutdown. Use when adding IBM MQ messaging, declaring queue/topic consumers and publishers, configuring MQ connections, or integrating with IBM MQ queue managers."
metadata:
  short-description: Annotation-driven IBM MQ messaging inside GuicedEE
---

# GuicedEE IBM MQ

Annotation-driven IBM MQ integration for GuicedEE using the IBM MQ JMS client (com.ibm.mq.allclient).

## Core Concept

Declare connections, queues/topics, consumers, and publishers with annotations — everything is discovered at startup via ClassGraph, wired through Guice, and managed by the IBM MQ JMS client.

## Required Flow

1. Add `com.guicedee:ibmmq` dependency.
2. Define a connection on `package-info.java` (preferred) or any class:
   ```java
   @com.guicedee.vertx.Verticle
   @IBMMQConnectionOptions(
       value = "my-connection",
       host = "localhost",
       port = 1414,
       queueManager = "QM1",
       channel = "DEV.APP.SVRCONN",
       user = "app",
       password = "passw0rd"
   )
   package com.example.messaging;
   ```
3. Create a consumer:
   ```java
   @IBMMQQueueDefinition(
       value = "DEV.QUEUE.1",
       options = @IBMMQQueueOptions(worker = true, transacted = true)
   )
   public class OrderConsumer implements IBMMQConsumer {
       @Override
       public void consume(Message message) {
           try {
               TextMessage tm = (TextMessage) message;
               System.out.println("Received: " + tm.getText());
           } catch (JMSException e) {
               throw new RuntimeException(e);
           }
       }
   }
   ```
4. Inject a publisher:
   ```java
   public class OrderService {
       @Inject @Named("DEV.QUEUE.1")
       private IBMMQPublisher orderPublisher;

       public void placeOrder(String orderJson) {
           orderPublisher.publish(orderJson);
       }
   }
   ```
5. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.ibmmq;
       opens my.app.messaging to com.google.guice, com.guicedee.ibmmq;
   }
   ```

## Annotations

### `@IBMMQConnectionOptions`
Connection configuration: host, port, queue manager, channel, credentials, transport type (client/bindings), SSL/TLS, CCSID, reconnect settings, application name. Targets `TYPE` and `PACKAGE`.

### `@IBMMQQueueDefinition`
Queue/topic declaration: name, consumer options, connection reference. Targets `TYPE` and `FIELD`.

### `@IBMMQQueueOptions`
Consumer tuning: auto-ack, worker threads, consumer count, transacted sessions, autobind, receive timeout, topic mode, durable subscriptions, message selectors, persistence, priority, time-to-live.

## Injectable Components

| Binding | Key | Description |
|---|---|---|
| `IBMMQPublisher` | `@Named("queue-name")` | Publisher for a specific queue or topic |
| `IBMMQConsumer` | `@Named("queue-name")` | Consumer for a specific queue or topic |
| `ConnectionFactory` | `@Named("connection-name")` | JMS ConnectionFactory per connection |

## Environment Variable Overrides

Every annotation attribute can be overridden via system properties or environment variables at runtime, scoped by connection/queue name:
- `IBMMQ_{NORMALIZED_NAME}_{PROPERTY}` — name-specific override
- `IBMMQ_{PROPERTY}` — global fallback

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ IBMMQPreStartup (annotation scanning)
     ├─ Discovers @IBMMQConnectionOptions
     ├─ Discovers @IBMMQQueueDefinition consumers
     ├─ Registers publisher metadata
     └─ Registers consumer metadata
 └─ IBMMQModule (Guice bindings)
     ├─ Creates JMS ConnectionFactory per connection
     ├─ Binds IBMMQConsumer as singletons
     └─ Binds IBMMQPublisher as @Named("queue-name")
 └─ IBMMQPostStartup (runtime initialization)
     ├─ Creates JMS contexts and consumers
     ├─ Starts polling threads for message consumption
     └─ Call-scoped message dispatch with transacted/ack support
 └─ IBMMQPreDestroy (shutdown)
     ├─ Closes all JMS consumers
     └─ Closes all JMS contexts
```

## Non-Negotiable Constraints

- Module must `requires com.guicedee.ibmmq;`.
- Consumer/publisher packages must `opens` to `com.google.guice` and `com.guicedee.ibmmq`.
- DTO packages must `opens` to `com.fasterxml.jackson.databind`.
- SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).
- `@IBMMQConnectionOptions` can be placed on `package-info.java` (preferred) or any class.
- Consumer classes must implement `IBMMQConsumer` and be annotated with `@IBMMQQueueDefinition`.
- IBM MQ client JAR (`com.ibm.mq.allclient`) must be available on the module path.

