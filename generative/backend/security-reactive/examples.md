# Security (Reactive) — Examples

This page provides practical Vert.x 5 examples for implementing the Security (Reactive) rules.

## 1) Router setup with security handlers

```java
Router router = Router.router(vertx);

// 1. Security headers
router.route().handler(ctx -> {
  ctx.response()
    .putHeader("X-Content-Type-Options", "nosniff")
    .putHeader("X-Frame-Options", "DENY")
    .putHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
    .putHeader("Content-Security-Policy", "default-src 'none'")
    .next();
});

// 2. CORS
Set<String> allowedOrigins = Set.of(System.getenv().getOrDefault("CORS_ALLOWED_ORIGINS", "").split(","));
CorsHandler cors = CorsHandler.create().addOrigins(allowedOrigins);
router.route().handler(cors);

// 3. Rate Limiter (pseudo-code; back with Redis/Atomix etc.)
router.route().handler(rateLimiterHandler(50));

// 4. Body limit
router.route().handler(BodyHandler.create().setBodyLimit(1_000_000));

// 5. AuthN: JWT Bearer (JWKS backed)
JWTAuth jwtAuth = JWTAuth.create(vertx, new JWTAuthOptions()
  .setJwks(new JsonArray().add(new JsonObject()
    .put("kid", "initial")
    .put("kty", "RSA")
    .put("n", "<modulus>")
    .put("e", "AQAB")))); // For production use JWKS URL + caching, not inline keys

router.route().handler(BearerAuthHandler.create(jwtAuth));

// 6. AuthZ
AuthorizationProvider authz = AuthorizationProvider.create();
router.route("/admin/*").handler(AuthorizationHandler.create(RoleBasedAuthorization.create("admin")).addAuthorizationProvider(authz));

// Public route
router.get("/health").handler(ctx -> ctx.response().end("OK"));

// Protected route
router.get("/admin/info").handler(ctx -> ctx.response().end("secret"));
```

## 2) OAuth2 discovery and WebClient token propagation

```java
OAuth2Options options = new OAuth2Options()
  .setSite(System.getenv("OIDC_ISSUER"))
  .setClientId(System.getenv("OIDC_CLIENT_ID"));
OAuth2Auth oauth2 = OAuth2Auth.create(vertx, options);

WebClient client = WebClient.create(vertx);

router.get("/call-downstream").handler(ctx -> {
  String incoming = ctx.request().getHeader("Authorization");
  client.getAbs("https://api.example.com/protected")
    .putHeader("Authorization", incoming)
    .send(ar -> {
      if (ar.succeeded()) {
        ctx.response().end(ar.result().bodyAsString());
      } else {
        ctx.fail(ar.cause());
      }
    });
});
```

## 3) HTTPS server with optional mTLS

```java
HttpServerOptions so = new HttpServerOptions()
  .setSsl(true)
  .setKeyStoreOptions(new JksOptions()
    .setPath(System.getenv("TLS_KEYSTORE_PATH"))
    .setPassword(System.getenv("TLS_KEYSTORE_PASSWORD")))
  .setTrustStoreOptions(new JksOptions()
    .setPath(System.getenv("TLS_TRUSTSTORE_PATH"))
    .setPassword(System.getenv("TLS_TRUSTSTORE_PASSWORD")))
  .setClientAuth(ClientAuth.REQUEST);

vertx.createHttpServer(so).requestHandler(router).listen(8443);
```

## 4) Test: authorization matrix (pseudo)

```java
@Test
void adminRoute_requires_admin_role() {
  // given: token without admin
  String token = tokenFor(Set.of("user"));
  // when
  HttpResponse<Buffer> res = client.get("/admin/info")
    .putHeader("Authorization", "Bearer " + token)
    .send().toCompletionStage().toCompletableFuture().join();
  // then
  assertEquals(403, res.statusCode());
}
```

## 5) Negative token cases

- Expired token → 401
- Invalid signature (kid unknown) → 401 and JWKS refresh attempt
- Wrong audience/issuer → 401
- Missing permission/role → 403

See also
- Specification and rules — ./security-reactive.rules.md
- Vert.x OAuth2 flow guide — ../vertx/vertx-5-oauth2-flow-guide.md
