# Service Interfaces & Templates Rules

Purpose
- Map the `com.jwebmp.core.base.angular.client.services.interfaces` package to the TypeScript generator flow so maintainers know which interfaces drive which emitted TS fragments.
- Keep CRTP-safe extension points (no `final` classes; fluent `(J) this` setters) while avoiding direct edits to generated outputs.

Interface roles
- Core composition:
  - `AnnotationUtils` — shared helpers that walk class/interface hierarchies to gather Ng annotations (including repeatables) and derive TS names/paths; used by render helpers to avoid missing metadata.
  - `ImportsStatementsComponent` — collects `NgImportReference`, `NgComponentReference`, and `NgDataTypeReference` annotations (plus SPI interceptors) and normalizes them into unique relative import statements for emitted TS files.
  - `IComponent` — base contract for everything emitted to TS; aggregates fields, constructor params, methods, interfaces, decorators, and host bindings from annotations and SPIs. Also tracks the current app file/thread locals so renderers know which Angular app/module they are targeting.
- App/module layout:
  - `INgApp` — root Angular app surface (extends `IPage`); declares assets/styles/scripts, route components, and package inclusion lists. Drives app-level file naming (`main.ts`, `app` folder) via `NgSourceDirectoryReference`.
  - `INgModule` — builds the `@NgModule` decorator string from `declarations/providers/exports/bootstrap/schemas` and collects `@TsDependency`/`@TsDevDependency` for `package.json` (and `overrides` when set) and aligned `angular.json` CLI builder versions.
  - `INgComponent` / `INgConfig` — render `@Component` decorators (standalone or module-based), selectors, templates, styles, providers, and host metadata. `INgConfig` is the config-only variant for structural wiring.
  - `INgRoutable` — enum-friendly contract for route metadata/import maps.
- Services/providers:
  - `INgProvider` — generic provider wiring hook; exposes declarations/providers/bootstrap placeholders.
  - `INgServiceProvider` — Injectable service template with RxJS imports, subscription lifecycle (`OnDestroy`), and deep-merge helpers for state updates.
  - `INgDataService` — event-bus–aware data service template (uses `DynamicData` + `EventBusService`) that wires constructor bodies, listeners, and cleanup snippets; renders Ng methods/fields for observable accessors.
- Data modelling:
  - `INgDataType` — maps Java fields (including inheritance and generics) into TS-typed properties; converts primitives, collections, temporal types, UUID, CSS types, nested `INgDataType`/`IComponent` references, and falls back to `any` when needed. Uses `@NgDataType` to mark DTO classes and supports `NgComponentReference` to pull nested types into imports.
- Directives & validation:
  - `INgDirective` — renders `@Directive` with selectors/providers and injects imports for core Angular directive hooks; aggregates constructor parameters for referenced providers.
  - `INgValidatorDirective` — validator-specific directive that auto-adds `NG_VALIDATORS` provider wiring and generates `validate()` delegations to the referenced validator function.
  - `INgFormControlValidatorFunction` / `INgFormGroupValidatorFunction` — scaffolds TS validator function bodies; group variant allows override of rendered fields while preserving exports.
- Utility:
  - `RenderableComponent` (internal) — marker for renderable types; keep extendable for future pipeline hooks.
  - `TypescriptIndexPageConfigurator` — hook for adjusting the rendered `index.html` used by the Angular app. Runs in the TS render pipeline (separate from the default JWebMP `PageConfigurator`), but a single class can implement both to keep base page markup and Angular bootstrap markup in sync.

Guidance
- Extend the closest interface rather than re-implementing rendering logic; the generator relies on these defaults to populate decorators/imports consistently.
- Add Ng annotations on the concrete classes (components, directives, services, data types) so `AnnotationUtils` can traverse superclasses/interfaces and the renderer can compose complete TS outputs.
- When introducing new service or DTO shapes, prefer enhancing the existing interfaces/SPIs (e.g., `OnGetAllImports`, `OnGetAllFields`) to keep generation centralized instead of embedding ad-hoc TS strings.

See also
- Index — `README.md`
- Annotations — `annotations.rules.md`
- Scanning/runtime — `scanning-runtime.rules.md`
- Configuration/rendering — `configuration-rendering.rules.md`
- Testing — `testing.rules.md`
