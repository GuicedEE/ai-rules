# Spring (Boot MVC) — Security (non-reactive)

Scope
- Security guidance for non-reactive Spring MVC services. Covers authentication, authorization, CSRF, CORS, password hashing, JWT/OIDC resource servers, exception handling, and testing.
- Aligns with enterprise auth: ../../platform/security-auth/README.md and secrets: ../../platform/secrets-config/README.md

Goals
- Stateless APIs by default, using JWT/OIDC resource server validation.
- Clear route-level authorization; consistent 401/403 behavior.
- Safe CSRF handling for browser flows; disabled for pure token APIs.
- Secure actuator exposure; no sensitive endpoints in public.

Dependencies
- spring-boot-starter-security
- For JWT: spring-boot-starter-oauth2-resource-server
- For OIDC client (if calling upstream IdP): spring-boot-starter-oauth2-client

Authentication strategies
- Resource Server (recommended for APIs)
  - Validate bearer JWTs issued by IdP.
  - Configure jwk-set-uri or issuer-uri.
- Session-based (form login) for admin-only UIs behind SSO.
- Basic auth only for internal tools over TLS and rotated credentials.

Minimal JWT resource server config (application.yml)
```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: https://login.example.com/realms/acme
          # or: jwk-set-uri: https://login.example.com/realms/acme/protocol/openid-connect/certs
```

HttpSecurity DSL — stateless API with JWT
```java
// com.example.security.SecurityConfig.java
package com.example.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableMethodSecurity
class SecurityConfig {

  @Bean
  SecurityFilterChain api(HttpSecurity http) throws Exception {
    http
      .csrf(csrf -> csrf.disable()) // stateless token APIs
      .cors(Customizer.withDefaults())
      .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
      .authorizeHttpRequests(auth -> auth
        .requestMatchers("/actuator/health", "/actuator/ready", "/actuator/live").permitAll()
        .requestMatchers("/actuator/**").hasRole("OPS")
        .requestMatchers("/api/admin/**").hasAuthority("SCOPE_admin")
        .requestMatchers("/api/**").authenticated()
        .anyRequest().denyAll()
      )
      .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()));
    return http.build();
  }
}
```

Roles vs authorities
- Spring maps "ROLE_X" to hasRole("X"). Authorities can carry scopes/claims like "SCOPE_read".
- Prefer authorities for fine-grained scopes from JWT (e.g., SCOPE_orders:write).
- Normalize claims mapping using a JwtAuthenticationConverter if IdP uses custom claim names.

Example: map custom claim "permissions" to authorities
```java
// com.example.security.JwtAuthConverter.java
package com.example.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

@Configuration
class JwtAuthConverterConfig {
  @Bean
  Converter<Jwt, ? extends org.springframework.security.core.Authentication> jwtAuthenticationConverter() {
    var converter = new JwtAuthenticationConverter();
    converter.setJwtGrantedAuthoritiesConverter(jwt -> {
      Object raw = jwt.getClaims().getOrDefault("permissions", List.of());
      if (raw instanceof List<?> list) {
        return list.stream()
          .filter(String.class::isInstance)
          .map(String.class::cast)
          .map(p -> new SimpleGrantedAuthority(p))
          .collect(Collectors.toList());
      }
      return List.<GrantedAuthority>of();
    });
    return converter;
  }
}
```

Method security
- Enable @EnableMethodSecurity and guard service methods with @PreAuthorize.
- Keep route rules and method rules consistent; prefer method rules for business invariants.

Example
```java
// com.example.domain.OrdersService.java
package com.example.domain;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

@Service
public class OrdersService {
  @PreAuthorize("hasAuthority('SCOPE_orders:write')")
  public void createOrder(...) { /* ... */ }
}
```

CSRF policy
- For session-based browser flows (form login), keep CSRF enabled and include token in forms/headers.
- For stateless APIs with bearer tokens, disable CSRF.

