# CRTP Rules — Generic Self-Type Fluent APIs

Purpose
- Define a type-safe fluent API strategy using the Curiously Recurring Template Pattern (CRTP) for Java libraries and services.
- Eliminate builder boilerplate where chaining setters/configurators are preferred and preserve precise return types for chained calls.

When to use
- Default for GuicedEE and JWebMP ecosystems (CRTP is implied and enforced).
- Fluent configurator-style APIs where mutation-in-place or staged configuration is acceptable.
- Scenarios requiring compile-time safety for chaining across inheritance hierarchies.

When not to use
- Construction requires validation of invariants across many fields and must yield an immutable aggregate: prefer Builder.
- Public API requires no partially-initialized states or must hide mutators: prefer Builder.

Core pattern
```java
// Generic self-type on the base
public abstract class Base<J extends Base<J>> {
  private String name;

  @SuppressWarnings("unchecked")
  public J setName(String name) {
    this.name = name;
    return (J) this; // CRTP: return the self type
  }
}

// Concrete subtype binds the type parameter to itself
public final class User extends Base<User> {
  private int age;

  @SuppressWarnings("unchecked")
  public User setAge(int age) {
    this.age = age;
    return (User) this;
  }
}

// Usage: type-safe chaining across inheritance
User u = new User().setName("Ada").setAge(37);
```

Rules
1) Generic self-type bound
- Declare the base as Base<J extends Base<J>> and return J from all fluent mutators.

2) Manual setters only (no Lombok-generated setters for CRTP)
- Lombok @Setter (even with chain=true) returns the declaring class, not J.
- Handwrite fluent setters in CRTP classes and return (J) this with a method-level @SuppressWarnings("unchecked").

3) Nullness and API contracts (JSpecify)
- Annotate packages or classes with @org.jspecify.annotations.NullMarked.
- Use @org.jspecify.annotations.Nullable on parameters/fields/returns only where null is part of the explicit contract.

4) Inheritance safety
- Do not widen nullness in overrides.
- Maintain fluent return type J in all overridden mutators.

5) Interop
- Lombok: Keep @Getter; disable @Setter per-field with @Setter(AccessLevel.NONE) where CRTP setters are handwritten.
- MapStruct: Mappers may call CRTP setters; configure null strategies explicitly (NullValueCheckStrategy/NullValueMappingStrategy).
- Hibernate/ORM: Prefer non-null fields; annotate truly nullable columns and validate at service layer.

6) Project exclusivity
- CRTP and Builder are mutually exclusive per project. If GuicedEE or JWebMP is selected, CRTP is enforced.

Lombok integration policy
- Do NOT use @Builder on CRTP types.
- Global chain configuration (lombok.accessors.chain=true) does not change return types for CRTP; handwritten setters remain required.
- Keep the class concise with @Getter, @EqualsAndHashCode, @ToString where appropriate; avoid @Data on entities.

JSpecify policy
- Package-level default:
```java
@org.jspecify.annotations.NullMarked
package com.example.domain;
```
- Apply @Nullable precisely (e.g., DTO fields that may be absent); avoid returning null collections/optionals (prefer empty).

MapStruct guidance
- Explicitly configure:
  - NullValueCheckStrategy = ALWAYS
  - NullValueMappingStrategy = RETURN_NULL (or RETURN_DEFAULT as per domain)
- Avoid @Nullable Optional<T>; prefer Optional.empty().

Examples

Package default
```java
@org.jspecify.annotations.NullMarked
package com.example.user;
```

CRTP base with multiple setters
```java
import org.jspecify.annotations.Nullable;

public abstract class Entity<J extends Entity<J>> {
  private String id;
  private @Nullable String description;

  @SuppressWarnings("unchecked")
  public J setId(String id) {
    this.id = id;
    return (J) this;
  }

  @SuppressWarnings("unchecked")
  public J setDescription(@Nullable String description) {
    this.description = description;
    return (J) this;
  }
}
```

