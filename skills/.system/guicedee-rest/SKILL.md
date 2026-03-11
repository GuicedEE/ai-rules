---
name: guicedee-rest
description: "Build Jakarta REST (JAX-RS) services on Vert.x 5 inside GuicedEE: @Path/@GET/@POST route registration, parameter binding (@PathParam, @QueryParam, @HeaderParam, etc.), Guice-managed resource classes, response handling, content negotiation, and JPMS module setup. Use when creating REST endpoints, configuring Jakarta REST resources, or wiring JAX-RS services with Guice injection."
metadata:
  short-description: Jakarta REST (JAX-RS) services on Vert.x inside GuicedEE
---

# GuicedEE REST

Lightweight Jakarta REST (JAX-RS) adapter for Vert.x 5 with full GuicedEE integration.

## Core Concept

Annotate your classes with standard `@Path`, `@GET`, `@POST`, etc. — routes are discovered at startup via ClassGraph and registered on the Vert.x `Router` automatically. Resource instances are created through Guice, so `@Inject` works everywhere.

## Required Flow

1. Add `com.guicedee:rest` dependency (pulls in `web` transitively).
2. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.rest;
       opens my.app.resources to com.google.guice, com.guicedee.rest;
       opens my.app.dto to com.fasterxml.jackson.databind;
   }
   ```
3. Create resource classes with Jakarta REST annotations:
   ```java
   @Path("/users")
   public class UserResource {
       @Inject
       private UserService userService;

       @GET
       @Produces(MediaType.APPLICATION_JSON)
       public Uni<List<User>> listUsers() {
           return userService.findAll();
       }

       @POST
       @Consumes(MediaType.APPLICATION_JSON)
       @Produces(MediaType.APPLICATION_JSON)
       public Uni<User> createUser(CreateUserRequest request) {
           return userService.create(request);
       }

       @GET
       @Path("/{id}")
       public Uni<User> getUser(@PathParam("id") Long id) {
           return userService.findById(id);
       }
   }
   ```
4. Bootstrap GuicedEE — routes are registered automatically:
   ```java
   IGuiceContext.registerModuleForScanning.add("my.app");
   IGuiceContext.instance().inject();
   ```

## Supported Annotations

### HTTP Methods
`@GET`, `@POST`, `@PUT`, `@DELETE`, `@PATCH`, `@HEAD`, `@OPTIONS`

### Parameter Binding
`@PathParam`, `@QueryParam`, `@HeaderParam`, `@CookieParam`, `@FormParam`, `@MatrixParam`, `@BeanParam`

### Content Negotiation
`@Produces`, `@Consumes`

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ OperationRegistry scans for @Path-annotated classes via ClassGraph
 └─ Routes mapped to Vert.x Router
 └─ Resource instances obtained from Guice injector
```

## Return Types

Methods can return:
- Plain objects (serialized to JSON via Jackson)
- `Uni<T>` for reactive composition
- `Future<T>` for Vert.x futures
- `void` for fire-and-forget operations

## Non-Negotiable Constraints

- Resource classes must be in packages opened to `com.google.guice` and `com.guicedee.rest`.
- DTO packages must `opens` to `com.fasterxml.jackson.databind`.
- Module must `requires com.guicedee.rest;`.
- The `web` module is included transitively — do not create `HttpServer` manually.
- SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).


