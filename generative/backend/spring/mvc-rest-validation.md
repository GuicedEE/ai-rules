# Spring (Boot MVC) — REST Controllers and Validation

Scope
- Non-reactive REST API design and implementation using Spring MVC (@RestController) with Jakarta Bean Validation, exception translation, pagination/sorting conventions, and content negotiation.
- Complements: ./overview-setup.md and ./configuration-profiles.md

Goals
- Thin controllers that validate inputs, delegate to services, and return representation DTOs.
- Deterministic error model (Problem Details) with centralized exception handling.
- Predictable pagination/sorting contracts and content negotiation.
- No entities exposed across API boundary; use DTOs and mappers.

Controller design principles
- Keep controllers small; route, validate, and map to services. No business logic in controllers.
- Use DTOs (prefer Java records) for request/response. Avoid exposing JPA entities.
- Validate inputs with Bean Validation; prefer @Valid on method parameters and request bodies.
- Return ResponseEntity<DTO> or DTO directly when sensible; avoid mixing view types.

DTO validation (request models)
```java
// src/main/java/com/example/api/user/UserCreateRequest.java
package com.example.api.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UserCreateRequest(
    @NotBlank @Email String email,
    @NotBlank @Size(min = 2, max = 64) String name
) {}
```

Controller with validation and explicit status codes
```java
// src/main/java/com/example/app/user/UserController.java
package com.example.app.user;

import com.example.api.user.UserCreateRequest;
import com.example.api.user.UserResponse;
import com.example.domain.user.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
class UserController {

  private final UserService service;

  UserController(UserService service) {
    this.service = service;
  }

  @PostMapping
  ResponseEntity<UserResponse> create(@Valid @RequestBody UserCreateRequest req) {
    var created = service.create(req);
    return ResponseEntity.status(201).body(created);
  }

  @GetMapping("/{id}")
  ResponseEntity<UserResponse> get(@PathVariable long id) {
    return ResponseEntity.ok(service.getById(id));
  }
}
```

Centralized exception translation (Problem Details)
- Use Spring Framework 6+ ProblemDetail to produce RFC 7807 responses.
- Map domain exceptions and validation errors to stable problem types and status codes.

Domain exception example
```java
// src/main/java/com/example/domain/errors/DomainExceptions.java
package com.example.domain.errors;

public final class DomainExceptions {
  private DomainExceptions() {}
  public static class NotFound extends RuntimeException {
    public NotFound(String message) { super(message); }
  }
  public static class Conflict extends RuntimeException {
    public Conflict(String message) { super(message); }
  }
}
```

ControllerAdvice with ProblemDetail
```java
// src/main/java/com/example/app/errors/GlobalExceptionHandler.java
package com.example.app.errors;

import com.example.domain.errors.DomainExceptions;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
class GlobalExceptionHandler {

  @ExceptionHandler(MethodArgumentNotValidException.class)
  ProblemDetail handleValidation(MethodArgumentNotValidException ex) {
    ProblemDetail pd = ProblemDetail.forStatus(HttpStatus.UNPROCESSABLE_ENTITY);
    pd.setTitle("Validation failed");
    pd.setType(URI.create("https://errors.example.com/problem/validation"));
    Map<String, Object> details = new HashMap<>();
    details.put("errors", ex.getBindingResult().getFieldErrors().stream()
        .map(fe -> Map.of(
            "field", fe.getField(),
            "message", resolveMessage(fe),
            "rejectedValue", fe.getRejectedValue()))
        .toList());
    pd.setProperty("details", details);
    return pd;
  }

  private static String resolveMessage(FieldError fe) {
    return fe.getDefaultMessage() != null ? fe.getDefaultMessage() : "Invalid value";
  }

  @ExceptionHandler(DomainExceptions.NotFound.class)
  ProblemDetail handleNotFound(DomainExceptions.NotFound ex) {
    ProblemDetail pd = ProblemDetail.forStatus(HttpStatus.NOT_FOUND);
    pd.setTitle("Resource not found");
    pd.setType(URI.create("https://errors.example.com/problem/not-found"));
    pd.setDetail(ex.getMessage());
    return pd;
  }

  @ExceptionHandler(DomainExceptions.Conflict.class)
  ProblemDetail handleConflict(DomainExceptions.Conflict ex) {
    ProblemDetail pd = ProblemDetail.forStatus(HttpStatus.CONFLICT);
    pd.setTitle("Conflict");
    pd.setType(URI.create("https://errors.example.com/problem/conflict"));
    pd.setDetail(ex.getMessage());
    return pd;
  }
}
```

