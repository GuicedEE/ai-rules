# Junie Rules for GuicedEE Services

## Introduction
This rules file provides guidance for consuming and applying the JPMS modular libraries produced by the GuicedEE Services project. It defines how Junie should use these artifacts instead of their original counterparts.

## Project Purpose
GuicedEE Services creates Java Platform Module System (JPMS) compatible versions of popular libraries by:
1. Shading the original libraries using Maven Shade Plugin
2. Adding proper module-info.java descriptors
3. Ensuring compatibility with the module system
4. Providing consistent groupId naming conventions

## Artifact Mapping Rules

### Library Transformations
The project transforms original libraries into JPMS-compatible versions with the following pattern:

| Original Coordinates | GuicedEE Coordinates | Module Name | Notes |
|----------------------|----------------------|-------------| ------ |
| ~~com.fazecast:jSerialComm~~ | ~~com.guicedee.services:jserialcomm~~ | ~~io.jserialcomm~~ | Removed as of 2.11.2 - now properly modularized |
| org.javassist:javassist | com.guicedee.services:javassist | javassist |
| io.cloudevents:cloudevents-core | com.guicedee.services:cloudevents | io.cloudevents |
| org.testcontainers:testcontainers | com.guicedee.services:testcontainers | org.testcontainers |
| org.hibernate:hibernate-core | com.guicedee.services:hibernate-core | org.hibernate.core |

### Usage Examples

#### Maven Dependency Example
For most libraries, use the GuicedEE modular version instead of the original:

Original library (not recommended for most libraries):
```xml
<dependency>
    <groupId>org.some.library</groupId>
    <artifactId>library-name</artifactId>
    <version>x.y.z</version>
</dependency>
```

GuicedEE modular version (recommended for most libraries):
```xml
<dependency>
    <groupId>com.guicedee.services</groupId>
    <artifactId>library-name</artifactId>
    <version>2.0.0-SNAPSHOT</version>
</dependency>
```

**Note for jSerialComm**: As of version 2.11.2, jSerialComm is properly modularized, so use the original library directly:
```xml
<dependency>
    <groupId>com.fazecast</groupId>
    <artifactId>jSerialComm</artifactId>
    <version>2.11.2</version>
</dependency>
```

#### Module Requires Example
For most libraries, use the GuicedEE module name:

```java
// For most libraries, use the GuicedEE module name
module your.module {
    requires org.some.library.module;
}
```

**Note for jSerialComm**: As of version 2.11.2, jSerialComm is properly modularized, so use its module directly:

```java
// For jSerialComm 2.11.2+, use the original module
module your.module {
    requires com.fazecast.jSerialComm;
}
```

## Library Categories

### Service Libraries (com.guicedee.services)
These are shaded versions of third-party libraries with added module-info.java descriptors:

#### Apache
- **CXF**: apache-cxf, apache-cxf-rest, apache-cxf-rt-security, apache-cxf-rt-transports-http, apache-cxf-rest-openapi

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| org.apache.cxf:cxf-core | com.guicedee.services:apache-cxf | org.apache.cxf |
| org.apache.cxf:cxf-rt-rs-client | com.guicedee.services:apache-cxf-rest | org.apache.cxf.rest |
| org.apache.cxf:cxf-rt-security | com.guicedee.services:apache-cxf-rt-security | org.apache.cxf.rt.security |
| org.apache.cxf:cxf-rt-transports-http | com.guicedee.services:apache-cxf-rt-transports-http | org.apache.cxf.rt.transports.http |
| org.apache.cxf:cxf-rt-rs-service-description-openapi-v3 | com.guicedee.services:apache-cxf-rest-openapi | org.apache.cxf.rest.openapi |

- **Commons**: commons-beanutils, commons-collections, commons-csv, commons-fileupload, commons-math

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| commons-beanutils:commons-beanutils | com.guicedee.services:commons-beanutils | org.apache.commons.beanutils |
| org.apache.commons:commons-collections4 | com.guicedee.services:commons-collections | org.apache.commons.collections |
| org.apache.commons:commons-csv | com.guicedee.services:commons-csv | org.apache.commons.csv |
| commons-fileupload:commons-fileupload | com.guicedee.services:commons-fileupload | org.apache.commons.fileupload |
| org.apache.commons:commons-math3 | com.guicedee.services:commons-math | org.apache.commons.math |

- **POI**: apache-poi, apache-poi-ooxml

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| org.apache.poi:poi | com.guicedee.services:apache-poi | org.apache.poi |
| org.apache.poi:poi-ooxml | com.guicedee.services:apache-poi-ooxml | org.apache.poi.ooxml |

