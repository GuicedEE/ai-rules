# Router Configuration & Request Handling — GuicedEE Vert.x Web

This module covers router setup, route registration, BodyHandler configuration, and request/response handling patterns.

## Default Router Setup

During `VertxWebServerPostStartup`, a Vert.x Router is created and configured with defaults:

```java
Router router = Router.router(vertx);

// Default BodyHandler
router.route().handler(
    BodyHandler.create()
        .setUploadsDirectory("uploads")
        .setDeleteUploadedFilesOnEnd(true)
);
```

**Default BodyHandler behavior:**
- Parses multipart, form-encoded, and JSON request bodies
- Stores file uploads in `uploads/` directory
- Automatically cleans up uploaded files after request ends
- Supports field size and file size limits (customizable)

## Registering Routes via VertxRouterConfigurator

Use `VertxRouterConfigurator` to add routes and handlers:

```java
public class ApiRoutesConfigurator implements VertxRouterConfigurator
{
    @Inject
    private UserService userService;

    @Override
    public Router builder(Router router)
    {
        // GET /api/users
        router.get("/api/users")
            .handler(ctx -> {
                List<User> users = userService.getAll();
                ctx.response()
                   .putHeader("content-type", "application/json")
                   .end(Json.encode(users));
            });

        // POST /api/users
        router.post("/api/users")
            .consumes("application/json")
            .handler(ctx -> {
                User user = ctx.body().asPojo(User.class);
                User created = userService.create(user);
                ctx.response()
                   .setStatusCode(201)
                   .putHeader("content-type", "application/json")
                   .end(Json.encode(created));
            });

        // GET /api/users/:id
        router.get("/api/users/:id")
            .handler(ctx -> {
                long id = Long.parseLong(ctx.pathParam("id"));
                User user = userService.findById(id);
                if (user != null) {
                    ctx.response()
                       .putHeader("content-type", "application/json")
                       .end(Json.encode(user));
                } else {
                    ctx.response().setStatusCode(404).end();
                }
            });

        return router;
    }
}
```

## Path Patterns & Routing

### HTTP Methods

Vert.x supports all standard HTTP methods:

```java
router.get("/path").handler(...);       // GET
router.post("/path").handler(...);      // POST
router.put("/path").handler(...);       // PUT
router.patch("/path").handler(...);     // PATCH
router.delete("/path").handler(...);    // DELETE
router.head("/path").handler(...);      // HEAD
router.options("/path").handler(...);   // OPTIONS
router.route("/path").handler(...);     // ANY method
```

### Path Parameters

```java
// /api/users/42 → pathParam("id") = "42"
router.get("/api/users/:id").handler(ctx -> {
    String userId = ctx.pathParam("id");
    // ...
});

// /api/users/alice/posts/5
router.get("/api/users/:username/posts/:postId").handler(ctx -> {
    String user = ctx.pathParam("username");
    String post = ctx.pathParam("postId");
    // ...
});
```

### Wildcard & Regex Patterns

```java
// /static/* matches /static/css/style.css
router.get("/static/*").handler(StaticHandler.create("webroot"));

// Regex: /api/v[0-9]+/users
router.getWithRegex("/api/v[0-9]+/users").handler(ctx -> {
    String path = ctx.request().path();
    // ...
});
```

## BodyHandler Customization

Override the default BodyHandler configuration:

```java
public class CustomBodyHandlerConfigurator implements VertxRouterConfigurator
{
    @Override
    public Router builder(Router router)
    {
        // Remove default, add custom
        BodyHandler bodyHandler = BodyHandler.create()
            .setUploadsDirectory("custom-uploads")
            .setDeleteUploadedFilesOnEnd(false) // Keep files
            .setMaxFormFields(50)
            .setMaxFileSize(10485760L); // 10 MB

        router.route().handler(bodyHandler);
        return router;
    }
}
```

## Request Access Patterns

### Query Parameters

```java
router.get("/search").handler(ctx -> {
    String query = ctx.request().getParam("q");
    String limit = ctx.request().getParam("limit");
    List<String> values = ctx.request().getParams("filter"); // Multiple values
    // ...
});
```

### Request Headers

```java
router.get("/protected").handler(ctx -> {
    String authHeader = ctx.request().getHeader("Authorization");
    String contentType = ctx.request().getHeader("Content-Type");
    // ...
});
```

### Request Body

