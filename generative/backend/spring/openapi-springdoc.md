# Spring (Boot MVC) — OpenAPI with springdoc

Scope
- Non-reactive Spring MVC OpenAPI 3 documentation using springdoc-openapi.
- Covers dependencies, UI and endpoints, grouping, JSON/YAML generation, security schemes, pagination/error models, versioning, and CI publishing.
- Provider posture: The Rules Repository supports three OpenAPI providers — Swagger (default), MicroProfile OpenAPI, and Springdoc (this page). For cross‑stack standards, see ../../platform/observability/openapi.md. Health endpoints default to MicroProfile (/health, /health/ready, /health/live); Spring Actuator endpoints are supported but not the default.

Dependencies
- org.springdoc:springdoc-openapi-starter-webmvc-ui (UI + endpoints)
- Optional: org.springdoc:springdoc-openapi-starter-common (if using custom setups)
- Optional: OpenAPI diff tool for CI (openapi-diff)

Maven (snippet)
```xml
<dependency>
  <groupId>org.springdoc</groupId>
  <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
  <version>2.6.0</version>
</dependency>
```

Gradle (Kotlin DSL)
```kotlin
dependencies {
  runtimeOnly("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.6.0")
}
```

Endpoints and UI
- JSON: /v3/api-docs
- YAML: /v3/api-docs.yaml (enabled with springdoc.api-docs.enabled=true)
- UI: /swagger-ui/index.html
- Grouped endpoints: /v3/api-docs/{group}

Baseline configuration (application.yml)
```yaml
springdoc:
  api-docs:
    enabled: true
    path: /v3/api-docs
  swagger-ui:
    enabled: true
    path: /swagger-ui
    operationsSorter: method
    tagsSorter: alpha
    displayOperationId: true
```

Production posture
- Restrict UI in production (auth, IP allowlist, or disable).
- Keep /v3 endpoints accessible only to trusted systems (e.g., CI or internal network) if contracts are sensitive.
- Example per-profile control:
```yaml
# application-prod.yml
springdoc:
  swagger-ui:
    enabled: false
```
- Or protect via Spring Security rules; see [rules/generative/backend/spring/security-mvc.md](./security-mvc.md)

Grouping APIs
- Use GroupedOpenApi to split large surfaces (e.g., admin vs public, versioned groups).
```java
// com.example.api.OpenApiGroupingConfig.java
package com.example.api;

import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
class OpenApiGroupingConfig {

  @Bean
  GroupedOpenApi publicApi() {
    return GroupedOpenApi.builder()
        .group("public")
        .pathsToMatch("/api/**")
        .pathsToExclude("/api/admin/**")
        .build();
  }

  @Bean
  GroupedOpenApi adminApi() {
    return GroupedOpenApi.builder()
        .group("admin")
        .pathsToMatch("/api/admin/**")
        .build();
  }
}
```

API metadata
```java
// com.example.api.OpenApiConfig.java
package com.example.api;

import io.swagger.v3.oas.models.*;
import io.swagger.v3.oas.models.info.*;
import io.swagger.v3.oas.models.servers.Server;
import org.springdoc.core.customizers.OpenApiCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
class OpenApiConfig {

  @Bean
  OpenAPI baseOpenApi() {
    return new OpenAPI()
      .info(new Info()
        .title("Example Service API")
        .version("1.0.0")
        .description("HTTP API for Example Service")
        .contact(new Contact().name("API Owners").email("api@example.com"))
        .license(new License().name("Apache 2.0").url("http://www.apache.org/licenses/LICENSE-2.0.html")))
      .servers(List.of(new Server().url("/"))); // relative base; set env-specific at gateway
  }

  @Bean
  OpenApiCustomizer sortAndTagCustomizer() {
    return openApi -> {
      // add global tags or standardize anything required
    };
  }
}
```

Security — JWT Bearer
- Define a global bearer security scheme; annotate operations or apply globally.
```java
// com.example.api.OpenApiSecurity.java
package com.example.api;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.security.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
class OpenApiSecurity {

  @Bean
  OpenAPI securityOpenApi(OpenAPI openApi) {
    final String scheme = "bearer-jwt";
    var bearer = new SecurityScheme()
        .name(scheme)
        .type(SecurityScheme.Type.HTTP)
        .scheme("bearer")
        .bearerFormat("JWT");
    openApi.getComponents()
        .addSecuritySchemes(scheme, bearer);
    openApi.addSecurityItem(new SecurityRequirement().addList(scheme));
    return openApi;
  }
}
```

