# Quarkus Reactive Messaging Rules

Purpose
- Standardize use of SmallRye Reactive Messaging in Quarkus for Kafka/AMQP streams.

## Extensions and connectors
- Add dependencies: `quarkus-smallrye-reactive-messaging`, `quarkus-smallrye-reactive-messaging-kafka` (or amqp).
- Declare channels via CDI annotations: `@Incoming`, `@Outgoing`, `@Channel`.

Example
```java
@ApplicationScoped
public class OrderEvents {
  @Incoming("orders-in")
  @Outgoing("orders-out")
  public Message<Order> enrich(Message<Order> in) {
    var payload = in.getPayload();
    // business logic
    return Message.of(payload.withState("ENRICHED"));
  }
}
```

## Configuration
- Define channels in `application.properties`:
```
mp.messaging.incoming.orders-in.connector=smallrye-kafka
mp.messaging.incoming.orders-in.topic=orders
mp.messaging.incoming.orders-in.value.deserializer=io.quarkus.kafka.client.serialization.ObjectMapperDeserializer
```
- Store credentials in secrets; use `%prod.` for production brokers and Dev Services for `%dev/%test`.

## Error handling & retries
- Use `@Retry`, `@CircuitBreaker` (MicroProfile Fault Tolerance) judiciously; prefer DLQs when business-specific.
- Enable failure channels (`mp.messaging.incoming.orders-in.failure-strategy=dead-letter-queue`).

## Testing
- Combine Dev Services Kafka (embedded broker) with `@QuarkusTestResource` to manage lifecycle.
- For harness flows, publish events via shared `KafkaClient` utilities and assert consumer state.

## Observability
- Expose metrics via `smallrye-metrics`; configure tracing with OpenTelemetry interceptors by setting `quarkus.otel.exporter.otlp.endpoint`.

## See also
- Topic index — ./README.md
- Panache persistence rules — ./panache-persistence.rules.md
- Testing rules — ./testing.rules.md
- Secrets & Config — ../../platform/secrets-config/README.md
