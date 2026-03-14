# GuicedEE baseline for new modules

Use this baseline when creating a new GuicedEE Maven module.

## Maven wrapper (Maven 4)
Create/update `.mvn/wrapper/maven-wrapper.properties` with a Maven 4 distribution URL, for example:

```properties
distributionUrl=https://dlcdn.apache.org/maven/maven-4/4.0.0-rc-5/binaries/apache-maven-4.0.0-rc-5-bin.zip
```

## Required `pom.xml` sections

### Java baseline (JDK 25+)
```xml
<properties>
    <maven.compiler.release>25</maven.compiler.release>
    <maven.compiler.source>25</maven.compiler.source>
    <maven.compiler.target>25</maven.compiler.target>
    <junit.jupiter.version>6.0.3</junit.jupiter.version>
    <mockito.version>5.12.0</mockito.version>
</properties>
```

### GuicedEE BOM import
```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>com.guicedee</groupId>
            <artifactId>guicedee-bom</artifactId>
            <version>${guicedee.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### Enforce Maven and Java versions
```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-enforcer-plugin</artifactId>
            <version>3.6.2</version>
            <executions>
                <execution>
                    <id>enforce-baseline</id>
                    <goals>
                        <goal>enforce</goal>
                    </goals>
                    <configuration>
                        <rules>
                            <requireMavenVersion>
                                <version>[4.0.0-rc-5,)</version>
                            </requireMavenVersion>
                            <requireJavaVersion>
                                <version>[25,)</version>
                            </requireJavaVersion>
                        </rules>
                    </configuration>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

### Testing dependencies (JUnit Jupiter + Mockito)
`pom.xml` must include this dependency at minimum:

```xml
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter</artifactId>
    <scope>test</scope>
</dependency>
```

Recommended full baseline:

```xml
<dependencies>
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>${junit.jupiter.version}</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-junit-jupiter</artifactId>
        <version>${mockito.version}</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Optional browser/E2E dependency (Playwright)
Add Playwright only when browser-level automation is needed.

```xml
<dependency>
    <groupId>com.microsoft.playwright</groupId>
    <artifactId>playwright</artifactId>
    <scope>test</scope>
</dependency>
```

## JPMS module templates

### Main module
`src/main/java/module-info.java`

```java
module com.example.my.module {
    requires com.google.guice;

    // Open package(s) as needed for reflection/injection/serialization/runtime hooks.
    opens com.example.my.module.core to com.google.guice, com.fasterxml.jackson.databind, com.guicedee.vertx;
    opens com.example.my.module.dto to com.fasterxml.jackson.databind;
    opens com.example.my.module.vertx to com.guicedee.vertx;

    exports com.example.my.module.api;
}
```

### Test module
`src/test/java/module-info.java`

```java
module com.example.my.module.test {
    requires com.example.my.module;
    requires org.junit.jupiter.api;

    opens com.example.my.module.core.test to org.junit.platform.commons;
}
```

## Bootstrap main class (required)
Create an application entrypoint under `src/main/java` that initializes logging and Guice context for the current module.

```java
package com.example.my.module.bootstrap;

import com.guicedee.client.IGuiceContext;
import com.guicedee.logging.LogUtils;
import org.apache.logging.log4j.Level;

public class Main {
    public static void main(String[] args) {
        // Configure Logging
        LogUtils.addHighlightedConsoleLogger(Level.DEBUG);
        // Register Slim Classpath Scanning and Modularization
        IGuiceContext.registerModule("com.example.my.module");
        // Start Guice Context
        IGuiceContext.instance().inject();
    }
}
```

Rule: the string passed to `IGuiceContext.registerModule(...)` must match the main module name from `src/main/java/module-info.java`.

## Lifecycle SPI customization (optional but strict when used)

Use the GuicedEE lifecycle SPI interfaces when you need to alter startup/injection behavior:

- `com.guicedee.client.services.lifecycle.IGuicePreStartup`
  - Runs before Guice module injection and can use Vert.x 5 runtime state.
- `com.guicedee.client.services.lifecycle.IGuiceModule`
  - Contributes Guice modules (`AbstractModule`, `PrivateModule`, or similar) in sorted loading order.
  - Cyclic loading forces exit (`Cannot call injector while loading injector`).
- `com.guicedee.client.services.lifecycle.IGuicePostStartup`
  - Runs after startup in sort order.
  - Duplicate `sortOrder` values run tasks in parallel on Vert.x.

All lifecycle hooks extend `IDefaultService<J>` (CRTP); always override `sortOrder()` to control execution order and `enabled()` to conditionally skip.

```java
@Override
public int sortOrder() {
    return 100;
}
```

If any lifecycle SPI is implemented, register it in both places below.

### `module-info.java` registration
```java
module com.example.my.module {
    // existing requires/exports

    provides com.guicedee.client.services.lifecycle.IGuicePreStartup
            with com.example.my.module.lifecycle.ExamplePreStartup;
    provides com.guicedee.client.services.lifecycle.IGuiceModule
            with com.example.my.module.lifecycle.ExampleGuiceModule;
    provides com.guicedee.client.services.lifecycle.IGuicePostStartup
            with com.example.my.module.lifecycle.ExamplePostStartup;
}
```

### `META-INF/services` registration
Create one file per SPI under `src/main/resources/META-INF/services/`:

- `com.guicedee.client.services.lifecycle.IGuicePreStartup`
- `com.guicedee.client.services.lifecycle.IGuiceModule`
- `com.guicedee.client.services.lifecycle.IGuicePostStartup`

Each file contains the implementing class FQCN, for example:

```text
com.example.my.module.lifecycle.ExamplePreStartup
```

## Package rules
- Main source packages remain normal (for example `com.example.my.module.core`).
- Test source packages must end with `.test` (for example `com.example.my.module.core.test`).
- Do not reuse the exact same package name in both main and test source sets.
- Any package requiring injection must include `opens <package> to com.google.guice;`.
- Any package containing DTO/JSON deserialization objects must include `opens <package> to com.fasterxml.jackson.databind;`.
- Any package using Vert.x features must include `opens <package> to com.guicedee.vertx;`.
- Every test package must include `opens <package> to org.junit.platform.commons;`.
- Safe default: if a package is used by multiple reflective runtimes, open it to all required targets in one directive.
