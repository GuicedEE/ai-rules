---
name: guicedee-persistence
description: "Reactive JPA persistence with Hibernate Reactive 7, Vert.x 5 SQL clients, and Mutiny sessions inside GuicedEE: DatabaseModule setup, persistence.xml configuration, multi-database support, @EntityManager scoping, and environment variable resolution. Use when adding database persistence, configuring Hibernate Reactive, creating DatabaseModule subclasses, wiring Mutiny.SessionFactory, or managing multiple persistence units."
metadata:
  short-description: Reactive JPA persistence with Hibernate Reactive inside GuicedEE
---

# GuicedEE Persistence

Reactive JPA persistence using Hibernate Reactive 7 and Vert.x 5 SQL clients, fully managed by the GuicedEE lifecycle.

## Core Concept

Extend `DatabaseModule`, point it at a `persistence.xml` unit, and the module wires a `Mutiny.SessionFactory` into Guice — fully reactive, annotation-driven, with built-in support for PostgreSQL, MySQL, SQL Server, Oracle, and DB2.

## Required Flow

1. Add `com.guicedee:persistence` dependency.
2. Create a `persistence.xml` with `ReactivePersistenceProvider`:
   ```xml
   <persistence xmlns="https://jakarta.ee/xml/ns/persistence" version="3.0">
     <persistence-unit name="mydb">
       <provider>org.hibernate.reactive.provider.ReactivePersistenceProvider</provider>
       <class>com.example.entities.User</class>
       <properties>
         <property name="jakarta.persistence.jdbc.url"
                   value="${DB_URL:jdbc:postgresql://localhost:5432/mydb}"/>
         <property name="jakarta.persistence.jdbc.user" value="${DB_USER:postgres}"/>
         <property name="jakarta.persistence.jdbc.password" value="${DB_PASSWORD:secret}"/>
         <property name="hibernate.hbm2ddl.auto" value="update"/>
       </properties>
     </persistence-unit>
   </persistence>
   ```
3. Create a `DatabaseModule` subclass:
   ```java
   public class MyDatabaseModule extends DatabaseModule<MyDatabaseModule> {
       @Override
       protected String getPersistenceUnitName() { return "mydb"; }

       @Override
       protected ConnectionBaseInfo getConnectionBaseInfo(
               PersistenceUnitDescriptor unit, Properties properties) {
           return ConnectionBaseInfoFactory.createConnectionBaseInfo("postgresql");
       }
   }
   ```
4. Register via JPMS:
   ```java
   module my.app {
       requires com.guicedee.persistence;
       provides com.guicedee.client.services.lifecycle.IGuiceModule
           with my.app.MyDatabaseModule;
   }
   ```
5. Inject `Mutiny.SessionFactory` and use reactive sessions:
   ```java
   @Inject
   private Mutiny.SessionFactory sessionFactory;

   public Uni<User> createUser(String name) {
       User user = new User();
       user.setName(name);
       return sessionFactory.withTransaction(session ->
           session.persist(user).replaceWith(user));
   }
   ```

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ IGuiceModule hooks
     └─ MyDatabaseModule (extends DatabaseModule)
         ├─ Parse persistence.xml
         ├─ IPropertiesEntityManagerReader SPIs (env var resolution, DB-specific props)
         ├─ IPropertiesConnectionInfoReader SPIs
         ├─ ConnectionBaseInfo.toPooledDatasource() (Vert.x SQL pool init)
         └─ JtaPersistModule
             ├─ bind PersistService @Named("mydb")
             └─ bind Mutiny.SessionFactory @Named("mydb") + default
 └─ IGuicePostStartup hooks
     └─ DatabaseModule.postLoad()
         └─ PersistService.start() (creates EntityManagerFactory on Vert.x context)
 └─ IGuicePreDestroy hooks
     └─ DatabaseModule.onDestroy()
         └─ PersistService.stop()
```

## @EntityManager Annotation

| Attribute | Default | Purpose |
|---|---|---|
| `value` | `""` | Persistence unit name (maps to `persistence.xml`) |
| `allClasses` | `true` | Include all entity classes or only the annotated package |
| `defaultEm` | `true` | Mark as the default `SessionFactory` binding |

Apply at class level (on `DatabaseModule` subclasses) or package level (`package-info.java`) to scope entities to specific persistence units.

## Multiple Persistence Units

Bind multiple `DatabaseModule` subclasses with distinct `@Named` qualifiers. One should be marked as the default with `defaultEm = true`:

```java
@Inject @Named("orders")
private Mutiny.SessionFactory ordersFactory;

@Inject @Named("users")
private Mutiny.SessionFactory usersFactory;
```

## Supported Databases

Built-in `ConnectionBaseInfo` implementations:
- `postgresql` — PostgreSQL via Vert.x PG Client
- `mysql` — MySQL via Vert.x MySQL Client
- `sqlserver` — SQL Server via Vert.x MSSQL Client
- `oracle` — Oracle via Vert.x Oracle Client
- `db2` — DB2 via Vert.x DB2 Client

## Environment Variable Resolution

`${VAR_NAME}` placeholders in `persistence.xml` properties are resolved from system properties or environment variables. Default values supported with `${VAR_NAME:default}` syntax.

## Non-Negotiable Constraints

- Always use `ReactivePersistenceProvider` — standard JPA providers are not supported.
- `persistence.xml` must exist in `META-INF/`.
- DatabaseModule subclass must be registered as an `IGuiceModule` SPI.
- Entity packages must `opens` to `com.fasterxml.jackson.databind` and `org.hibernate.orm.core`.
- Module must `requires com.guicedee.persistence;`.
- SPI implementations must be dual-registered for tests to find services (`module-info.java` + `META-INF/services/`).


