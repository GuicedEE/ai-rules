# Spring (Boot MVC) — Messaging (Kafka/RabbitMQ)

Scope
- Non-reactive messaging for Spring Boot MVC services using Spring for Apache Kafka (spring-kafka) and Spring AMQP (RabbitMQ).
- Covers dependencies, configuration, producers/consumers, serialization, retries/DLQs, idempotency/transactions, outbox pattern, observability, security, and testing with Testcontainers.

Choose transport per use-case
- Kafka (streaming, partitioned topics, high-throughput, ordering within partitions, log-based retention).
- RabbitMQ (work queues, routing via exchanges/bindings, per-message acks, simpler request/worker patterns).

Dependencies (select what you use)
- Kafka:
```xml
<!-- pom.xml -->
<dependency>
  <groupId>org.springframework.kafka</groupId>
  <artifactId>spring-kafka</artifactId>
</dependency>
```
```kotlin
// build.gradle.kts
dependencies {
  implementation("org.springframework.kafka:spring-kafka")
}
```
- RabbitMQ:
```xml
<!-- pom.xml -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-amqp</artifactId>
</dependency>
```
```kotlin
// build.gradle.kts
dependencies {
  implementation("org.springframework.boot:spring-boot-starter-amqp")
}
```
- Optional (Kafka Avro + Schema Registry): io.confluent:kafka-avro-serializer (align versions with registry)
- Testcontainers for integration tests

Topic/queue naming policy
- Lowercase kebab-case. Include bounded context and version when schema contracts evolve:
  - bc1.users-created.v1
  - bc1.billing-invoices.v2
- Document retention, partitions, compaction policy, and consumer groups per topic.

Serialization and schema
- JSON: simplest; validate with JSON Schema in tests/CI if desired.
- Avro/Protobuf: use Schema Registry for compatibility checks (backward/forward).
- For JSON, version payloads explicitly and keep additive changes backward compatible when possible.

Kafka — configuration (application.yml)
```yaml
spring:
  kafka:
    bootstrap-servers: ${KAFKA_BOOTSTRAP:localhost:9092}
    properties:
      security.protocol: ${KAFKA_SECURITY_PROTOCOL:PLAINTEXT} # SASL_SSL in prod
      # sasl.jaas.config / sasl.mechanism when using SASL
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
      acks: all
      retries: 10
      properties:
        enable.idempotence: true
        delivery.timeout.ms: 120000
        linger.ms: 5
        batch.size: 32768
    consumer:
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer
      properties:
        spring.json.trusted.packages: "*"
      group-id: ${KAFKA_GROUP:service-users-v1}
      auto-offset-reset: latest
      enable-auto-commit: false
```

Kafka — producer and consumer
```java
// com.example.messaging.UserEventsProducer.java
package com.example.messaging;

import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
public class UserEventsProducer {
  private final KafkaTemplate<String, Object> kafka;

  public UserEventsProducer(KafkaTemplate<String, Object> kafka) { this.kafka = kafka; }

  public void userCreated(String userId, Object payload) {
    kafka.send("bc1.users-created.v1", userId, payload);
  }
}
```

```java
// com.example.messaging.UserEventsConsumer.java
package com.example.messaging;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.stereotype.Component;

@Component
class UserEventsConsumer {

  @KafkaListener(topics = "bc1.users-created.v1", groupId = "service-users-v1", concurrency = "3")
  void onUserCreated(ConsumerRecord<String, Object> record, Acknowledgment ack) {
    try {
      // process record.value()
      ack.acknowledge(); // manual ack on success
    } catch (Exception e) {
      // let error handler decide (seek/retry/DLQ); do not ack
      throw e;
    }
  }
}
```

Kafka — error handling and DLQ
- Prefer Dead Letter Topic (DLT) pattern with error handler configured to route failed records.
- Spring Kafka DefaultErrorHandler can retry then publish to DLT with backoff policy.

Kafka — error handler configuration
```java
// com.example.messaging.KafkaConfig.java
package com.example.messaging;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.kafka.listener.DefaultErrorHandler;
import org.springframework.util.backoff.ExponentialBackOff;

@Configuration
class KafkaConfig {

  @Bean
  NewTopic usersCreated() {
    return TopicBuilder.name("bc1.users-created.v1").partitions(6).replicas(3).build();
  }

  @Bean
  NewTopic usersCreatedDlt() {
    return TopicBuilder.name("bc1.users-created.v1.DLT").partitions(6).replicas(3).build();
  }

  @Bean
  DefaultErrorHandler errorHandler() {
    var backoff = new ExponentialBackOff(500L, 2.0);
    backoff.setMaxElapsedTime(30_000L);
    return new DefaultErrorHandler((rec, ex) -> {
      // With DeadLetterPublishingRecoverer if configured via KafkaTemplate & Dlt topic
    }, backoff);
  }
}
```

