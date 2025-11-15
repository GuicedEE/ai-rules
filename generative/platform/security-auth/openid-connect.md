# OpenID Connect — Generic Configuration Guide

Use this guide to configure authentication using a standards-compliant OpenID Connect (OIDC) provider. It covers discovery, client registration, token validation, and environment variables.

Audience: application developers and platform engineers.

---

## 1) Discovery and metadata
- Base issuer URL (example): https://idp.example.com
- Well-known configuration: {issuer}/.well-known/openid-configuration
- From metadata, retrieve:
  - authorization_endpoint
  - token_endpoint
  - jwks_uri
  - end_session_endpoint (if supported)

Tip: Do not hardcode endpoints; prefer discovery.

---

## 2) Client types and flows
- Public clients (SPAs, mobile): Authorization Code with PKCE
- Confidential clients (backend): Authorization Code (server) and/or Client Credentials for service-to-service

Registration inputs
- Redirect URIs
- Post-logout redirect URIs
- Allowed scopes (openid, profile, email, offline_access, custom scopes)
- Token endpoint auth method (none for PKCE; client_secret_basic for confidential)

---

## 3) Environment variables
Recommended variables (see Env Variables reference):
- OIDC_ISSUER=https://idp.example.com/
- OIDC_CLIENT_ID=<client-id>
- OIDC_CLIENT_SECRET=<client-secret> (confidential clients only)
- OIDC_AUDIENCE=<expected-aud>
- OIDC_SCOPES="openid profile email"
- OIDC_JWKS_CACHE_TTL_SECONDS=300
- OIDC_CLOCK_SKEW_SECONDS=60

Store secrets with a secret manager; never commit them.

---

## 4) Token validation (backend)
- Validate signature using JWKS from jwks_uri
- Validate claims: iss, aud, exp, nbf, iat
- Optional: nonce (for browser flows), acr/amr enforcement
- Map identity to app roles via claims: roles, groups, permissions, or custom claim namespaces

JWKS handling
- Cache keys with TTL; refresh on key id (kid) misses; fail closed on signature mismatch

---

## 5) Logout and session handling
- Browser apps: use end_session_endpoint if supported; clear local session and refresh tokens
- Backend sessions: invalidate on logout and rotate refresh tokens

---

## 6) Troubleshooting
- 401 with valid token: check audience/issuer mismatch
- Signature errors: outdated JWKS cache or wrong kid
- CORS errors: update allowed origins on IdP app config

---

## See also
- Topic index — ./README.md
- Security & Auth rules — ./security-auth.rules.md
- Backend Security (Reactive) — ../../backend/security-reactive/README.md
- Vert.x OAuth2 flow guide — ../../backend/vertx/vertx-5-oauth2-flow-guide.md
- Secrets & Config — ../secrets-config/README.md
- Env variables — ../secrets-config/env-variables.md
