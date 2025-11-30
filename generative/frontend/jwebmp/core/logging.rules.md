# Logging Rules (Log4j2 Default)

Overview
- Default to Log4j2 (`org.apache.logging.log4j.*`) for new code and examples.
- Some legacy classes use Lombok `@Log` (java.util.logging); maintain compatibility but prefer Log4j2 going forward.
- Avoid mixing logging frameworks; rely on host-provided bridges if needed.

Usage
```java
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public final class ComponentDiagnostics {
  private static final Logger LOG = LogManager.getLogger(ComponentDiagnostics.class);

  public void onRenderStart(String componentId) {
    LOG.debug("render start componentId={}", componentId);
  }
}
```

Guidance
- Do not log raw user-supplied HTML/JS; sanitize or truncate payloads from event deserialization.
- Keep configurators and startup hooks fail-fast with clear messages; avoid side effects in logging.
- Let host configuration control levels/appenders; avoid hard-coded level changes in library code.

See also
- Topic index: ./README.md
- Enterprise rules: ../../backend/logging/README.md
- Trust boundaries: docs/architecture/foundations.md (host repository)
