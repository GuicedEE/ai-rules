# Common Use Cases — GuicedEE Vert.x Web

This module covers practical implementations: REST APIs, WebSockets, static content, file uploads, CORS, and authentication.

## Recommended Approach: Use GuicedEE Addons

While the examples below demonstrate lower-level direct use of Vert.x Web routing and handlers, **GuicedEE provides dedicated addons for common use cases that are the recommended implementation approach:**

- **[guicedee-rest](https://github.com/GuicedEE)** — REST/CRUD APIs with automatic OpenAPI/Swagger documentation, parameter validation, content negotiation
- **[guicedee-websocket](https://github.com/GuicedEE)** — WebSocket connections with lifecycle management, message routing, and error handling
- **[guicedee-webservice](https://github.com/GuicedEE)** — SOAP/XML web services with automatic WSDL generation
- **[guicedee-graphql](https://github.com/GuicedEE)** — GraphQL schemas with automatic schema introspection, query validation, subscriptions

These addons provide:
- **Automatic Request/Response Binding** — Type-safe parameter and body binding
- **Lifecycle Management** — Proper resource cleanup, transaction handling
- **Built-in Validation** — JSR-303 Bean Validation integration
- **Security Integration** — Authorization annotations and access control
- **Documentation Generation** — OpenAPI/Swagger specs, WSDL, GraphQL introspection
- **Error Handling** — Standardized exception mapping to HTTP responses
- **Composition** — SPI-based plugin architecture for extensibility

The examples below show lower-level Vert.x Web mechanisms for scenarios requiring fine-grained control or custom implementations not covered by the addons. For standard REST/WebSocket/web service needs, prefer the dedicated GuicedEE addons.

## REST API Implementation

**Recommended:** Use **guicedee-rest** addon for automatic route discovery, validation, and OpenAPI documentation.

### Using guicedee-rest (Recommended)

```java
@Path("/api/users")
public class UserApiController
{
    @Inject
    private UserService userService;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public List<User> listUsers()
    {
        return userService.getAll();
    }

    @GET
    @Path("{id}")
    @Produces(MediaType.APPLICATION_JSON)
    public User getUser(@PathParam("id") long id)
    {
        return userService.findById(id);
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response createUser(User user)
    {
        User created = userService.create(user);
        return Response.status(201).entity(created).build();
    }

    @PUT
    @Path("{id}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public User updateUser(@PathParam("id") long id, User user)
    {
        return userService.update(id, user);
    }

    @DELETE
    @Path("{id}")
    public Response deleteUser(@PathParam("id") long id)
    {
        userService.delete(id);
        return Response.noContent().build();
    }
}
```

### Lower-Level Vert.x Web Implementation (Manual Routing)

If you need fine-grained control beyond what the REST addon provides, use lower-level routing directly:

```java
public class UserApiConfigurator implements VertxRouterConfigurator
{
    @Inject
    private UserService userService;

    @Override
    public Router builder(Router router)
    {
        String path = "/api/users";
        router.get(path).handler(this::listUsers);
        router.get(path + "/:id").handler(this::getUser);
        router.post(path).handler(this::createUser);
        router.put(path + "/:id").handler(this::updateUser);
        router.delete(path + "/:id").handler(this::deleteUser);
        return router;
    }

    private void listUsers(RoutingContext ctx) {
        List<User> users = userService.getAll();
        ctx.response().putHeader("content-type", "application/json").end(Json.encode(users));
    }

    private void getUser(RoutingContext ctx) {
        long id = Long.parseLong(ctx.pathParam("id"));
        User user = userService.findById(id);
        if (user != null) {
            ctx.response().putHeader("content-type", "application/json").end(Json.encode(user));
        } else {
            ctx.response().setStatusCode(404).end();
        }
    }

    private void createUser(RoutingContext ctx) {
        User user = ctx.body().asPojo(User.class);
        User created = userService.create(user);
        ctx.response().setStatusCode(201).putHeader("content-type", "application/json").end(Json.encode(created));
    }

    private void updateUser(RoutingContext ctx) {
        long id = Long.parseLong(ctx.pathParam("id"));
        User user = ctx.body().asPojo(User.class);
        User updated = userService.update(id, user);
        ctx.response().putHeader("content-type", "application/json").end(Json.encode(updated));
    }

    private void deleteUser(RoutingContext ctx) {
        long id = Long.parseLong(ctx.pathParam("id"));
        userService.delete(id);
        ctx.response().setStatusCode(204).end();
    }
}
```

## WebSocket Support

**Recommended:** Use **guicedee-websocket** addon for connection lifecycle management, automatic message routing, and error handling.

### Using guicedee-websocket (Recommended)

```java
@WebSocketEndpoint("/ws/chat")
public class ChatWebSocketEndpoint
{
    @Inject
    private ChatService chatService;

    @OnOpen
    public void onOpen(WebSocketSession session)
    {
        String clientId = session.getId();
        chatService.registerClient(clientId, session);
    }

    @OnMessage
    public void onMessage(WebSocketSession session, String message)
    {
        chatService.broadcast(message);
    }

    @OnClose
    public void onClose(WebSocketSession session)
    {
        chatService.unregisterClient(session.getId());
    }

    @OnError
    public void onError(WebSocketSession session, Throwable error)
    {
        System.err.println("WebSocket error: " + error.getMessage());
    }
}
```

### Lower-Level Vert.x Web Implementation (Manual Handler)

For custom WebSocket handling beyond the addon framework:

```java
public class WebSocketConfigurator implements VertxHttpServerConfigurator
{
    @Override
    public HttpServer builder(HttpServer server)
    {
        server.webSocketHandler(ws -> {
            String clientId = UUID.randomUUID().toString();
            
            ws.textMessageHandler(message -> {
                ws.writeTextMessage("Echo: " + message);
            });
            
            ws.binaryMessageHandler(buffer -> {
                ws.writeBinaryMessage(buffer);
            });
            
            ws.closeHandler(v -> System.out.println("Client disconnected: " + clientId));
            ws.exceptionHandler(err -> System.err.println("WebSocket error: " + err.getMessage()));
        });
        return server;
    }
}
```

## Static File Serving

Static content is typically served via configurators without needing a dedicated addon:

```java
public class StaticContentConfigurator implements VertxRouterConfigurator
{
    @Override
    public Router builder(Router router)
    {
        router.get("/static/*")
            .handler(StaticHandler.create("webroot")
                .setCachingEnabled(true)
                .setMaxAgeSeconds(3600));
        
        router.get("/")
            .handler(StaticHandler.create("webroot")
                .setDefaultDocument("index.html"));
        
        return router;
    }
}
```

## File Uploads

```java
public class FileUploadConfigurator implements VertxRouterConfigurator
{
    @Override
    public Router builder(Router router)
    {
        router.post("/upload").handler(ctx -> {
            Set<FileUpload> uploads = ctx.fileUploads();
            List<Map<String, String>> info = new ArrayList<>();
            
            for (FileUpload upload : uploads) {
                String fileName = upload.fileName();
                String uploadedPath = upload.uploadedFileName();
                long size = upload.size();
                
                info.add(Map.of(
                    "name", fileName,
                    "path", uploadedPath,
                    "size", String.valueOf(size)
                ));
            }
            
            ctx.response().putHeader("content-type", "application/json").end(Json.encode(info));
        });
        return router;
    }
}
```

## CORS Configuration

CORS is typically configured via a VertxRouterConfigurator. The guicedee-rest addon automatically handles CORS negotiation:

```java
public class CorsConfigurator implements VertxRouterConfigurator
{
    @Override
    public Router builder(Router router)
    {
        router.route().handler(CorsHandler.create("http://localhost:3000")
            .allowedMethods(EnumSet.of(
                HttpMethod.GET, HttpMethod.POST, HttpMethod.PUT, HttpMethod.DELETE, HttpMethod.OPTIONS
            ))
            .allowedHeader("Content-Type")
            .allowedHeader("Authorization")
            .maxAgeSeconds(86400));
        
        return router;
    }
}
```

## Authentication & Authorization

**Recommended:** Use **guicedee-rest** with security annotations and **GuicedEE Security** addon for declarative access control.

### Using guicedee-rest + GuicedEE Security (Recommended)

```java
@Path("/api/admin")
@RolesAllowed("ADMIN")
public class AdminApiController
{
    @GET
    @Path("/users")
    @Produces(MediaType.APPLICATION_JSON)
    public List<User> listAllUsers()
    {
        return userService.getAll();
    }

    @DELETE
    @Path("{id}")
    public Response deleteUser(@PathParam("id") long id)
    {
        userService.delete(id);
        return Response.noContent().build();
    }
}

@Path("/api/public")
@PermitAll
public class PublicApiController
{
    @POST
    @Path("/login")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response login(LoginRequest credentials)
    {
        String token = authService.authenticate(credentials);
        return Response.ok(new TokenResponse(token)).build();
    }
}
```

### Lower-Level Authentication via Middleware (Manual Implementation)

For custom authentication schemes not covered by GuicedEE Security:

```java
public class AuthMiddlewareConfigurator implements VertxRouterConfigurator
{
    @Inject
    private AuthService authService;

    @Override
    public Router builder(Router router)
    {
        router.route("/api/*").handler(ctx -> {
            String auth = ctx.request().getHeader("Authorization");
            if (auth == null || !auth.startsWith("Bearer ")) {
                ctx.response().setStatusCode(401).end("Unauthorized");
                return;
            }
            
            try {
                String token = auth.substring(7);
                User user = authService.validateToken(token);
                ctx.put("user", user);
                ctx.next();
            } catch (Exception e) {
                ctx.response().setStatusCode(401).end("Invalid token");
            }
        });
        return router;
    }
}
```

## See Also

- [router-configuration.rules.md](router-configuration.rules.md) — Core routing patterns
- [spi-configurators.rules.md](spi-configurators.rules.md) — SPI interfaces
- [server-configuration.rules.md](server-configuration.rules.md) — Server setup
- **GuicedEE addons** — Recommended approaches:
  - **guicedee-rest** — REST/CRUD APIs with validation, content negotiation, OpenAPI
  - **guicedee-websocket** — WebSocket connections with lifecycle management
  - **guicedee-webservice** — SOAP/XML services with WSDL generation
  - **guicedee-graphql** — GraphQL schemas with introspection and subscriptions
  - **GuicedEE Security** — Authorization, authentication, RBAC with annotations