Pagination, sorting, and filtering
- Prefer explicit request parameters with stable defaults and caps:
  - page (1-based), size (max cap, e.g., 100), sort (comma-separated property[,asc|desc])
- Document defaults and limits in OpenAPI.
- Option A (explicit params): stable and framework-agnostic.
- Option B (Spring Data Pageable): convenient but couples API to framework details. If used, normalize input.

Explicit pagination example
```java
// src/main/java/com/example/app/Paging.java
package com.example.app;

public record Paging(int page, int size) {
  public static Paging of(Integer page, Integer size) {
    int p = page == null || page < 1 ? 1 : page;
    int s = size == null || size < 1 ? 20 : Math.min(size, 100);
    return new Paging(p, s);
  }
}
```

```java
// src/main/java/com/example/app/user/UserControllerList.java
package com.example.app.user;

import com.example.api.user.UserListResponse;
import com.example.app.Paging;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
class UserControllerList {

  private final UserQueryService queries;

  UserControllerList(UserQueryService queries) {
    this.queries = queries;
  }

  @GetMapping
  ResponseEntity<UserListResponse> list(
      @RequestParam(required = false) Integer page,
      @RequestParam(required = false) Integer size,
      @RequestParam(required = false) String sort
  ) {
    var paging = Paging.of(page, size);
    var result = queries.list(paging, sort);
    return ResponseEntity.ok(result);
  }
}
```

Response envelope for lists (example)
```java
// src/main/java/com/example/api/user/UserListResponse.java
package com.example.api.user;

import java.util.List;

public record UserListResponse(
    List<UserResponse> items,
    int page,
    int size,
    long total
) {}
```

Content negotiation and serialization
- Default media type: application/json; disable XML unless explicitly required.
- Configure ObjectMapper predictably (e.g., JavaTimeModule, snake/camel case policy).
- For large payloads, ensure streaming is not required (non-reactive); paginate or chunk results.

Disable XML on classpath (avoid adding XML starters)
- Do not include jackson-dataformat-xml unless required.
- If XML must be disabled despite presence, customize HttpMessageConverters to remove XML.

ID and version handling
- Never trust client-provided IDs for creates; return server-assigned identifiers.
- Use @Version for optimistic locking and return ETags/If-Match where appropriate.

Validation messages and i18n
- Provide message bundles for validation messages (ValidationMessages.properties).
- Use message keys on constraints for stable error localization.

CORS
- Configure CORS per endpoint or globally for browser clients; restrict origins, headers, and methods in production.

Testing controllers (MockMvc)
- Prefer slice tests with @WebMvcTest for routing/validation/serialization.
- Use integration tests with @SpringBootTest + Testcontainers for end-to-end paths.
- See: ./testing.md

Checklist
- Controllers are thin; DTOs in/out; no entities on API.
- Validation via Bean Validation; centralized Problem Details advice.
- Pagination defaults and caps documented; deterministic sorting.
- JSON only (unless required); consistent ObjectMapper.
- Tests cover routing, validation, and error envelopes.

See also
- Topic index — ./README.md
- Overview & setup — ./overview-setup.md
- Security (non-reactive) — ./security-mvc.md
- OpenAPI (springdoc) — ./openapi-springdoc.md