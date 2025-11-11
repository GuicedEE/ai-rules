# Google Cloud (GCP) Auth — Configuration Guide

Use this guide to configure authentication for services running on or integrating with Google Cloud. It covers Identity-Aware Proxy (IAP), Google as an OpenID Provider (OIDC), and service-to-service options.

Audience: backend developers and platform engineers deploying on GCP.

---

## 1) Choose an approach
- IAP fronting your service
  - Clients authenticate to Google; IAP injects a signed identity header
  - Backend verifies the IAP JWT and extracts the user principal
- Direct OIDC with Google as IdP
  - Your app performs standard OIDC flows against Google endpoints
- Service-to-service
  - Workload Identity Federation or metadata server tokens for GCP-native workloads

---

## 2) Identity-Aware Proxy (IAP)
Headers
- X-Goog-Authenticated-User-Email: user identity (obfuscated for privacy unless configured)
- X-Goog-IAP-JWT-Assertion: signed JWT asserting the user

Verification steps
1. Fetch Google certs and verify signature of the assertion JWT
2. Validate claims:
   - aud equals your IAP OAuth client ID
   - iss equals https://cloud.google.com/iap
   - exp/nbf/iat within tolerance
3. Trust identity only if traffic is known to traverse IAP (e.g., via ingress metadata)

Env variables (suggested)
- GCP_IAP_AUDIENCE=<iap-oauth-client-id>
- OIDC_JWKS_CACHE_TTL_SECONDS=300
- OIDC_CLOCK_SKEW_SECONDS=60

References
- https://cloud.google.com/iap/docs/signed-headers-howto

---

## 3) Google as OIDC provider
Issuer and discovery
- Issuer: https://accounts.google.com
- Discovery: https://accounts.google.com/.well-known/openid-configuration

Registration
- Create OAuth 2.0 Client ID in Google Cloud Console
- For browser apps: use Authorization Code with PKCE
- For server-side apps: Authorization Code; Client Credentials is uncommon with Google consumer identities

Env variables
- OIDC_ISSUER=https://accounts.google.com
- OIDC_CLIENT_ID=<client-id>
- OIDC_CLIENT_SECRET=<client-secret>
- OIDC_AUDIENCE=<your-api-aud or client id>
- OIDC_SCOPES="openid email profile"

Rules
- Consider restricting allowed hosted domains via hd claim
- Validate email_verified claim if email is used for authorization

---

## 4) Service-to-service
Options
- Metadata server tokens (on GCE/GKE/Cloud Run)
- Workload Identity Federation (from non-GCP to GCP)

Guidance
- Prefer short-lived tokens; do not distribute long-lived JSON keys
- Scope tokens narrowly for the target API

---

## 5) Troubleshooting
- IAP 403 despite login: check IAP policy and aud mismatch
- Signature failure: update Google certs/JWKS cache
- Invalid hd/hosted domain: ensure user belongs to allowed domain(s)

---

## See also
- Topic index — ./README.md
- Security & Auth rules — ./security-auth.rules.md
- OpenID Connect (generic) — ./openid-connect.md
- Backend Security (Reactive) — ../../backend/security-reactive/README.md
- Env variables — ../secrets-config/env-variables.md
