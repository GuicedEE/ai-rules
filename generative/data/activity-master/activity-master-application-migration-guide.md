# ActivityMaster Application Migration Guide

## Introduction

This guide provides comprehensive instructions for migrating applications that use the ActivityMaster library to the new reactive programming model. The ActivityMaster library has undergone significant changes to adopt reactive programming using SmallRye Mutiny, and applications using this library will need to adapt to these changes.

This migration guide covers all major components of the ActivityMaster library:
- ActivityMaster Core
- Cerial Master
- Session Master
- Profile Master

## Overview of Major Changes

### 1. Reactive Programming Model

The most significant change in the ActivityMaster library is the adoption of a reactive programming model using SmallRye Mutiny. This change affects:

- **Method Signatures**: Methods now accept a Mutiny.Session parameter and return Uni<T> types
- **Operation Flow**: Operations are now chained using reactive operators (.chain(), .onItem(), .onFailure(), etc.)
- **Session Management**: Sessions are passed through the chain rather than created within methods
- **Error Handling**: Errors are handled using reactive error handling operators

### 2. Session Management

The new model requires explicit session management:

- Sessions must be created by the application and passed to ActivityMaster methods
- Only one operation per session can be performed at a time
- Operations on a session must be sequential, not parallel
- Sessions should be passed through the entire reactive chain

### 3. Critical Reactivity Rules

The following rules must be strictly followed when working with the ActivityMaster library:

- **No await() Usage**: The await() method should never be used in library code. It blocks the thread and defeats the purpose of reactive programming.
- **One Write Action at a Time per Session**: A Mutiny.Session must not be used for parallel operations. All operations on a session must be sequential.
- **Proper Chain Utilization**: Always use .chain(), .flatMap(), or .map() to maintain the reactive chain. Don't break the chain by not properly chaining operations.
- **Session Passing**: Always pass the Mutiny.Session through the entire reactive chain. Don't create new sessions within methods.

### 4. Logging Standards

The library now implements comprehensive logging standards:

- Visual indicators using emoji icons for different types of operations
- Appropriate log levels for different scenarios
- Structured context information in log messages
- Session tracking for traceability

### 5. Component-Specific Changes

Each component of the ActivityMaster library has specific migration requirements:

- **ActivityMaster Core**: Core services and systems have been migrated to the reactive model
- **Cerial Master**: Communication functionality now follows reactive patterns
- **Session Master**: Session management has been updated to support reactive operations
- **Profile Master**: Profile services now provide reactive methods

## Step-by-Step Migration Instructions

### 1. Update Dependencies

Ensure your application includes the necessary dependencies for reactive programming:

```xml
<dependency>
    <groupId>io.vertx</groupId>
    <artifactId>vertx-pg-client</artifactId>
</dependency>

<dependency>
    <groupId>com.guicedee.services</groupId>
    <artifactId>hibernate-reactive</artifactId>
</dependency>

<dependency>
    <groupId>com.guicedee.services</groupId>
    <artifactId>scram</artifactId>
</dependency>

<dependency>
    <groupId>com.entityassist</groupId>
    <artifactId>entity-assist-reactive</artifactId>
</dependency>

<dependency>
    <groupId>io.smallrye.reactive</groupId>
    <artifactId>mutiny</artifactId>
</dependency>

<dependency>
    <groupId>com.guicedee.activitymaster</groupId>
    <artifactId>activity-master-client</artifactId>
</dependency>
```

### 2. Session Management

Update your application to create and manage sessions explicitly:

#### Before:

```java
public void createExample(String name, String description) {
    exampleService.create(name, description, system);
}
```

#### After:

```java
public Uni<IExample<?, ?>> createExample(String name, String description) {
    return sessionFactory.withSession(session -> {
        log.debug("📋 Session created by application, passing to ActivityMaster");
        return exampleService.create(session, name, description, system);
    });
}
```

### 3. Handle Reactive Return Types

Update your code to handle Uni<T> return types:

#### Before:

```java
ISystems<?, ?> system = systemsService.findSystem(enterprise, systemName);
// Use system immediately
processSystem(system);
```

#### After:

```java
// RECOMMENDED: Continue with reactive chain
systemsService.findSystem(session, enterprise, systemName)
    .chain(system -> {
        // Process system reactively
        return processSystem(session, system);
    })
    .subscribe().with(
        result -> log.info("✅ Processing completed successfully"),
        error -> log.error("❌ Processing failed", error)
    );

// NOT RECOMMENDED: Using await() blocks the thread and defeats the purpose of reactive programming
// Only use this approach in application code during migration, never in library code
// ISystems<?, ?> system = systemsService.findSystem(session, enterprise, systemName)
//    .await().atMost(Duration.ofMinutes(1));
// processSystem(system);
```

### 4. Convert Parallel Operations to Sequential

Replace parallel operations with sequential chains. Remember that only one write action at a time per session is allowed:

#### Before:

```java
List<Uni<?>> operations = new ArrayList<>();
operations.add(service.create(session, type1, system, classification));
operations.add(service.create(session, type2, system, classification));
operations.add(service.create(session, type3, system, classification));

return Uni.combine().all().unis(operations)
    .discardItems();
```

#### After:

```java
// CORRECT: Sequential operations on the same session
return service.create(session, type1, system, classification)
    .chain(() -> service.create(session, type2, system, classification))
    .chain(() -> service.create(session, type3, system, classification));
```

### 5. Implement Proper Error Handling

Update error handling to use reactive patterns:

#### Before:

```java
try {
    ISystems<?, ?> system = systemsService.findSystem(enterprise, systemName);
    return system;
} catch (Exception e) {
    log.error("Failed to find system", e);
    return null;
}
```

#### After:

```java
return systemsService.findSystem(session, enterprise, systemName)
    .onItem().invoke(system -> log.debug("✅ System found: '{}'", system.getName()))
    .onFailure().invoke(error -> log.error("❌ Failed to find system: {}", error.getMessage(), error))
    .onFailure().recoverWithItem(() -> {
        log.warn("🔄 Recovering with default system");
        return defaultSystem;
    });
```

### 6. Update Logging

Implement the new logging standards:

#### Before:

```java
log.info("Creating new example: " + name);
// ... operation code ...
log.info("Example created successfully");
```

#### After:

```java
log.info("🚀 Creating new example: '{}' for system: '{}' with external session", name, system.getName());
log.debug("📝 Example details - Name: '{}', Description: '{}', System ID: {}, Session: {}", 
    name, description, system.getId(), session.hashCode());
// ... operation code ...
log.info("✅ Example '{}' successfully persisted with ID: {}", name, persisted.getId());
log.info("🎉 Example '{}' creation completed successfully", name);
```

### 7. Component-Specific Migration

#### ActivityMaster Core

Update calls to core services to pass the session parameter and use proper reactive chains:

```java
// Before
ISystems<?, ?> system = systemsService.findSystem(enterprise, systemName);

// After - RECOMMENDED
systemsService.findSystem(session, enterprise, systemName)
    .chain(system -> {
        // Process system reactively
        return otherService.process(session, system);
    });

// After - NOT RECOMMENDED (uses await())
// ISystems<?, ?> system = systemsService.findSystem(session, enterprise, systemName)
//    .await().atMost(Duration.ofMinutes(1));
```

##### System-Related Methods

The following system-related methods have been updated to use reactive programming:

```java
// Before
ISystems<?, ?> system = getISystem(systemName, enterprise);
UUID token = getISystemToken(systemName, enterprise);

// After - Using static methods from IActivityMasterService
IActivityMasterService.getISystem(session, systemName, enterprise)
    .chain(system -> {
        // Process system reactively
        return processSystem(session, system);
    });

IActivityMasterService.getISystemToken(session, systemName, enterprise)
    .chain(token -> {
        // Process token reactively
        return processToken(session, token);
    });

// After - Using instance methods from ActivityMasterDefaultSystem
activityMasterSystem.getSystem(session, enterprise)
    .chain(system -> {
        // Process system reactively
        return processSystem(session, system);
    });

activityMasterSystem.getSystemToken(session, enterprise)
    .chain(token -> {
        // Process token reactively
        return processToken(session, token);
    });
```

#### Cerial Master

Update calls to Cerial Master services to follow reactive patterns:

```java
// Before
cerialMasterService.createConnection(connectionName, connectionType, system);

// After
cerialMasterService.createConnection(session, connectionName, connectionType, system)
    .chain(connection -> {
        // Process connection reactively
        return processConnection(session, connection);
    })
    .subscribe().with(
        result -> log.info("✅ Connection created successfully"),
        error -> log.error("❌ Connection creation failed", error)
    );
```

