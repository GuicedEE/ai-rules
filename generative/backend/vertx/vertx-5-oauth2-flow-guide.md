## 🔐 OAuth 2.0 Authentication Guide

This guide describes how the `ai-experiment` project handles authentication and authorization using [Vert.x OAuth2](https://vertx.io/docs/vertx-auth-oauth2/java/) instead of Keycloak, supporting various flows including Authorization Code, Client Credentials, and OpenID Connect Discovery.

> 📌 This replaces full Keycloak dependency with a lightweight, flexible OAuth2 integration via `vertx-auth-oauth2`.

---

### 📆 Maven Dependency

```xml
<dependency>
  <groupId>io.vertx</groupId>
  <artifactId>vertx-auth-oauth2</artifactId>
  <version>5.0.1</version>
</dependency>
```

---

## 🌟 Supported OAuth2 Flows

| Flow                     | When to Use                                               |
| ------------------------ | --------------------------------------------------------- |
| Authorization Code       | For web apps needing user login redirects (browser-based) |
| Password Credentials     | For trusted apps or CLI/testing flows                     |
| Client Credentials       | For server-to-server API communication                    |
| JWT / On-Behalf-Of Flow  | For secure delegation scenarios using signed JWTs         |
| OpenID Connect Discovery | For auto-config via providers like Google, Azure, etc.    |

---

### 🔀 Authorization Code Flow

```java
OAuth2Auth oauth2 = OAuth2Auth.create(vertx, new OAuth2Options()
  .setClientId("your-client-id")
  .setClientSecret("your-secret")
  .setSite("https://auth.gedmarc.co.za")
  .setTokenPath("/realms/ai-experiment/protocol/openid-connect/token")
  .setAuthorizationPath("/realms/ai-experiment/protocol/openid-connect/auth"));

String authorizationUri = oauth2.authorizeURL(new OAuth2AuthorizationURL()
  .setRedirectUri("http://localhost:8080/callback")
  .addScope("openid profile")
  .setState("secure-state"));

oauth2.authenticate(
  new Oauth2Credentials()
    .setCode("auth-code-from-callback")
    .setRedirectUri("http://localhost:8080/callback"))
  .onSuccess(user -> {
    // Store access token and proceed
  });
```

---

### 🔑 Password Credentials Flow

```java
OAuth2Auth oauth2 = OAuth2Auth.create(vertx, new OAuth2Options());

Credentials credentials = new UsernamePasswordCredentials("user", "password");

oauth2.authenticate(credentials)
  .onSuccess(user -> {
    String token = user.principal().getString("access_token");
    // Use token in Authorization header
  });
```

---

### 🧲 Client Credentials Flow

```java
OAuth2Auth oauth2 = OAuth2Auth.create(vertx, new OAuth2Options()
  .setClientId("server-app")
  .setClientSecret("server-secret")
  .setSite("https://auth.gedmarc.co.za"));

oauth2.authenticate(new TokenCredentials("existing-token"))
  .onSuccess(user -> {
    // Server-to-server call authenticated
  });
```

---

### 🌍 OpenID Connect Discovery

```java
OpenIDConnectAuth.discover(
  vertx,
  new OAuth2Options()
    .setClientId("client-id")
    .setClientSecret("secret")
    .setSite("https://auth.gedmarc.co.za"))
  .onSuccess(oauth2 -> {
    // Ready to authenticate
  });
```

---

## 🛡️ Token Management

### 🔄 Refreshing Tokens

```java
if (user.expired()) {
  oauth2.refresh(user)
    .onSuccess(refreshed -> { /* continue */ })
    .onFailure(err -> { /* logout */ });
}
```

### ❌ Revoking Tokens

```java
oauth2.revoke(user, "access_token")
  .onSuccess(v -> oauth2.revoke(user, "refresh_token"));
```

---

## 📜 Authorization with Roles

```java
AuthorizationProvider authz = KeycloakAuthorization.create();

authz.getAuthorizations(user)
  .onSuccess(v -> {
    if (PermissionBasedAuthorization.create("admin").match(user)) {
      // Allowed
    }
  });
```

---

## 🔍 JWT Validation (Stateless)

```java
oauth2.authenticate(new TokenCredentials("jwt-access-token"))
  .onSuccess(user -> {
    // Token valid, proceed
  });
```

---

## 🤎 Experimental Mode Setup

In our experimental setup, we host the OAuth2 server ourselves using:

* `https://auth.gedmarc.co.za` (Keycloak or compatible OIDC server)
* Token paths follow `/realms/ai-experiment/...`
* Public access for login flows via IAM: `allUsers` → Cloud Run Invoker
* Tokens used for session validation and authorization downstream