Subtype and usage
```java
public final class Customer extends Entity<Customer> {
  private int tier;

  @SuppressWarnings("unchecked")
  public Customer setTier(int tier) {
    this.tier = tier;
    return (Customer) this;
  }
}

// Chain:
Customer c = new Customer()
    .setId("C-1")
    .setDescription(null)
    .setTier(2);
```

Testing checklist
- Unit test fluent chains compile and return the expected concrete subtype.
- Static analysis (Error Prone/IDE) is configured; no unchecked warnings remain except on the annotated methods.
- Nullness checks pass under @NullMarked; inputs are validated at boundaries.

Anti-patterns
- Using Lombok-generated setters for CRTP types (they return the declaring class, not J).
- Mixing CRTP with Builder on the same type.
- Returning null collections/optionals (prefer empty).
- @Nullable Optional<T> (prefer Optional.empty()).

Migration notes
- From Builder to CRTP: remove @Builder, expose handwritten fluent setters returning J; preserve validation using preconditions in setters.
- From ad-hoc chaining to CRTP: add the generic self-type and update return types; annotate method-level @SuppressWarnings("unchecked").

See also
- Fluent API index — ./README.md
- Builder pattern rules — ./builder.rules.md
- Lombok topic — ../lombok/README.md
- Lombok guide — ../lombok/lombok.md
- JSpecify — ../jspecify/README.md
- MapStruct — ../mapstruct/README.md
- GuicedEE — ../guicedee/README.md
- JWebMP — ../../frontend/jwebmp/README.md
## Class design policy (abstract vs final)

Extensibility rules
- Extensible types MUST be declared using the CRTP pattern so chained methods preserve the concrete subtype across the hierarchy.
  - Abstract base (class):
    ```java
    public abstract class Base<J extends Base<J>> {
      @SuppressWarnings("unchecked")
      public J setName(String name) { /* ... */ return (J) this; }
    }
    ```
  - Concrete subtype:
    ```java
    public final class User extends Base<User> {
      @SuppressWarnings("unchecked")
      public User setAge(int age) { /* ... */ return (User) this; }
    }
    ```
  - Interface form (where appropriate):
    ```java
    public interface Fluent<J extends Fluent<J>> {
      J setName(String name);
    }
    ```
- Non‑extensible types MUST be declared final.
  - If the project strategy is CRTP, you may still bind to a CRTP base for consistency (e.g., `final class User extends Base<User>`), but it is not required when there is no inheritance surface to preserve.
  - If providing fluent setters on a final type without a CRTP base, return the concrete type (not `this` as a generic) and keep the class final to avoid accidental extension.

Prohibitions and guidance
- Do NOT publish non‑CRTP base classes intended to be extended. All bases intended for subclassing must be CRTP‑parameterized (`abstract class Base<J extends Base<J>>`).
- Prefer sealed CRTP bases when the subtype set is known and fixed (Java 17+):
  ```java
  public sealed abstract class Base<J extends Base<J>> permits SubA, SubB { /* ... */ }
  public final class SubA extends Base<SubA> { /* ... */ }
  public final class SubB extends Base<SubB> { /* ... */ }
  ```
- Keep fluent mutators handwritten with method‑level `@SuppressWarnings("unchecked")` and `return (J) this;`. Do not use Lombok‑generated setters for CRTP return types.
- Under `@org.jspecify.annotations.NullMarked`, mark only truly nullable values with `@org.jspecify.annotations.Nullable`.

LLM routing and checks
- When generating a base intended for extension, emit an abstract CRTP base by default and ensure all fluent setters return `J`.
- When generating a class not intended for extension, emit `final` and avoid introducing inheritance; if fluent setters are required, return the concrete type or bind to a CRTP base tied to self for uniformity.
- Flag as violation: non‑final, non‑CRTP classes that expose fluent setters and are externally extensible.