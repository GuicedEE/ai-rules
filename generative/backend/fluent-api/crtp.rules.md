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
public class User<J extends User<J>> extends Base<J> {
  private int age;

  @SuppressWarnings("unchecked")
  public J setAge(int age) {
    this.age = age;
    return (J) this;
  }
}

// Usage: type-safe chaining across inheritance
User<?> u = new User<>().setName("Ada").setAge(37);

// Client extension example
public class ExtendedUser extends User<ExtendedUser> {
  public ExtendedUser setCustomProperty(String value) {
    return this;
  }
}

ExtendedUser eu = new ExtendedUser().setName("Bob").setAge(25).setCustomProperty("value");
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

7) Comprehensive JavaDoc requirements
- ALL getters and setters (including fluent CRTP setters) MUST have comprehensive JavaDoc documentation.
- JavaDoc MUST include @param tags for all parameters with meaningful descriptions.
- JavaDoc MUST include @return tags for all non-void methods with clear return descriptions.
- For CRTP fluent setters, @return should specify "this instance for method chaining" or similar.
- Property descriptions should explain purpose, constraints, and any side effects.
- Use @throws tags where applicable for validation exceptions.
- Example:
  ```java
  /**
   * Sets the user's age with validation.
   * <p>
   * The age must be between 0 and 150 years. Setting the age may trigger
   * age-related validations in dependent systems.
   *
   * @param age the user's age in years, must be between 0 and 150
   * @return this instance for method chaining
   * @throws IllegalArgumentException if age is negative or exceeds 150
   */
  @SuppressWarnings("unchecked")
  public J setAge(int age) {
    if (age < 0 || age > 150) {
      throw new IllegalArgumentException("Age must be between 0 and 150");
    }
    this.age = age;
    return (J) this;
  }

  /**
   * Gets the user's current age.
   *
   * @return the user's age in years, or 0 if not set
   */
  public int getAge() {
    return this.age;
  }
  ```

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
public class Customer<J extends Customer<J>> extends Entity<J> {
  private int tier;

  @SuppressWarnings("unchecked")
  public J setTier(int tier) {
    this.tier = tier;
    return (J) this;
  }
}

// Direct usage:
Customer<?> c = new Customer<>()
    .setId("C-1")
    .setDescription(null)
    .setTier(2);

// Client extension:
public class PremiumCustomer extends Customer<PremiumCustomer> {
  public PremiumCustomer setPremiumLevel(int level) {
    return this;
  }
}
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
## Class design policy (JWebMP/GuicedEE Pattern)

Extensibility rules (JWebMP/GuicedEE Ecosystems)
- ALL types using CRTP MUST be declared as extensible (NOT final) to enable type-safe client extension.
  - Abstract base (class):
    ```java
    public abstract class Base<J extends Base<J>> {
      @SuppressWarnings("unchecked")
      public J setName(String name) { /* ... */ return (J) this; }
    }
    ```
  - Concrete extensible subtype:
    ```java
    public class User<J extends User<J>> extends Base<J> {
      @SuppressWarnings("unchecked")
      public J setAge(int age) { /* ... */ return (J) this; }
    }
    ```
  - Client extension capability:
    ```java
    public class ExtendedUser extends User<ExtendedUser> {
      public ExtendedUser setCustomField(String value) { 
        return this; 
      }
    }
    ```
  - Interface form (where appropriate):
    ```java
    public interface Fluent<J extends Fluent<J>> {
      J setName(String name);
    }
    ```

JWebMP/GuicedEE specific guidance
- **DO NOT use `final` on CRTP classes**: All JWebMP and GuicedEE components are designed for client extension
- **Library classes are intentionally extensible**: This enables type-safe customization by client applications
- **Concrete implementations remain generic**: Use `User<J extends User<J>>` pattern even for concrete classes
- **Client code flexibility**: Applications can extend any library class while maintaining type safety

Prohibitions and guidance
- Do NOT make CRTP classes `final` in JWebMP/GuicedEE ecosystems
- Do NOT publish non‑CRTP base classes intended to be extended. All bases intended for subclassing must be CRTP‑parameterized (`abstract class Base<J extends Base<J>>`).
- Avoid sealed classes in JWebMP/GuicedEE (conflicts with client extensibility)
- Keep fluent mutators handwritten with method‑level `@SuppressWarnings("unchecked")` and `return (J) this;`. Do not use Lombok‑generated setters for CRTP return types.
- Under `@org.jspecify.annotations.NullMarked`, mark only truly nullable values with `@org.jspecify.annotations.Nullable`.

LLM routing and checks (JWebMP/GuicedEE)
- When generating ANY CRTP class in JWebMP/GuicedEE context, NEVER emit `final`
- Ensure all CRTP classes use the generic self-type pattern: `Class<J extends Class<J>>`
- All fluent setters must return `J` (not the concrete type)
- Flag as violation: `final` CRTP classes in JWebMP/GuicedEE projects
- Flag as violation: non‑CRTP classes that expose fluent setters and should be extensible