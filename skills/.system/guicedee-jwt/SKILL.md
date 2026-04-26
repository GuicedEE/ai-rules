---
name: guicedee-jwt
description: "MicroProfile JWT Auth bridge for GuicedEE with Vert.x 5: VertxJsonWebToken (Vert.x User → JsonWebToken), @Claim injection without @Inject, MicroProfileJwtContext (CallScope-aware request context), ClaimValueProvider, SPI registration (InjectionPointProvider, NamedAnnotationProvider, BindingAnnotationProvider), type-specific claim bindings (String, Set<String>, Long, Integer, Boolean, Optional<T>), Keycloak/OIDC integration via JWKS, and Guice-managed JsonWebToken. Use when bridging Vert.x JWT auth to MicroProfile JWT, injecting JWT claims, configuring @Claim fields, implementing JWT context propagation, or integrating with Keycloak/OIDC identity providers."
metadata:
  short-description: MicroProfile JWT Auth bridge for GuicedEE with Vert.x 5
---

# GuicedEE MicroProfile JWT

Bridges the MicroProfile JWT Auth specification to Vert.x 5 JWT authentication inside GuicedEE.

## Core Concept

The module converts a Vert.x `User` (authenticated via `JWTAuth`) into an `org.eclipse.microprofile.jwt.JsonWebToken`, making all standard and custom JWT claims available through the MP JWT API. Claims can be injected directly using `@Claim` — no `@Inject` required.

## Architecture

```
Vert.x JWTAuth → User → VertxJsonWebToken (implements JsonWebToken)
                           ↓
                    MicroProfileJwtContext (CallScope + ThreadLocal)
                           ↓
                    MicroProfileJwtModule (Guice bindings)
                           ↓
                    @Claim("sub") String subject  ← injected per-request
```

## Required Flow

1. Add `com.guicedee.microprofile:jwt` dependency.
2. Configure JWT authentication via `@JwtAuthOptions` on `package-info.java` (from the auth module).
3. Use `@Claim` to inject claims into your classes:
   ```java
   @Claim("sub")
   private String subject;

   @Claim("groups")
   private Set<String> roles;

   @Claim("exp")
   private Long expiration;
   ```
4. Access the full token when needed:
   ```java
   @Inject
   private JsonWebToken jwt;
   ```
5. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.microprofile.jwt;
       opens my.app to com.google.guice;
   }
   ```

## Key Classes

### `VertxJsonWebToken`

Bridge from Vert.x `User` to MP `JsonWebToken`. Extracts claims from the User's `principal()` and `accessToken` attribute.

- `getName()` resolves via MP JWT spec: `upn` → `preferred_username` → `sub`
- `getGroups()` maps from the `groups` claim
- `getAudience()` handles both string and array formats
- `getClaim(String)` returns typed values, converting `JsonArray` → `Set<String>` and `JsonObject` → `Map`

### `MicroProfileJwtContext`

Request-scoped holder for the current `JsonWebToken`:
- **Primary:** Stores in `CallScopeProperties` when a CallScope is active (Vert.x HTTP handlers)
- **Fallback:** Uses `ThreadLocal` when no call scope is active (unit tests, non-HTTP code)

```java
// In a route handler or auth filter:
User user = routingContext.user();
MicroProfileJwtContext.setCurrent(new VertxJsonWebToken(user));
// ... handle request ...
MicroProfileJwtContext.clear();
```

Or use the convenience method:
```java
MicroProfileJwtPreStartup.setCurrentUser(routingContext.user());
```

### `ClaimValueProvider<T>`

Guice `Provider<T>` that resolves a claim from the current `JsonWebToken` at injection time.

### `MicroProfileJwtModule`

Guice module (auto-discovered via SPI) that:
1. Binds `JsonWebToken` → `MicroProfileJwtContext::getCurrent`
2. Scans `@Claim`-annotated fields via ClassGraph
3. Creates type-specific `@Named("claimName")` bindings for each discovered claim

Supported field types:
| Type | Example | Null/absent behavior |
|---|---|---|
| `String` | `@Claim("sub") String subject` | `null` |
| `Set<String>` | `@Claim("groups") Set<String> roles` | `Set.of()` |
| `Long` / `long` | `@Claim("exp") Long expiration` | `0L` |
| `Integer` / `int` | `@Claim("level") Integer level` | `0` |
| `Boolean` / `boolean` | `@Claim("email_verified") Boolean verified` | `false` |
| `Optional<String>` | `@Claim("sub") Optional<String> subject` | `Optional.empty()` |
| `Object` | `@Claim("custom") Object data` | `null` |

### `MicroProfileJwtPreStartup`

Pre-startup hook that validates the JWT auth provider availability. Also provides:
```java
MicroProfileJwtPreStartup.setCurrentUser(User user);
```

## SPI Registrations

The module registers three Guice SPIs so `@Claim` works without `@Inject`:

| SPI | Implementation | Purpose |
|---|---|---|
| `InjectionPointProvider` | `ClaimInjectionPointProvider` | Marks `@Claim` as injection point |
| `NamedAnnotationProvider` | `ClaimNamedAnnotationProvider` | Converts `@Claim("sub")` → `@Named("sub")` |
| `BindingAnnotationProvider` | `ClaimBindingAnnotationProvider` | Registers `@Claim` as binding annotation |

## JPMS Module

```java
module com.guicedee.microprofile.jwt {
    requires transitive com.guicedee.vertx;
    requires transitive com.guicedee.guicedinjection;
    requires transitive io.vertx.auth.jwt;
    requires transitive microprofile.jwt.auth.api;
    requires transitive jakarta.json;

