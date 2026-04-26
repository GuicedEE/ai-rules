---
name: guicedee-kafka
description: "Annotation-driven Kafka integration for GuicedEE with Vert.x 5: @KafkaConnectionOptions, @KafkaTopicDefinition, @KafkaTopicCreate, KafkaTopicConsumer/KafkaTopicPublisher injection, KafkaAdminClient binding, per-topic consumers, manual offset commit, worker thread support, partition assignment and revocation handlers, environment variable overrides, call-scoped message handling, and graceful shutdown. Use when adding Kafka messaging, declaring topic consumers and publishers, creating topics via admin client, or configuring Kafka connections."
metadata:
  short-description: Annotation-driven Kafka messaging inside GuicedEE
---

# GuicedEE Kafka

Annotation-driven Apache Kafka integration for GuicedEE using the Vert.x Kafka client.

## Core Concept

Declare connections, topics, consumers, and publishers with annotations — everything is discovered at startup via ClassGraph, wired through Guice, and managed by the Vert.x Kafka client.

## Required Flow

1. Add `com.guicedee:kafka` dependency.
2. Define a connection on `package-info.java` (preferred) or any class:
   ```java
   @KafkaConnectionOptions(
       value = "my-connection",
       bootstrapServers = "localhost:9092",
       groupId = "my-group"
   )
   @KafkaTopicCreate(value = "order-events", partitions = 3, replicationFactor = 1)
   package com.example.messaging;
   ```
3. Create a consumer:
   ```java
   @KafkaTopicDefinition(
       value = "order-events",
       options = @KafkaTopicOptions(worker = true)
   )
   public class OrderConsumer implements KafkaTopicConsumer<String, String> {
       @Override
       public void consume(KafkaConsumerRecord<String, String> record) {
           System.out.println("Received: " + record.value());
       }
   }
   ```
4. Inject a publisher:
   ```java
   public class OrderService {
       @Inject @Named("order-events")
       private KafkaTopicPublisher orderPublisher;

       public void placeOrder(String orderJson) {
           orderPublisher.send("order-key", orderJson);
       }
   }
   ```
5. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.kafka;
       opens my.app.messaging to com.google.guice, com.guicedee.kafka;
   }
   ```

## Annotations

### `@KafkaConnectionOptions`
Connection configuration: bootstrap servers, group id, serializers/deserializers, acks, retries, timeouts, batch size, buffer memory. Targets `TYPE` and `PACKAGE`.

### `@KafkaTopicDefinition`
Topic declaration: name, consumer options. Targets `TYPE`, `FIELD`, and `PACKAGE`.

### `@KafkaTopicOptions`
Consumer tuning: auto-commit, worker threads, consumer count, partition assignment, max poll interval, pause on start.

### `@KafkaTopicCreate` (Repeatable)
Admin client topic creation at startup: topic name, partitions, replication factor, ignore-if-exists. Targets `TYPE` and `PACKAGE`.

## Injectable Components

| Binding | Key | Description |
|---|---|---|
| `KafkaTopicPublisher` | `@Named("topic-name")` | Publisher for a specific topic |
| `KafkaTopicConsumer` | `@Named("topic-name")` | Consumer for a specific topic |
| `KafkaProducer<String,String>` | `@Named("connection-name")` | Raw Vert.x Kafka producer per connection |
| `KafkaConsumer<String,String>` | `@Named("connection-name")` | Raw Vert.x Kafka consumer per connection |
| `KafkaAdminClient` | `@Named("connection-name")` | Vert.x Kafka admin client per connection |

## Environment Variable Overrides

Every annotation attribute can be overridden via system properties or environment variables at runtime, scoped by connection/topic name:
- `KAFKA_{NORMALIZED_NAME}_{PROPERTY}` — name-specific override
- `KAFKA_{PROPERTY}` — global fallback

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ KafkaPreStartup (annotation scanning)
     ├─ Discovers @KafkaConnectionOptions (classes and package-info.java)
     ├─ Discovers @KafkaTopicCreate annotations
     ├─ Discovers @KafkaTopicDefinition consumers
     └─ Registers metadata for binding
 └─ KafkaModule (Guice bindings)
     ├─ Creates KafkaProducer per connection
     ├─ Creates KafkaConsumer per connection
     ├─ Creates KafkaAdminClient per connection
     ├─ Binds KafkaTopicConsumer as singletons
     └─ Binds KafkaTopicPublisher as @Named("topic-name")
 └─ KafkaPostStartup (runtime initialization)
     ├─ Creates declared topics via admin client
     ├─ Creates per-topic consumers
     ├─ Registers partition assigned/revoked handlers
     ├─ Subscribes to topics or assigns partitions
     └─ Starts consuming with call-scoped message handling
 └─ KafkaPreDestroy (shutdown)
     ├─ Closes all topic consumers
     ├─ Closes all package consumers
     ├─ Closes all producers
     └─ Closes all admin clients
```

## Non-Negotiable Constraints

- Module must `requires com.guicedee.kafka;`.
- Consumer/publisher packages must `opens` to `com.google.guice` and `com.guicedee.kafka`.
- DTO packages must `opens` to `com.fasterxml.jackson.databind`.
- SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).
- `@KafkaConnectionOptions` can be placed on `package-info.java` (preferred) or any class.
- `@KafkaTopicCreate` can be placed on `package-info.java` (preferred) or any class. It is repeatable.
