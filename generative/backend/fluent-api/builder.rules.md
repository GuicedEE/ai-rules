# Builder Pattern Rules — Immutable Construction and Validation

Purpose
- Define a fluent API strategy based on the Builder pattern for constructing immutable (or controlled-mutable) objects with validation and staged assembly.
- Provide ergonomic, readable object creation while centralizing invariants and defaults.

When to use
- Construction requires validation of multiple fields or cross-field invariants.
- Object should be immutable (preferred) or mutation must be tightly controlled.
- Public API must avoid partially-initialized states and enforce completeness at build() time.
- Interop with serialization/deserialization frameworks that benefit from canonical constructors/factory methods.

When not to use
- Ecosystems where CRTP is implied/enforced (GuicedEE, JWebMP) — prefer CRTP rules.
- Simple, in-place configurators where mutation is acceptable and type-safe chaining across inheritance is desired — prefer CRTP.

Strategy exclusivity
- CRTP and Builder are mutually exclusive per project. Select exactly one strategy in prompts.
- If GuicedEE or JWebMP is selected anywhere in the stack, CRTP is enforced and Builder must not be used for fluent APIs.

Core patterns

Immutable type with Lombok @Builder
```java
import org.jspecify.annotations.NullMarked;
import org.jspecify.annotations.Nullable;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.ToString;
import lombok.Value;

@NullMarked
@Value // final fields + getters; class is immutable
@Builder(toBuilder = true) // generate builder and toBuilder()
@EqualsAndHashCode
@ToString
public class User {
  String id;
  String email;
  @Nullable String middleName;

  // Optional: custom validation in builder via a custom build method
}
```

Manual builder (no Lombok)
```java
import org.jspecify.annotations.NullMarked;
import org.jspecify.annotations.Nullable;

@NullMarked
public final class Order {
  private final String id;
  private final int quantity;
  private final @Nullable String notes;

  private Order(String id, int quantity, @Nullable String notes) {
    if (id.isBlank()) throw new IllegalArgumentException("id required");
    if (quantity <= 0) throw new IllegalArgumentException("quantity > 0");
    this.id = id;
    this.quantity = quantity;
    this.notes = notes;
  }

  public static Builder builder() { return new Builder(); }

  public static final class Builder {
    private String id;
    private int quantity = 1;
    private @Nullable String notes;

    public Builder id(String id) { this.id = id; return this; }
    public Builder quantity(int quantity) { this.quantity = quantity; return this; }
    public Builder notes(@Nullable String notes) { this.notes = notes; return this; }

    public Order build() { return new Order(id, quantity, notes); }
  }

  // getters...
}
```

Rules

1) Immutability first
- Prefer immutable value types (final fields) with @Value or explicit finals. Provide a builder for construction and a minimal API surface.
- If partial mutability is required, restrict mutators to targeted operations that preserve invariants.

2) Validation in build()
- Validate required fields and cross-field invariants inside build() (or constructor if manual).
- Avoid leaking partially-initialized instances. Keep validation centralized.

3) JSpecify nullness contracts
- Adopt @NullMarked at package/class level.
- Use @Nullable precisely on optional fields and builder inputs. Avoid returning null collections/optionals — prefer empty values.

4) Lombok usage
- @Builder on immutable types or factory methods; consider toBuilder = true for controlled cloning.
- Combine with @Value (or @Getter on finals) and explicit @EqualsAndHashCode/@ToString as needed.
- Do not use @Data for entities. Prefer explicit annotations: @Getter, @EqualsAndHashCode, @ToString.

5) MapStruct interop
- MapStruct can construct target objects via builder if properly detected:
  - Ensure Lombok-mapstruct-binding is present when using Lombok builders.
  - Configure NullValueCheckStrategy and NullValueMappingStrategy to align null handling.
  - Provide factory methods when needed for complex creation.

6) Hibernate/ORM and serialization
- For JPA/ORM entities, builders may be awkward due to framework constraints; prefer CRTP or explicit constructors + factory methods if entity lifecycle requires it.
- For DTOs/API models, builders are appropriate and can coexist with serialization frameworks via canonical constructors or all-args constructors.

7) Inheritance considerations
- Builders and inheritance can become complex. Prefer composition or separate builders per concrete type.
- If inheritance is required, prefer builders that delegate to private constructors, or static factory methods per subtype.

8) Project exclusivity
- If the project selected CRTP in the prompt (or GuicedEE/JWebMP are present), do not use Builder for fluent APIs. If Builder is selected, do not implement CRTP setters.

Anti-patterns
- Mixing CRTP and Builder on the same type or across APIs that should be consistent.
- @Nullable Optional<T> (prefer Optional.empty()).
- Returning null collections/optionals (prefer empty).
- Using @Data on entities or complex domain types with invariants.

Examples

Lombok @Builder with required fields
```java
import lombok.Builder;
import lombok.NonNull;
import org.jspecify.annotations.NullMarked;

@NullMarked
@Builder
public record Address(
  @NonNull String line1,
  @NonNull String city,
  @NonNull String country,
  String line2
) {}
```

Factory method builder
```java
public final class Token {
  private final String value;
  private final long expiresAt;

  private Token(String value, long expiresAt) { this.value = value; this.expiresAt = expiresAt; }

  public static Token of(String value, long ttlSeconds) {
    if (value.isBlank()) throw new IllegalArgumentException("value");
    long exp = System.currentTimeMillis() + ttlSeconds * 1000;
    return new Token(value, exp);
  }
}
```

Testing checklist
- Validation paths in build() covered; invalid inputs fail fast.
- Nullness contracts verified by static analysis (IDE/Error Prone/Checker).
- MapStruct uses builder correctly (generate and inspect mappers).
- No CRTP-specific chaining in codebase if Builder strategy is selected.

Migration notes
- From CRTP to Builder: remove handwritten CRTP setters; introduce builders and make fields final; move validations to build(); update MapStruct bindings and serialization as needed.
- From ad-hoc mutability to Builder: identify invariants; design builder API; deprecate public setters; provide toBuilder() for controlled updates.

See also
- Fluent API index — ./README.md
- CRTP rules — ./crtp.rules.md
- Lombok topic — ../lombok/README.md
- Lombok guide — ../lombok/lombok.md
- MapStruct — ../mapstruct/README.md
- JSpecify — ../jspecify/README.md
- GuicedEE — ../guicedee/README.md
- JWebMP — ../../frontend/jwebmp/README.md