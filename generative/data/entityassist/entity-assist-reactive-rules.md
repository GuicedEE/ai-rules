# EntityAssistReactive Package Structure Guidelines

This document outlines the recommended package structure and usage guidelines for the EntityAssistReactive module, designed to provide a reactive ORM framework for GuicedEE applications using Vert.x and Hibernate Reactive.

## Table of Contents

1. [Overview](#overview)
2. [Package Structure](#package-structure)
3. [Core Components](#core-components)
   - [RootEntity](#rootentity)
   - [BaseEntity](#baseentity)
   - [QueryBuilderRoot](#querybuilderroot)
   - [QueryBuilder](#querybuilder)
4. [Module Configuration](#module-configuration)
   - [module-info.java](#module-infojava)
   - [Transitive Dependencies](#transitive-dependencies)
   - [Required Module Reads and Opens](#required-module-reads-and-opens)
5. [Database Configuration](#database-configuration)
   - [Database Module Creation](#database-module-creation)
   - [Persistence Unit Configuration](#persistence-unit-configuration)
   - [Entity Manager Configuration](#entity-manager-configuration)
6. [Entity Creation](#entity-creation)
   - [Creating Entity Classes](#creating-entity-classes)
   - [Creating Query Builders](#creating-query-builders)
   - [Entity Relationships](#entity-relationships)
7. [Reactive Operations](#reactive-operations)
   - [Session Management](#session-management)
   - [Transaction Management](#transaction-management)
   - [CRUD Operations](#crud-operations)
   - [Query Building](#query-building)
8. [Integration with GuicedInjection](#integration-with-guicedinjection)
   - [Dependency Injection](#dependency-injection)
   - [Lifecycle Management](#lifecycle-management)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

## Overview

EntityAssistReactive is a module that provides a reactive ORM framework for GuicedEE applications using Vert.x and Hibernate Reactive. It extends the capabilities of GuicedVertxPersistence by providing a structured approach to entity management and query building in a reactive context.

The module is designed to work with the Mutiny API provided by Hibernate Reactive, enabling non-blocking database operations. It integrates with the GuicedInjection framework to provide dependency injection and lifecycle management for persistence components.

## Package Structure

The EntityAssistReactive module follows a modular package structure that separates concerns and promotes maintainability. Here's the recommended package structure:

```
com.entityassist
├── converters           # Attribute converters for various data types
│   ├── LocalDateAttributeConverter.java
│   ├── LocalDateTimeAttributeConverter.java
│   └── LocalDateTimestampAttributeConverter.java
├── enumerations         # Enumerations used by the module
├── exceptions           # Custom exceptions
├── querybuilder         # Query building components
│   ├── builders         # Concrete query builder implementations
│   │   └── QueryBuilderRoot.java  # Base class for query builders
│   └── QueryBuilder.java  # Main query builder class
├── services             # Service interfaces and implementations
│   ├── entities         # Entity-related services
│   │   └── IRootEntity.java  # Interface for root entities
│   └── querybuilders    # Query builder services
│       └── IQueryBuilderRoot.java  # Interface for query builders
├── BaseEntity.java      # Base class for entities with additional functionality
└── RootEntity.java      # Root class for all entities
```

## Core Components

### RootEntity

The `RootEntity` class is the foundation of the EntityAssistReactive framework. It's an abstract class that implements the `IRootEntity` interface and provides the core functionality for all entity classes.

Key features:
- Generic type parameters for type-safe entity operations
- Integration with query builders
- Entity validation
- Property management
- Reactive operations using Uni<> return types

Example:
```java
public abstract class RootEntity<J extends RootEntity<J, Q, I>, Q extends QueryBuilderRoot<Q, J, I>, I extends Serializable>
        implements IRootEntity<J, Q, I>
{
    // Implementation details
}
```

### BaseEntity

The `BaseEntity` class extends `RootEntity` and provides additional functionality for entity classes. It's the recommended base class for all entity classes in your application.

### QueryBuilderRoot

The `QueryBuilderRoot` class is the foundation for query building in EntityAssistReactive. It implements the `IQueryBuilderRoot` interface and provides the core functionality for building and executing queries.

Key features:
- Generic type parameters for type-safe query building
- Integration with JPA Criteria API
- Support for pagination
- Entity validation
- Reactive operations using Uni<> return types

Example:
```java
public abstract class QueryBuilderRoot<J extends QueryBuilderRoot<J, E, I>,
        E extends RootEntity<E, J, I>,
        I extends Serializable>
        implements IQueryBuilderRoot<J, E, I>
{
    // Implementation details
}
```

### QueryBuilder

The `QueryBuilder` class extends `QueryBuilderRoot` and provides additional functionality for query building. It's the recommended base class for all query builder classes in your application.

## Module Configuration

### module-info.java

The `module-info.java` file for a module that uses EntityAssistReactive should follow these guidelines:

1. Require the EntityAssistReactive module
2. Use the interfaces provided by EntityAssistReactive
3. Open your entity packages to Hibernate ORM and other required modules

Example:
```java
module com.example.persistence {
    requires transitive com.entityassist;

    opens com.example.entities to org.hibernate.orm.core, com.fasterxml.jackson.databind, com.google.guice, org.hibernate.validator;
}
```

### Transitive Dependencies

EntityAssistReactive includes several transitive dependencies that are automatically available to modules that depend on it. This means you don't need to explicitly declare these dependencies in your module-info.java file.

The following modules are transitive dependencies of EntityAssistReactive:

```java
// Transitive dependencies in EntityAssistReactive
requires transitive com.guicedee.vertxpersistence;
requires transitive jakarta.persistence;
requires transitive io.vertx.sql.client.pg;
requires transitive org.hibernate.reactive;
requires transitive org.hibernate.orm.core;
```

### Required Module Reads and Opens

When using EntityAssistReactive, you need to ensure that certain modules can read and access each other. In particular, you need to add the following to your Maven configuration to avoid `IllegalAccessException` errors:

```xml
<!-- Add these to your compiler and surefire plugin configuration -->
<compilerArgs>
    <arg>--add-reads</arg>
    <arg>org.jboss.logging=org.hibernate.reactive</arg>
    <arg>--add-reads</arg>
    <arg>org.hibernate.orm.core=your.module.name</arg>
</compilerArgs>

<!-- For surefire plugin -->
<argLine>
    --add-reads org.jboss.logging=org.hibernate.reactive
    --add-reads org.hibernate.orm.core=your.module.name
</argLine>
```

These arguments are necessary for the following reasons:

1. The module `org.jboss.logging` needs to read the module `org.hibernate.reactive` to avoid the following error:
   ```
   java.lang.IllegalAccessException: module org.jboss.logging does not read module org.hibernate.reactive
   ```

2. The module `org.hibernate.orm.core` needs to read the specific module that contains your entity classes to avoid access errors when Hibernate tries to access your entities:
   ```
   java.lang.IllegalAccessException: module org.hibernate.orm.core does not read [your application module]
   ```

   Important: Replace `your.module.name` with the actual module name of the JAR file containing your entity classes. This is the name defined in your module-info.java file, not `ALL-UNNAMED`. Using the specific module name ensures proper module access between Hibernate ORM and your entity classes.

## Database Configuration

### Database Module Creation

To use EntityAssistReactive, you need to create a database module by extending the `DatabaseModule` class from the `com.guicedee.vertxpersistence` package. This class is responsible for configuring a persistence unit for use with Guice.

Example:
```java
import com.guicedee.vertxpersistence.DatabaseModule;
import com.guicedee.vertxpersistence.ConnectionBaseInfo;
import com.guicedee.vertxpersistence.implementations.postgres.PostgresConnectionBaseInfo;
import org.hibernate.jpa.boot.spi.PersistenceUnitDescriptor;

import java.util.Properties;
public class MyDatabaseModule extends DatabaseModule<MyDatabaseModule>
{
    @Override
    protected String getPersistenceUnitName()
    {
        return "myPersistenceUnit";
    }

    @Override
    protected ConnectionBaseInfo getConnectionBaseInfo(PersistenceUnitDescriptor unit, Properties filteredProperties)
    {
        PostgresConnectionBaseInfo connectionInfo = new PostgresConnectionBaseInfo();
        connectionInfo.setServerName("localhost");
        connectionInfo.setPort("5432");
        connectionInfo.setDatabaseName("mydb");
        connectionInfo.setUsername("user");
        connectionInfo.setPassword("password");
        connectionInfo.setDefaultConnection(true);
        connectionInfo.setReactive(true); // Enable reactive mode
        return connectionInfo;
    }

    @Override
    protected String getJndiMapping()
    {
        return "jdbc/mydb";
    }
}
```

### Persistence Unit Configuration

The persistence unit for EntityAssistReactive must be configured in the `persistence.xml` file. The persistence unit must use the `org.hibernate.reactive.provider.ReactivePersistenceProvider` provider and have the `hibernate.reactive` property set to `true`.

Example:
```xml
<persistence xmlns="https://jakarta.ee/xml/ns/persistence"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="https://jakarta.ee/xml/ns/persistence https://jakarta.ee/xml/ns/persistence/persistence_3_0.xsd"
             version="3.0">

    <persistence-unit name="myPersistenceUnit">
        <provider>org.hibernate.reactive.provider.ReactivePersistenceProvider</provider>
        <class>com.entityassist.converters.LocalDateAttributeConverter</class>
        <class>com.entityassist.converters.LocalDateTimeAttributeConverter</class>
        <class>com.entityassist.converters.LocalDateTimestampAttributeConverter</class>

        <class>com.example.entities.MyEntity</class>
        <exclude-unlisted-classes>true</exclude-unlisted-classes>
        <properties>
            <!-- Database-specific configuration -->
            <property name="hibernate.dialect" value="org.hibernate.dialect.PostgreSQLDialect"/>

            <!-- Reactive specific properties -->
            <property name="hibernate.reactive" value="true"/>

            <property name="hibernate.flushMode" value="FLUSH_AUTO"/>
            <property name="hibernate.hbm2ddl.auto" value="update"/>

            <property name="hibernate.show_sql" value="true"/>
            <property name="hibernate.format_sql" value="true"/>
            <property name="hibernate.use_sql_comments" value="true"/>
        </properties>
    </persistence-unit>
</persistence>
```


## Entity Creation

### Creating Entity Classes

To create an entity class in EntityAssistReactive, extend the `BaseEntity` class and implement the required methods. Use JPA annotations to define the entity's mapping to the database.

Example:
```java
import com.entityassist.BaseEntity;
import com.entityassist.querybuilder.QueryBuilder;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.Accessors;
import org.hibernate.reactive.mutiny.Mutiny;

@Entity
@Accessors(chain = true)
@Table(name = "my_entity")
public class MyEntity extends BaseEntity<MyEntity, MyEntity.MyEntityQueryBuilder, String>
{
    @Id
    @Column(name = "id", nullable = false)
    @Getter
    @Setter
    private String id;

    @Column(name = "name")
    @Getter
    @Setter
    private String name;

    @Override
    public String getId() {
        return id;
    }

    @Override
    public MyEntity setId(String id) {
        this.id = id;
        return this;
    }

    public static class MyEntityQueryBuilder extends QueryBuilder<MyEntityQueryBuilder, MyEntity, String>
    {
        public MyEntityQueryBuilder() {
            super();
        }

        	@Override
	public Mutiny.Session getEntityManager()
	{
        return IGuiceContext.get(Mutiny.SessionFactory.class)
                       .getCurrentSession();
	}
        @Override
        public boolean isIdGenerated() {
            return false;
        }
    }
}
```

### Creating Query Builders

Each entity class must have an associated query builder class. The query builder class should extend the `QueryBuilder` class and implement the required methods.

Example:
```java
public static class MyEntityQueryBuilder extends QueryBuilder<MyEntityQueryBuilder, MyEntity, String>
{
    public MyEntityQueryBuilder() {
        super();
    }

    	@Override
	public Mutiny.Session getEntityManager()
	{
        return IGuiceContext.get(Mutiny.SessionFactory.class)
                       .getCurrentSession();
	}

    @Override
    public boolean isIdGenerated() {
        return false;
    }
}
```

### Entity Relationships

EntityAssistReactive supports all standard JPA relationship types: @OneToOne, @OneToMany, @ManyToOne, and @ManyToMany. Use these annotations to define relationships between entities.

Example:
```java
@Entity
@Accessors(chain = true)
@Table(name = "child_entity")
public class ChildEntity extends BaseEntity<ChildEntity, ChildEntity.ChildEntityQueryBuilder, String>
{
    @Id
    @Column(name = "id", nullable = false)
    @Getter
    @Setter
    private String id;

    @ManyToOne
    @JoinColumn(name = "parent_id")
    @Getter
    @Setter
    private ParentEntity parent;

    // Other fields and methods
}
```

## Reactive Operations

### Session Management

EntityAssistReactive uses Hibernate Reactive's Mutiny API for reactive database operations. The `Mutiny.Session` is the reactive equivalent of JPA's `EntityManager`.

To get a session, use the `getEntityManager()` method in your query builder:
```java
	@Override
	public Mutiny.Session getEntityManager()
	{
        return IGuiceContext.get(Mutiny.SessionFactory.class)
                       .getCurrentSession();
	}
```

### Transaction Management

Transactions in EntityAssistReactive are managed using Hibernate Reactive's Mutiny API. Use the `withTransaction()` method to execute operations within a transaction.

Example:
```java
sessionFactory.withSession(session -> {
    return session.withTransaction(tx -> {
        return entity.builder()
                     .persist(entity);
    });
});
```

### CRUD Operations

EntityAssistReactive provides methods for common CRUD operations:

**Create**:
```java
Uni<MyEntity> persistedEntity = entity.builder().persist(entity);
```

**Read**:
```java
Uni<MyEntity> foundEntity = new MyEntity().builder().find("entityId").get();
```

**Update**:
```java
Uni<MyEntity> updatedEntity = entity.builder().update(entity);
```

**Delete**:
```java
// Using the query builder to delete an entity
Uni<Integer> deletedCount = new MyEntity().builder().delete().where("id", "entityId").executeUpdate();
```

### Query Building

EntityAssistReactive provides a fluent API for building queries using the JPA Criteria API.

Example:
```java
// Find all entities with a specific name
List<MyEntity> entities = new MyEntity().builder()
                                       .where("name", "John")
                                       .getResultList()
                                       .await().indefinitely();

// Find entities with pagination
List<MyEntity> entities = new MyEntity().builder()
                                       .setFirstResults(10)
                                       .setMaxResults(10)
                                       .getResultList()
                                       .await().indefinitely();

// Complex queries
List<MyEntity> entities = new MyEntity().builder()
                                       .where("name", "John")
                                       .and()
                                       .where("age", ">", 30)
                                       .orderBy("name", true)
                                       .getResultList()
                                       .await().indefinitely();
```

## Integration with GuicedInjection

### Dependency Injection

EntityAssistReactive integrates with GuicedInjection for dependency injection. You can inject the `Mutiny.SessionFactory` or other components into your classes.

Example:
```java
public class MyService
{
    @Inject
    @Named("myPersistenceUnit")
    private Mutiny.SessionFactory sessionFactory;

    public Uni<MyEntity> findEntity(String id)
    {
        return sessionFactory.withSession(session ->
            session.find(MyEntity.class, id)
        );
    }
}
```

### Lifecycle Management

EntityAssistReactive integrates with GuicedInjection's lifecycle management. The persistence units are initialized during the module configuration phase and closed during the pre-destroy phase.

## Best Practices

1. **Use BaseEntity for All Entities**: Always extend `BaseEntity` for your entity classes to ensure consistent behavior.

2. **Implement Query Builders**: Create a nested query builder class for each entity class to provide type-safe query building.

3. **Use Reactive Patterns**: Follow reactive programming patterns when working with EntityAssistReactive:
   - Use `Uni<>` and `Multi<>` for asynchronous operations
   - Chain operations using `.chain()` and `.invoke()`
   - Use `.await().indefinitely()` only at the boundary of your application

4. **Manage Sessions Properly**: Always use the `withSession()` pattern to ensure sessions are properly closed:
   ```java
   sessionFactory.withSession(session -> {
       // Your code here
   });
   ```

5. **Use Transactions**: Always use transactions for operations that modify the database:
   ```java
   session.withTransaction(tx -> {
       // Your code here
   });
   ```

6. **Configure Logging**: Configure logging to help diagnose issues with database connections and queries.

7. **Use Named Injection**: Use `@Named` injection to specify which entity manager to use when you have multiple persistence units.

8. **Test with Testcontainers**: Use Testcontainers to test your database modules with real databases in a controlled environment.

## Troubleshooting

### Common Issues

1. **Connection Refused**: Check that the database server is running and accessible from your application.

2. **Authentication Failed**: Verify that the username and password are correct.

3. **Missing Driver**: Ensure that the appropriate database driver is included in your dependencies.

4. **Entity Not Found**: Check that your entity classes are properly annotated and included in the persistence unit.

5. **Transaction Issues**: Ensure that transactions are properly begun and ended, and that you're not trying to perform operations outside a transaction when required.

### Debugging Tips

1. Enable debug logging to see more detailed information:
```java
System.setProperty("hibernate.show_sql", "true");
System.setProperty("hibernate.format_sql", "true");
System.setProperty("hibernate.use_sql_comments", "true");
```

2. Use the `getConnectionBaseInfo` method to inspect the connection properties:
```java
ConnectionBaseInfo connectionInfo = VertxPersistenceModule.getConnectionInfoByEntityManager("myPersistenceUnit");
System.out.println("Connection URL: " + connectionInfo.getJdbcUrl());
```

3. Check the entity manager properties:
```java
Properties properties = getEntityManagerProperties(entityManager);
properties.forEach((key, value) -> System.out.println(key + " = " + value));
```

4. Verify that the persistence unit is properly configured in persistence.xml:
```xml
<persistence-unit name="myPersistenceUnit" transaction-type="JTA">
    <provider>org.hibernate.reactive.provider.ReactivePersistenceProvider</provider>
    <class>com.example.MyEntity</class>
    <properties>
        <!-- Database properties -->
    </properties>
</persistence-unit>
```

5. Use Testcontainers for testing to ensure a clean database environment:
```java
@Container
private static final PostgreSQLContainer<?> postgresContainer = new PostgreSQLContainer<>("postgres:latest")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test");
```
