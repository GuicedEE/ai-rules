---
name: guicedee-mail-client
description: "Annotation-driven SMTP mail client for GuicedEE with Vert.x 5: @MailConnectionOptions for SMTP server configuration, MailService injection for sending text/HTML/multipart emails with attachments, connection pooling, StartTLS/SSL support, DKIM signing, environment variable overrides, and graceful shutdown. Use when sending emails via SMTP, configuring mail connections, or injecting mail services."
metadata:
  short-description: Annotation-driven SMTP mail client inside GuicedEE
---

# GuicedEE Mail Client

Annotation-driven SMTP mail client for GuicedEE using the Vert.x Mail Client.

## Core Concept

Declare SMTP connections with annotations — everything is discovered at startup via ClassGraph, wired through Guice, and managed by the Vert.x Mail Client with connection pooling.

## Required Flow

1. Add `com.guicedee:mail-client` dependency.
2. Define a connection on `package-info.java` (preferred) or any class:
   ```java
   @MailConnectionOptions(
       value = "notifications",
       hostname = "smtp.example.com",
       port = 587,
       startTls = MailConnectionOptions.StartTLSMode.REQUIRED,
       login = MailConnectionOptions.LoginMode.REQUIRED,
       username = "user@example.com",
       password = "secret",
       defaultFrom = "noreply@example.com"
   )
   package com.example.mail;
   ```
3. Inject and send:
   ```java
   public class NotificationService {
       @Inject @Named("notifications")
       private MailService mailService;

       public void sendWelcome(String to) {
           mailService.sendHtml(to, "Welcome!", "<h1>Welcome aboard!</h1>");
       }
   }
   ```
4. Or use full MailMessage for attachments:
   ```java
   MailMessage message = new MailMessage()
       .setTo("user@example.com")
       .setSubject("Report")
       .setText("See attached.")
       .setAttachment(List.of(
           MailAttachment.create()
               .setContentType("application/pdf")
               .setName("report.pdf")
               .setData(Buffer.buffer(pdfBytes))
       ));
   mailService.send(message);
   ```
5. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.mailclient;
       opens my.app.mail to com.google.guice, com.guicedee.mailclient;
   }
   ```

## Annotations

### `@MailConnectionOptions`
SMTP connection configuration: hostname, port, StartTLS, SSL, login credentials, connection pooling, DKIM, keep-alive, default from address. Targets `TYPE` and `PACKAGE`.

## Injectable Components

| Binding | Key | Description |
|---|---|---|
| `MailService` | `@Named("connection-name")` | High-level mail service with convenience send methods |
| `MailClient` | `@Named("connection-name")` | Raw Vert.x mail client per connection |

## Environment Variable Overrides

Every annotation attribute can be overridden via system properties or environment variables at runtime, scoped by connection name:
- `MAIL_{NORMALIZED_NAME}_{PROPERTY}` — name-specific override
- `MAIL_{PROPERTY}` — global fallback

Examples:
- `MAIL_NOTIFICATIONS_HOSTNAME=smtp.prod.example.com`
- `MAIL_NOTIFICATIONS_USERNAME=prod-user`
- `MAIL_NOTIFICATIONS_PASSWORD=prod-secret`
- `MAIL_PORT=465` (global fallback)

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ MailClientPreStartup (annotation scanning)
     ├─ Discovers @MailConnectionOptions (classes and package-info.java)
     └─ Wraps with environment variable resolution
 └─ MailClientModule (Guice bindings)
     ├─ Creates shared MailClient per connection (pooled)
     ├─ Binds MailClient as @Named("connection-name")
     └─ Binds MailService as @Named("connection-name") singleton
 └─ MailClientPostStartup (initialization logging)
 └─ MailClientPreDestroy (shutdown)
     └─ Closes all mail clients
```

## MailService Methods

| Method | Description |
|---|---|
| `send(MailMessage)` | Send a pre-built message (auto-fills from if defaultFrom set) |
| `sendText(to, subject, text)` | Send plain text using default from |
| `sendText(from, to, subject, text)` | Send plain text with explicit from |
| `sendHtml(to, subject, html)` | Send HTML using default from |
| `sendHtml(from, to, subject, html)` | Send HTML with explicit from |
| `sendMultipart(from, to, subject, text, html)` | Send multipart (text + HTML) |
| `getMailClient()` | Access underlying Vert.x MailClient |

## Non-Negotiable Constraints

- Module must `requires com.guicedee.mailclient;`.
- Packages using injection must `opens` to `com.google.guice` and `com.guicedee.mailclient`.
- `@MailConnectionOptions` can be placed on `package-info.java` (preferred) or any class.
- SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).