Kafka — transactions and outbox
- For DB + Kafka atomicity, use the transactional outbox pattern:
  - Write domain event to an outbox table within the same DB transaction as your state change.
  - A publisher reads and publishes to Kafka with transactional producer (enable.idempotence=true, transaction.id set).
- Avoid dual-writes in a single transaction unless you own the infra and confirm exactly-once semantics end-to-end.

RabbitMQ — configuration (application.yml)
```yaml
spring:
  rabbitmq:
    host: ${RABBIT_HOST:localhost}
    port: ${RABBIT_PORT:5672}
    username: ${RABBIT_USER:guest}
    password: ${RABBIT_PASS:guest}
    ssl:
      enabled: false
```

RabbitMQ — declarations and listener
```java
// com.example.messaging.RabbitConfig.java
package com.example.messaging;

import org.springframework.amqp.core.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
class RabbitConfig {
  static final String EX = "bc1.users";
  static final String Q = "bc1.users.created.v1";

  @Bean Exchange usersExchange() { return ExchangeBuilder.topicExchange(EX).durable(true).build(); }
  @Bean Queue usersCreatedQueue() { return QueueBuilder.durable(Q).build(); }
  @Bean Binding binding() { return BindingBuilder.bind(usersCreatedQueue()).to(usersExchange()).with("created.v1").noargs(); }
}
```

```java
// com.example.messaging.RabbitConsumers.java
package com.example.messaging;

import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Component;

@Component
class RabbitConsumers {

  @RabbitListener(queues = RabbitConfig.Q, concurrency = "3")
  void onUserCreated(@Payload byte[] body) {
    // deserialize JSON/Avro and process
  }
}
```

Retries and DLQ patterns
- Kafka: use DefaultErrorHandler with backoff + DLT, and consumer group specific DLT topics.
- RabbitMQ: use TTL + dead-letter exchanges for delayed retries or a delayed message exchange plugin. Keep retry counts bounded.

Idempotency and ordering
- Design consumers idempotent: deduplicate via business keys or event IDs; enforce unique constraints for side effects.
- For Kafka, retain ordering per key by using the same partition key for related events (e.g., userId).

Security and secrets
- Kafka production posture: SASL_SSL, client auth, ACLs scoped minimally. Externalize secrets (JAAS creds). See:
  - Secrets & Config — rules/generative/platform/secrets-config/README.md
  - Security & Auth — rules/generative/platform/security-auth/README.md
- RabbitMQ: TLS + per-service users with minimal permissions; rotate credentials; network policies restrict broker access.

Observability
- Emit metrics: producer/consumer throughput, lag, error counts, retry counts, DLQ depth.
- Kafka consumer lag: monitor with micrometer (if available) or external tooling (Burrow/Kafka UI).
- Structured logs include topic/partition/offset, key, correlationId; avoid logging full payloads with PII.

Testing with Testcontainers
- Spin up Kafka/RabbitMQ for integration tests; use real serializers and DLQ routing.
```java
// com.example.messaging.KafkaIT.java
package com.example.messaging;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class KafkaIT {
  @Test
  void contextLoads() {
    // Verify producer/consumer wiring; use embedded container in test lifecycle
  }
}
```

Operational guidance
- Provision topics/queues via IaC (Terraform/Helm operators) or application auto-creation (only in non-prod).
- Capacity planning: partitions for Kafka (throughput×parallelism), prefetch for RabbitMQ consumers.
- Back-pressure: bound concurrency on consumers; scale partitions and instances rather than unbounded threads.

Checklist
- Topic/queue names versioned and documented with retention and partitions/bindings.
- Serialization chosen and validated; Schema Registry (if used) enforces compatibility.
- Retries bounded; DLQ or parking lot configured with clear remediation procedures.
- Consumers idempotent; ordering preserved per key; outbox used for cross-system consistency.
- Security hardened (TLS, auth, ACLs); secrets externalized; least-privilege credentials.
- Metrics and alerts for lag, failures, and DLQ depth; tests use Testcontainers.

See also
- Data JPA & Transactions (Outbox) — ./data-jpa-transactions.md
- Scheduling & Async (Publishers/Workers) — ./scheduling-async.md
- Observability — ../../platform/observability/README.md
- Secrets & Config — ../../platform/secrets-config/README.md
- Security & Auth — ../../platform/security-auth/README.md
- Topic index — ./README.md