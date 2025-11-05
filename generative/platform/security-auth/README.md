# Security & Auth — Topic Index

Use this topic to configure and operate authentication and authorization for applications and services. It focuses on OpenID Connect (OIDC) fundamentals and provider-specific guidance for Google Cloud (GCP), Firebase Auth, and Microsoft Entra ID (Azure AD).

What this covers
- Identity providers and discovery (OIDC well-known endpoints)
- Token types: ID token, access token, refresh token
- Audience, issuer, scopes/roles, and claims
- JWKS rotation and caching
- Backend verification and session/token handling

Guides
- OpenID Connect (generic) — ./openid-connect.md
- Google Cloud (GCP) Auth — ./gcp-auth.md
- Firebase Auth — ./firebase-auth.md
- Microsoft Entra ID (Azure AD) — ./microsoft-auth.md

Rules
- Common rules and conventions — ./security-auth.rules.md

See also
- Backend Security (Reactive) — ../../backend/security-reactive/README.md
- Vert.x OAuth2 flow guide — ../../backend/vertx/vertx-5-oauth2-flow-guide.md
- Secrets & Config — ../secrets-config/README.md
- Env variables reference — ../secrets-config/env-variables.md
- Platform category index — ../README.md
