# Quarkus Security & Identity Rules

Purpose
- Define authentication/authorization patterns using Quarkus OIDC, JWT, and HTTP security extensions.

## OIDC setup
- Use `quarkus-oidc` for server-to-server flows; configure per profile:
```
%prod.quarkus.oidc.auth-server-url=${OIDC_ISSUER}
%prod.quarkus.oidc.client-id=${OIDC_CLIENT_ID}
%prod.quarkus.oidc.credentials.secret=${OIDC_CLIENT_SECRET}
quarkus.oidc.application-type=service
```
- Cache tokens by enabling `quarkus.oidc.token-cache.enabled=true`.

## JWT propagation
- For REST clients, use `quarkus-rest-client-oidc-filter` to propagate tokens; document required scopes in RULES.md.
- Validate roles via `@RolesAllowed` on resources/services. Map claims to roles using `quarkus.oidc.roles.role-claim-path`.

## Native considerations
- Avoid dynamic proxies that rely on reflection; register classes using `@RegisterForReflection` when needed.

## Testing security
- Provide mock tokens using `quarkus-oidc-token-propagation` test utilities or `io.quarkus.test.security.TestSecurity`.
- For harness suites, generate JWTs via helper utilities referencing the same JWKS secrets.

## Secret storage
- Never commit secrets. Use Secrets & Config policies (env vars, Vault). Reference them using `${ENV_VAR}` placeholders.

## Observability & audit
- Enable audit logging: `quarkus.http.access-log.enabled=true`.
- Export metrics via `quarkus.smallrye-metrics` and tag with principal info cautiously.

## See also
- Topic index — ./README.md
- Security/Auth platform rules — ../../platform/security-auth/README.md
- Secrets & Config — ../../platform/secrets-config/README.md
- Testing — ./testing.rules.md