CORS
- Configure allowed origins/methods/headers per environment.
- Example global CORS config:
```java
// com.example.web.CorsConfig.java
package com.example.web;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.List;

@Configuration
class CorsConfig {
  @Bean
  CorsFilter corsFilter() {
    var cfg = new CorsConfiguration();
    cfg.setAllowedOrigins(List.of("https://app.example.com"));
    cfg.setAllowedMethods(List.of("GET","POST","PUT","PATCH","DELETE"));
    cfg.setAllowedHeaders(List.of("Authorization","Content-Type","If-Match","If-None-Match"));
    cfg.setAllowCredentials(false);
    var source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", cfg);
    return new CorsFilter(source);
  }
}
```

Password hashing
- Use DelegatingPasswordEncoder via PasswordEncoderFactories.createDelegatingPasswordEncoder() with BCrypt default.
- Never store plaintext or weak hashes; rotate via {id} prefixing.

Exception handling (401/403)
- Customize AuthenticationEntryPoint for 401 and AccessDeniedHandler for 403 to return Problem Details aligned with API error model.

Example handlers
```java
// com.example.security.SecurityErrors.java
package com.example.security;

import org.springframework.http.*;
import org.springframework.http.ProblemDetail;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URI;

@Component
class ApiAuthEntryPoint implements AuthenticationEntryPoint {
  @Override
  public void commence(jakarta.servlet.http.HttpServletRequest request,
                       jakarta.servlet.http.HttpServletResponse response,
                       AuthenticationException authException) throws IOException {
    var pd = ProblemDetail.forStatus(HttpStatus.UNAUTHORIZED);
    pd.setTitle("Unauthorized");
    pd.setType(URI.create("https://errors.example.com/problem/unauthorized"));
    response.setStatus(HttpStatus.UNAUTHORIZED.value());
    response.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
    response.getWriter().write(org.springframework.http.converter.json.Jackson2ObjectMapperBuilder.json().build().writeValueAsString(pd));
  }
}

@Component
class ApiAccessDeniedHandler implements AccessDeniedHandler {
  @Override
  public void handle(jakarta.servlet.http.HttpServletRequest request,
                     jakarta.servlet.http.HttpServletResponse response,
                     AccessDeniedException accessDeniedException) throws IOException {
    var pd = ProblemDetail.forStatus(HttpStatus.FORBIDDEN);
    pd.setTitle("Forbidden");
    pd.setType(URI.create("https://errors.example.com/problem/forbidden"));
    response.setStatus(HttpStatus.FORBIDDEN.value());
    response.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
    response.getWriter().write(org.springframework.http.converter.json.Jackson2ObjectMapperBuilder.json().build().writeValueAsString(pd));
  }
}
```

Wire handlers into HttpSecurity
```java
// in SecurityConfig.api(...)
http.exceptionHandling(ex -> ex
  .authenticationEntryPoint(apiAuthEntryPoint)
  .accessDeniedHandler(apiAccessDeniedHandler)
);
```

Actuator security
- Permit health/ready/live; restrict all other actuator endpoints to ops role/network.
- Do not expose env/configprops publicly; prefer basic auth or token-based protection for admin UIs.

Token validation hardening
- Validate audience (aud) when provided.
- Enforce clock skew and token freshness (exp, nbf).
- Scope mapping should be explicit; deny by default.

Testing security
- Use spring-security-test:
  - @WithMockUser for simple role tests.
  - SecurityMockMvcRequestPostProcessors.jwt() for JWT-based tests.

Example MockMvc with JWT
```java
// com.example.web.UserControllerTest.java
package com.example.web;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest
class UserControllerTest {
  @Autowired MockMvc mvc;

  @Test
  void requiresAuth() throws Exception {
    mvc.perform(get("/api/users")).andExpect(status().isUnauthorized());
  }

  @Test
  void allowsWithScope() throws Exception {
    mvc.perform(get("/api/users").with(jwt().authorities(() -> "SCOPE_admin")))
       .andExpect(status().isOk());
  }
}
```

Cross-links
- Security & Auth — ../../platform/security-auth/README.md
- Secrets & Config — ../../platform/secrets-config/README.md
- Actuator & Observability — ./actuator-observability.md
- MVC REST & Validation — ./mvc-rest-validation.md