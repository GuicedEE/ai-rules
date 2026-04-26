---
name: guicedee-auth
description: "Annotation-driven authentication and authorization for GuicedEE with Vert.x 5: 8 optional providers (OAuth2/OIDC, JWT, ABAC, OTP/TOTP/HOTP, Property File, LDAP, htpasswd, htdigest), ChainAuth, @AuthOptions, @RolesAllowed/@PermitAll/@DenyAll, IGuicedAuthenticationProvider and IGuicedAuthorizationProvider SPIs, env var overrides, and Guice injection of all provider types. Use when adding authentication, authorization, security annotations, configuring auth providers, or implementing custom auth SPIs."
metadata:
  short-description: Authentication and authorization providers for GuicedEE with Vert.x 5
---

# GuicedEE Auth

Annotation-driven, opt-in authentication and authorization for GuicedEE using Vert.x 5 auth modules.

## Architecture

All auth providers live in `com.guicedee.vertx` as optional dependencies. Each is activated **only** when its annotation is found on a class or `package-info.java`. Providers are chained via `ChainAuth` (ANY or ALL mode).

```
@AuthOptions (core)          → ChainAuth, KeyStore, PEM, PRNG
@OAuth2Options               → OAuth2/OIDC (vertx-auth-oauth2)
@JwtAuthOptions              → JWT (vertx-auth-jwt)
@AbacOptions                 → ABAC policies (vertx-auth-abac)
@OtpAuthOptions              → TOTP/HOTP (vertx-auth-otp)
@PropertyFileAuthOptions     → Shiro properties (vertx-auth-properties)
@LdapAuthOptions             → LDAP (vertx-auth-ldap)
@HtpasswdAuthOptions         → htpasswd (vertx-auth-htpasswd)
@HtdigestAuthOptions         → htdigest (vertx-auth-htdigest)
```

## Required Flow (any provider)

1. Add the Vert.x auth dependency for the provider(s) you need.
2. Add the annotation to `package-info.java` (or a class).
3. Add `requires` for the auth module in `module-info.java`.
4. Inject the provider type via Guice.
5. Use `@RolesAllowed`, `@PermitAll`, `@DenyAll` on REST endpoints.

## Provider Reference

### JWT — `@JwtAuthOptions`

**Dependency:** `io.vertx:vertx-auth-jwt`
**Module:** `requires io.vertx.auth.jwt;`
**Annotation package:** `com.guicedee.vertx.auth.jwt`

```java
@JwtAuthOptions(
    keystorePath = "keystore.jceks",
    keystoreType = "jceks",
    keystorePassword = "${JWT_KEYSTORE_PASSWORD}",
    algorithm = "RS256",
    issuer = "my-corp.com",
    audience = {"my-service"},
    expiresInSeconds = 3600,
    permissionsClaimKey = "realm_access/roles",
    authorizationType = JwtAuthorizationType.MICROPROFILE
)
package com.example.auth;
```

**Env overrides:** `VERTX_AUTH_JWT_KEYSTORE_PATH`, `VERTX_AUTH_JWT_KEYSTORE_PASSWORD`, `VERTX_AUTH_JWT_ALGORITHM`, `VERTX_AUTH_JWT_ISSUER`, `VERTX_AUTH_JWT_AUDIENCE`, `VERTX_AUTH_JWT_EXPIRES_IN_SECONDS`, `VERTX_AUTH_JWT_PERMISSIONS_CLAIM_KEY`

**Guice bindings:** `JWTAuth`, `JWTAuthOptions`

**Provides both AuthN and AuthZ** (via JWTAuthorization or MicroProfileAuthorization).

### OAuth2 — `@OAuth2Options`

**Dependency:** `io.vertx:vertx-auth-oauth2`
**Module:** `requires io.vertx.auth.oauth2;`
**Annotation package:** `com.guicedee.vertx.auth.oauth2`

