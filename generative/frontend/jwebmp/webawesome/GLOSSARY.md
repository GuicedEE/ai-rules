# Glossary — WebAwesome (JWebMP Wrapper)

Precedence
- Topic-first: load after base WebAwesome, Angular, and JWebMP glossaries. Do not duplicate definitions in host projects; link here.
- Prompt language alignment: use WebAwesome names (WaButton, WaInput, WaCluster, WaStack) in prompts and docs; copy only these enforced names into host glossaries.

Terms
- **WaButton** — JWebMP wrapper for `wa-button`; CRTP setters for variant/appearance/size/pill, slot helpers for prefix/suffix, supports link attributes via `setAsLink`.
- **WaInput** — Wrapper for `wa-input`; CRTP setters for types/validation/slots; includes number input support (`type=number` with `min`/`max`/`step` and `without-spin-buttons`).
- **WaCluster** — Horizontal layout primitive (`wa-cluster` class) with gap and alignment helpers; use for rows/toolbars; `setNoWrap()` disables wrapping.
- **WaStack** — Vertical layout primitive (`wa-stack` class) with gap and alignment helpers; use for stacked/column layouts.
- **WebAwesomePageConfigurator** — Page-level configurator injecting CSS/JS assets with `RequirementsPriority.First`/`Top_Shelf`, applying theme/body classes, and advertising `angular-awesome` TypeScript dependency.

See also
- Topic index — ./README.md
- Base WebAwesome glossary and rules — ../../webawesome/README.md
- Angular glossary — ../../language/angular/GLOSSARY.md
- TypeScript glossary — ../../language/typescript/GLOSSARY.md
