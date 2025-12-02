# WaFormatDate — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-format-date` to render localized dates/times. Aligns with ../../webawesome/format-date.rules.md.

Usage
- Configure date value, format, calendar, hour/minute/weekday/month options, and time zone via fluent setters (see enums in `text` package).
- Place in clusters/stacks; output-only component.

Patterns
- Ensure values are ISO strings or Date-compatible; prefer UTC handling when server-rendering.
