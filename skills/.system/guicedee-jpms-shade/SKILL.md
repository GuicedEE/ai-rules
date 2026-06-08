---
name: guicedee-jpms-shade
description: "Convert an automatic-module (or non-modular) JAR dependency into a GuicedEE shaded JPMS service module so the GuicedEE/jlink pipeline stays clean. Use when a GuicedEE module requires an automatic module (a JAR with only an Automatic-Module-Name or none), when jlink/jpms complains about automatic modules on the module path, or when adding a new `com.guicedee.modules.services` shade under `services/Libraries`. Covers the maven-shade + moditect module-info pattern, version + BOM registration (Versioner, StandaloneBOM, guicedee-bom), dev-suite build registration, and rewiring the consuming module."
---

# GuicedEE JPMS Shade

Turn an automatic-module dependency into a proper, named JPMS module published as a
`com.guicedee.modules.services` artifact, then make the consuming GuicedEE module require the
shaded module instead of the automatic one. This yields a clean `jlink` image (no automatic
modules on the module path).

## When This Applies
- A GuicedEE module `requires <some.automatic.module>` that resolves to a plain JAR.
- `jlink` / `jpms` rejects or warns about automatic modules.
- Goal: a fully-named module graph for a reliable runtime image.

## Inputs To Gather First
1. The upstream coordinates and resolved version (e.g. `com.graphql-java:graphql-java:26.0`).
   Resolve the EXACT version the parent already pulls (check the dependency's own POM, the BOM
   that imports it, or `mvn dependency:tree`). Pin to that version — do not guess.
2. The **module name** the JAR advertises. Read it from the JAR manifest
   `Automatic-Module-Name`; if absent, derive a stable name from the root package.
   See `references/inspect-jar.md` for ready-to-run commands to read the manifest and enumerate
   packages (needed for accurate `exports`).
3. The dependency's own external module dependencies (its compile deps that are NOT already
   bundled/relocated inside the JAR). Each becomes a `requires` in the module-info.
   Annotation-only deps (jspecify, jsr305, checker, error_prone) become `requires static`.

> Many libraries already relocate their transitives internally (e.g. graphql-java bundles ANTLR
> and Guava under `graphql.*`). Inspect the package list — only NON-relocated, externally-visible
> dependencies need a `requires`.

## Workflow

### 1. Create the shade module
Create `GuicedEE/services/Libraries/<artifactId>/` (mirror the `json` / `kafka-client` modules):
- `pom.xml` — parent `com.guicedee:parent`, groupId `com.guicedee.modules.services`, the shade
  `artifactSet` pinned to the single upstream artifact, and the standard plugin chain
  (shade → antrun → moditect → flatten → copy-rename → javadoc). Exclude transitives that you
  re-add as their own proper modules.
- `src/moditect/module-info.java` — the named module descriptor.

Use the exact templates in `references/templates.md`.

### 2. Write the moditect module-info
- `module <module-name> { ... }` using the manifest's Automatic-Module-Name.
- `exports` every public package found in the JAR EXCEPT internally-relocated/shaded packages
  (e.g. `*.com.google.*`, `*.org.antlr.*`).
- `requires transitive` for deps whose types appear in the exported API (e.g. `org.reactivestreams`).
- `requires static` for annotation-only deps.
- Add `provides ... with ...` for any `META-INF/services` the JAR ships (the SPI needs explicit
  `provides` in the descriptor, even though the shade keeps the service files).

### 3. Register versions and BOMs
- `GuicedEE/bom/Versioner/pom.xml` — add `<...version>` properties for the upstream artifact(s).
- `GuicedEE/bom/StandaloneBOM/pom.xml` — `dependencyManagement` for the UPSTREAM artifacts (so the
  shade module's `pom.xml` and its exclusions resolve versions).
- `GuicedEE/bom/pom.xml` (guicedee-bom) — `dependencyManagement` for the new
  `com.guicedee.modules.services:<artifactId>` at `${guicedee.version}` (so consumers omit versions).

### 4. Register in the dev-suite build (the "workflows")
- Root `DevSuite/pom.xml` → `services` profile `<modules>` list. This is the module list the
  dev-suite GitHub workflows build/deploy; the reusable workflows in `GuicedEE/workflows` are generic
  templates and do NOT enumerate modules. Each shade also ships as its own GitHub repo that calls the
  reusable `Projects Builder` workflow — mention this to the user, but it is created outside DevSuite.
- Optionally document the mapping table in `GuicedEE/services/services.md`.

### 5. Rewire the consuming module
In the GuicedEE module that used the automatic module:
- Exclude the upstream automatic artifact(s) from whatever transitively brought them in
  (e.g. exclude `com.graphql-java:graphql-java` from `io.vertx:vertx-web-graphql`).
- Add a dependency on the new `com.guicedee.modules.services:<artifactId>`.
- The consumer's `module-info.java` usually needs **no change**: the shaded module keeps the same
  module name, so `requires <module-name>` already resolves — now to a real named module.

### 6. Validate
Install the updated BOMs first (they are SNAPSHOTs the shade module imports), then build:
```
mvn -B -N install        # in Versioner, then StandaloneBOM, then GuicedEE/bom
mvn -B install -DskipTests -Dmaven.javadoc.skip=true   # in each new shade module
jar --describe-module --file target/<artifactId>-<ver>.jar   # confirm requires/exports
mvn -B -o clean compile  # in the consumer module — must compile on the module path
```
Confirm `jar --describe-module` shows the expected named module with correct `requires`/`exports`,
and that the consumer compiles with `[debug release N module-path]`.

## Pitfalls
- **Build env (Windows)**: the repo `mvnw` wrapper may be broken; a system Maven 4
  (`C:\Software\maven4`) + `JAVA_HOME=c:\software\jdk\25` works. Chain PowerShell commands with `;`.
- **Relocated deps need explicit `requires` for JDK modules.** When a library internally relocates
  its dependencies (e.g. graphql-java bundles Guava under `graphql.com.google.*` and ANTLR under
  `graphql.org.antlr.*`), those classes still use JDK APIs such as `java.util.logging`. As an
  *automatic* module the jar implicitly read every module, so it worked; as a *named* module it only
  reads what it `requires`. Missing ones surface at RUNTIME, not compile time, as
  `IllegalAccessError: class X (in module M) cannot access class Y (in module java.logging) because
  module M does not read module java.logging`. Add the JDK module (e.g. `requires java.logging;`).
  Compile + `jar --describe-module` will NOT catch this — only running the code does. Always run the
  consumer's integration tests after a shade.
- **Missing version errors** in the shade module mean the updated StandaloneBOM was not installed yet.
- **Split packages**: never let the shaded module and a separately-required module both export the
  same package — exclude the transitive from one side.
- **Don't export relocated internals** — they are implementation detail and break encapsulation.

## References
- `references/templates.md` — copy-paste `pom.xml` and `module-info.java` templates + BOM snippets.
- `references/inspect-jar.md` — PowerShell snippets to read the manifest module name and package list.
- `references/worked-example.md` — the graphql-java + java-dataloader case, end to end.

