# JSpecify Examples — Java nullness contracts

This file shows small, focused examples of applying JSpecify annotations in common scenarios. Copy/paste and adapt for your project.

---

## 1) Package-level non-null by default

package-info.java
```java
@org.jspecify.annotations.NullMarked
package com.example.users;
```

All references in this package are non-null unless annotated with @Nullable.

---

## 2) DTO with selectively nullable fields

```java
package com.example.users;

import org.jspecify.annotations.Nullable;

public record User(
    String id,
    String email,
    @Nullable String middleName,
    @Nullable String phoneNumber
) {}
```

---

## 3) Service with explicit nullness on API boundaries

```java
package com.example.users;

import java.util.Optional;
import java.util.UUID;
import org.jspecify.annotations.Nullable;

public interface UserService {
  Optional<User> findById(String id);

  /** Returns null if the user has no nickname set. */
  @Nullable String findNickname(UUID userId);

  /** Accepts null to clear the nickname. */
  void setNickname(String userId, @Nullable String nickname);
}
```

---

## 4) Generics and collections

```java
package com.example.collections;

import java.util.*;
import org.jspecify.annotations.Nullable;

class Example {
  List<@Nullable String> maybeNames = new ArrayList<>();
  Map<String, @Nullable Integer> counts = new HashMap<>();

  Optional<String> bestName() {
    return Optional.empty(); // prefer Optional over @Nullable return when conveying absence
  }
}
```

---

## 5) Overriding without widening nullness

```java
package com.example.override;

import org.jspecify.annotations.NullMarked;

@NullMarked
class BaseRepo {
  public String getRequired() { return "ok"; }
}

class DerivedRepo extends BaseRepo {
  @Override
  public String getRequired() { return super.getRequired(); }
}
```

---

## 6) Interop with MapStruct and Lombok

MapStruct mapper with explicit null handling:
```java
@Mapper(nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
        nullValueMappingStrategy = NullValueMappingStrategy.RETURN_NULL)
public interface UserMapper {
  UserDto toDto(User entity);
}
```

Lombok-generated getter on a nullable field:
```java
import lombok.Getter;
import org.jspecify.annotations.Nullable;

public class Customer {
  @Getter @Nullable
  private String title;
}
```

---

## 7) Boundary validation (fail fast)

```java
package com.example.boundary;

import org.jspecify.annotations.Nullable;

class Controller {
  Response handle(@Nullable String id) {
    if (id == null || id.isBlank()) {
      throw new IllegalArgumentException("id is required");
    }
    // proceed; inside @NullMarked code, prefer non-null
    return new Response(id);
  }
}
```

---

See also
- Topic README — ./README.md
- Rules — ./jspecify.rules.md
- Lombok — ../lombok/README.md
- MapStruct — ../mapstruct/README.md
- Logging — ../logging/README.md
