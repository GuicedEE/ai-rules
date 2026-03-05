---
name: guicedee-rest-client
description: "Annotation-driven REST client for GuicedEE using Vert.x 5 WebClient: @Endpoint declarations, RestClient<Send, Receive> injection, authentication strategies (Bearer, Basic, API Key), path parameters, environment variable overrides, package-level endpoints, and RestClientConfigurator SPI. Use when making outbound REST calls, configuring REST client endpoints, or wiring reactive HTTP clients with Guice injection."
metadata:
  short-description: Annotation-driven REST client with Vert.x WebClient inside GuicedEE
---

# GuicedEE REST Client

Annotation-driven REST client using the Vert.x 5 WebClient, fully managed by GuicedEE.

## Core Concept

Declare an `@Endpoint` on any `RestClient<Send, Receive>` field, add `@Named`, and inject — URL, HTTP method, authentication, timeouts, and connection options are all driven from the annotation. Every call returns a `Uni<Receive>` for fully reactive composition.

## Required Flow

1. Add `com.guicedee:rest-client` dependency.
2. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.rest.client;
       opens my.app.clients to com.google.guice, com.guicedee.rest.client;
       opens my.app.dto to com.fasterxml.jackson.databind;
   }
   ```
3. Declare a REST client field with `@Endpoint`:
   ```java
   public class UserService {
       @Endpoint(url = "https://api.example.com/users", method = "POST",
                 security = @EndpointSecurity(value = SecurityType.Bearer,
                                              token = "${API_TOKEN}"))
       @Named("create-user")
       private RestClient<CreateUserRequest, UserResponse> createUserClient;

       public Uni<UserResponse> createUser(CreateUserRequest request) {
           return createUserClient.send(request);
       }
   }
   ```
4. Once defined, inject the same client elsewhere by name only:
   ```java
   public class OrderService {
       @Inject @Named("create-user")
       private RestClient<CreateUserRequest, UserResponse> client;
   }
   ```

## Sending Requests

```java
client.send();                           // no body
client.send(body);                       // with body
client.send(body, headers, queryParams); // with headers and query params
client.publish(body);                    // fire-and-forget (no response)
```

All methods return `Uni<Receive>`.

## Path Parameters

Use `{paramName}` placeholders in the endpoint URL:

```java
@Endpoint(url = "https://api.example.com/users/{userId}", method = "GET")
@Named("get-user")
private RestClient<Void, UserResponse> getUserClient;

// Usage
getUserClient.pathParam("userId", "123").send();
```

## Authentication

| Strategy | Annotation |
|---|---|
| Bearer/JWT | `@EndpointSecurity(value = SecurityType.Bearer, token = "${API_TOKEN}")` |
| Basic | `@EndpointSecurity(value = SecurityType.Basic, username = "user", password = "${PASSWORD}")` |
| API Key | `@EndpointSecurity(value = SecurityType.ApiKey, apiKeyName = "X-API-Key", apiKeyValue = "${API_KEY}")` |

## Package-Level Endpoints

Declare a shared base URL on `package-info.java`:

```java
@Endpoint(url = "http://localhost:8080/api",
          options = @EndpointOptions(readTimeout = 1000))
package com.example.api;
```

Field-level URLs starting with `/` are appended to the package-level base URL.

## Environment Variable Overrides

Every annotation attribute can be overridden via `REST_CLIENT_*` environment variables without code changes.

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ RestClientPreStartup (scans for @Endpoint-annotated fields)
 └─ RestClientBinder (binds RestClient instances per @Named endpoint)
     ├─ RestClientRegistry (metadata: URL, types, security, options)
     ├─ WebClient cache (one per endpoint)
     └─ RestClientConfigurator SPI (custom WebClientOptions)
```

## Non-Negotiable Constraints

- Client packages must `opens` to `com.google.guice` and `com.guicedee.rest.client`.
- DTO packages must `opens` to `com.fasterxml.jackson.databind`.
- Module must `requires com.guicedee.rest.client;`.
- Only one `@Endpoint` field is needed per named endpoint; other classes inject by `@Named` alone.
- `RestClientConfigurator` SPI implementations must be dual-registered.


