# GuicedVertxPersistence Package Structure Guidelines

This document outlines the recommended package structure and usage guidelines for the GuicedVertxPersistence module, designed to provide database connectivity and ORM capabilities for GuicedEE applications using Vert.x and Hibernate Reactive.

## Table of Contents

1. [Overview](#overview)
2. [Package Structure](#package-structure)
3. [SPI Implementation](#spi-implementation)
   - [Creating SPI Interfaces](#creating-spi-interfaces)
   - [Implementing SPI Interfaces](#implementing-spi-interfaces)
   - [Registering SPI Implementations](#registering-spi-implementations)
4. [Module Configuration](#module-configuration)
   - [module-info.java](#module-infojava)
   - [Transitive Dependencies](#transitive-dependencies)
   - [META-INF/services](#meta-infservices)
5. [Lifecycle Management](#lifecycle-management)
   - [Startup Sequence](#startup-sequence)
   - [Shutdown Sequence](#shutdown-sequence)
6. [Persistence Configuration](#persistence-configuration)
   - [Database Module Creation](#database-module-creation)
   - [Connection Configuration](#connection-configuration)
   - [Entity Manager Configuration](#entity-manager-configuration)
   - [Reactive Mode](#reactive-mode)
7. [Common Use Cases](#common-use-cases)
   - [Creating a Database Module](#creating-a-database-module)
   - [Using the Entity Manager](#using-the-entity-manager)
   - [Using Reactive Persistence](#using-reactive-persistence)
   - [Transaction Management](#transaction-management)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

## Overview

GuicedVertxPersistence is a module that provides database connectivity and ORM capabilities for GuicedEE applications using Vert.x and Hibernate Reactive. It integrates with the GuicedInjection framework to provide dependency injection and lifecycle management for persistence components.

The module automatically sets up and configures persistence units based on the persistence.xml file and provides extension points through SPI interfaces to customize the persistence behavior. It supports both traditional and reactive database access patterns.

## Package Structure

The GuicedVertxPersistence module follows a modular package structure that separates concerns and promotes maintainability. Here's the recommended package structure:

```
com.guicedee.vertxpersistence
├── annotations           # Annotations for persistence
│   └── EntityManager.java  # Annotation for entity manager configuration
├── bind                  # Binding classes for Guice
│   ├── JtaPersistModule.java  # Module for JTA persistence
│   └── PersistModule.java     # Base persistence module
├── implementations       # Implementation classes
│   ├── postgres          # PostgreSQL-specific implementations
│   ├── mysql             # MySQL-specific implementations
│   ├── db2               # DB2-specific implementations
│   ├── sqlserver         # SQL Server-specific implementations
│   ├── oracle            # Oracle-specific implementations
│   ├── vertxsql          # Vert.x SQL client implementations
│   └── systemproperties  # System properties implementations
├── spi                   # Service Provider Interfaces
│   ├── IPropertiesConnectionInfoReader.java  # SPI for connection info
│   └── IPropertiesEntityManagerReader.java   # SPI for entity manager properties
└── util                  # Utility classes
```

## SPI Implementation

### Creating SPI Interfaces

GuicedVertxPersistence provides two main SPI interfaces for extending and customizing the persistence behavior:

1. **IPropertiesConnectionInfoReader**: Reads connection information from properties and populates a ConnectionBaseInfo object.
2. **IPropertiesEntityManagerReader**: Reads entity manager properties from a persistence unit descriptor and processes them.

These interfaces follow a consistent pattern and provide extension points at different stages of the persistence unit initialization process.

Example:

```java
package com.guicedee.vertxpersistence;

import com.guicedee.guicedinjection.interfaces.IDefaultService;
import org.hibernate.jpa.boot.spi.PersistenceUnitDescriptor;

import java.util.Properties;

/**
 * A functional interface to populate a connection base info based on properties received
 */
@FunctionalInterface
public interface IPropertiesConnectionInfoReader<J extends IPropertiesConnectionInfoReader<J>>
    extends IDefaultService<J>
{
    /**
     * Method populateConnectionBaseInfo ...
     *
     * @param unit
     *        of type PersistenceUnit
     * @param filteredProperties
     *        of type Properties
     * @param cbi
     *        of type ConnectionBaseInfo
     *
     * @return ConnectionBaseInfo
     */
    ConnectionBaseInfo populateConnectionBaseInfo(PersistenceUnitDescriptor unit, Properties filteredProperties, ConnectionBaseInfo cbi);
}
```

### Implementing SPI Interfaces

Implementations of these SPI interfaces should follow these guidelines:

1. Place implementations in a separate package or module
2. Name implementations clearly, typically ending with "Impl" or a descriptive term
3. Implement only the methods defined in the interface
4. Use field injection for dependencies to maintain proper encapsulation
5. Keep implementations stateless when possible

Example implementation of IPropertiesConnectionInfoReader:

```java
package com.guicedee.vertxpersistence.implementations.postgres;

import com.guicedee.vertxpersistence.ConnectionBaseInfo;
import com.guicedee.vertxpersistence.IPropertiesConnectionInfoReader;
import org.hibernate.jpa.boot.spi.PersistenceUnitDescriptor;

import java.util.Properties;

public class PostgresConnectionInfoReader implements IPropertiesConnectionInfoReader<PostgresConnectionInfoReader>
{
    @Override
    public ConnectionBaseInfo populateConnectionBaseInfo(PersistenceUnitDescriptor unit, Properties filteredProperties, ConnectionBaseInfo cbi)
    {
        // Check if this is a PostgreSQL connection
        if (!(cbi instanceof PostgresConnectionBaseInfo))
        {
            return cbi;
        }

        PostgresConnectionBaseInfo pgCbi = (PostgresConnectionBaseInfo) cbi;

        // Populate from properties
        if (filteredProperties.containsKey("hibernate.connection.url"))
        {
            String url = filteredProperties.getProperty("hibernate.connection.url");
            // Parse URL and set properties
            // ...
        }

        // Set other properties
        if (filteredProperties.containsKey("hibernate.connection.username"))
        {
            pgCbi.setUsername(filteredProperties.getProperty("hibernate.connection.username"));
        }

        // Return the populated object
        return pgCbi;
    }
}
```

### Registering SPI Implementations

SPI implementations can be registered using both the Java Module System and the META-INF/services mechanism:

#### Using the Java Module System:

In your `module-info.java` file:

```java
module com.example.persistence {
    requires transitive com.guicedee.vertxpersistence;

    provides com.guicedee.vertxpersistence.IPropertiesConnectionInfoReader 
        with com.example.persistence.CustomConnectionInfoReader;
}
```

#### Using META-INF/services:

Create a file at `META-INF/services/com.guicedee.vertxpersistence.IPropertiesConnectionInfoReader` with the content:

```
com.example.persistence.CustomConnectionInfoReader
```

## Module Configuration

### module-info.java

The `module-info.java` file for a module that uses GuicedVertxPersistence should follow these guidelines:

1. Require the GuicedVertxPersistence module
2. Use the SPI interfaces provided by GuicedVertxPersistence
3. Provide implementations of the SPI interfaces as needed
4. **Do not** specify `uses com.guicedee.guicedinjection.interfaces.IGuiceModule` as this is already handled by the GuicedInjection library

Example:

```java
module com.example.persistence {
    requires transitive com.guicedee.vertxpersistence;

    uses com.guicedee.vertxpersistence.IPropertiesConnectionInfoReader;
    uses com.guicedee.vertxpersistence.IPropertiesEntityManagerReader;

    provides com.guicedee.vertxpersistence.IPropertiesConnectionInfoReader 
        with com.example.persistence.CustomConnectionInfoReader;

    // Do NOT include this line:
    // uses com.guicedee.guicedinjection.interfaces.IGuiceModule;
}
```

> **Important Note**: The GuicedInjection library already includes `uses com.guicedee.guicedinjection.interfaces.IGuiceModule` in its module-info.java file. Since your module will require GuicedInjection (directly or transitively), you should not specify this "uses" directive in your own module-info.java file. The GuicedInjection library will automatically discover and load all IGuiceModule implementations.

### Transitive Dependencies

GuicedVertxPersistence includes several transitive dependencies that are automatically available to modules that depend on it. This means you don't need to explicitly declare these dependencies in your module-info.java file.

The following modules are transitive dependencies of GuicedVertxPersistence:

```java
// Transitive dependencies in GuicedVertxPersistence
requires transitive org.hibernate.reactive;
requires transitive jakarta.transaction;
requires transitive org.hibernate.orm.core;
requires transitive io.vertx.sql.client;
requires transitive io.vertx.mutiny;
requires transitive com.guicedee.microprofile.config;
requires transitive io.smallrye.mutiny;
requires transitive com.ongres.scram.client;
```

When you include `requires com.guicedee.vertxpersistence` in your module-info.java file, these dependencies are automatically available to your module without needing to declare them explicitly.

### Required Module Reads and Opens

When using GuicedVertxPersistence, you need to ensure that certain modules can read and access each other. In particular, you need to add the following to your Maven configuration to avoid `IllegalAccessException` errors:

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

If you're using the Maven compiler plugin and Surefire plugin, make sure to add these arguments to their configurations.

#### Recommendation for Java Clients

When creating Java modules that use GuicedVertxPersistence and want to expose its functionality to their own consumers, it is recommended to use `requires transitive` instead of just `requires`:

```java
// Recommended approach for modules that expose GuicedVertxPersistence functionality
requires transitive com.guicedee.vertxpersistence;
```

This ensures that your module's consumers will also have access to GuicedVertxPersistence and its transitive dependencies without having to explicitly require them.

### META-INF/services

The META-INF/services mechanism can be used alongside or instead of the Java Module System for registering SPI implementations. Follow these guidelines:

1. Create a file in the `META-INF/services` directory with the fully qualified name of the SPI interface
2. Add the fully qualified name of each implementation on a separate line
3. Ensure the file is included in your JAR file

Example:

File: `META-INF/services/com.guicedee.vertxpersistence.IPropertiesConnectionInfoReader`
```
com.example.persistence.CustomConnectionInfoReader
```

## Lifecycle Management

### Startup Sequence

The GuicedVertxPersistence module integrates with the GuicedInjection lifecycle management system. The persistence units are initialized during the module configuration phase by the `VertxPersistenceModule` class, which implements `IGuiceModule`.

The startup sequence is as follows:

1. The core GuicedInjection framework initializes
2. The Vert.x instance is created and configured during the pre-startup phase
3. The `VertxPersistenceModule` is executed as part of the module configuration phase
4. Database modules are discovered and configured
5. Persistence units are initialized
6. Entity managers are bound for injection
7. The application starts using the configured persistence units

### Shutdown Sequence

The shutdown sequence is handled by the GuicedInjection framework. The persistence units are closed during the pre-destroy phase.

## Persistence Configuration

### Database Module Creation

To use GuicedVertxPersistence, you need to create a database module by extending the `DatabaseModule` class from the `com.guicedee.vertxpersistence` package. This class is responsible for configuring a persistence unit for use with Guice.

> **Important Note**: The `DatabaseModule` class already implements `IGuiceModule<J>` with CRTP (Curiously Recurring Template Pattern), so your implementation will automatically have type safety for the Guice module. You don't need to explicitly implement `IGuiceModule` in your subclass.

Example:

```java
import com.guicedee.vertxpersistence.DatabaseModule;
import com.guicedee.vertxpersistence.ConnectionBaseInfo;
import com.guicedee.vertxpersistence.annotations.EntityManager;
import org.hibernate.jpa.boot.spi.PersistenceUnitDescriptor;

import java.util.Properties;

@EntityManager
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
        return connectionInfo;
    }

    @Override
    protected String getJndiMapping()
    {
        return "jdbc/mydb";
    }
}
```

### Connection Configuration

GuicedVertxPersistence provides several connection base info classes for different database types:

- PostgresConnectionBaseInfo
- MySqlConnectionBaseInfo
- DB2ConnectionBaseInfo
- SqlServerConnectionBaseInfo
- OracleConnectionBaseInfo

These classes provide database-specific configuration options and are used to create the connection to the database.

Example:

```java
import com.guicedee.vertxpersistence.implementations.postgres.PostgresConnectionBaseInfo;

PostgresConnectionBaseInfo connectionInfo = new PostgresConnectionBaseInfo();
connectionInfo.setServerName("localhost");
connectionInfo.setPort("5432");
connectionInfo.setDatabaseName("mydb");
connectionInfo.setUsername("user");
connectionInfo.setPassword("password");
connectionInfo.setDefaultConnection(true);
```

### Entity Manager Configuration

GuicedVertxPersistence uses the `@EntityManager` annotation from the `com.guicedee.vertxpersistence.annotations` package to configure entity managers. This annotation can be applied to database modules and packages.

Example:

```java
import com.guicedee.vertxpersistence.DatabaseModule;
import com.guicedee.vertxpersistence.annotations.EntityManager;

@EntityManager(value = "myPersistenceUnit", defaultEm = true)
public class MyDatabaseModule extends DatabaseModule<MyDatabaseModule>
{
    // ...
}
```

The `@EntityManager` annotation has the following attributes:

- `value`: The name of the persistence unit
- `defaultEm`: Whether this is the default entity manager
- `allClasses`: Whether all classes in the package should be scanned for entities

### Reactive Mode

GuicedVertxPersistence supports reactive database access using Hibernate Reactive. To enable reactive mode, set the `reactive` property to `true` on the connection base info object.

Example:

```java
import com.guicedee.vertxpersistence.implementations.postgres.PostgresConnectionBaseInfo;

PostgresConnectionBaseInfo connectionInfo = new PostgresConnectionBaseInfo();
// ... set other properties
connectionInfo.setReactive(true);
```

When reactive mode is enabled, the entity manager is bound to a reactive session factory, and you can use the Mutiny API to perform database operations.

## Common Use Cases

### Creating a Database Module

To create a database module, extend the `DatabaseModule` class from the `com.guicedee.vertxpersistence` package and override the required methods:

```java
import com.guicedee.vertxpersistence.DatabaseModule;
import com.guicedee.vertxpersistence.ConnectionBaseInfo;
import com.guicedee.vertxpersistence.annotations.EntityManager;
import org.hibernate.jpa.boot.spi.PersistenceUnitDescriptor;

import java.util.Properties;

@EntityManager
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
        return connectionInfo;
    }

    @Override
    protected String getJndiMapping()
    {
        return "jdbc/mydb";
    }
}
```

### Using the Entity Manager

To use the entity manager, inject it into your class:

```java
public class MyService
{
    @Inject
    @Named("myPersistenceUnit")
    private EntityManager entityManager;

    public void saveEntity(MyEntity entity)
    {
        // For non-reactive EntityManager
        // Use the EntityManager's transaction methods
        entityManager.getTransaction().begin();
        try
        {
            entityManager.persist(entity);
            entityManager.getTransaction().commit();
        }
        catch (Exception e)
        {
            if (entityManager.getTransaction().isActive()) {
                entityManager.getTransaction().rollback();
            }
            throw e;
        }
    }
}
```

### Using Reactive Persistence

To use reactive persistence, inject the Mutiny session factory:

```java
public class MyReactiveService
{
    @Inject
    private Mutiny.SessionFactory sessionFactory;

    public Uni<MyEntity> findEntity(Long id)
    {
        return sessionFactory.withSession(session ->
            session.find(MyEntity.class, id)
        );
    }

    public Uni<Void> saveEntity(MyEntity entity)
    {
        return sessionFactory.withSession(session ->
            session.persist(entity)
                .chain(session::flush)
        );
    }

    /**
     * Correct implementation of getEntityManager that separates session retrieval from usage.
     * This approach allows for proper session management and ensures sessions are closed.
     */
    	@Override
	public Mutiny.Session getEntityManager()
	{
        return IGuiceContext.get(Mutiny.SessionFactory.class)
                       .getCurrentSession();
	}
}

/**
 * IMPORTANT: Session Opening and Closing Best Practices
 * 
 * When using Hibernate Reactivity, it's crucial to separate session opening and closing from usage.
 * This ensures resources are properly managed and prevents session leaks.
 * 
 * 1. Always use the withSession() or withTransaction() pattern when possible:
 *    ```
 *    sessionFactory.withSession(session -> {
 *        // Your code here
 *    });
 *    ```
 *    
 * 2. If you need to manage sessions manually, ensure they are always closed:
 *    ```
 *    Mutiny.Session session = sessionFactory.openSession();
 *    try {
 *        // Your code here
 *        return result;
 *    } finally {
 *        session.close();
 *    }
 *    ```
 *    
 * 3. Never store sessions as instance variables or in thread-local storage.
 * 
 * 4. For services that need to provide an EntityManager, implement getEntityManager() 
 *    to return the current session from the session factory, not a stored session.
 */
```

### Transaction Management

GuicedVertxPersistence provides transaction management for both traditional and reactive persistence:

```java
// Traditional transaction management with EntityManager
entityManager.getTransaction().begin();
try
{
    entityManager.persist(entity);
    entityManager.getTransaction().commit();
}
catch (Exception e)
{
    if (entityManager.getTransaction().isActive()) {
        entityManager.getTransaction().rollback();
    }
    throw e;
}

// Reactive transaction management
sessionFactory.withSession(session ->
    session.withTransaction(tx ->
        session.persist(entity)
    )
);
```

## Best Practices

1. **Use Database-Specific Connection Info Classes**: Use the database-specific connection info classes (e.g., PostgresConnectionBaseInfo) to ensure proper configuration for your database.

2. **Set Default Connection**: Set the `defaultConnection` property to `true` on the connection base info object for the primary database to ensure it's used as the default.

3. **Use Named Injection**: Use `@Named` injection to specify which entity manager to use when you have multiple persistence units.

4. **Properly Manage Transactions**: Always begin and end transactions properly, preferably using try-finally blocks or the `withTransaction` method for reactive persistence.

5. **Use Reactive Mode for High Concurrency**: Use reactive mode for applications that require high concurrency and non-blocking I/O.

6. **Configure Logging**: Configure logging to help diagnose issues with database connections and queries.

7. **Use System Properties for Configuration**: Use system properties to externalize database configuration, making it easier to change without recompiling.

8. **Implement Custom Property Readers**: Implement custom property readers to handle specific configuration requirements for your application.

9. **Use JNDI Mapping**: Use JNDI mapping to make it easier to switch between different database implementations.

10. **Test with Testcontainers**: Use Testcontainers to test your database modules with real databases in a controlled environment.

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
