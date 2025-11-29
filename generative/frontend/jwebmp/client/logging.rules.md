# Logging — JWebMP Client (Log4j2 Defaults)

Scope
- Logging expectations for consumers using the JWebMP Client library, aligned with GuicedEE Log4j2 defaults.

Rules
- **Framework**: Use Log4j2 APIs; do not introduce alternative logging frameworks.
- **Context**: Log within call scope; avoid logging raw browser payloads or PII. Redact secrets and tokens.
- **Levels**: Favor `INFO` for lifecycle events, `DEBUG` for diagnostics, `WARN`/`ERROR` for recoverable/terminal issues. Avoid noisy trace logs on render paths.
- **Configuration**: Keep logging configuration in host applications; rules do not ship log config files. Provide guidance only.
- **Tracing**: When integrating with reactive flows, ensure logs preserve correlation/context (e.g., MDC) without blocking event loops.

See also
- Topic index — README.md
- GuicedEE logging defaults — ../../backend/guicedee/README.md#logging
