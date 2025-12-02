# Release Notes — WebAwesome (JWebMP Wrapper)

## 2.0.0-SNAPSHOT (Forward-only)
- Added JWebMP WebAwesome topic index under `rules/generative/frontend/jwebmp/webawesome/` with overview, configurator, component, testing rules, and glossary alignment.
- Documented asset ordering for `WebAwesomePageConfigurator` (CSS first, JS module top-shelf) and CRTP component patterns for WaButton/WaInput/WaCluster/WaStack.
- Captured testing expectations (Java Micro Harness, Jacoco, optional BrowserStack) and prompt language alignment for Wa* naming.
- Added comprehensive wrapper rules for all shipped Wa* components (animated image, animation, avatar, badge, breadcrumbs, callout, card, carousel, checkbox, color picker, comparison/image compare, copy button, details, dialog, divider, drawer, formatters, icon, include, popover/popup, progress bar/ring, QR code, radio/group, slider/range, rating, relative time, scroller, select/option, skeleton, spinner, split panel, tabs, tag, text, textarea, toast, tooltip, tree, switch, zoomable frame) plus layout helpers (grid, flank, frame, split).

Notes
- Forward-only policy: no backward compatibility stubs. Add new component rule files here as wrappers grow; update README links instead of keeping legacy anchors.