#### Session Master

Update session management to handle reactive session services:

```java
// Before
IUserSession<UserSession> userSession = userSessionProvider.get();
IInvolvedParty<?, ?> involvedParty = userSession.getInvolvedParty();

// After - RECOMMENDED: Continue with reactive approach
sessionFactory.withSession(session -> {
    return userSessionService.getSession(session, involvedParty, system, systemToken)
        .chain(userSession -> {
            return userSession.getInvolvedParty(session)
                .chain(party -> {
                    // Process involved party reactively
                    return processPartyReactive(session, party);
                });
        });
});

// After - NOT RECOMMENDED: Using await() (only for migration scenarios)
// IUserSession<UserSession> userSession = sessionFactory.withSession(session ->
//    userSessionService.getSession(session, involvedParty, system, systemToken)
// ).await().atMost(Duration.ofMinutes(1));
```

#### Profile Master

Use the reactive versions of profile methods:

```java
// Before
IInvolvedParty<?, ?> involvedParty = profileServiceDTO.findInvolvedParty();
Set<String> roles = profileServiceDTO.findRoles();

// After - RECOMMENDED: Continue with reactive approach
profileServiceDTO.findInvolvedPartyReactive()
    .chain(involvedParty -> {
        return profileServiceDTO.findRolesReactive()
            .chain(roles -> {
                // Process involved party and roles reactively
                return processDataReactive(involvedParty, roles);
            });
    });

// After - NOT RECOMMENDED: Using await() (only for migration scenarios)
// IInvolvedParty<?, ?> involvedParty = profileServiceDTO.findInvolvedPartyReactive()
//    .await().atMost(Duration.ofMinutes(1));
```

## Handling Transitional Components

Some components of the ActivityMaster library are in a transitional state, with both synchronous and reactive methods available. For these components:

1. **Prefer reactive methods**: Use methods with "Reactive" suffix when available
2. **Check method signatures**: Look for methods that accept a Mutiny.Session parameter
3. **Handle both patterns**: Be prepared to handle both synchronous and reactive patterns during the migration period

Example of handling a transitional component:

```java
// Check if reactive method is available
if (methodHasReactiveVersion) {
    // Use reactive approach
    return componentService.methodReactive(session, param1, param2)
        .chain(result -> {
            // Process result reactively
            return processResultReactive(session, result);
        });
} else {
    // Fall back to synchronous approach with blocking
    return Uni.createFrom().item(() -> {
        Object result = componentService.method(param1, param2);
        return processResult(result);
    });
}
```

## Common Pitfalls and Solutions

### Pitfall 1: Using await() in Library Code

**Problem**: Using await() blocks the thread and defeats the purpose of reactive programming.

**Solution**: Never use await() in library code. Always use reactive chains instead.

```java
// INCORRECT - Using await() blocks the thread
ISystems<?, ?> system = systemsService.findSystem(session, enterprise, systemName)
    .await().atMost(Duration.ofMinutes(1));
processSystem(system);

// CORRECT - Using reactive chain
return systemsService.findSystem(session, enterprise, systemName)
    .chain(system -> processSystem(session, system));
```

### Pitfall 2: Mixing Synchronous and Reactive Code

**Problem**: Calling synchronous methods from reactive chains or vice versa can lead to unexpected behavior.

**Solution**: Ensure all code in a reactive chain is reactive. Convert synchronous operations to reactive using Uni.createFrom().item() or similar methods.

```java
// INCORRECT
return reactiveMethod1(session)
    .chain(result -> {
        // This blocks the reactive chain!
        Object syncResult = synchronousMethod(result);
        return reactiveMethod2(session, syncResult);
    });

// CORRECT
return reactiveMethod1(session)
    .chain(result -> {
        // Convert synchronous operation to reactive
        return Uni.createFrom().item(() -> synchronousMethod(result))
            .chain(syncResult -> reactiveMethod2(session, syncResult));
    });
```

### Pitfall 3: Forgetting to Pass the Session

**Problem**: Methods that need to perform database operations don't have access to the session.

**Solution**: Always pass the session as a parameter to methods that need it. Don't rely on creating new sessions.

```java
// INCORRECT
private Uni<Void> processData(Data data) {
    // No session parameter!
    return dataService.save(data);
}

// CORRECT
private Uni<Void> processData(Mutiny.Session session, Data data) {
    return dataService.save(session, data);
}
```

