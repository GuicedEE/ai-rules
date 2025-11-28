# Examples — GuicedEE Inject Client

This page provides minimal, self-contained examples demonstrating the conventions and rules for the GuicedEE Inject Client.

Contents
- CRTP fluent API example
- JSpecify nullness usage
- Reactive patterns with Mutiny (Uni/Multi)

CRTP fluent API example
```java
// CRTP: Curiously Recurring Template Pattern
// Enforces fluent APIs to return the most specific subtype for chaining.
public abstract class BaseFluent<T extends BaseFluent<T>> {
  public T withName(String name) {
    // set name...
    return self();
  }
  protected abstract T self();
}

public final class ClientConfig extends BaseFluent<ClientConfig> {
  private String name;
  @Override
  protected ClientConfig self() { return this; }
  public ClientConfig enableFeatureX(boolean enabled) { /* ... */ return this; }
}

// Usage
ClientConfig cfg = new ClientConfig()
  .withName("demo")
  .enableFeatureX(true);
```

JSpecify nullness usage
```java
import org.jspecify.annotations.Nullable;
import org.jspecify.annotations.NullMarked;

@NullMarked
public interface IGuiceProvider {
  /**
   * Returns a value or null when not available.
   */
  @Nullable String currentTenantId();
}
```

Reactive patterns with Mutiny
```java
import io.smallrye.mutiny.Uni;

public interface AsyncService {
  Uni<String> fetchData(String id);
}

// Example implementation: avoid blocking on event loop; compose non-blockingly.
public class AsyncServiceImpl implements AsyncService {
  @Override
  public Uni<String> fetchData(String id) {
    return Uni.createFrom().item(() -> "data-" + id)
      .onItem().transform(String::toUpperCase);
  }
}
```

See also
- Nullness & Reactive Rules — ../rules/nullness-reactive.md
- Topic index — ../README.md