```java
@OAuth2Options(
    flow = OAuth2Options.FlowType.AUTH_CODE,
    clientId = "${OAUTH2_CLIENT_ID}",
    clientSecret = "${OAUTH2_CLIENT_SECRET}",
    site = "https://accounts.google.com",
    tokenPath = "/o/oauth2/token",
    authorizationPath = "/o/oauth2/auth",
    discoveryUrl = "${OAUTH2_DISCOVERY_URL}",
    callbackPath = "/callback"
)
package com.example.auth;
```

**Env overrides:** `VERTX_AUTH_OAUTH2_CLIENT_ID`, `VERTX_AUTH_OAUTH2_CLIENT_SECRET`, `VERTX_AUTH_OAUTH2_SITE`, `VERTX_AUTH_OAUTH2_DISCOVERY_URL`

**Guice binding:** `OAuth2Auth`

**AuthN only** — use with JWT or ABAC for authorization.

### ABAC — `@AbacOptions`

**Dependency:** `io.vertx:vertx-auth-abac`
**Module:** `requires io.vertx.auth.abac;`
**Annotation package:** `com.guicedee.vertx.auth.abac`

```java
@AbacOptions(
    policyFiles = {"policies/admin.json", "policies/readonly.json"}
)
package com.example.auth;
```

Or inline:
```java
@AbacOptions(policies = {
    """{"name":"MFA DELETE","attributes":{"/principal/amr":{"eq":"mfa"}},
       "authorizations":[{"type":"wildcard","permission":"web:DELETE"}]}"""
})
```

**SPI:** `IAbacPolicyProvider` — programmatic policies with custom `Attribute.create(Function<User, Boolean>)`.

**Env override:** `VERTX_AUTH_ABAC_POLICY_FILES`

**Guice binding:** `PolicyBasedAuthorizationProvider`

**AuthZ only.**

### OTP — `@OtpAuthOptions`

**Dependency:** `io.vertx:vertx-auth-otp`
**Module:** `requires io.vertx.auth.otp;`
**Annotation package:** `com.guicedee.vertx.auth.otp`

```java
@OtpAuthOptions(type = OtpType.TOTP, passwordLength = 6, period = 30)
package com.example.auth;
```

**Required SPI:** `IOtpAuthenticatorService` — must implement `authenticatorFetcher()` and `authenticatorUpdater()` for storage.

```java
provides IOtpAuthenticatorService with MyOtpService;
```

**Env overrides:** `VERTX_AUTH_OTP_TYPE`, `VERTX_AUTH_OTP_PASSWORD_LENGTH`, `VERTX_AUTH_OTP_PERIOD`, `VERTX_AUTH_OTP_LOOK_AHEAD_WINDOW`, `VERTX_AUTH_OTP_COUNTER`

**Guice binding:** `TotpAuth` or `HotpAuth` (depending on type)

**AuthN only.**

### Property File — `@PropertyFileAuthOptions`

**Dependency:** `io.vertx:vertx-auth-properties`
**Module:** `requires io.vertx.auth.properties;`
**Annotation package:** `com.guicedee.vertx.auth.properties`

```java
@PropertyFileAuthOptions(path = "auth.properties")
package com.example.auth;
```

File format (Apache Shiro):
```properties
user.tim = mypassword,administrator,developer
user.bob = hispassword,developer
role.administrator = *
role.developer = do_actual_work
```

**Env override:** `VERTX_AUTH_PROPERTIES_PATH`

**Guice bindings:** `PropertyFileAuthentication`, `PropertyFileAuthorization`

**Both AuthN and AuthZ.**

### LDAP — `@LdapAuthOptions`

**Dependency:** `io.vertx:vertx-auth-ldap`
**Module:** `requires io.vertx.auth.ldap;`
**Annotation package:** `com.guicedee.vertx.auth.ldap`

```java
@LdapAuthOptions(
    url = "${LDAP_URL}",
    authenticationQuery = "uid={0},ou=users,dc=example,dc=com",
    authenticationMechanism = "simple",
    referral = "follow"
)
package com.example.auth;
```

**Env overrides:** `VERTX_AUTH_LDAP_URL`, `VERTX_AUTH_LDAP_AUTHENTICATION_QUERY`, `VERTX_AUTH_LDAP_AUTHENTICATION_MECHANISM`, `VERTX_AUTH_LDAP_REFERRAL`

