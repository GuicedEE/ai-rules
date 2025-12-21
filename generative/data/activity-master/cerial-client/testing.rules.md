# Testing and Validation (Cerial Master Client)

Coverage and harness
- Use Jacoco and Java Micro Harness guidance (`rules/generative/platform/testing/jacoco.rules.md`, `rules/generative/platform/testing/java-micro-harness.rules.md`) for coverage targets and micro-benchmark style harnessing.
- Exercise Mutiny `Multi` streams with real subscribers to verify retry, pause/resume, cancel, and idle transitions. Ensure subscribers observe `StatusUpdate`, `MessageProgress`, and snapshot callbacks.

Scenarios to cover
- Payload suppliers: verify `Supplier` and `IntFunction` payload hooks run per attempt and fall back to previous payloads on null.
- Timeout semantics: assert behavior when `alwaysWaitFullTimeoutAfterSend` is toggled; confirm `alwaysSucceed` messages terminate after computed window.
- Publishing controls: validate `setPublishingEnabled(false)` still triggers in-process telemetry while suppressing Vert.x emissions.
- Idle timeout: test both `cerialmaster.manager.idleAfterMs` and `cerialmaster.manager.idleAfterMinutes` bindings to ensure manager resets correctly after inactivity.
- Registry reuse: assert `ComPortConnection.getOrCreate` returns the same instance per port and keeps `TIMED_SENDERS` in sync.

Observability
- Capture Log4j2 appenders during tests to assert retries, terminal states, and error paths are logged with COM port and message identifiers.
- Include timestamps and `friendlyName` in assertions to keep telemetry readable.

Forward-only notes
- When changing DTO fields or telemetry contract, update `GLOSSARY.md`, this file, and release notes in the same change set. Do not keep legacy aliases.
