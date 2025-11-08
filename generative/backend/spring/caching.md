# Spring (Boot MVC) — Caching (Caffeine/Redis)

Scope
- Non-reactive Spring Boot MVC cache strategy using Spring Cache abstraction.
- Covers local in-memory caching with Caffeine and distributed caching with Redis (Lettuce), including naming, TTL/size, keying, invalidation, serialization, metrics, testing, and production posture.

Goals
- Predictable performance with bounded memory/TTL.
- Deterministic keys and invalidation strategy.
- Zero PII leakage; secure transport and storage.
- Observability of hit/miss/eviction with actionable alerts.

Dependencies
- spring-boot-starter-cache (brings cache abstraction)
- Local cache: com.github.ben-manes.caffeine:caffeine
- Distributed: org.springframework.boot:spring-boot-starter-data-redis (Lettuce driver)
- Metrics: Micrometer; Prometheus registry optional

Enable caching
- Add @EnableCaching on a configuration class. Keep cache names centralized and explicit.

Cache naming policy
- Use lowercase kebab-case names scoped by domain. Examples:
  - users-by-id
  - users-by-email
  - products-by-id
  - exchange-rates
- Document each cache’s key contract, TTL, max size, and invalidation triggers.

Keying strategy
- Prefer explicit key expressions (SpEL) with stable, minimal inputs.
- Include versioning prefix when schema/DTO evolution risks stale shape (e.g., v1:users).
- Avoid including unbounded values (raw JSON) in keys; use IDs and concise parameters.
- For multi-tenant systems, include tenant ID in keys or use separate cache namespaces.

Core annotations
- @Cacheable — read-through, caches method result
- @CacheEvict — invalidates entry/region
- @CachePut — updates cache without skipping method invocation

Example service with @Cacheable and @CacheEvict
```java
// com.example.domain.user.UserReadService.java
package com.example.domain.user;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class UserReadService {

  @Cacheable(cacheNames = "users-by-id", key = "#id", unless = "#result == null")
  public UserDto byId(long id) {
    // fetch from repository; map to DTO
    return load(id);
  }

  @CacheEvict(cacheNames = { "users-by-id", "users-by-email" }, key = "#id")
  public void invalidateById(long id) {
    // called after user update/delete
  }
}
```

Caffeine (local, per-instance)
- Best for hot, small working sets requiring very low latency.
- Not shared across instances; invalidation must be local or broadcast via events if consistency matters.

Caffeine configuration (properties)
```yaml
spring:
  cache:
    type: caffeine
    cache-names: users-by-id, users-by-email, products-by-id, exchange-rates
  # spring.cache.caffeine.spec can be global; prefer per-cache builders in config for different TTLs/sizes.
```

Caffeine spec string (global default)
```yaml
spring:
  cache:
    caffeine:
      spec: maximumSize=10000,expireAfterWrite=10m,recordStats
```

Custom Caffeine per cache (Java config)
```java
// com.example.cache.CaffeineConfig.java
package com.example.cache;

import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.cache.CacheManager;
import org.springframework.cache.caffeine.CaffeineCache;
import org.springframework.cache.support.SimpleCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;
import java.util.List;

@Configuration
class CaffeineConfig {

  @Bean
  CacheManager cacheManager() {
    var usersById = new CaffeineCache(
        "users-by-id",
        Caffeine.newBuilder()
            .maximumSize(20_000)
            .expireAfterWrite(Duration.ofMinutes(15))
            .recordStats()
            .build()
    );

    var usersByEmail = new CaffeineCache(
        "users-by-email",
        Caffeine.newBuilder()
            .maximumSize(10_000)
            .expireAfterWrite(Duration.ofMinutes(5))
            .recordStats()
            .build()
    );

    var scm = new SimpleCacheManager();
    scm.setCaches(List.of(usersById, usersByEmail));
    return scm;
  }
}
```

Redis (distributed)
- Best for cross-instance sharing, larger datasets, or when cache coherence matters across nodes.
- Use Lettuce (default) with SSL/TLS. Configure timeouts and pooling conservatively.
- Serialization: prefer JSON with GenericJackson2JsonRedisSerializer for DTO-like payloads.

Redis configuration (properties)
```yaml
spring:
  cache:
    type: redis
    cache-names: users-by-id, users-by-email, products-by-id
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      ssl:
        enabled: true
      timeout: 2s
```