### Pitfall 4: Losing the Reactive Chain

**Problem**: Breaking the reactive chain by not properly chaining operations.

**Solution**: Use .chain(), .flatMap(), or .map() to maintain the reactive chain. Avoid using .subscribe() except at the very end of a chain.

```java
// INCORRECT - chain is broken
Uni<Data> dataUni = dataService.getData(session);
// This doesn't wait for dataUni to complete!
return otherService.process(session, someValue);

// CORRECT
return dataService.getData(session)
    .chain(data -> otherService.process(session, data));
```

### Pitfall 5: Handling Errors Incorrectly

**Problem**: Not properly handling errors in the reactive chain.

**Solution**: Use .onFailure() handlers to catch and handle errors. Consider using .recoverWith() for fallback behavior.

```java
// INCORRECT - errors are not handled
return dataService.getData(session)
    .chain(data -> otherService.process(session, data));

// CORRECT
return dataService.getData(session)
    .onFailure().invoke(error -> log.error("❌ Failed to get data: {}", error.getMessage(), error))
    .onFailure().recoverWithItem(() -> defaultData)
    .chain(data -> otherService.process(session, data)
        .onFailure().invoke(error -> log.error("❌ Failed to process data: {}", error.getMessage(), error))
    );
```

### Pitfall 6: Parallel Operations on the Same Session

**Problem**: Using Uni.combine().all().unis() with operations that share the same session.

**Solution**: Use sequential chains instead of parallel operations when using the same session. Remember that only one write action at a time per session is allowed.

```java
// INCORRECT - parallel operations on the same session
List<Uni<?>> operations = new ArrayList<>();
operations.add(service1.operation1(session, param1));
operations.add(service2.operation2(session, param2));
return Uni.combine().all().unis(operations).discardItems();

// CORRECT - sequential operations
return service1.operation1(session, param1)
    .chain(() -> service2.operation2(session, param2));
```

## Testing Reactive Code

Update your tests to handle reactive code:

```java
@Test
public void testReactiveMethod() {
    // Use withSession for test
    sessionFactory.withSession(session -> {
        return serviceUnderTest.reactiveMethod(session, param1, param2)
            .onItem().invoke(result -> {
                // Assertions
                assertNotNull(result);
                assertEquals(expectedValue, result.getValue());
            });
    })
    .await().atMost(Duration.ofSeconds(30));
}
```

## Conclusion

Migrating your application to use the new reactive ActivityMaster library requires significant changes to your code, but the benefits include:

- Improved resource utilization
- Better scalability
- More predictable behavior
- Fewer concurrency issues

By following this guide, you can successfully migrate your application to the new reactive programming model while maintaining compatibility with existing code during the transition period.

### Key Principles to Remember

1. **No await() Usage**: Never use await() in library code. It blocks the thread and defeats the purpose of reactive programming.

2. **One Write Action at a Time per Session**: A Mutiny.Session must not be used for parallel operations. All operations on a session must be sequential.

3. **Proper Chain Utilization**: Always use .chain(), .flatMap(), or .map() to maintain the reactive chain. Don't break the chain by not properly chaining operations.

4. **Session Passing**: Always pass the Mutiny.Session through the entire reactive chain. Don't create new sessions within methods.

5. **Synchronous Execution of Reactive Chains**: Reactive chains must be executed synchronously. Avoid fire-and-forget operations with subscribe().with().

6. **No Session Creation in Libraries**: The library doesn't create or start sessions or transactions. Sessions should be passed in from the caller.

7. **System-Related Methods**: Use the reactive versions of system-related methods:
   - Replace `getISystem(systemName, enterprise)` with `IActivityMasterService.getISystem(session, systemName, enterprise)`
   - Replace `getISystemToken(systemName, enterprise)` with `IActivityMasterService.getISystemToken(session, systemName, enterprise)`
   - Replace direct system access with `activityMasterSystem.getSystem(session, enterprise)` and `activityMasterSystem.getSystemToken(session, enterprise)`

For more detailed information, refer to:
- [LOGGING_RULES.md](../logging/LOGGING_RULES.md) - Logging standards
- [activity-master-application-migration-guide-updated.md](activity-master-application-migration-guide-updated.md) - Updated migration rules