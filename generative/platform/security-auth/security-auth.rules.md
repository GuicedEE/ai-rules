# Security & Auth Rules — OpenID Connect and Provider Configuration

Purpose
- Provide consistent, secure, and interoperable rules for configuring authentication and authorization across providers: generic OIDC, GCP, Firebase Auth, and Microsoft Entra ID (Azure AD).
- Close the loop with backend frameworks (e.g., Vert.x reactive) without duplicating framework specifics.

Scope
- Applies to platform-level identity configuration, token validation, and environment wiring.
- Pairs with backend-specific security rules (see Backend Security (Reactive)).

---

## Core principles
1) Prefer standards (OIDC) over proprietary flows
- Use OIDC Discovery (/.well-known/openid-configuration).
- Use OAuth 2.0 Authorization Code with PKCE for browser apps; Client Credentials only for service-to-service.

2) Verify tokens server-side
- Validate issuer (iss), audience (aud), expiration (exp), not-before (nbf), and signature using JWKS.
- Enforce scopes/roles via claims (scope, roles, permissions) mapped to application authorization.

3) Cache and rotate keys safely
- Cache JWKS with short TTL; honor cache-control headers; handle key rotation gracefully.
- Fail closed on signature mismatch; support background refresh.

4) Least privilege and defense-in-depth
- Use minimal scopes; segment APIs by audience; prefer mTLS for internal service-to-service when feasible.

5) Traceability and observability
- Log auth decisions at debug level (no secrets). Emit metrics for auth failures by reason (expired, audience, signature).

---

## Environment configuration (common)
Recommended variables (align with Env Variables reference):
- OIDC_ISSUER=https://issuer.example.com/
- OIDC_CLIENT_ID=<client-id>
- OIDC_CLIENT_SECRET=<client-secret> (backend-confidential; not in SPAs)
- OIDC_AUDIENCE=<expected-audience>
- OIDC_SCOPES="openid profile email"
- OIDC_JWKS_CACHE_TTL_SECONDS=300
- OIDC_CLOCK_SKEW_SECONDS=60
- AUTH_REQUIRE_MTLS=false

Store secrets in a secure secret manager or CI secret store. Never commit secrets.

See: ../secrets-config/env-variables.md

---

## Generic OIDC rules
- Discover endpoints from: {issuer}/.well-known/openid-configuration
- Use token_endpoint_auth_method appropriate to client type (PKCE for public clients, client_secret_basic for confidential clients).
- Validate nonce/state in browser flows; rotate refresh tokens.
- Map claims to application roles: e.g., roles, groups, permissions.

---

## GCP Auth (Google Cloud)
Use cases
- IAP (Identity-Aware Proxy) protecting backend services
- Google OAuth 2.0 / OIDC with Google as IdP

Rules
- IAP: verify X-Goog-Authenticated-User-JWT with Google certs; check aud equals IAP OAuth client ID; trust only if request came via IAP.
- Direct OIDC: issuer https://accounts.google.com, or https://accounts.google.com for discovery; prefer hosted domain restrictions via hd claim if applicable.
- Service-to-service: consider Workload Identity Federation; prefer metadata server where applicable within GCP.

Env examples
- GCP_IAP_AUDIENCE=<iap-oauth-client-id>
- OIDC_ISSUER=https://accounts.google.com
- OIDC_AUDIENCE=<your-api-audience>

---

## Firebase Auth
Use cases
- Mobile/Web apps using Firebase Authentication with backend verification.

Rules
- Verify Firebase ID tokens using Google public keys and expected project_id/issuer: https://securetoken.google.com/<PROJECT_ID>
- Check aud matches Firebase project; check auth_time if required; allow revoked token checks when needed.
- For multi-tenancy, validate tenant_id claim.

Env examples
- FIREBASE_PROJECT_ID=<project-id>
- OIDC_ISSUER=https://securetoken.google.com/<project-id>
- OIDC_AUDIENCE=<project-id>

---

## Microsoft Entra ID (Azure AD)
Use cases
- Enterprise SSO for users or service principals.

Rules
- Use issuer and discovery per tenant: https://login.microsoftonline.com/{tenant}/v2.0/.well-known/openid-configuration
- Validate tid (tenant) and azp/appid as applicable; confirm aud matches your API application ID URI or client ID.
- For multi-tenant apps, validate allowed tenants list.

Env examples
- MS_TENANT_ID=<tenant-guid>
- OIDC_ISSUER=https://login.microsoftonline.com/<tenant>/v2.0
- OIDC_AUDIENCE=<app-id-uri or api application id>

---

## Authorization mapping
- Normalize claims to a local model (e.g., roles → ROLE_*)
- Deny-by-default; explicit allow lists for sensitive operations
- Prefer policy-as-code (e.g., route metadata → required scopes)

---

## Operational guidance
- Rate-limit token introspection (if used)
- Alert on repeated signature or issuer failures
- Rotate client secrets and certificates; monitor JWKS key sets for rotation

---

## See also
- Topic index — ./README.md
- OpenID Connect — ./openid-connect.md
- GCP Auth — ./gcp-auth.md
- Firebase Auth — ./firebase-auth.md
- Microsoft Auth — ./microsoft-auth.md
- Backend Security (Reactive) — ../../backend/security-reactive/README.md
- Vert.x OAuth2 flow guide — ../../backend/vertx/vertx-5-oauth2-flow-guide.md
- Secrets & Config — ../secrets-config/README.md
- Env variables — ../secrets-config/env-variables.md
