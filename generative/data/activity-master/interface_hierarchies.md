# ActivityMaster Interface Hierarchies

This document provides an overview of the interface hierarchies in the ActivityMaster framework. Understanding these hierarchies is essential for developers working with the system, especially when implementing new features or extending existing functionality.

## Core System Interfaces

### IActivityMasterSystem

`IActivityMasterSystem<J extends IActivityMasterSystem<J>>` is the root interface for all system implementations in ActivityMaster. It extends:

- `IDefaultService<J>` - Provides basic service functionality
- `IProgressable` - Enables progress tracking for long-running operations

Key methods:
- `registerSystem(session, enterprise)` - Registers a system with an enterprise
- `createDefaults(session, enterprise)` - Creates default data for a system
- `getSystem(session, enterpriseName)` - Retrieves a system by enterprise name
- `getSystemToken(session, enterpriseName)` - Gets the security token for a system
- `hasSystemInstalled(session, enterprise)` - Checks if a system is installed
- `getSystemName()` - Returns the system's name
- `getSystemDescription()` - Returns the system's description
- `totalTasks()` - Returns the number of tasks for progress tracking
- `postStartup(session, enterprise)` - Performs post-startup operations

### ActivityMasterDefaultSystem

`ActivityMasterDefaultSystem<J extends ActivityMasterDefaultSystem<J>>` is an abstract base class that implements `IActivityMasterSystem<J>`. It provides default implementations for most methods, requiring concrete subclasses to implement only:

- `getSystemName()`
- `getSystemDescription()`

This class serves as the foundation for most system implementations in ActivityMaster.

## Service Interfaces

### IActivityMasterService

`IActivityMasterService<J extends IActivityMasterService<J>>` is a core service interface that provides methods for managing the ActivityMaster system:

- `loadSystems(session, enterpriseName)` - Loads systems for the specified enterprise
- `loadUpdates(session, enterprise)` - Loads updates for the specified enterprise
- `runScript(script)` - Runs a SQL script
- `updatePartitionBases()` - Updates partition bases (deprecated)

It also provides important static utility methods:
- `getISystem(session, systemName, enterprise)` - Gets a system by name for the specified enterprise
- `getISystemToken(session, systemName, enterprise)` - Gets a system token by name for the specified enterprise

These static methods are critical for the reactive programming model and are referenced in the migration guide as replacements for their synchronous counterparts.

## Specific System Interfaces

ActivityMaster includes numerous specialized system interfaces that define functionality for specific domains:

### ITimeSystem

`ITimeSystem` defines operations related to time management:
- `loadTimeRange(startYear, endYear)` - Loads time data for a range of years
- `getDay(session, date)` - Gets or creates a day entity for a given date
- `createTime()` - Creates time-related data

### Other System Interfaces

Other specialized system interfaces include:
- `IEventSystem` - Event management
- `IProfileSystem` - User profile management
- `ISecuritySystem` - Security and authentication
- `IResourceSystem` - Resource management
- `IMailSystem` - Email and communication
- `ICerialSystem` - Data serialization and communication

## Implementation Hierarchy

The typical implementation hierarchy for a system in ActivityMaster is:

1. **Interface Definition**: A specialized interface (e.g., `ITimeSystem`) defines the domain-specific operations
2. **Abstract Implementation**: `ActivityMasterDefaultSystem` provides default implementations of `IActivityMasterSystem` methods
3. **Concrete Implementation**: A concrete class (e.g., `TimeSystem`) extends `ActivityMasterDefaultSystem` and implements the specialized interface

Example:
```
IActivityMasterSystem (interface)
↑
ActivityMasterDefaultSystem (abstract class)
↑
TimeSystem (concrete class) → implements ITimeSystem
```

## Service Discovery

ActivityMaster uses Java's `ServiceLoader` mechanism for discovering system implementations. The `IActivityMasterSystem.allSystems()` static method returns all registered system implementations:

```java
static @NotNull Set<IActivityMasterSystem<?>> allSystems() {
    Set iActivityMasterSystems = IGuiceContext.loaderToSet(ServiceLoader.load(IActivityMasterSystem.class));
    return iActivityMasterSystems;
}
```

System implementations must be registered in the appropriate `META-INF/services` file to be discovered.

## Reactive Programming Model

All interfaces in ActivityMaster follow a reactive programming model using SmallRye Mutiny:

- Methods accept a `Mutiny.Session` parameter for database operations
- Methods return `Uni<T>` types for asynchronous operations
- Operations are chained using reactive operators (`.chain()`, `.onItem()`, etc.)
- Error handling uses reactive patterns (`.onFailure()`)

Example:
```java
Uni<ISystems<?, ?>> getSystem(Mutiny.Session session, IEnterprise<?, ?> enterprise) {
    return systemsService.findSystem(session, enterprise, getSystemName());
}
```

## System Registration and Initialization

Systems are registered and initialized through the following process:

1. The `EnterpriseService` discovers all `IActivityMasterSystem` implementations
2. For each system, `registerSystem(session, enterprise)` is called to register it with the enterprise
3. After registration, `createDefaults(session, enterprise)` is called to create default data
4. Finally, `postStartup(session, enterprise)` is called to perform any post-startup operations

This process ensures that all systems are properly initialized and ready for use.

## Common System Implementations

ActivityMaster includes several core system implementations:

- `EnterpriseSystem` - Enterprise management
- `SystemsSystem` - System registration and management
- `SecurityTokenSystem` - Security token management
- `TimeSystem` - Time management
- `EventsSystem` - Event management
- `ProfileSystem` - User profile management
- `CerialMasterSystem` - Communication and serialization
- `SessionMasterSystem` - Session management

Each system implementation follows the hierarchy described above and provides specific functionality for its domain.