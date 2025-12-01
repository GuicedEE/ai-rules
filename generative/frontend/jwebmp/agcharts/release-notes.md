# Release and Migration Notes — AgCharts (JWebMP Rules)

Forward-only stance
- This ruleset replaces any previous AgCharts guidance; do not retain legacy anchors or monolithic docs.
- Angular 20 + JWebMP client + TypeScript + Java 25 are locked for this topic; mixing versions requires explicit override and new rules.

Breaking changes in this release
- Introduced modular AgCharts topic under `rules/generative/frontend/jwebmp/agcharts` with index, glossary, and per-topic rules (overview, angular integration, options/styling, chart components, data/events, testing).
- Added explicit listener naming guidance (`<id>Options`, `<id>Data`) and merge behavior references to architecture sequences.
- Topic-first glossary now authoritative for chart terms; host projects should link rather than duplicate.

Migration guidance
- Update prompts and host project docs to reference `rules/generative/frontend/jwebmp/agcharts/README.md` for AgCharts usage.
- Remove references to deprecated `highlightStyle` and `AgSeriesAreaPaddingOptions`; use `highlight` and general padding options.
- When enabling enterprise features, also load `rules/generative/frontend/jwebmp/agcharts-enterprise/README.md` and ensure licensing is handled in the host app.

See also
- Topic index — ./README.md
- Glossary — ./GLOSSARY.md
- JWebMP topic index — ../README.md