#### Database
- **Database Drivers**: postgresql, mssql-jdbc, msal4j

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| org.postgresql:postgresql | com.guicedee.services:postgresql | org.postgresql |
| com.microsoft.sqlserver:mssql-jdbc | com.guicedee.services:mssql-jdbc | com.microsoft.sqlserver.jdbc |
| com.microsoft.azure:msal4j | com.guicedee.services:msal4j | com.microsoft.azure.msal4j |

Policy (PostgreSQL + JPMS):
- Do not shade the PostgreSQL driver in host projects. Always consume the GuicedEE Services JPMS artifact.
- Maven:
```xml
<dependency>
  <groupId>com.guicedee.services</groupId>
  <artifactId>postgresql</artifactId>
  <version>${guicedee.services.version}</version>
</dependency>
```
- module-info.java:
```java
module your.module {
  requires org.postgresql;
}
```

#### Google
- **Core**: aop, guava, guice-assistedinject, guice-core, guice-grapher, guice-jmx, guice-jndi, guice-persist, guice-servlet

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| com.google.inject.extensions:guice-assistedinject | com.guicedee.services:guice-assistedinject | com.google.inject.assistedinject |
| com.google.inject:guice | com.guicedee.services:guice-core | com.google.inject |
| com.google.inject.extensions:guice-grapher | com.guicedee.services:guice-grapher | com.google.inject.grapher |
| com.google.inject.extensions:guice-jmx | com.guicedee.services:guice-jmx | com.google.inject.jmx |
| com.google.inject.extensions:guice-jndi | com.guicedee.services:guice-jndi | com.google.inject.jndi |
| com.google.inject.extensions:guice-persist | com.guicedee.services:guice-persist | com.google.inject.persist |
| com.google.inject.extensions:guice-servlet | com.guicedee.services:guice-servlet | com.google.inject.servlet |
| com.google.guava:guava | com.guicedee.services:guava | com.google.common |
| org.aopalliance:aopalliance | com.guicedee.services:aop | org.aopalliance |

#### Hibernate
- **ORM**: hibernate-core, hibernate-c3p0, hibernate-jcache, hibernate-reactive, hibernate-validator

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| org.hibernate:hibernate-core | com.guicedee.services:hibernate-core | org.hibernate.core |
| org.hibernate:hibernate-c3p0 | com.guicedee.services:hibernate-c3p0 | org.hibernate.c3p0 |
| org.hibernate:hibernate-jcache | com.guicedee.services:hibernate-jcache | org.hibernate.jcache |
| org.hibernate.reactive:hibernate-reactive-core | com.guicedee.services:hibernate-reactive | org.hibernate.reactive |
| org.hibernate.validator:hibernate-validator | com.guicedee.services:hibernate-validator | org.hibernate.validator |

#### JBoss
- **Logging**: jboss-logmanager

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| org.jboss.logmanager:jboss-logmanager | com.guicedee.services:jboss-logmanager | org.jboss.logmanager |

#### JCache
- **Caching**: cache-annotations-ri-common, cache-annotations-ri-guice, cache-api, hazelcast, hazelcast-hibernate

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| org.jsr107.ri:cache-annotations-ri-common | com.guicedee.services:cache-annotations-ri-common | org.jsr107.ri.annotations.common |
| org.jsr107.ri:cache-annotations-ri-guice | com.guicedee.services:cache-annotations-ri-guice | org.jsr107.ri.annotations.guice |
| javax.cache:cache-api | com.guicedee.services:cache-api | javax.cache |
| com.hazelcast:hazelcast | com.guicedee.services:hazelcast | com.hazelcast |
| com.hazelcast:hazelcast-hibernate53 | com.guicedee.services:hazelcast-hibernate | com.hazelcast.hibernate |

#### JNI
- **Native Interface**: jna-platform, nrjavaserial

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| net.java.dev.jna:jna-platform | com.guicedee.services:jna-platform | com.sun.jna.platform |
| com.neuronrobotics:nrjavaserial | com.guicedee.services:nrjavaserial | com.neuronrobotics.nrjavaserial |

#### Jakarta
- **Security**: jakarta-security-jacc

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| jakarta.security.jacc:jakarta.security.jacc-api | com.guicedee.services:jakarta-security-jacc | jakarta.security.jacc |

#### Libraries
- **Transaction Management**: BitronixTransactionManager
  > **Note**: BTM/Bitronix must only be used in non-reactive environments.

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| org.codehaus.btm:btm | com.guicedee.services:btm | org.codehaus.btm |

- **Utility Libraries**: bcrypt, jandex, javassist, json, kafka-client, mapstruct, scram, uadetector-core, uadetector-resources