Annotating operations
```java
// com.example.app.user.UserController.java
package com.example.app.user;

import com.example.api.user.UserCreateRequest;
import com.example.api.user.UserResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.*;
import io.swagger.v3.oas.annotations.parameters.RequestBody;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
class UserController {

  @Operation(
    summary = "Create a user",
    requestBody = @RequestBody(
      required = true,
      content = @Content(mediaType = "application/json",
        schema = @Schema(implementation = UserCreateRequest.class))
    ),
    responses = {
      @ApiResponse(responseCode = "201", description = "Created",
        content = @Content(schema = @Schema(implementation = UserResponse.class))),
      @ApiResponse(responseCode = "409", description = "Conflict",
        content = @Content(schema = @Schema(implementation = org.springframework.http.ProblemDetail.class)))
    }
  )
  @PostMapping
  ResponseEntity<UserResponse> create(@org.springframework.web.bind.annotation.RequestBody UserCreateRequest req) {
    // ...
    return ResponseEntity.status(201).body(new UserResponse(/*...*/));
  }
}
```

Problem Details and error model
- Spring Framework 6+ ProblemDetail integrates with springdoc schemas automatically.
- Standardize problem "type" URLs; ensure consistent mapping in @ControllerAdvice. See [rules/generative/backend/spring/mvc-rest-validation.md](./mvc-rest-validation.md)

Validation annotations
- Bean Validation constraints on DTOs are reflected in schema (min/max/format). Prefer precise constraints for better contracts.

Pagination documentation
- Prefer explicit parameters (page, size, sort) for stable contracts; document caps and defaults.
```java
// com.example.api.user.UserListParams.java
package com.example.api.user;

import io.swagger.v3.oas.annotations.media.Schema;

public record UserListParams(
  @Schema(description = "Page number (1-based)", example = "1", minimum = "1") Integer page,
  @Schema(description = "Page size", example = "20", minimum = "1", maximum = "100") Integer size,
  @Schema(description = "Sort expression", example = "email,asc") String sort
) {}
```

```java
// in controller
@Operation(summary = "List users")
@GetMapping
ResponseEntity<com.example.api.user.UserListResponse> list(
  @ParameterObject UserListParams params
) { /* ... */ }
```
- If using Pageable, consider springdoc-data-rest integration or a custom @PageableAsQueryParam-like approach to keep the API explicit.

Hiding internal endpoints
- Mark internal or non-API endpoints with @io.swagger.v3.oas.annotations.Hidden or exclude via GroupedOpenApi.

Examples and schemas
- Use @ExampleObject for concrete payloads where helpful (error responses, typical DTOs).
```java
@Operation(
  summary = "Get user",
  responses = {
    @ApiResponse(
      responseCode = "200",
      content = @Content(
        mediaType = "application/json",
        examples = @ExampleObject(name = "User", value = "{\"id\":1,\"email\":\"a@b.test\",\"name\":\"Alice\"}")
      )
    )
  }
)
```

Versioning and deprecation
- Group per version (e.g., group "v1") and include path prefix /api/v1/.
- Mark deprecated operations with @Deprecated (class/method) and OpenAPI annotations where desired.
- Use tags like "Users (v1)" to keep surfaces organized.

Generating JSON/YAML contracts
- Endpoints:
  - /v3/api-docs (JSON)
  - /v3/api-docs.yaml (YAML)
  - /v3/api-docs/{group} for group-specific documents
- CI step: fetch and publish as artifacts. Example (PowerShell):
```powershell
# Save public group OpenAPI JSON
Invoke-WebRequest -Uri http://localhost:8080/v3/api-docs/public -OutFile .\build\openapi-public.json
```

Publishing contracts (CI)
- Store contracts as build artifacts or push to a contract registry repository.
- Optional: validate no breaking changes with openapi-diff.
  - Tool example: https://github.com/OpenAPITools/openapi-diff
  - CI strategy: compare main branch contract with PR artifact; fail on breaking diffs.

Security for UI/Docs
- Restrict /swagger-ui/** and /v3/api-docs/** in production environments via Spring Security:
```java
// in SecurityFilterChain
.authorizeHttpRequests(auth -> auth
  .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").hasRole("OPS")
  // ...
)
```

Contract stability policy
- DTOs are API contracts; evolve with additive changes when possible (new fields optional).
- Breaking changes require new versioned routes/groups and migration guidance.

Checklist
- springdoc starter wired; endpoints reachable in dev/test; restricted in prod.
- GroupedOpenApi configured for logical API subsets or versions.
- JWT bearer scheme defined; security added globally or per-operation.
- Problem Details consistently modeled and examples provided for errors.
- Pagination parameters documented with defaults and caps.
- CI publishes contracts; optional openapi-diff gate for breaking changes.

See also
- Topic index — [rules/generative/backend/spring/README.md](./README.md)
- MVC REST & Validation — [rules/generative/backend/spring/mvc-rest-validation.md](./mvc-rest-validation.md)
- Security (non-reactive) — [rules/generative/backend/spring/security-mvc.md](./security-mvc.md)
- Configuration & Profiles — [rules/generative/backend/spring/configuration-profiles.md](./configuration-profiles.md)
- Observability — [rules/generative/backend/spring/actuator-observability.md](./actuator-observability.md)