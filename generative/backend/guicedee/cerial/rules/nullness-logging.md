# Nullness, Logging, and Diagnostics — Cerial

Purpose
- Apply JSpecify nullness and logging/diagnostics patterns to the Cerial module.

Requirements
- Nullness: annotate packages with `@org.jspecify.annotations.NullMarked`; use `@Nullable` only where `null` is part of the contract (e.g., optional callbacks). Avoid returning null collections/optionals.
- Logging: use Log4j2 per `rules/generative/backend/logging/README.md`; include port identifiers, statuses, and exception context. Do not use `System.out.println`.
- Diagnostics: prefer structured events via `ComPortEvents` for status/data/error reporting so telemetry remains centralized.
- Lombok: allowed for getters/setters/logging helpers; do not generate builders on CRTP classes.

See also
- API rules — ./api.md
- Data listeners — ./data-listeners.md
- Idle monitoring — ./idle-monitoring.md