    exports com.guicedee.microprofile.jwt;
    exports com.guicedee.microprofile.jwt.implementations;

    provides IGuiceModule with MicroProfileJwtModule;
    provides IGuicePreStartup with MicroProfileJwtPreStartup;
    provides InjectionPointProvider with ClaimInjectionPointProvider;
    provides NamedAnnotationProvider with ClaimNamedAnnotationProvider;
    provides BindingAnnotationProvider with ClaimBindingAnnotationProvider;
}
```

## Keycloak / OIDC Integration

When using Keycloak or any OIDC provider:

1. Configure `@JwtAuthOptions` or `@OAuth2Options` for the provider.
2. Fetch JWKS from the provider's certs endpoint.
3. Filter signing keys only (`use=sig`) to avoid `RSA-OAEP` encryption key errors.
4. Use `JWTAuthOptions.addJwk(JsonObject)` for JWKS JSON keys (not `PubSecKeyOptions`).

Keycloak JWTs include `preferred_username`, `realm_access`, `resource_access`, `email`, `given_name`, `family_name` as standard claims — all accessible via `getClaim()`.

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ MicroProfileJwtPreStartup (validates JWT provider availability)
 └─ MicroProfileJwtModule (Guice bindings)
     ├─ Binds JsonWebToken → MicroProfileJwtContext::getCurrent
     ├─ Scans @Claim-annotated fields via ClassGraph
     └─ Creates per-type @Named("claimName") providers
 └─ HTTP Request arrives
     ├─ Auth handler authenticates → User
     ├─ MicroProfileJwtContext.setCurrent(new VertxJsonWebToken(user))
     ├─ @Claim fields resolved from current JWT
     └─ MicroProfileJwtContext.clear() at request end
```

## Non-Negotiable Constraints

- Module must `requires com.guicedee.microprofile.jwt;`.
- Classes with `@Claim` fields must `opens` their package to `com.google.guice`.
- `@Claim` works **without** `@Inject` (via SPI registration).
- `MicroProfileJwtContext.clear()` **must** be called at end of request to prevent memory leaks.
- The Vert.x auth JWT dependency (`io.vertx:vertx-auth-jwt`) is required at runtime for token verification.
- `JsonWebToken` binding resolves from `MicroProfileJwtContext` — it is `null` outside a request scope.
- Claim name resolution: `@Claim("name")` → value attribute; `@Claim(standard = Claims.sub)` → standard enum name.

