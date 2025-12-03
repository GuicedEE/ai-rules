# Java Null Safety & Getter Rules

Audience: JVM services and libraries that prioritize null safety, clear API contracts, and defensive getters when reading from the Java language stack.

## Getter Rules

### Complex Objects and Collections Must Never Return Null

When getters expose complex objects or collections, they **must not return null**. Instead, lazy initialize the backing field and always return a concrete instance. This keeps callers from having to null-check every access and keeps object identities consistent.

#### Pattern: Lazy Initialization

```java
private List<Item> items;

public List<Item> getItems() {
    if (this.items == null) {
        this.items = new ArrayList<>();
    }
    return this.items;
}
```

#### Pattern: With Custom Objects

```java
private Address address;

public Address getAddress() {
    if (this.address == null) {
        this.address = new Address();
    }
    return this.address;
}
```

#### Rationale

- **Prevents NullPointerException**: Consumers never need to guard getters with null checks.
- **Consistent Behavior**: Every getter reliably returns an initialized reference.
- **Cleaner Code**: Calling code stays focused on domain logic rather than safety checks.
- **Lazy Loading**: Instances are created only when needed.

#### Guidelines

1. **Always use lazy initialization** for getters that expose collections or custom objects.
2. **Initialize collections appropriately**:
   - `new ArrayList<>()` for lists
   - `new HashSet<>()` for sets
   - `new HashMap<>()` for maps
3. **Maintain a single instance** by reusing the field once initialized.
4. **Thread-safety**: In multi-threaded contexts, consider synchronization or thread-safe suppliers if initialization races are possible.

#### Practical Application

```java
private List<String> names;
private Set<UUID> identifiers;
private Map<String, Object> metadata;
private CustomObject custom;

public List<String> getNames() {
    if (this.names == null) {
        this.names = new ArrayList<>();
    }
    return this.names;
}

public Set<UUID> getIdentifiers() {
    if (this.identifiers == null) {
        this.identifiers = new HashSet<>();
    }
    return this.identifiers;
}

public Map<String, Object> getMetadata() {
    if (this.metadata == null) {
        this.metadata = new HashMap<>();
    }
    return this.metadata;
}

public CustomObject getCustom() {
    if (this.custom == null) {
        this.custom = new CustomObject();
    }
    return this.custom;
}
```

#### Anti-Pattern: What NOT to Do

```java
// ❌ DON'T: Return null for complex objects
public List<Item> getItems() {
    return this.items;  // Could be null!
}

// ❌ DON'T: Create a new instance every time
public List<Item> getItems() {
    return new ArrayList<>(this.items);  // Breaks identity and wastes memory
}
```

## Null Safety and JSpecify

This project standardizes on **JSpecify** for null-safety annotations and API contracts. Annotate packages or modules with `@NullMarked` and only mark references as `@Nullable` when null is meaningful and unavoidable.

### Optional Return Types

When a synchronous (non-reactive) method may legitimately have no value to return, prefer `Optional<T>` over nullable references. If the expected return value can never be absent, keep the base type to avoid unnecessary wrapping. This shifts responsibility for handling absence into the caller without introducing null.

- **Non-reactive methods**: use `Optional<T>` only when the return can legitimately be absent.
- **Reactive methods**: rely on Mutiny (`Uni`, `Multi`, etc.) or other reactive publishers to model presence/absence and **never** wrap those reactive types in `Optional`.

#### Patterns

```java
public Optional<User> findUserById(UUID id) { /* ... */ }
public Optional<Address> getUserAddress() { /* ... */ }
public Optional<List<Item>> findItemsByCategory(String category) { /* ... */ }
```

#### Reactive Exception

```java
public Uni<User> findUserByIdAsync(UUID id) { /* reactive implementation */ }
public Uni<List<Item>> findItemsAsync(String category) { /* reactive implementation */ }
```

#### Anti-Pattern: What NOT to Do

```java
// ❌ DON'T: Use @Nullable instead of Optional for non-reactive methods
@Nullable
public User findUserById(UUID id) { /* caller must null-check */ }

// ❌ DON'T: Return null without Optional
public List<Item> findItems(String category) {
    return null; // Violates rules
}

// ❌ DON'T: Wrap reactive types inside Optional
public Optional<Uni<User>> findUserAsync(UUID id) { /* incorrect */ }
```

### Using JSpecify Annotations

```java
import org.jspecify.annotations.Nullable;
import org.jspecify.annotations.NullMarked;

@NullMarked
public class UserService {
    public Optional<User> findById(UUID id) { /* ... */ }

    public String getOptionalMetadata(@Nullable String key) { /* key can be null */ }
}
```

### Decision Tree for Return Types

```
Can method return no value / nullable?
├─ YES: Is the method reactive (Uni, Mono, etc)?
│  ├─ YES: Return Uni<T> or equivalent (no Optional needed)
│  └─ NO: Return Optional<T>
└─ NO: Return T directly
```

## Lombok Configuration

- Enable chained setters: `lombok.accessors.chain = true`
- Disable `@Generated` annotation generation.
- Do not let Lombok add annotations to compiled classes when analysis or tooling needs cleaner metadata.

## Null Safety Summary

- Apply lazy initialization for collections and complex object getters.
- Document nullable contracts through JSpecify (`@Nullable`, `@NullMarked`) consistently.
- Use `Optional<T>` for non-reactive methods that may have no result; rely on reactive publishers for async flows.
- Never return bare `null` from public APIs without an `Optional` wrapper.

## Code Quality

- Favor empty collections over `null` collections.
- Keep initialization patterns consistent across the codebase to reduce footguns.
- When deviating from these rules to meet practical constraints, document the rationale and consider updating this guide if the deviation becomes common.
