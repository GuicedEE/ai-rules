# WaBadge — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-badge` to display status/count indicators. Attributes mirror ../../webawesome/badge.rules.md; use CRTP setters on `WaBadge<J>`.

Usage
- Attach to clusters/stacks or alongside other Wa* components; no implicit columns.
- Configure variant/appearance/shape, count/value, and optional pill/dot styles via fluent setters.
- Keep labels accessible; provide screen-reader text when displaying icons-only badges.

Patterns
- Avoid inline HTML; use component APIs.
- Use WebAwesome variants for consistent theming; align with project glossary (WaBadge).
