# JWebMP Angular — Type Generation Pipeline

Scope
- Applies to generating Angular 20 source/config from JWebMP annotations using the TypeScript compiler stack.
- Respects forward-only policy and CRTP fluent APIs.

Inputs
- Annotations: `@NgApp`, `@NgComponent`, `@NgRoutable`.
- Configuration flag: `JWEBMP_PROCESS_ANGULAR_TS` (system property `jwebmp.process.angular.ts` or env) gates generation.
- SPI hooks: `ConfigureImportReferences` (maps JWebMP components to Angular tags/imports/inputs/outputs), `NpmrcConfigurator` for `.npmrc` content, optional index/page configurators declared via `uses` in `module-info.java`.

Process
- Lifecycle: `AngularPreStartup` avoids conflicting bindings; `AngularTSPostStartup` triggers generation when the flag is enabled.
- Compiler: `JWebMPTypeScriptCompiler` is present; new work should target `TypeScriptCompiler` while maintaining compatibility.
- Steps:
  - Scan annotated apps/components/routes; build `DefinedRoute` tree.
  - Resolve imports/inputs/outputs via `ConfigureImportReferences`.
  - Apply npm configuration via `NpmrcConfigurator` if provided.
  - Emit Angular source/config (package.json, tsconfig, angular.json) and assets under the dist/webroot tree.
- Do not hand-edit generated outputs; adjust Java annotations/components instead.

Rules
- Honor Angular 20 APIs only; avoid mixing Angular 17/19 APIs.
- Keep CRTP fluent setters in JWebMP components (no Lombok builders or setters).
- Logging in generators uses Log4j2 (`@Log4j2`).
- Avoid inline HTML strings; render structure with JWebMP components.
- Preserve topic-first glossary alignment; reuse terminology from Angular/TypeScript rules.

Validation cues
- Generation runs only when the flag is true; produces Angular 20 source/config without running the Angular build.
- Route tree reflects all `@NgRoutable` entries; missing routes are errors.
- Generated imports/inputs/outputs match the JWebMP component definitions.

See also
- Overview — ./overview.rules.md
- Hosting/messaging — ./hosting-messaging.rules.md
- Angular base — ../../../language/angular/README.md, ../../../language/angular/angular-20.rules.md
- TypeScript base — ../../../language/typescript/README.md
- JWebMP TypeScript client — ../typescript/README.md
