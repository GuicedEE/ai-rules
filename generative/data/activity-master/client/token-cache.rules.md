# Token Cache Rules

Scope: SYSTEM_TOKEN_CACHE usage for Activity Master client authentication and authorization.

Cache behavior
- SYSTEM_TOKEN_CACHE (ConcurrentHashMap) is keyed by system name -> enterprise UUID -> token UUID; see src/main/java/com/guicedee/activitymaster/fsdm/client/services/IActivityMasterService.java.
- Always read through the cache before calling ISecurityTokenService; populate on cache miss via ISystemsService.getSecurityIdentityToken or equivalent.
- Guard mutations with computeIfAbsent to avoid race conditions and use Vert.x-friendly, non-blocking token retrieval.

Invalidation and refresh
- Invalidate per-system/enterprise entries on token expiry, credential rotation, or system update events; tie cache clears to IOnSystemUpdate and IOnExpireUser hooks.
- Avoid global cache clear unless migration demands it; prefer targeted invalidation to reduce token churn.
- Document cache eviction triggers and token lifetimes in IMPLEMENTATION.md and tests to keep behaviors deterministic.

Security and observability
- Do not log token material; only log token IDs and system/enterprise keys via Log4j2 per ../../../backend/logging/README.md.
- Expose health/metrics for cache hit rates and token refresh counts following ../../../platform/observability/README.md.
- Keep secrets isolated via ../../../platform/secrets-config/env-variables.md and ensure GuicedEE injects secrets through Terraform/CI.

Testing
- Provide unit/contract tests that simulate cache hits/misses and invalidation paths (see ./testing.rules.md).
- Use deterministic token providers or fakes to avoid leaking real credentials in tests.