**Guice binding:** `LdapAuthentication`

**AuthN only.**

### htpasswd — `@HtpasswdAuthOptions`

**Dependency:** `io.vertx:vertx-auth-htpasswd`
**Module:** `requires io.vertx.auth.htpasswd;`
**Annotation package:** `com.guicedee.vertx.auth.htpasswd`

```java
@HtpasswdAuthOptions(path = ".htpasswd", plainTextEnabled = false)
package com.example.auth;
```

**Env overrides:** `VERTX_AUTH_HTPASSWD_PATH`, `VERTX_AUTH_HTPASSWD_PLAIN_TEXT_ENABLED`

**Guice binding:** `HtpasswdAuth`

**AuthN only.**

### htdigest — `@HtdigestAuthOptions`

**Dependency:** `io.vertx:vertx-auth-htdigest`
**Module:** `requires io.vertx.auth.htdigest;`
**Annotation package:** `com.guicedee.vertx.auth.htdigest`

```java
@HtdigestAuthOptions(path = ".htdigest")
package com.example.auth;
```

**Env override:** `VERTX_AUTH_HTDIGEST_PATH`

**Guice binding:** `HtdigestAuth`

**AuthN only.**

## Core Auth — `@AuthOptions`

The base annotation for ChainAuth configuration, KeyStore, PEM keys, and PRNG:

```java
@AuthOptions(
    chainMode = AuthOptions.ChainMode.ANY,
    keyStore = @AuthKeyStore(path = "keystore.pkcs12", type = "pkcs12", password = "changeit"),
    pubSecKeys = {@AuthPubSecKey(algorithm = "RS256", path = "/path/to/public.pem")},
    prngAlgorithm = "SHA1PRNG",
    leeway = 5
)
package com.example.auth;
```

**Guice bindings:** `AuthenticationProvider`, `ChainAuth`, `AuthorizationProvider`, `Set<AuthorizationProvider>`, `VertxContextPRNG`, `KeyStoreOptions`, `Set<PubSecKeyOptions>`

## SPI Extension Points

| SPI | Purpose | Registration |
|---|---|---|
| `IGuicedAuthenticationProvider` | Custom AuthN provider | `provides IGuicedAuthenticationProvider with MyProvider;` |
| `IGuicedAuthorizationProvider` | Custom AuthZ provider | `provides IGuicedAuthorizationProvider with MyProvider;` |
| `IAbacPolicyProvider` | Programmatic ABAC policies | `provides IAbacPolicyProvider with MyPolicies;` |
| `IOtpAuthenticatorService` | OTP storage callbacks | `provides IOtpAuthenticatorService with MyOtpService;` |

## Jakarta Security Annotations

Apply to REST resource classes/methods:

```java
@Path("/api/admin")
@RolesAllowed({"admin", "super-admin"})
public class AdminResource {
    @GET @Path("/users")
    public List<User> listUsers() { ... }

    @DELETE @Path("/users/{id}")
    @RolesAllowed("super-admin")
    public void deleteUser(@PathParam("id") String id) { ... }

    @GET @Path("/health")
    @PermitAll
    public String health() { return "OK"; }
}
```

## Three-Tier Configuration

1. **Annotation defaults** — in code
2. **Environment variables** — deploy-time override (`VERTX_AUTH_*`)
3. **SPI hooks** — programmatic control

All string attributes support `${ENV_VAR}` placeholders.

## Non-Negotiable Constraints

- Auth providers are **opt-in** — only activated when their annotation is found.
- Each provider's Vert.x dependency must be on the module path.
- Module must `requires static` the auth module (e.g., `requires io.vertx.auth.jwt;`).
- SPI implementations must be dual-registered (`module-info.java` provides + `META-INF/services/`).
- Auth packages must `opens` to `com.google.guice` and `com.fasterxml.jackson.databind`.
- OTP **requires** `IOtpAuthenticatorService` SPI — no storage = no auth.
- `@RolesAllowed` only works on REST resources when the `rest` module is present.

