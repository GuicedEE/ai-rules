# Glossary — JWebMP Typescript Client (Topic-First)

Scope: canonical terms for the Ng* annotation-to-TypeScript pipeline. This glossary overrides root definitions for this topic. Host projects should link here and copy only enforced prompt-language mappings.

Precedence & usage
- Topic-first: prefer this glossary for Ng*/Angular metadata terms; fall back to root `GLOSSARY.md` and enterprise glossaries in `rules/`.
- Prompt alignment: use Ng-prefixed names (NgComponent, NgDirective, NgDataService, NgProvider, NgSignal, NgModel) when prompting AIs; avoid generic “component metadata” phrasing.
- LLM guidance: describe flows as “annotation scan → configuration builder → render helpers → generated TS build artifacts”. Do not invent Angular runtime behavior inside this library.

Terms
- Ng* annotations: Java annotations under `com.jwebmp.core.base.angular.client.annotations.*` that declare Angular-facing metadata (components, directives, providers, routing, signals, models, constructors, bootstrapping).
- AnnotationHelper: service that triggers ClassGraph scan and aggregates Ng* metadata into `AnnotationsMap`; invoked by `AngularTypeScriptPostStartup` via Vert.x worker.
- Configuration builders: `ComponentConfiguration`, `AbstractNgConfiguration`, and reference classes that structure metadata (imports, injects, inputs/outputs, interfaces, routing, providers) before rendering.
- Render helpers: `renderOnInit`, `renderOnDestroy`, `renderFields`, `renderSignals`, `renderModels`, and related helpers that emit TypeScript code fragments for downstream assembly.
- TypeScript artifacts: build-time outputs consumed by the Angular toolchain; never edited by hand and not treated as runtime inputs.
- CRTP chaining: fluent setters returning `(J) this` across configuration types; builders are not used in this library.
- Trusted infrastructure: GuicedEE/Guice lifecycle and Vert.x worker pool used to run scans without blocking event-loop threads; logging routed through Log4j2 with Lombok `@Log4j2`.
