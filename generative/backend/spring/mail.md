# Spring (Boot MVC) — Mail

Scope
- Guidance for sending email from non-reactive Spring Boot MVC services.
- Covers dependencies, configuration, templating, security (TLS, auth, secrets), deliverability (SPF/DKIM/DMARC), retries, async offloading, testing with in-memory/containers, and observability.

Goals
- Reliable, secure, and observable email delivery.
- Zero secrets in VCS; configuration via env/secret stores.
- Non-blocking request threads: offload mail IO to background executors.

Dependencies
- Spring Mail starter:
```xml
<!-- pom.xml -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-mail</artifactId>
</dependency>
```
```kotlin
// build.gradle.kts
dependencies {
  implementation("org.springframework.boot:spring-boot-starter-mail")
}
```
- Optional templating: Thymeleaf, Pebble, or FreeMarker (choose one)
- Optional test SMTP: GreenMail or Testcontainers-based SMTP

Configuration (application.yml)
```yaml
spring:
  mail:
    host: ${MAIL_HOST:localhost}
    port: ${MAIL_PORT:1025}
    username: ${MAIL_USER:}
    password: ${MAIL_PASSWORD:}
    properties:
      mail.smtp.auth: ${MAIL_SMTP_AUTH:false}
      mail.smtp.starttls.enable: ${MAIL_SMTP_STARTTLS:true}
      mail.smtp.connectiontimeout: 5000
      mail.smtp.timeout: 5000
      mail.smtp.writetimeout: 5000
```
- Do not commit credentials. Route secrets via env/secret stores. See: ../../platform/secrets-config/README.md

Basic service
```java
// com.example.mail.MailService.java
package com.example.mail;

import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class MailService {
  private final JavaMailSender sender;
  public MailService(JavaMailSender sender) { this.sender = sender; }

  public void sendPlain(String to, String subject, String body) {
    var msg = new SimpleMailMessage();
    msg.setTo(to);
    msg.setSubject(subject);
    msg.setText(body);
    sender.send(msg);
  }
}
```

HTML templating (Thymeleaf example)
```java
// com.example.mail.TemplatedMailService.java
package com.example.mail;

import jakarta.mail.internet.MimeMessage;
import org.springframework.mail.javamail.*;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

@Service
public class TemplatedMailService {
  private final JavaMailSender sender;
  private final TemplateEngine templates;

  public TemplatedMailService(JavaMailSender sender, TemplateEngine templates) {
    this.sender = sender;
    this.templates = templates;
  }

  public void sendWelcome(String to, String name) throws Exception {
    Context ctx = new Context();
    ctx.setVariable("name", name);
    String html = templates.process("welcome", ctx); // src/main/resources/templates/welcome.html
    MimeMessage mm = sender.createMimeMessage();
    MimeMessageHelper helper = new MimeMessageHelper(mm, "UTF-8");
    helper.setTo(to);
    helper.setSubject("Welcome!");
    helper.setText(html, true);
    sender.send(mm);
  }
}
```

Async offloading
- Avoid sending emails on request threads. Offload using @Async or a queue/outbox.
```java
// com.example.mail.AsyncMailService.java
package com.example.mail;

import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class AsyncMailService {
  private final MailService mail;
  public AsyncMailService(MailService mail) { this.mail = mail; }

  @Async("asyncExecutor")
  public void sendWelcomeAsync(String to, String body) {
    mail.sendPlain(to, "Welcome", body);
  }
}
```
- See executors and MDC propagation: ./scheduling-async.md

Retries and resilience
- Transient SMTP/network errors should be retried with backoff. Prefer resilience4j:
```java
// com.example.mail.RetryingMailService.java
package com.example.mail;

import io.github.resilience4j.retry.annotation.Retry;
import org.springframework.stereotype.Service;

@Service
public class RetryingMailService {
  private final MailService mail;
  public RetryingMailService(MailService mail) { this.mail = mail; }

  @Retry(name = "mail", fallbackMethod = "fallback")
  public void send(String to, String subject, String body) {
    mail.sendPlain(to, subject, body);
  }

  void fallback(String to, String subject, String body, Exception ex) {
    // enqueue for later or persist for ops investigation
  }
}
```

Security posture
- TLS: enable STARTTLS; require TLS in production.
- Auth: service-specific credentials; rotate regularly; restrict scope.
- Secrets: never commit; inject via env/secret stores.
- Content security: no secrets/PII beyond policy; prefer link tokens that expire instead of embedding sensitive data.

Deliverability
- Configure SPF, DKIM, and DMARC on your sending domain.
- Use a reputable SMTP relay or email provider; maintain sender reputation and bounce handling.
- Avoid spam triggers: balanced HTML/text, proper headers, unsubscribe for marketing.

Observability
- Emit counters/timers for sent, failed, retried emails; include domain and template tags (low-cardinality).
- Log message IDs and correlation IDs; never log full message bodies containing PII.

Testing
- Use in-memory/ephemeral SMTP for tests (GreenMail or Testcontainers-based solutions).
```java
// com.example.mail.MailServiceTest.java
package com.example.mail;

import org.junit.jupiter.api.Test;

class MailServiceTest {
  @Test
  void sends() {
    // Arrange a mock JavaMailSender or use GreenMail; assert send() called and message headers set
  }
}
```
- Avoid relying on live SMTP in CI; keep tests deterministic.

Operations
- Rate limiting: align with provider quotas; implement circuit breakers on persistent failures.
- Outbox pattern (recommended): write mail intents to DB within business transaction; separate worker sends and marks delivered/failed with retries. See: ./data-jpa-transactions.md (outbox) and ./scheduling-async.md

Checklist
- STARTTLS and auth configured; secrets externalized.
- Async/offloaded send path; retries with backoff; dead-letter or outbox for failures.
- Templates separated from code; i18n supported where required.
- Metrics and structured logs; message IDs tracked.
- Deliverability controls (SPF/DKIM/DMARC) validated.

See also
- Scheduling & Async — ./scheduling-async.md
- Security & Auth — ../../platform/security-auth/README.md
- Secrets & Config — ../../platform/secrets-config/README.md
- Observability — ../../platform/observability/README.md