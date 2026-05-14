---
name: guicedee-openapi
description: "Automatic OpenAPI 3.1 spec generation and serving for GuicedEE with Vert.x 5: scans Jakarta REST resources at startup, serves /openapi.json and /openapi.yaml endpoints, Swagger annotations support, @OpenAPIDefinition configuration, and companion Swagger UI module. Use when generating API documentation, serving OpenAPI specs, or configuring Swagger annotations on REST resources."
metadata:
  short-description: OpenAPI 3.1 spec generation and serving inside GuicedEE
---

# GuicedEE OpenAPI

Automatic OpenAPI 3.1 spec generation and serving for the GuicedEE / Vert.x stack.

## Core Concept

Add the dependency, annotate your Jakarta REST resources with Swagger/OpenAPI annotations, and the module scans them at startup — `/openapi.json` and `/openapi.yaml` are live with zero configuration.

## Required Flow

1. Add `com.guicedee:openapi` dependency.
2. Annotate REST resources with Swagger/OpenAPI annotations:
   ```java
   @Path("/users")
   @Tag(name = "Users", description = "User management operations")
   public class UserResource {

       @GET
       @Operation(summary = "List all users")
       @APIResponse(responseCode = "200", description = "Success",
           content = @Content(schema = @Schema(implementation = User.class)))
       public List<User> listUsers() { ... }

       @POST
       @Operation(summary = "Create a new user")
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

All standard Swagger/OpenAPI annotations are supported:
- `@OpenAPIDefinition` — API-level info, servers, security
- `@Tag` — resource grouping
- `@Operation` — per-endpoint summary, description
- `@APIResponse` / `@APIResponses` — response documentation
- `@Parameter` — parameter documentation
- `@Schema` — model schema customization
- `@Content` — response content types
- `@RequestBody` — request body documentation

## Non-Negotiable Constraints

- Module must `requires com.guicedee.openapi;`.
- Requires `rest` module for Jakarta REST resource scanning.
- The OpenAPI module is registered automatically — no `provides` needed.
- Spec generation happens at startup via ClassGraph scanning.


