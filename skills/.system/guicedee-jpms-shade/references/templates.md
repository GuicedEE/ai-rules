# Templates

Copy-paste templates for a GuicedEE JPMS shade module. Replace `<...>` placeholders.

## Contents
- Shade module `pom.xml`
- moditect `src/moditect/module-info.java`
- Versioner property snippet
- StandaloneBOM dependencyManagement (upstream)
- guicedee-bom dependencyManagement (shaded service)
- Root dev-suite `pom.xml` registration
- Consumer module rewire

---

## Shade module `pom.xml`

`GuicedEE/services/Libraries/<artifactId>/pom.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://maven.apache.org/POM/4.0.0" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>com.guicedee</groupId>
        <artifactId>parent</artifactId>
        <version>2.1.1-SNAPSHOT</version>
    </parent>
    <groupId>com.guicedee.modules.services</groupId>
    <artifactId><ARTIFACT_ID></artifactId>
    <name><MODULE_NAME></name>          <!-- conventionally the JPMS module name -->
    <version>2.1.1-SNAPSHOT</version>
    <description>JPMS modularized shade of <UPSTREAM_GA> exposing the <MODULE_NAME> module.</description>
    <url>https://guicedee.com</url>
    <licenses>
        <license>
            <name>The Apache Software License, Version 2.0</name>
            <url>https://www.apache.org/licenses/LICENSE-2.0</url>
            <distribution>repo</distribution>
        </license>
    </licenses>
    <properties>
        <project.scm.nameUrl>/GuicedEE/Services</project.scm.nameUrl>
    </properties>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <executions>
                    <execution>
                        <id>shade</id>
                        <phase>package</phase>
                        <goals><goal>shade</goal></goals>
                        <configuration>
                            <artifactSet>
                                <includes>
                                    <include><UPSTREAM_GROUP>:<UPSTREAM_ARTIFACT></include>
                                </includes>
                            </artifactSet>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
            <plugin><groupId>org.apache.maven.plugins</groupId><artifactId>maven-antrun-plugin</artifactId></plugin>
            <plugin><groupId>org.moditect</groupId><artifactId>moditect-maven-plugin</artifactId></plugin>
            <plugin><groupId>org.codehaus.mojo</groupId><artifactId>flatten-maven-plugin</artifactId></plugin>
            <plugin><groupId>com.coderplus.maven.plugins</groupId><artifactId>copy-rename-maven-plugin</artifactId></plugin>
            <plugin><groupId>org.apache.maven.plugins</groupId><artifactId>maven-javadoc-plugin</artifactId></plugin>
        </plugins>
    </build>
    <dependencies>
        <!-- The thing being shaded. optional=true keeps it out of consumers' graphs. -->
        <dependency>
            <groupId><UPSTREAM_GROUP></groupId>
            <artifactId><UPSTREAM_ARTIFACT></artifactId>
            <optional>true</optional>
            <exclusions>
                <!-- Exclude any transitive that is re-added below as its own proper module -->
                <exclusion><groupId><DEP_GROUP></groupId><artifactId><DEP_ARTIFACT></artifactId></exclusion>
            </exclusions>
        </dependency>
        <!-- External proper-module deps that the module-info will 'requires' -->
        <dependency><groupId><DEP_GROUP></groupId><artifactId><DEP_ARTIFACT></artifactId></dependency>
    </dependencies>
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>com.guicedee</groupId>
                <artifactId>standalone-bom</artifactId>
                <version>${guicedee.version}</version>
                <scope>import</scope>
                <type>pom</type>
            </dependency>
            <!-- Add guicedee-bom import ONLY if depending on another com.guicedee.modules.services shade -->
            <dependency>
                <groupId>com.guicedee</groupId>
                <artifactId>guicedee-bom</artifactId>
                <version>${guicedee.version}</version>
                <scope>import</scope>
                <type>pom</type>
            </dependency>
        </dependencies>
    </dependencyManagement>
</project>
```

Notes:
- Plugin config (versions, shade transformers/relocations, moditect `add-module-info` reading
  `src/moditect/module-info.java`) is inherited from `com.guicedee:parent` `pluginManagement`.
- Each plugin element just *activates* the inherited config.

---

## moditect `src/moditect/module-info.java`

```java
module <MODULE_NAME> {
    requires transitive <DEP_MODULE>;     // dep whose types appear in exported API
    requires <OTHER_DEP_MODULE>;          // runtime dep not in API
    requires static <ANNOTATION_MODULE>;  // compile-only annotations (jspecify, etc.)

    exports <pkg.a>;
    exports <pkg.b>;
    // ... every public, NON-relocated package

    // provides <spi.Interface> with <impl.Class>;  // if the JAR ships META-INF/services
}
```

---

## Versioner property snippet

`GuicedEE/bom/Versioner/pom.xml` `<properties>`:

```xml
<upstream.version>X.Y.Z</upstream.version>
```

---

## StandaloneBOM dependencyManagement (UPSTREAM artifacts)

`GuicedEE/bom/StandaloneBOM/pom.xml`:

```xml
<dependency>
    <groupId><UPSTREAM_GROUP></groupId>
    <artifactId><UPSTREAM_ARTIFACT></artifactId>
    <version>${upstream.version}</version>
</dependency>
<!-- plus any external module deps the shade re-requires, e.g. reactive-streams -->
```

---

## guicedee-bom dependencyManagement (SHADED service)

`GuicedEE/bom/pom.xml`:

```xml
<dependency>
    <groupId>com.guicedee.modules.services</groupId>
    <artifactId><ARTIFACT_ID></artifactId>
    <version>${guicedee.version}</version>
</dependency>
```

---

## Root dev-suite `pom.xml` registration

`DevSuite/pom.xml` → profile `id=services` → `<modules>`:

```xml
<module>GuicedEE/services/Libraries/<ARTIFACT_ID></module>
```

---

## Consumer module rewire

In the GuicedEE module's `pom.xml`:

```xml
<dependency>
    <groupId>io.vertx</groupId>
    <artifactId>vertx-web-graphql</artifactId>   <!-- whatever pulled the automatic module -->
    <version>${vertx.version}</version>
    <exclusions>
        <exclusion><groupId><UPSTREAM_GROUP></groupId><artifactId><UPSTREAM_ARTIFACT></artifactId></exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>com.guicedee.modules.services</groupId>
    <artifactId><ARTIFACT_ID></artifactId>
</dependency>
```

The consumer `module-info.java` keeps `requires <MODULE_NAME>;` unchanged.

