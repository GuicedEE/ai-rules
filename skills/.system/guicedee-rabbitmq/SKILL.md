---
name: guicedee-rabbitmq
description: "Annotation-driven RabbitMQ integration for GuicedEE with Vert.x 5: @RabbitConnectionOptions, @QueueExchange, @QueueDefinition, QueueConsumer/QueuePublisher injection, exchange management, queue options (priority, TTL, prefetch), publisher confirms, environment variable overrides, and verticle-scoped connections. Use when adding RabbitMQ messaging, declaring exchanges and queues, creating consumers and publishers, or configuring AMQP topology."
metadata:
  short-description: Annotation-driven RabbitMQ messaging inside GuicedEE
---

# GuicedEE RabbitMQ

Annotation-driven RabbitMQ integration for GuicedEE using the Vert.x RabbitMQ client.

## Core Concept

Declare connections, exchanges, queues, consumers, and publishers with annotations — everything is discovered at startup via ClassGraph, wired through Guice, and managed by the Vert.x RabbitMQ client.

## Required Flow

1. Add `com.guicedee:rabbitmq` dependency.
2. Define a connection and exchange on `package-info.java` (or any class):
   ```java
   @Verticle
   @RabbitConnectionOptions(
       value = "my-connection",
       host = "localhost",
       user = "guest",
       password = "guest"
   )
   @QueueExchange(
       value = "my-exchange",
       exchangeType = QueueExchange.ExchangeType.Direct,
       durable = true
   )
   package com.example.messaging;
   ```
3. Create a consumer:
   ```java
   @QueueDefinition("order-events")
   public class OrderConsumer implements QueueConsumer {
       @Override
       public void consume(RabbitMQMessage message) {
           System.out.println("Received: " + message.body());
       }
   }
   ```
4. Inject a publisher:
   ```java
   public class OrderService {
       @Inject @Named("order-events")
       private QueuePublisher orderPublisher;

       public void placeOrder(String orderJson) {
           orderPublisher.publish(orderJson);
       }
   }
   ```
5. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.rabbit;
       opens my.app.messaging to com.google.guice, com.guicedee.rabbit;
   }
   ```

## Annotations

### `@RabbitConnectionOptions`
Connection configuration: host, port, credentials, virtual host, reconnect, publisher confirms.

### `@QueueExchange`
Exchange declaration: name, type (Direct, Fanout, Topic, Headers), durability, auto-delete, dead-letter exchange.

### `@QueueDefinition`
Queue declaration: name, routing key, bound exchange reference.

### `@QueueOptions`
Queue tuning: priority, prefetch count, TTL, durability, auto-ack, single-consumer, exclusive, transacted, consumer count, dedicated channel/connection.

## Environment Variable Overrides

Every annotation attribute can be overridden via system properties or environment variables at runtime, scoped by connection/exchange/queue name.

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ RabbitMQPreStartup (annotation scanning)
     ├─ Discovers @RabbitConnectionOptions
     ├─ Discovers @QueueExchange per package
     ├─ Discovers @QueueDefinition consumers
     └─ Registers metadata for binding
 └─ RabbitMQModule (Guice bindings)
     ├─ Creates RabbitMQClient per connection
     ├─ Binds QueueConsumer as singletons
     └─ Binds QueuePublisher as @Named("queue-name")
 └─ RabbitPostStartup (runtime initialization)
     ├─ Starts connections
     ├─ Declares exchanges and queues
     ├─ Binds queues to exchanges
     └─ Starts consumer listeners
```

## Non-Negotiable Constraints

- Module must `requires com.guicedee.rabbit;`.
- Consumer/publisher packages must `opens` to `com.google.guice` and `com.guicedee.rabbit`.
- DTO packages must `opens` to `com.fasterxml.jackson.databind`.
- SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).
- `@RabbitConnectionOptions` and `@QueueExchange` can be placed on `package-info.java` (preferred) or any class.
- Verticle-scoped connections use `@Verticle` on the package.


