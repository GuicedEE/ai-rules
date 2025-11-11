# JSpecify Rules — Nullness Contracts for Java

Purpose
- Provide clear, enforceable conventions for applying JSpecify annotations in Java libraries and services.
- Reduce NullPointerExceptions by making nullness explicit and verifiable by tooling.

Scope
- Applies to Java codebases that choose Structural: JSpecify in prompts.
- Complements Lombok, MapStruct, and Logging guidance; interoperates with Hibernate Reactive, Vert.x, and other backend topics.

---

## Core principles
1) Non-null by default with @NullMarked
- Annotate packages via package-info.java or modules/classes to make references non-null by default.
- Only use @Nullable where null is a legitimate value.

2) Document API boundaries
- Public methods and DTOs must encode nullness intent on inputs and outputs.
- For cross-language consumers (Kotlin, TS via OpenAPI), prefer non-null defaults and explicit @Nullable.

3) Prefer fail-fast over silent nulls
- Validate external inputs at boundaries; inside @NullMarked code, avoid passing/returning null where not annotated.

4) Be specific on generics and nested types
- Use type-use nullness on type parameters and wildcards (e.g., List<@Nullable String>). Avoid ambiguous raw types.

---

## How to apply

Package-level default (recommended)
- Create package-info.java in each package:
```java
@org.jspecify.annotations.NullMarked
package com.example.myapp;
```

Class-level (if package-level not possible)
```java
import org.jspecify.annotations.NullMarked;

@NullMarked
public class UserService { /* ... */ }
```

Mark allowed nulls explicitly
```java
import org.jspecify.annotations.Nullable;

public record User(@Nullable String middleName) {}

public @Nullable String findNickname(@Nullable UUID userId) { /* ... */ }
```

Generics and collections
```java
import java.util.*;
import org.jspecify.annotations.Nullable;

List<@Nullable String> maybeNames = new ArrayList<>();
Map<String, @Nullable Integer> counts = new HashMap<>();
Optional<String> maybeName = Optional.empty(); // avoid @Nullable Optional; prefer Optional.empty()
```

Overriding and inheritance
- Subclass overrides must not widen nullness (Liskov):
  - If base method returns non-null, override must also return non-null.
  - If base method parameter is non-null, override must accept non-null (you may narrow to @Nullable in base only, not in override).

Interop notes
- Lombok: annotate on generated members using onX features or place annotations on fields/getters after generation; ensure Lombok config doesn’t strip type-use annotations.
- MapStruct: map nullability explicitly; configure nullValueCheckStrategy/NullValueMappingStrategy to align with @Nullable semantics.
- Hibernate Reactive: prefer non-null entity fields unless domain permits null; annotate nullable columns and validate at service layer.

---

## Tooling configuration

Maven
- Include JSpecify as provided/compileOnly and enable your analyzer.
- Error Prone example (pom):
```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <configuration>
    <compilerArgs>
      <arg>-Xep:NullAway:ERROR</arg>
    </compilerArgs>
    <annotationProcessorPaths>
      <path>
        <groupId>org.jspecify</groupId>
        <artifactId>jspecify</artifactId>
        <version>1.0.0</version>
      </path>
    </annotationProcessorPaths>
  </configuration>
</plugin>
```

Gradle (Kotlin DSL)
```kotlin
dependencies {
  compileOnly("org.jspecify:jspecify:1.0.0")
  annotationProcessor("org.jspecify:jspecify:1.0.0")
  errorprone("com.google.errorprone:error_prone_core:2.26.1")
}

tasks.withType<JavaCompile>().configureEach {
  options.errorprone.errorproneArgs.addAll("-Xep:NullAway:ERROR")
}
```

IDE
- IntelliJ IDEA: enable external nullability annotations and inspection profile; ensure type-use annotations are considered.

---

## Patterns and anti-patterns

Do
- Use @NullMarked widely; use @Nullable sparingly.
- Document external API nullness; prefer Optional<T> over @Nullable T for return values that may be absent (except on DTOs where field null conveys absence).
- Validate deserialized input (JSON, DB) at boundaries.

Avoid
- @Nullable Optional<T> — prefer Optional.empty().
- Returning null collections/optionals — return empty instances instead.
- Mixing multiple nullness systems without a plan (e.g., javax.annotation vs JSpecify) — standardize on JSpecify; add adapters only at boundaries.

---

## Testing guidance
- Add unit tests that assert NPEs are not thrown in normal paths and that boundary validators reject nulls when required.
- Add static analysis to CI and fail builds on nullness violations.

---

## See also
- JSpecify topic README — ./README.md
- Examples — ./examples.md
- Lombok — ../lombok/README.md
- MapStruct — ../mapstruct/README.md
- Logging — ../logging/README.md
- Backend index — ../README.md
- Architecture DDD — ../../architecture/ddd/README.md
- Repository RULES — ../../../RULES.md
