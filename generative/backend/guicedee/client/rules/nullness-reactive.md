# GuicedEE Inject Client — Nullness and Reactive Rules

Summary
- The client library consumes GuicedEE Core, adopts JSpecify for nullness, and uses Mutiny for reactive flows.

Nullness (JSpecify)
- Use org.jspecify:jspecify annotations. Prefer package-level @NullMarked where feasible.
- Treat parameters and return values as non-null by default; mark optional values with @Nullable.
- Avoid using javax/FindBugs nullness annotations — do not mix frameworks.
- Document nullness of SPI contracts explicitly. Example:
  - interface IGuiceProvider<T> { T get(); }
  - If a provider may return empty, prefer Optional<T> or Uni<T> with failure/empty signaling instead of returning null.

Reactive (Mutiny)
- Use Mutiny types for async and stream operations: Uni<T> for single async result, Multi<T> for streams.
- Do not block event loops. Compose using onItem()/onFailure() chains or await().indefinitely() only in managed worker contexts.
- When wrapping Vert.x futures, convert via Uni.createFrom().completionStage or existing adapters in the stack.

Code patterns
```java
import io.smallrye.mutiny.Uni;
import org.jspecify.annotations.Nullable;

public interface ExampleService {
    Uni<String> fetchValue(String id);

    @Nullable String optionalSyncLookup(String key);
}
```

SPI guidance
- For startup/shutdown hooks (e.g., IGuicePreStartup, IGuicePostStartup), prefer async variants returning Uni<Void> when work is non-trivial.
- Register implementations under META-INF/services or via JPMS provides in module-info.java.

Cross-references
- JSpecify rules — ../../jspecify/README.md
- Vert.x 5 — ../../vertx/README.md
