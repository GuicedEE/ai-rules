# Java export contracts

## Modules and input

| Artifact | JPMS module | Purpose |
| --- | --- | --- |
| com.jwebmp.plugins:java-generator | com.jwebmp.java.generator | Reflection capture, source emission, JSON reading, file output |
| com.jwebmp.plugins:java-generator-client | com.jwebmp.java.generator.client | Options/results, internal records, annotations, adapter contracts |

Versions are managed by the JWebMP BOM; inspect the current workspace POMs. Generated Java directly references JWebMP and the original component/behavior libraries. It contains no exporter helper calls. Libraries used by a contributed snippet remain consumer dependencies.

The runtime accepts existing `IComponentHierarchyBase<?, ?>` trees or ordinary JWebMP JSON:

```json
{
  "componentClass": "com.jwebmp.core.base.html.DivSimple",
  "text": "Welcome",
  "classes": ["card"],
  "children": [
    {"componentClass": "com.jwebmp.core.base.html.Paragraph", "text": "Hello"}
  ]
}
```

`JavaComponentIO` registers `JWebMPJacksonModule` through `IJsonRepresentation.registerModule()` and delegates to `IComponentBase.from()`. Nested children use the existing concrete-class discriminator contract. This path invokes component constructors but does not start GuicedEE. JSON fidelity is governed by JWebMP's serialization/deserialization contract; an in-memory export can preserve additional state omitted from JSON. A hosting editor owns its exposed component catalog and source configuration.

## Generate and save

```java
import com.jwebmp.java.generator.JavaGenerator;
import com.jwebmp.java.generator.JavaExportFiles;
import com.jwebmp.java.generator.client.JavaExportOptions;
import java.nio.file.Path;

var options = JavaExportOptions.defaults("example.ui", "WelcomePanel").asComponent();
var result = new JavaGenerator().exportJson(componentJson, options);
// For an existing object tree: generator.export(component, options).
String source = result.javaSource();
Path output = Path.of("target", "generated-examples", "welcome").toAbsolutePath().normalize();
var written = JavaExportFiles.write(result, output);
written.forEach(System.out::println);
```

This explicitly saves `<output>/example/ui/WelcomePanel.java`. Resolve `output` from the intended module/workspace directory; IDE and Maven working directories may differ. Report the printed absolute filenames to the user.

Default options emit a final factory with a static `create()` returning the original concrete type. `.asComponent()` emits a reusable subclass with a public constructor. Final/sealed/abstract roots and superclass arguments that need preparation or other components require factory mode. `.withIds(PRESERVE_ALL)` retains framework IDs when existing strings/scripts refer to them; the default `EXPLICIT_ONLY` retains IDs represented by an id attribute. `.withModule("example.ui")` also emits `module-info.java` based on discovered source types plus explicit requirements; it is not an application dependency resolver.

`JavaExportFiles.write()` protects differing existing files by default and checks path containment. A caller intentionally regenerating owned files may pass `JavaExportFiles.ExistingFiles.OVERWRITE`. Do not silently choose overwrite for handwritten files.

## Inspect test output

The DevSuite test is `JWebMP/plugins/java-generator/src/test/java/com/jwebmp/java/generator/test/JavaGeneratorTest.java`. Its `@TempDir Path temporary` owns compilation, CLI, and conflict-test artifacts. `compileAndInstantiate()` writes to `temporary/source-<UUID>/generated/example/ExportedPanel.java`; CLI fixtures use sibling `cli-source/` and `json-cli-source/` directories. JUnit normally deletes these after the test.

To retain one result, add or run an explicit inspection export with `JavaExportFiles.write()` as above. Use a case/run directory so independent fixtures using the same class name do not conflict. Do not redirect all temporary fixture paths into a shared persistent directory: some tests deliberately mutate files to verify conflict handling. If changing test retention itself, keep compilation isolated and document the retained path.

## Source contributions

Annotations live in `com.jwebmp.java.generator.client.annotations` and apply to the root component type:

| Annotation | Contribution |
| --- | --- |
| JavaImport | Qualified type import |
| JavaClassAnnotation | Complete annotation declaration including @ |
| JavaImplements | Qualified interface name |
| JavaField | Complete field declaration |
| JavaMethod | Complete method declaration including body |
| JavaBody | Constructor/factory body statements |
| JavaModule | Additional JPMS requirement |

All are repeatable. Declared contributions are collected base class first, then the caller's `JavaClassConfiguration` is appended. Its record fields are `imports`, `annotations`, `interfaces`, `fields`, `methods`, `body`, `requiredModules`, each an immutable string list. Imports/interfaces/modules are qualified names; use fully qualified names inside snippets if an import collides. These snippets are explicit source, while component text/attributes/properties remain escaped literals.

```java
@JavaImport("java.util.Locale")
@JavaField("private int visits;")
@JavaMethod("public String greeting() { return \"HELLO\".toLowerCase(Locale.ROOT); }")
@JavaBody("component.addAttribute(\"data-generated\", \"true\");")
public class WelcomeDefinition extends DivSimple<WelcomeDefinition> { }
```

Use subclass output for instance fields/methods. The body runs after reflected reconstruction and sees the root through `component`; `this` is also available in subclass mode. Factory bodies are static, so their class contributions must respect static method semantics. Source compilation validates contributed Java; generation does not compile/execute snippets automatically or decompile existing behavior.

## Adapters and model

`JavaTypeAdapter` in `com.jwebmp.java.generator.client.spi` supplies `supports()`, `construction()`, optional `mutations()`, `handledProperties()`, and `priority()`. Declare constructor/mapping-managed fields in `handledProperties()`; the remaining bean fields still undergo capture. Larger priorities win and matching ties fail. Register providers in both `module-info.java` and `META-INF/services`, or pass instances into `new JavaGenerator(List.of(adapter))`.

`JavaCaptureContext.value()` captures nested data, `reference()` retains component identity including components held outside the child tree, and `field()` reads a raw field without invoking a lazy getter. `JavaValue.CONSTRUCT` models constructors; `ACCESSOR` models existing owner-held objects. Do not recreate getter-owned instances as detached objects. Core page metadata needs initializer calls before accessing nullable owned values. Read `CoreTypeAdapter` and `ComponentCapture` before extending these mappings.

Serializable state packages use the existing `opens ... to tools.jackson.databind` boundary. Preserve the JWebMP hierarchy; handle construction/state through public APIs and adapters rather than widening marker interfaces or module access. Capture rejects hierarchy/constructor/value cycles and unsupported reconstruction with a path.

`capture()` produces immutable `JavaDesign`; `generate()` emits it. `JavaDesignIO` optionally persists this internal model and does not execute constructors or snippets on read. The frontend does not need to author it.

## CLI

Run `com.jwebmp.java.generator.JavaGeneratorBootstrap` with the generator/component dependencies on the classpath or module path:

```text
--component-json component.json package.name ClassName output-source-root
design.json package.name ClassName output-source-root
```

Both modes emit factories without bootstrapping GuicedEE. A zero-argument invocation is an explicit host bootstrap. The first mode uses component JSON; the second uses a saved internal design. No Git publication occurs.
