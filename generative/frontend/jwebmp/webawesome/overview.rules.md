# Overview — WebAwesome (JWebMP Wrapper)

Use these rules to scope work on the WebAwesome wrapper that plugs Angular Awesome web components into JWebMP pages. Apply them after the base language/framework topics (Java 25 + Maven, Angular 20 + TypeScript, JWebMP client/Angular).

Stack and constraints
- Java 25 LTS with Maven; CRTP fluent APIs (no builders) and Log4j2 logging only.
- Nullness: JSpecify defaults; suppress unchecked warnings only when required by CRTP chaining.
- Generated Angular/TypeScript artifacts remain read-only; change Java sources that drive generation instead.
- Prompt language alignment: prefer `WaButton`, `WaInput`, `WaCluster`, `WaStack` and other WebAwesome names; map variants to base WebAwesome rules under `../../webawesome/`.

Wrapper conventions
- Services: `WebAwesomeInclusionModule` registers the package for Guice scanning; `WebAwesomePageConfigurator` handles assets and theme classes; `@TsDependency` advertises `angular-awesome`.
- Asset order: CSS (`webawesome.css`, theme) with `RequirementsPriority.First`; JS module loader (`webawesome.loader.js`) with `Top_Shelf` priority and `type=module`.
- Avoid inline string HTML in Java; build markup from components. Keep wrappers non-final and CRTP-friendly.
- For new components, extend existing Wa* bases when possible and expose slots/attributes as strongly typed setters returning `(J) this`.

See also
- Page configurator details — ./page-configurator.rules.md
- Component rules — ./button.rules.md, ./input.rules.md#number-input, ./cluster.rules.md, ./stack.rules.md
- Testing — ./testing.rules.md
- Glossary — ./GLOSSARY.md
- Base WebAwesome components — ../../webawesome/README.md
