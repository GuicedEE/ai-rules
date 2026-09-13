# entityassist: Configuration

Read this reference when working on the topics below. Commands run from the skill directory.

- [Configuration](#configuration)
- [JPMS Module](#jpms-module)
- [Installation](#installation)
- [Module Graph](#module-graph)

## Configuration

### Database Module

Create a `DatabaseModule` subclass annotated with `@EntityManager`:

```java
@EntityManager(value = "entityAssistReactive", defaultEm = true)
public class EntityAssistReactiveDBModule
        extends DatabaseModule<EntityAssistReactiveDBModule>
        implements IGuiceModule<EntityAssistReactiveDBModule> {

    @Override
    protected String getPersistenceUnitName() {
        return "entityAssistReactive";
    }

    @Override
    protected ConnectionBaseInfo getConnectionBaseInfo(
            PersistenceUnitDescriptor unit, Properties filteredProperties) {
        PostgresConnectionBaseInfo connectionInfo = new PostgresConnectionBaseInfo();
        // Always resolve config via com.guicedee.client.Environment — never System.getenv/getProperty.
        connectionInfo.setServerName(Environment.getSystemPropertyOrEnvironment("DB_HOST", "localhost"));
        connectionInfo.setPort(Environment.getSystemPropertyOrEnvironment("DB_PORT", "5432"));
        connectionInfo.setDatabaseName(Environment.getSystemPropertyOrEnvironment("DB_NAME", "mydb"));
        String username = Environment.getSystemPropertyOrEnvironment("DB_USER", null);
        String password = Environment.getSystemPropertyOrEnvironment("DB_PASSWORD", null);
        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            throw new IllegalStateException("DB_USER and DB_PASSWORD must be configured");
        }
        connectionInfo.setUsername(username);
        connectionInfo.setPassword(password);
        connectionInfo.setDefaultConnection(true);
        connectionInfo.setReactive(true);
        return connectionInfo;
    }

    @Override
    protected String getJndiMapping() {
        return "jdbc:entityAssistReactive";
    }
}
```

### JPMS Registration

```java
module my.app {
    requires com.entityassist;
    requires com.guicedee.persistence;

    opens my.app.entities to org.hibernate.orm.core, com.google.guice, com.entityassist;

    provides com.guicedee.client.services.lifecycle.IGuiceModule
        with my.app.MyDatabaseModule;
}
```

### Environment Variables

| Variable | Purpose | Default |
|---|---|---|
| `DB_HOST` | Database hostname | `localhost` |
| `DB_PORT` | Database port | `5432` |
| `DB_NAME` | Database name | — |
| `DB_USER` | Database username | — |
| `DB_PASSWORD` | Database password | — |
| `ENVIRONMENT` | Runtime environment | `dev` |

## JPMS Module

```java
module com.entityassist {
    requires transitive com.guicedee.persistence;
    requires transitive jakarta.persistence;
    requires transitive org.hibernate.reactive;
    requires transitive io.smallrye.mutiny;

    exports com.entityassist.entities;
    exports com.entityassist.querybuilder;
    exports com.entityassist.enumerations;

    opens com.entityassist.entities to org.hibernate.orm.core, com.google.guice;
}
```

### Required JVM module flags (runtime / jlink)

Hibernate ORM core reflectively reaches into EntityAssist's classes when bootstrapping
the metamodel, but `org.hibernate.orm.core` does not (and must not) statically
`requires com.entityassist`. The reverse read edge therefore has to be added at launch
time. Add this flag to the application launcher (and to any `jlink`
`--add-reads`/launcher options, surefire `argLine`, and IDE run configs):

```
--add-reads
org.hibernate.orm.core=com.entityassist
```

Without it, metamodel/attribute resolution for EntityAssist entities fails at runtime
with an `IllegalAccessError` / `does not read` module error. This edge belongs to
EntityAssist (it is required by *any* application that persists EntityAssist entities),
independent of which downstream domain (e.g. ActivityMaster) is in use.

## Installation

```xml
<dependency>
  <groupId>com.entityassist</groupId>
  <artifactId>entity-assist-reactive</artifactId>
</dependency>
```

## Module Graph

```
com.entityassist
 ├── com.guicedee.persistence
 ├── com.guicedee.client
 ├── jakarta.persistence
 ├── org.hibernate.reactive
 ├── org.hibernate.orm.core
 ├── io.smallrye.mutiny
 ├── io.vertx.sql.client.pg
 └── jakarta.xml.bind
```