RedisCacheManager with per-cache TTL and JSON serializer
```java
// com.example.cache.RedisCacheConfig.java
package com.example.cache;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.cache.CacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;

import java.time.Duration;
import java.util.Map;

@Configuration
class RedisCacheConfig {

  @Bean
  CacheManager redisCacheManager(RedisConnectionFactory cf) {
    var mapper = new ObjectMapper()
        .findAndRegisterModules()
        .setSerializationInclusion(JsonInclude.Include.NON_NULL);
    var serializer = new GenericJackson2JsonRedisSerializer(mapper);

    var defaultCfg = RedisCacheConfiguration.defaultCacheConfig()
        .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(serializer))
        .entryTtl(Duration.ofMinutes(10));

    var perCache = Map.of(
        "users-by-id", defaultCfg.entryTtl(Duration.ofMinutes(30)),
        "users-by-email", defaultCfg.entryTtl(Duration.ofMinutes(10))
    );

    return RedisCacheManager.builder(cf)
        .cacheDefaults(defaultCfg)
        .withInitialCacheConfigurations(perCache)
        .build();
  }
}
```

CompositeCacheManager (fallback pattern)
- You can chain cache managers (e.g., Level-1 Caffeine, Level-2 Redis) using CompositeCacheManager. Note:
  - Spring Cache treats first manager that returns a cache as the owner; it does not automatically “fill” lower tiers.
  - A two-tier cache requires manual coordination or a purpose-built L1/L2 library. Prefer choosing one tier unless you own the complexity.

Invalidation and coherence
- Invalidate precisely on writes: evict by ID; evict related lookups (email) when identity changes.
- Use @CacheEvict(allEntries = true) sparingly; prefer targeted evictions.
- To broadcast invalidations across instances for Caffeine, publish domain events to a topic (e.g., Redis pub/sub or Kafka) and subscribe to evict locally.

Versioned keys
- Prefix keys with a shape/version when payload structure changes (e.g., v2:users-by-id:123).
- For @Cacheable, incorporate a static version prefix in key or configure a custom KeyGenerator.

Custom KeyGenerator
```java
// com.example.cache.VersionedKeyGenerator.java
package com.example.cache;

import org.springframework.cache.interceptor.KeyGenerator;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.util.Arrays;

@Component("v1KeyGen")
public class VersionedKeyGenerator implements KeyGenerator {
  private static final String PREFIX = "v1";
  @Override
  public Object generate(Object target, Method method, Object... params) {
    return PREFIX + ":" + target.getClass().getSimpleName() + ":" + method.getName() + ":" + Arrays.deepToString(params);
  }
}
```

Using the KeyGenerator
```java
// com.example.domain.user.UserReadService.java
@Cacheable(cacheNames = "users-by-id", keyGenerator = "v1KeyGen")
public UserDto byId(long id) { /* ... */ }
```

Error handling and timeouts
- For Redis: set connection and command timeouts; handle network partitions gracefully.
- Do not fail critical paths solely due to cache errors; treat cache as an optimization (cache-aside).

Security and PII
- Never cache secrets, tokens, or highly sensitive PII unless encrypted at rest and justified by risk assessment.
- For Redis, enable TLS, authentication, and network restrictions. Separate cache DB/index by environment/tenant if applicable.

Metrics
- Caffeine: recordStats exposes hit/miss/eviction; Micrometer auto-binds for Spring Cache where supported.
- Redis: monitor command latency, timeouts, and connection pool metrics.
- Alert on low hit rate for hot caches, high evictions, and Redis timeouts.

Observability examples (properties)
```yaml
management:
  metrics:
    tags:
      application: ${spring.application.name}
```

Testing
- Unit tests: assert keying logic and invalidation flows at service level (call twice, ensure second is cached).
- Slice tests: with Caffeine configuration; for Redis, prefer embedded-redis only for demos—use Testcontainers for parity instead.
- Disable caching when it obscures behavior:
```java
// @SpringBootTest(properties = "spring.cache.type=NONE")
```

Example test (Mocking repository and observing one fetch)
```java
// com.example.domain.user.UserReadServiceTest.java
package com.example.domain.user;

import org.junit.jupiter.api.Test;
import static org.mockito.Mockito.*;

class UserReadServiceTest {

  @Test
  void cachesSecondCall() {
    var svc = spy(new UserReadService());
    // first call -> load; second call -> cached
    svc.byId(1L);
    svc.byId(1L);
    verify(svc, times(1)).byId(1L); // simplistic; prefer counting actual loader invocations
  }
}
```

Production checklist
- Cache names/contracts documented with TTL/size and invalidation rules.
- Caffeine/Redis configured with bounded resources; TLS for Redis enabled; timeouts set.
- Keying strategy deterministic; version prefix applied when shapes evolve.
- Evictions targeted; cross-node invalidation strategy defined (or choose Redis for shared cache).
- Metrics and alerts in place; no sensitive data cached without policy.
- Load tests validate hit rates and latency under expected concurrency.

See also
- Topic index — ./README.md
- MVC REST & Validation — ./mvc-rest-validation.md
- Security (non-reactive) — ./security-mvc.md
- Observability — ../../platform/observability/README.md
- Secrets & Config — ../../platform/secrets-config/README.md
- Database reference — ../../data/database/README.md