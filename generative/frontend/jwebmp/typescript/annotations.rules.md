# Annotations & Contracts Rules

Purpose
- Define how to model Angular metadata using Ng* annotations and CRTP-friendly interfaces so the generator can build accurate TypeScript fragments.

Usage patterns
- Components/directives/services/providers: annotate classes with `@NgComponent`, `@NgDirective`, `@NgServiceProvider`, `@NgProvider`, `@NgModule`, `@NgApp` as needed; pair with the corresponding `INg*` interface for fluent TS helpers (imports, injects, interfaces).
- Inputs/outputs/events: declare `@NgInputs`/`@NgOutputs` with `@NgInput`/`@NgOutput`; match field names to Angular binding expectations; mark `@NgIgnoreRender` or `@NgIgnoreImportReference` when a member should be skipped.
- Routing: use `@NgRoutable` and `@NgRouteData` for path + data; prefer explicit module names over defaults to keep generated import paths stable.
- Signals/models/method hooks: apply `@NgSignal*`, `@NgModels`, `@NgMethods`, `@NgInterfaces`, `@NgInjects` to drive render helpers; keep CRTP setters returning `(J) this`.
- Bootstrapping/module wiring: add `@NgBoot*` annotations for root module imports/providers/declarations; use `@NgImportModule(s)` and `@NgImportProvider(s)` to pull external Angular modules/providers.
- Constructor metadata: `@NgConstructorParameters`/`@NgConstructorBodies` describe generated constructors; pair with TS types (`tstypes`) for primitives.
- TypeScript dependency annotations:
  - `@TsDependency` (repeatable or grouped via `@TsDependencies`) defines runtime `dependencies` for the generated `package.json`. Use the exact semver string you want emitted; set `overrides = true` when the package must also appear under `overrides` to force a resolution for transitive consumers.
  - `@TsDevDependency` (repeatable or grouped via `@TsDevDependencies`) defines `devDependencies` for `package.json` and drives the Angular CLI/build tool versions referenced in `angular.json` project entries. Keep these aligned with the Angular major/minor used by your Ng annotations to avoid mismatched builders.
  - Place these annotations on the Ng app/module types that represent the workspace root (e.g., `INgModule` implementations). The generator aggregates them during scan and writes out `dependencies`, `devDependencies`, and `overrides` blocks before composing `angular.json` so the CLI builder versions match the declared dev dependencies.

Constraints
- Do not mark component classes `final`; CRTP requires extensible generics for fluent chaining.
- Avoid inline HTML/TS; annotations should point to JWebMP component properties rather than embedding markup.
- Inheritance is flattened into the concrete TS output; annotate base classes to contribute metadata, but expect a single emitted TS class unless a base type is explicitly annotated as its own output.
- Do not mix Angular roles across a single inheritance chain (e.g., `@NgComponent` on a base class and `@NgDirective` on a subclass). The generator merges annotations into one TS class, so conflicting roles produce invalid output. Use composition or separate, non-related types when you need both.
- Nullness: follow JSpecify defaults; annotate nullable members explicitly to avoid widening nullability in generated TS.

Examples (minimal)
```java
@NgComponent(tagName = "app-user-card", moduleName = "UserModule")
@NgInput(name = "userId", type = number.class)
@NgInput(name = "username", type = string.class)
@NgOutput(name = "saved", type = number.class)
@Getter
@EqualsAndHashcode(of={"id"})
public class UserCard<J extends UserCard<J>> implements INgComponent<J> {
    // fields/methods follow CRTP; no Lombok setters
}
```

See also
- Index — `README.md`
- Configuration/rendering — `configuration-rendering.rules.md`
- Runtime wiring — `scanning-runtime.rules.md`
- Glossary — `GLOSSARY.md`
