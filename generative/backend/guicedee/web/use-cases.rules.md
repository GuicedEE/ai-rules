# Common Use Cases — GuicedEE Vert.x Web

This module covers practical implementations: REST APIs, WebSockets, static content, file uploads, CORS, and authentication.

## REST API Implementation

### Basic CRUD API

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

### JWT-based Auth

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
