# TypeScript — Topic Glossary (Priority over root glossary)

Scope
- Minimal canonical terms for TypeScript in this topic. When this topic is referenced, these terms and directives take precedence over the root glossary. Keep entries concise and route to rules/guides for detail.

LLM interpretation guidance (how to apply these terms)
- Baseline tsconfig (strict-first)
  - Enable strict and related flags by default for libraries and services:
    - "strict": true, "noImplicitAny": true, "strictNullChecks": true
    - "noUncheckedIndexedAccess": true, "exactOptionalPropertyTypes": true
    - "noImplicitOverride": true, "useUnknownInCatchVariables": true
    - "isolatedModules": true (toolchain compatibility and faster TS)
  - Module system (prefer ESM): "module": "ESNext", "target": "ES2022+"; for Node: "moduleResolution": "NodeNext"; for bundlers (Vite/tsup): "moduleResolution": "Bundler".
  - Type-only imports: prefer "import type { T } from '...'" and "export type { T }" with "verbatimModuleSyntax": true (or "preserveValueImports": true on older TS). Set "importsNotUsedAsValues": "error" if available.
- Defaults for code generation
  - Prefer unknown over any; avoid non-null assertion (!). Narrow using type guards and predicates.
  - Prefer discriminated unions over inheritance for variant modeling.
  - Prefer readonly properties/arrays for immutability. Use "as const" for literal inference when appropriate.
  - Prefer string literal unions + const objects with "as const" over enums for runtime-light libs; use enums (or const enums with care) only when interop demands.
- Routing:
  - Language index → ./README.md
  - Angular/React specifics → ../angular/README.md, ../react/README.md
  - Web Components fundamentals → ../../frontend/webcomponents/README.md

Canonical terms

- strict mode
  - Meaning: Compiler configuration enabling comprehensive type safety checks.
  - Includes: "strict": true and allied flags (see above).
  - LLM: generate tsconfig with strict on by default for new libs/apps.

- strictNullChecks
  - Meaning: null and undefined are not assignable to other types unless included in the union.
  - LLM: encode optionality explicitly via unions or optional properties.

- exactOptionalPropertyTypes
  - Meaning: obj.opt?: T is not identical to T | undefined in all contexts; optional presence is tracked more precisely.
  - LLM: model APIs carefully; do not rely on broad undefined unions for optionals; preserve intent.

- noUncheckedIndexedAccess
  - Meaning: Indexed access T[K] includes undefined unless proven.
  - LLM: guard property/index access; prefer safe narrowing and defaults.

- any vs unknown
  - any: opt-out of type safety (unsafest). unknown: top type requiring refinement before use.
  - LLM: prefer unknown; narrow via typeof/in/instanceof/predicates; avoid any unless interop forces it (document).

- never / void
  - never: value that never occurs (exhaustive checks, throws, infinite loop).
  - void: absence of a returned value.
  - LLM: for exhaustiveness, ensure never in switch default triggers compile-time failure.

- type narrowing
  - Meaning: Refinement using control flow analysis (typeof, instanceof, in, equality checks).
  - LLM: prefer narrowing to type assertions; use "satisfies" and predicates for precise inference.

- type predicate
  - Meaning: function isFoo(x: unknown): x is Foo that narrows on true.
  - LLM: provide predicates when external input enters the system (API/DOM/JSON).

- assertion function
  - Meaning: asserts condition is true or asserts x is T; throws on failure.
  - LLM: use sparingly at boundaries; pair with runtime checks.

- discriminated union
  - Meaning: union of object types tagged by a shared discriminant field (kind/type).
  - LLM: prefer for variants; use exhaustive switch + never in default.

- union type / intersection type
  - Union (A | B): one of several types; Intersection (A & B): combine constraints.
  - LLM: avoid excessive intersections that complicate assignability; prefer composition and utility types.

- utility types (canonical set)
  - Partial<T>, Required<T>, Readonly<T>, Pick<T, K>, Omit<T, K>, Record<K, T>, ReturnType<F>, Parameters<F>, InstanceType<C>, NonNullable<T>, Exclude<T, U>, Extract<T, U>.
  - LLM: use to model transformations; avoid deep mutation helpers without need.

- mapped types / template literal types
  - Mapped: {[K in Keys]: T}; Template literals: type Route = `/api/${string}`.
  - LLM: leverage for API/DTO modeling and stringly-typed contracts safely.

- readonly / ReadonlyArray
  - Meaning: compile-time immutability.
  - LLM: prefer readonly where possible; for arrays use readonly T[] or ReadonlyArray<T>.

- as const (const assertion)
  - Meaning: narrows literals and marks properties readonly in the asserted expression.
  - LLM: apply to config objects/enums-as-objects; avoid overuse that harms flexibility.

- satisfies operator
  - Meaning: checks an expression satisfies a type without changing the inferred/narrowed literal types.
  - LLM: prefer for config validation while retaining helpful inference.

- interface vs type alias
  - interface: open to declaration merging; extends other interfaces.
  - type alias: unions/intersections, primitives, mapped/template literal types.
  - LLM: prefer interface for object shapes intended for extension/merging; use type for unions, advanced compositions, and constants.

- structural typing (duck typing)
  - Meaning: assignability based on shape, not nominal identity.
  - LLM: model contracts via shape; employ branded types (opaque types) only when accidental assignability is harmful.

- module system (ESM vs CJS)
  - ESM recommended across modern toolchains. For Node: "module": "NodeNext", "moduleResolution": "NodeNext".
  - LLM: prefer ESM and type-only imports; adhere to bundler/Node configuration consistently.

- DOM/Node libs
  - Meaning: tsconfig "lib" selection controls global types (e.g., "DOM", "ES2022", "DOM.Iterable").
  - LLM: include only required libs; avoid polluting globals unnecessarily.

- path mapping
  - Meaning: "baseUrl" + "paths" for import aliases.
  - LLM: provide coherent aliases; pair with tooling (ts-node/tsx, jest, bundlers) config to resolve identically.

- JSX / React
  - Meaning: "jsx": "react-jsx" (or "react-jsxdev") for React 17+, with automatic runtime.
  - LLM: prefer type-only imports for React types; do not import React for JSX runtime when unnecessary.

- decorators (proposal)
  - Meaning: Experimental; stabilized decorators differ from legacy TS experimental decorators.
  - LLM: avoid unless project/toolchain requires; configure "experimentalDecorators"/"emitDecoratorMetadata" only with explicit instruction.

- linting/format
  - typescript-eslint + eslint:recommended + @typescript-eslint/recommended with type-aware rules; Prettier for formatting.
  - LLM: scaffold lint config with parserOptions.project for type-aware linting where performance budget allows.

- build & tooling
  - tsx/ts-node for dev runtime; tsup/esbuild/rollup/vite for build.
  - LLM: prefer emit-less typechecking (tsc --noEmit) in CI and a bundler for output; use isolatedModules true.

Prompt alignment
- When this topic is selected in prompts:
  - Generate tsconfig.json with strict-first defaults and ESM module settings aligned to the chosen runtime (NodeNext/Bundler).
  - Use unknown, narrowing, and discriminated unions in generated code; avoid any and non-null assertion.
  - Add ESLint (typescript-eslint) and Prettier scaffolding if linting is in scope.
  - For frameworks, route to their language topics (Angular/React) and apply TypeScript idioms consistently.

See also
- Topic index — ./README.md
- Angular — ../angular/README.md
- React — ../react/README.md
- Web Components — ../../frontend/webcomponents/README.md