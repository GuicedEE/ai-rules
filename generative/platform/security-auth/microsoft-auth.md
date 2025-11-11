# Microsoft Entra ID (Azure AD) — Configuration Guide

Use this guide to configure authentication with Microsoft Entra ID (formerly Azure AD). It covers tenant-specific discovery, app registration, token validation, and multi-tenant considerations.

Audience: application developers integrating enterprise SSO.

---

## 1) Tenant and discovery
- Determine tenant:
  - Single-tenant: organization-only
  - Multi-tenant: any Microsoft account (organizations) or specific allowlist
- Discovery
  - Issuer: https://login.microsoftonline.com/{tenant}/v2.0
  - Well-known: https://login.microsoftonline.com/{tenant}/v2.0/.well-known/openid-configuration

Tip: Use the tenant ID (GUID) to avoid ambiguity; common/organizations have special semantics.

---

## 2) App registration
- Register an application in Entra ID
- Configure:
  - Redirect URIs (web/native)
  - Expose an API (if backend): set Application ID URI (api://<client-id> or custom)
  - Required delegated/application permissions (scopes/roles)
  - Client credentials (certificates or secrets) for confidential clients

---

## 3) Flows
- Authorization Code with PKCE (web/native)
- Client Credentials for service-to-service with app roles

---

## 4) Environment variables
- MS_TENANT_ID=<tenant-guid>
- OIDC_ISSUER=https://login.microsoftonline.com/<tenant>/v2.0
- OIDC_CLIENT_ID=<client-id>
- OIDC_CLIENT_SECRET=<client-secret> (confidential clients)
- OIDC_AUDIENCE=<app-id-uri or client-id>
- OIDC_SCOPES="api://<client-id>/.default" (for client credentials) or delegated scopes
- OIDC_JWKS_CACHE_TTL_SECONDS=300
- OIDC_CLOCK_SKEW_SECONDS=60

---

## 5) Token validation
- Validate iss matches tenant issuer
- Validate aud equals your API Application ID URI or client ID
- For delegated tokens, check upn/preferred_username and tenant (tid)
- For app tokens, check azp/appid if required

Multi-tenant apps
- Maintain an allowlist of tenant IDs; deny others

---

## 6) Troubleshooting
- AADSTS50011: redirect URI mismatch — update app registration
- Invalid audience: ensure API Application ID URI matches
- Signature failures: refresh JWKS or check kid mismatch

---

## See also
- Topic index — ./README.md
- Security & Auth rules — ./security-auth.rules.md
- OpenID Connect (generic) — ./openid-connect.md
- Backend Security (Reactive) — ../../backend/security-reactive/README.md
- Env variables — ../secrets-config/env-variables.md
