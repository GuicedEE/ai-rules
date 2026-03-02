# Classpath Scanning

Detailed reference for configuring the ClassGraph-based classpath scanner via SPI interfaces and `GuiceConfig`.

## Scanner SPI Interfaces

All scanner SPIs are discovered via `ServiceLoader` / JPMS `provides`. Implement, register in both `module-info.java` and `META-INF/services/`.

### Module & JAR filtering

| SPI Interface | Method | Purpose |
|---|---|---|
| `IGuiceScanModuleInclusions` | `includeModules()` | Modules to **include** in scanning |
| `IGuiceScanModuleExclusions` | `excludeModules()` | Modules to **exclude** from scanning |
| `IGuiceScanJarInclusions` | `includeJars()` | JAR filenames to **include** |
| `IGuiceScanJarExclusions` | `excludeJars()` | JAR filenames to **exclude** |

```java
public class MyExclusions implements IGuiceScanModuleExclusions<MyExclusions> {
    @Override
    public Set<String> excludeModules() {
        return Set.of("java.sql", "jdk.crypto.ec");
    }
}
```

### Package & path filtering

| SPI Interface | Method | Purpose |
|---|---|---|
| `IPackageContentsScanner` | `searchFor()` | Packages to **include** |
| `IPackageRejectListScanner` | `exclude()` | Packages to **exclude** |
| `IPathContentsScanner` | `searchFor()` | Resource paths to **include** |
| `IPathContentsRejectListScanner` | `searchFor()` | Resource paths to **exclude** |

### File content scanners

Fire during the ClassGraph scan to process matched resources inline:

| SPI Interface | Method | Match by |
|---|---|---|
| `IFileContentsScanner` | `onMatch()` | Exact file name (`Map<String, ByteArrayConsumer>`) |
| `IFileContentsPatternScanner` | `onMatch()` | Regex pattern (`Map<Pattern, ByteArrayConsumer>`) |

```java
public class ChangelogScanner implements IFileContentsScanner {
    @Override
    public Map<String, ResourceList.ByteArrayConsumer> onMatch() {
        return Map.of("changelog.xml", (resource, bytes) -> {
            // process matched resource
        });
    }
}
```

## `GuiceConfig` Options

Configure via an `IGuiceConfigurator` SPI implementation:

```java
public class MyConfig implements IGuiceConfigurator {
    @Override
    public void configure(IGuiceConfig config) {
        config.setAnnotationScanning(true);
        config.setFieldScanning(true);
        config.setIncludePackages(true);
    }
}
```

| Setter | Default | Effect |
|---|---|---|
| `setFieldScanning(true)` | `false` | Enable field-level scanning |
| `setAnnotationScanning(true)` | `false` | Enable annotation scanning |
| `setMethodInfo(true)` | `false` | Include method metadata |
| `setIgnoreFieldVisibility(true)` | `false` | Scan non-public fields |
| `setIgnoreMethodVisibility(true)` | `false` | Scan non-public methods |
| `setIgnoreClassVisibility(true)` | `false` | Scan non-public classes |
| `setIncludePackages(true)` | `false` | Whitelist-only package scanning |
| `setPathScanning(true)` | `false` | Enable resource path scanning |
| `setClasspathScanning(true)` | `false` | Enable classpath scanning |
| `setExcludeModulesAndJars(true)` | `false` | Apply module/JAR exclusion lists |
| `setIncludeModuleAndJars(true)` | `false` | Apply module/JAR inclusion lists |
| `setExcludePackages(true)` | `false` | Apply package exclusion lists |
| `setVerbose(true)` | `false` | Verbose ClassGraph output |

## Module Registration

`IGuiceContext.registerModuleForScanning.add("my.module.name")` is the simplest way to restrict scanning to your module. This automatically enables `includeModuleAndJars` and adds the module to the inclusion list.

Without registration, scanning is unrestricted and may incur a performance penalty on large classpaths.

## Default Exclusions

`GuiceDefaultModuleExclusions` ships with a large exclusion list covering JDK internal modules, common library modules (Guice, Jackson, Hibernate, Hazelcast, Log4j, etc.), and framework modules. These are applied by default and rarely need modification.

## Using the Scan Result

The `ScanResult` is injectable:

```java
@Inject
private ScanResult scanResult;
```

Or accessed via:

```java
IGuiceContext.instance().getScanResult()
    .getClassesWithAnnotation(MyAnnotation.class);
```

