---
name: guicedee-openapi
description: "Automatic OpenAPI 3.1 spec generation and serving for GuicedEE with Vert.x 5: scans Jakarta REST resources at startup, serves /openapi.json and /openapi.yaml endpoints, Swagger annotations support, @OpenAPIDefinition configuration, and companion Swagger UI module. Use when generating API documentation, serving OpenAPI specs, or configuring Swagger annotations on REST resources."
metadata:
  short-description: OpenAPI 3.1 spec generation and serving inside GuicedEE
---

# GuicedEE OpenAPI

Automatic OpenAPI 3.1 spec generation and serving for the GuicedEE / Vert.x stack.

## Core Concept

Add the dependency, annotate your Jakarta REST resources with **Swagger annotations** (the `io.swagger.v3.oas.annotations.*` package), and the module scans them at startup — `/openapi.json` and `/openapi.yaml` are live with zero configuration.

> **Annotation choice — use Swagger, not MicroProfile.** This stack standardises on the
> Swagger v3 annotations from `io.swagger.v3.oas.annotations.*`. Do **not** mix in the
> MicroProfile OpenAPI annotations (`org.eclipse.microprofile.openapi.annotations.*`).
> The two packages share simple names (`@Schema`, `@Content`, `@Tag`, `@Parameter`,
> `@Operation`), so a stray import of the wrong package compiles but silently fails to
> drive the generated spec. Always import from `io.swagger.v3.oas.annotations`.

## Required Flow

1. Add `com.guicedee:openapi` dependency.
2. Annotate REST resources with Swagger annotations (note the import package):
   ```java
   import io.swagger.v3.oas.annotations.Operation;
   import io.swagger.v3.oas.annotations.media.Content;
   import io.swagger.v3.oas.annotations.media.Schema;
   import io.swagger.v3.oas.annotations.responses.ApiResponse;
   import io.swagger.v3.oas.annotations.tags.Tag;

   @Path("/users")
   @Tag(name = "Users", description = "User management operations")
   public class UserResource {

       @GET
       @Operation(summary = "List all users")
       @ApiResponse(responseCode = "200", description = "Success",
           content = @Content(schema = @Schema(implementation = User.class)))
       public List<User> listUsers() { ... }

       @POST
       @Operation(summary = "Create a new user")
       @ApiResponse(responseCode = "200", description = "Created user",
           content = @Content(schema = @Schema(implementation = User.class)))
       public User createUser(CreateUserRequest request) { ... }
   }
   ```
3. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.openapi;
   }
   ```
4. Bootstrap GuicedEE — OpenAPI endpoints are live automatically:
   ```java
   IGuiceContext.registerModuleForScanning.add("my.app");
   IGuiceContext.instance().inject();
   // GET /openapi.json → OpenAPI 3.1 JSON spec
   // GET /openapi.yaml → OpenAPI 3.1 YAML spec
   ```

## Companion: Swagger UI

Add the `guiced-swagger-ui` module for a browsable UI at `/swagger/`:

```xml
<dependency>
  <groupId>com.guicedee</groupId>
  <artifactId>swagger-ui</artifactId>
</dependency>
```

The UI reads from `/openapi.json` automatically — zero code required.

## Supported Annotations

Use the **Swagger v3** annotations from `io.swagger.v3.oas.annotations.*`:
- `@OpenAPIDefinition` — API-level info, servers, security
- `@Tag` (`...annotations.tags.Tag`) — resource grouping
- `@Operation` (`...annotations.Operation`) — per-endpoint summary, description
- `@ApiResponse` / `@ApiResponses` (`...annotations.responses.*`) — response documentation
- `@Parameter` (`...annotations.Parameter`) — parameter documentation
- `@Schema` (`...annotations.media.Schema`) — model schema customization
- `@Content` (`...annotations.media.Content`) — response content types
- `@RequestBody` (`...annotations.parameters.RequestBody`) — request body documentation

## Troubleshooting

### `additionalProperties must be either a Boolean or a Schema instance`

A consuming service (e.g. an OpenAPI registry that merges specs) fails to **parse**
a produced spec with this error, typically pointing at a `Map`-typed property:

```
... Components["schemas"] -> ["ArrangementCreateDTO"] -> Schema["properties"]
    -> ["classifications"] -> Schema["additionalProperties"]
```

**Root cause — this is a consumer-side deserialization bug, *not* a producer fault.**
A `Map<String, V>` field correctly generates `additionalProperties: { type: ... }`,
which is **valid** OpenAPI 3.1 — Swagger UI and browsers read it fine. The failure
happens only when the consumer deserializes the spec with a **plain Jackson
`ObjectMapper`**. That mapper lacks Swagger's custom `Schema` deserializers, so it
turns the `additionalProperties` JSON object into a `LinkedHashMap` and then
`Schema.setAdditionalProperties(...)` throws, because the value is neither a
`Boolean` nor a `Schema`.

**Fix — deserialize with Swagger's own configured mapper.** Use
`io.swagger.v3.core.util.Json31.mapper()` (OpenAPI 3.1) or `Json.mapper()` (3.0),
which register the proper `Schema` deserializers. Copy it before tweaking features
so you don't mutate the shared singleton:

```java
import io.swagger.v3.core.util.Json31;

ObjectMapper mapper = Json31.mapper().copy()
        .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

OpenAPI remoteSpec = mapper.readValue(specJson, OpenAPI.class);
```

This corrects **all** `Map`/`additionalProperties` cases across every service at once
— no per-DTO annotation needed. (`io.swagger.v3.core.util` is exported by the shaded
`com.guicedee.modules.services.openapi` module.)

> **Do not** "fix" this by avoiding `Map` fields or hand-annotating each endpoint —
> the produced spec is already correct. The single robust fix is the consumer mapper.

## Non-Negotiable Constraints

- Use the **Swagger** annotation package `io.swagger.v3.oas.annotations.*`; never the MicroProfile package.
- Always give endpoints an explicit `@ApiResponse` with `@Schema(implementation = …)` for typed responses.
- Module must `requires com.guicedee.openapi;`.
- Requires `rest` module for Jakarta REST resource scanning.
- The OpenAPI module is registered automatically — no `provides` needed.
- Spec generation happens at startup via ClassGraph scanning.