```java
router.post("/api/users").handler(ctx -> {
    // As JSON object
    JsonObject json = ctx.body().asJsonObject();
    
    // As JSON array
    JsonArray array = ctx.body().asJsonArray();
    
    // As POJO (requires Jackson)
    User user = ctx.body().asPojo(User.class);
    
    // As String
    String raw = ctx.body().asString();
    
    // As bytes
    Buffer buffer = ctx.body().buffer();
});
```

### File Uploads

```java
router.post("/upload").handler(ctx -> {
    Set<FileUpload> uploads = ctx.fileUploads();
    for (FileUpload upload : uploads) {
        String fieldName = upload.name();        // "file"
        String fileName = upload.fileName();     // "image.png"
        String uploaded = upload.uploadedFileName(); // Path on disk
        String contentType = upload.contentType();    // "image/png"
        long size = upload.size();
        
        // Process or move file...
    }
    ctx.response().end("Upload complete");
});
```

## Response Patterns

### Status Codes & Headers

```java
router.get("/api/resource/:id").handler(ctx -> {
    // Set status and headers
    ctx.response()
        .setStatusCode(200)
        .putHeader("X-Custom-Header", "value")
        .putHeader("content-type", "application/json");
    
    // Send body
    ctx.response().end(Json.encode(data));
});

// Not found
ctx.response().setStatusCode(404).end("Not found");

// Server error
ctx.response().setStatusCode(500).end("Internal error");
```

### Chunked Responses

```java
router.get("/stream").handler(ctx -> {
    ctx.response().setChunked(true);
    ctx.response().write("Chunk 1\n");
    ctx.response().write("Chunk 2\n");
    ctx.response().end("Done");
});
```

### File Downloads

```java
router.get("/download/:file").handler(ctx -> {
    String filename = ctx.pathParam("file");
    ctx.response()
        .putHeader("content-disposition", "attachment;filename=" + filename)
        .sendFile("downloads/" + filename);
});
```

## Middleware & Composability

### Handler Chain

```java
router.get("/protected")
    .handler(authMiddleware())      // Check auth
    .handler(loggingMiddleware())   // Log request
    .handler(mainHandler());         // Process
```

### Conditional Handlers

```java
router.route("/api/*")
    .produces("application/json")   // Only if accept header matches
    .handler(ctx -> {
        // This only runs if Accept: application/json
        ctx.response().end(Json.encode(data));
    });

router.route("/upload")
    .consumes("multipart/form-data")
    .handler(ctx -> {
        // Only runs for multipart requests
    });
```

### Failure Handlers

```java
router.route().failureHandler(ctx -> {
    int statusCode = ctx.statusCode();
    Throwable failure = ctx.failure();
    
    ctx.response()
        .setStatusCode(statusCode)
        .end("Error: " + failure.getMessage());
});

router.route("/api/*").failureHandler(ctx -> {
    ctx.response()
        .putHeader("content-type", "application/json")
        .setStatusCode(ctx.statusCode())
        .end(Json.encode(new ErrorResponse(ctx.failure())));
});
```

## Static File Serving

```java
public class StaticAssetsConfigurator implements VertxRouterConfigurator
{
    @Override
    public Router builder(Router router)
    {
        // Serve from webroot/ directory
        router.get("/static/*")
            .handler(StaticHandler.create("webroot")
                .setCachingEnabled(true)
                .setMaxAgeSeconds(3600));
        
        // Root index
        router.get("/")
            .handler(StaticHandler.create("webroot")
                .setDefaultDocument("index.html"));

        return router;
    }
}
```

## Common Patterns

### REST API with CRUD

```java
public class CrudApiConfigurator implements VertxRouterConfigurator
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

    private void listUsers(RoutingContext ctx) { /*...*/ }
    private void getUser(RoutingContext ctx) { /*...*/ }
    private void createUser(RoutingContext ctx) { /*...*/ }
    private void updateUser(RoutingContext ctx) { /*...*/ }
    private void deleteUser(RoutingContext ctx) { /*...*/ }
}
```

### Versioned API

```java
router.get("/api/v1/users").handler(ctx -> { /* V1 impl */ });
router.get("/api/v2/users").handler(ctx -> { /* V2 impl */ });
```

## See Also

- [spi-configurators.rules.md](spi-configurators.rules.md) — VertxRouterConfigurator interface
- [use-cases.rules.md](use-cases.rules.md) — WebSocket, file uploads, CORS
- [server-configuration.rules.md](server-configuration.rules.md) — Server-level setup
- [lifecycle.rules.md](lifecycle.rules.md) — Router setup in startup sequence
- [GLOSSARY.md](GLOSSARY.md) — Router, RoutingContext, BodyHandler terminology
