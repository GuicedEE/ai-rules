# Security (Reactive) — Specification and Rules

Audience: Reactive backend services using Vert.x 5 (or compatible reactive stacks). These rules define how to implement authentication, authorization, and transport/web security without blocking the event loop and with clear separation of concerns.

Goals
- Standardize reactive security across services (AuthN, AuthZ, transport security, and web controls)
- Prefer token-based auth (OIDC/OAuth2 + JWT) and stateless handlers
- Keep the event loop non-blocking; delegate blocking work to worker threads
- Centralize configuration via environment variables and secrets management

Scope
- Authentication: OAuth2/OIDC, JWT bearer, mTLS client certs (optional)
- Authorization: roles/permissions, route protection, policy composition
- Web security: CORS, CSRF strategy, headers, rate limiting, session usage guidance
- Transport: HTTPS/TLS, optional mTLS for internal services

Dependencies and packages
- io.vertx:vertx-web
- io.vertx:vertx-auth-oauth2
- io.vertx:vertx-auth-jwt
- io.vertx:vertx-web-client (token introspection, JWKS fetch)

Configuration (env variables)
- OIDC_ISSUER=https://issuer.example.com/realms/<realm>
- OIDC_JWKS_URL=https://issuer.example.com/realms/<realm>/protocol/openid-connect/certs
- OIDC_CLIENT_ID=<client-id>
- OIDC_AUDIENCE=<audience>
- AUTH_REQUIRED_ROLES=admin,ops
- CORS_ALLOWED_ORIGINS=https://app.example.com,https://admin.example.com
- RATE_LIMIT_RPS=50
- TLS_KEYSTORE_PATH, TLS_KEYSTORE_PASSWORD, TLS_TRUSTSTORE_PATH (for HTTPS/mTLS)

Authentication rules
1) JWT bearer tokens
- Use BearerAuthHandler with JWTAuth for local validation when JWKS is available.
- Validate iss, aud, exp, nbf; require signature verification against cached JWKS.
- For rotated keys, refresh JWKS on kid misses with jittered backoff.

2) OAuth2/OIDC
- Use OAuth2Auth for discovery (well-known config) and token introspection when required.
- Prefer JWT validation over introspection for performance; fall back only when scopes/claims require it.
- Support confidential clients for service-to-service with client_credentials flow.

3) mTLS (optional)
- For internal services, enable TLS with truststore; optionally require client certs.
- Map client cert DNs to service principals/roles as a separate auth provider.

Authorization rules
- Represent permissions as strings (e.g., resource:action) and roles as sets of permissions.
- Use AuthorizationHandler with PermissionBasedAuthorization/RoleBasedAuthorization.
- Prefer route-level enforcement; add per-handler checks for business invariants.
- Deny-by-default: unlisted routes should not be exposed or must explicitly attach an auth handler.

Route protection (Vert.x Web)
- Global handlers order:
  1. HSTS/CSP/security headers
  2. CORS (if needed)
  3. RateLimiter (token bucket) — worker-friendly and non-blocking data store
  4. BodyHandler (size limited)
  5. BearerAuthHandler / OAuth2AuthHandler
  6. AuthorizationHandler (roles/permissions)
- Static assets should be served from a separate router with least privilege and caching headers.

Token propagation
- Outbound WebClient requests must forward Authorization: Bearer <token> or exchange for client_credentials as needed.
- Never log tokens; redact Authorization headers in logs/metrics.

Web security controls
- CORS: whitelist origins via CORS_ALLOWED_ORIGINS; disallow wildcard in production.
- CSRF: prefer stateless APIs with idempotent design; if browser stateful flows are required, use double-submit cookie or same-site=strict cookies.
- Headers: set HSTS, X-Content-Type-Options, X-Frame-Options/Content-Security-Policy as applicable.
- Body limits: enforce request body size; reject excessive multipart part counts.

Transport (HTTPS/mTLS)
- Always terminate TLS; in development allow HTTP only behind local reverse proxies.
- For mTLS, configure trust store and require client auth; use SANs and narrow trust.

Multitenancy
- Support multiple issuers/realms by mapping host/header → issuer config; cache per-tenant JWKS independently.

Blocking boundaries
- JWKS fetch, introspection, and persistent rate limit operations that may block must use worker threads (executeBlocking) or truly non-blocking clients/backends.

Observability
- Add auth failure metrics and reasons (no token, invalid, expired, insufficient scope).
- Log at INFO only for security-relevant state changes; redact secrets and PII.

Testing
- Provide token fixtures and JWKS test servers; validate route protection matrix.
- Include negative tests: expired tokens, wrong aud/iss, missing permissions.

Anti-patterns
- Using blocking crypto/lib calls on the event loop
- Wildcard CORS in production
- Logging raw tokens or sensitive claims
- Granting broad roles to public routes

References
- Vert.x OAuth2 flow guide — ../vertx/vertx-5-oauth2-flow-guide.md
- Platform secrets and security — ../../platform/secrets-config/security.md
- Env variables — ../../platform/secrets-config/env-variables.md
