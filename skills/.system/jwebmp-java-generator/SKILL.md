---
name: jwebmp-java-generator
description: "Export JWebMP component JSON or object trees as Java source; configure class snippets, extend reflection mappings, and inspect generated test files."
metadata:
  short-description: JWebMP component JSON and objects to Java source
---

# JWebMP Java Generator

Use the existing Java generator for component JSON → JWebMP objects → reflected construction/state calls → Java files. The frontend submits JWebMP component JSON, with `componentClass` on each node. `JavaDesign` is the internal capture model with optional persistence for tooling.

For usage, configuration, adapters, and CLI examples, read [Java export contracts](references/java-export.md).

## Locate the implementation

In DevSuite, runtime source is under `JWebMP/plugins/java-generator` and contracts/annotations are under `JWebMP/plugins/java-generator-client`. Locate these modules in other workspaces before assuming absolute paths. Their `GUIDES.md`, `RULES.md`, and `docs/architecture/` describe the current implementation.

| Responsibility | Owner |
| --- | --- |
| JSON/object export and adapter discovery | JavaGenerator |
| Existing JWebMP JSON reconstruction | JavaComponentIO |
| Reflection and component identity capture | ComponentCapture |
| Core constructors and owned metadata mappings | CoreTypeAdapter |
| Java emission, imports, dependency ordering | JavaSourceWriter |
| Explicit conflict-checked file output | JavaExportFiles |
| Optional internal design persistence | JavaDesignIO |
| Source contribution annotations/configuration | java-generator-client |

## Output and inspection

`export()`, `exportJson()`, and `generate()` return a `JavaExportResult` in memory. Inspect `javaSource()` / `files()` or call `JavaExportFiles.write(result, sourceRoot)` to save it. Paths in `files()` are relative to that source root and include the generated package directories.

`JavaGeneratorTest` currently writes sources under JUnit `@TempDir`, including `source-<UUID>/generated/example/ExportedPanel.java`. JUnit normally removes that directory after each test. A successful test run does **not** imply retained files under the module's `target/` directory.

When the user wants files for inspection, explicitly save a selected result under a dedicated output directory, for example `<module>/target/generated-examples/<case-or-run>/`, and report the resolved absolute path. Treat this as an additional inspection artifact; keep temporary compilation and fixture directories isolated. Do not say artifacts have been retained unless they were actually written. See the reference for an example and the current test source locations.

## Reconstruction and extension

Capture an authoring tree before request configuration/rendering. Preserve ordered children, explicit identity policy, state and references. Generated reconstruction uses `add()`, `addEvent()`, `addFeature()`, setters and mutable collection calls; getter-owned objects must remain attached to their owners. Keep JWebMP's component marker interfaces and generic hierarchy intact.

Capture reads existing fields through Jackson's reflection boundary rather than constructing defaults or invoking lazy getters. Extend a mapping when state lacks a public reconstruction contract; do not silently discard state or substitute generic HTML. Named behavior stays in its library unless explicitly contributed as Java source. Object snapshots do not recover original loops or method bodies.

Keep component literals separate from explicit Java source contributions. Use repeatable Java source annotations or `JavaClassConfiguration`; body snippets run after captured state restoration, with `component` as the root alias. The generator emits these snippets and does not execute them.

Default writes create new files or accept identical content. Differing existing files are conflicts. Use explicit `ExistingFiles.OVERWRITE` only for output the caller intends to regenerate. Generation does not commit/publish files or bootstrap an application host. Component JSON reconstruction invokes selected constructors and registers the core Jackson module; it follows the existing JSON contract.

## Validation

Run the focused suite from the DevSuite root using Java 25+ and Maven 4:

```powershell
.\mvnw.cmd -o '-P?jwebmp' -pl JWebMP/plugins/java-generator-client,JWebMP/plugins/java-generator -am test '-Dtest=DesignContractTest,JavaGeneratorTest' '-Dsurefire.failIfNoSpecifiedTests=false' '-Dexec.skip=true' '-Dmaven.javadoc.skip=true'
```

Omit `-o` if dependencies are not cached. The optional profile spelling accommodates Maven 4 profile checks. These tests compile emitted sources and reconstruct objects; they do not prove host HTTP/frontend integration or live browser behavior. Inspect `JavaGeneratorTest.java` for supported fixtures and current temporary output paths.