| Original Coordinates | GuicedEE Coordinates | Module Name | Notes |
|----------------------|----------------------|-------------| ------ |
| at.favre.lib:bcrypt | com.guicedee.services:bcrypt | at.favre.lib.bcrypt | |
| ~~com.fazecast:jSerialComm~~ | ~~com.guicedee.services:jserialcomm~~ | ~~io.jserialcomm~~ | Removed as of 2.11.2 - now properly modularized as `com.fazecast.jSerialComm` |
| org.jboss:jandex | com.guicedee.services:jandex | org.jboss.jandex |
| org.javassist:javassist | com.guicedee.services:javassist | javassist |
| org.json:json | com.guicedee.services:json | org.json |
| org.mapstruct:mapstruct | com.guicedee.services:mapstruct | org.mapstruct |
| com.ongres.scram:client | com.guicedee.services:scram | com.ongres.scram.client |
| net.sf.uadetector:uadetector-core | com.guicedee.services:uadetector-core | net.sf.uadetector.core |
| net.sf.uadetector:uadetector-resources | com.guicedee.services:uadetector-resources | net.sf.uadetector.resources |

- **Integration Libraries**: cloudevents, ibm-mq, rabbitmq-client

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| io.cloudevents:cloudevents-core | com.guicedee.services:cloudevents | io.cloudevents |
| com.ibm.mq:com.ibm.mq.allclient | com.guicedee.services:ibm-mq | com.ibm.mq |
| com.rabbitmq:amqp-client | com.guicedee.services:rabbitmq-client | com.rabbitmq.client |
| org.apache.kafka:kafka-client | com.guicedee.services:kafka-client | org.apache.kafka.clients |

- **Testing Libraries**: testcontainers

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| org.testcontainers:testcontainers | com.guicedee.services:testcontainers | org.testcontainers |

- **Document Processing**: openpdf, swagger

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| com.github.librepdf:openpdf | com.guicedee.services:openpdf | com.lowagie.text |
| io.swagger:swagger-core | com.guicedee.services:swagger | io.swagger |

#### MicroProfile
- **Configuration**: config-core, metrics-core

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| org.eclipse.microprofile.config:microprofile-config-api | com.guicedee.services:config-core | org.eclipse.microprofile.config |
| org.eclipse.microprofile.metrics:microprofile-metrics-api | com.guicedee.services:metrics-core | org.eclipse.microprofile.metrics |

#### Representations
- **Data Formats**: ExcelRepresentation, JsonRepresentation, XmlRepresentation

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| com.guicedee.services:excel-representation | com.guicedee.services:ExcelRepresentation | com.guicedee.services.excelrepresentation |
| com.guicedee.services:json-representation | com.guicedee.services:JsonRepresentation | com.guicedee.services.jsonrepresentation |
| com.guicedee.services:xml-representation | com.guicedee.services:XmlRepresentation | com.guicedee.services.xmlrepresentation |

#### Vert.x
- **Reactive**: vertx-mutiny, vertx-pg-client, vertx-rabbitmq

| Original Coordinates | GuicedEE Coordinates | Module Name |
|----------------------|----------------------|-------------|
| io.smallrye.reactive:smallrye-mutiny-vertx-core | com.guicedee.services:vertx-mutiny | io.smallrye.mutiny.vertx.core |
| io.vertx:vertx-pg-client | com.guicedee.services:vertx-pg-client | io.vertx.pgclient |
| io.vertx:vertx-rabbitmq-client | com.guicedee.services:vertx-rabbitmq | io.vertx.rabbitmq |


## Module Information
The project provides proper JPMS modules through:

- **Standard Libraries**: `src/moditect/module-info.java`
  ```java
  module io.cloudevents {
      exports io.cloudevents;
      exports io.cloudevents.core.builder;
      // Additional exports...

      uses io.cloudevents.core.format.EventFormat;
      provides io.cloudevents.core.format.EventFormat with io.cloudevents.jackson.JsonFormat;
  }
  ```

- **Core Components**: `src/main/java/module-info.java`

## Exclusions
- **Excluded Components**: `com.guicedee:guice-inject-client` should not be used with Junie.
  - Note: guice-inject-client provides the interfaces and SPIs for GuicedEE to develop libraries that are loosely coupled.
  - It contains core interfaces like IGuiceModule, IGuiceProvider, IGuicePreStartup, IGuicePostStartup, etc.
  - These interfaces enable the plugin architecture and dependency injection framework of GuicedEE.

## Implementation Notes
1. All libraries maintain the same package structure as their original counterparts
2. The shaded artifacts include all transitive dependencies
3. Version alignment is managed through the guicedee-bom
4. Module names typically match the main package of the original library

## Troubleshooting
When using these modular libraries, you might encounter the following issues:

1. **Module not found**: Ensure you're using the correct module name in your `requires` statement
2. **Package not accessible**: Check that the package is properly exported in the module-info.java
3. **Version conflicts**: Use the guicedee-bom to manage version alignment
