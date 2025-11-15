# Quarkus RESTEasy Reactive Rules

Purpose
- Define API conventions when using RESTEasy Reactive (JAX-RS) in Quarkus 3.x.
- Align resource design with DDD and testing strategies.

## Resource basics
- Annotate resources with `@Path`, `@Produces`, `@Consumes`; prefer constructor injection of services.
- Use `Uni<T>` for asynchronous endpoints; return DTOs (records) not entities.
- Enable validation via `@Valid` and Jakarta Bean Validation constraints.

Example
```java
@Path("/orders")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class OrderResource {
  private final OrderService service;

  public OrderResource(OrderService service) {
    this.service = service;
  }

  @POST
  public Uni<Response> create(@Valid CreateOrderRequest request) {
    return service.createOrder(request)
        .map(order -> Response.status(Response.Status.CREATED).entity(order).build());
  }
}
```

## Filters, exception mappers, and observability
- Centralize exception handling via `@Provider` classes returning RFC7807 payloads.
- Instrument endpoints with OpenTelemetry using `@WithSpan` where business spans add value.
- Use SmallRye OpenAPI; expose spec via `/q/openapi` and document in GUIDES.

## Testing
- For unit tests, prefer `@QuarkusTest` + RestAssured; for micro harness flows, reuse HarnessContext.
- Include contract tests (Pact) if the service acts as provider/consumer.

## Performance & scaling
- Keep DTO serialization with JSON-B/Jackson; configure via `application.properties`.
- Use `quarkus.http.limits.max-body-size` to guard against large payloads.
- Document concurrency expectations and timeouts per endpoint.

## See also
- Topic index — ./README.md
- Testing — ./testing.rules.md
- Java language rules — ../../language/java/README.md
