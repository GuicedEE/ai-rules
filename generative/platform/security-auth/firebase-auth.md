# Firebase Auth — Backend Verification Guide

Use this guide to verify Firebase Authentication tokens issued to your web or mobile apps. Backend services must validate Firebase ID tokens and apply authorization based on claims.

Audience: backend developers integrating Firebase clients.

---

## 1) Token types
- Firebase issues ID tokens (JWT) signed by Google for authenticated users
- Optional: session cookies for long-lived sessions

---

## 2) Verification steps (backend)
1. Retrieve Google public keys (JWKS) and verify JWT signature
2. Validate claims:
   - iss must be https://securetoken.google.com/<PROJECT_ID>
   - aud must equal <PROJECT_ID>
   - sub is the user UID
   - exp/nbf/iat within tolerance
3. Optionally check auth_time and revocation status if you maintain revocation lists
4. For multi-tenancy, validate tenant_id claim where used

---

## 3) Environment variables
- FIREBASE_PROJECT_ID=<project-id>
- OIDC_ISSUER=https://securetoken.google.com/<project-id>
- OIDC_AUDIENCE=<project-id>
- OIDC_JWKS_CACHE_TTL_SECONDS=300
- OIDC_CLOCK_SKEW_SECONDS=60

Secrets handling: Do not store service account JSON in the repo. Use secret managers.

---

## 4) Authorization mapping
- Map custom claims (e.g., admin=true) or roles array to application permissions
- Deny-by-default; explicitly allow role-based routes

---

## 5) Troubleshooting
- Invalid issuer: ensure issuer includes project id
- Audience mismatch: verify you used the Firebase project id, not client id
- Stale keys: refresh JWKS on kid miss

---

## See also
- Topic index — ./README.md
- Security & Auth rules — ./security-auth.rules.md
- OpenID Connect (generic) — ./openid-connect.md
- Backend Security (Reactive) — ../../backend/security-reactive/README.md
- Env variables — ../secrets-config/env-variables.md
