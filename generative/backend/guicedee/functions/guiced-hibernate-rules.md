# GuicedHazelcast and HazelcastHibernate Framework Guidelines

This document provides comprehensive guidelines for using the GuicedHazelcast and HazelcastHibernate frameworks, including package structure, configuration, usage patterns, and best practices.

## Table of Contents

1. [Overview](#overview)
2. [Package Structure](#package-structure)
3. [Configuration](#configuration)
   - [Hazelcast Properties](#hazelcast-properties)
   - [Hibernate Integration](#hibernate-integration)
4. [Lifecycle Management](#lifecycle-management)
   - [Startup Sequence](#startup-sequence)
   - [Shutdown Sequence](#shutdown-sequence)
5. [Client and Server Configuration](#client-and-server-configuration)
   - [Server Configuration](#server-configuration)
   - [Client Configuration](#client-configuration)
   - [Custom Configuration](#custom-configuration)
6. [Hibernate Integration](#hibernate-integration)
   - [Second-Level Cache](#second-level-cache)
   - [Query Cache](#query-cache)
   - [Cache Regions](#cache-regions)
7. [Common Use Cases](#common-use-cases)
   - [Distributed Caching](#distributed-caching)
   - [Clustered Hibernate](#clustered-hibernate)
   - [Local Development](#local-development)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

## Overview

GuicedHazelcast provides integration with Hazelcast, a distributed in-memory data grid, for GuicedEE applications. HazelcastHibernate extends this integration to provide Hazelcast-based caching for Hibernate ORM.

The frameworks offer:
- Seamless integration with GuicedInjection for dependency injection
- Automatic lifecycle management
- Flexible configuration through SPIs
- Integration with Hibernate for second-level caching
- Support for both client and server modes

## Package Structure

### GuicedHazelcast

The GuicedHazelcast module follows a modular package structure:

```
com.guicedee.guicedhazelcast
├── HazelcastProperties.java       # Configuration properties
├── services                       # Service interfaces and implementations
│   ├── HazelcastPreStartup.java   # Server initialization
│   ├── HazelcastClientPreStartup.java # Client initialization
│   ├── IGuicedHazelcastClientConfig.java # Client configuration SPI
│   └── IGuicedHazelcastServerConfig.java # Server configuration SPI
└── implementations                # Implementation classes
    ├── HazelcastBinderGuice.java  # Guice bindings
    └── HazelcastClientProvider.java # Provider for client instance
```

### HazelcastHibernate

The HazelcastHibernate module has a simpler structure:

```
com.guicedee.guicedhazelcast.hibernate
└── HazelcastHibernateProperties.java # Hibernate integration properties
```

## Configuration

### Hazelcast Properties

GuicedHazelcast provides a central configuration class, `HazelcastProperties`, with the following properties:

- **HazelcastNativeClientProperty**: Property to enable native client mode
- **regionName**: The specific region name to apply the configuration to
- **useLocalRegionFactory**: Whether to use the local region factory
- **address**: The address to contact Hazelcast (default: "localhost")
- **groupName**: The group name to contact Hazelcast (default: "dev")
- **instanceName**: The instance name for Hazelcast
- **startLocal**: Whether to start a local Hazelcast instance

These properties can be set programmatically:

```
// Configure Hazelcast
HazelcastProperties.setAddress("192.168.1.100:5701");
HazelcastProperties.setGroupName("production");
HazelcastProperties.setStartLocal(true);
```

Or through system properties or environment variables:

```
CLIENT_ADDRESS=192.168.1.100:5701
GROUP_NAME=production
```

### Hibernate Integration

HazelcastHibernate automatically configures Hibernate to use Hazelcast as its second-level cache provider. The following properties are set:

- **hibernate.cache.region.factory_class**: Set to JCacheRegionFactory or HazelcastCacheRegionFactory
- **hibernate.javax.cache.provider**: Set to HazelcastClientCachingProvider
- **hibernate.cache.use_minimal_puts**: Set to true
- **hibernate.cache.use_second_level_cache**: Set to true
- **hibernate.cache.use_query_cache**: Set to true
- **hibernate.cache.hazelcast.use_native_client**: Set to true

Additional properties are set based on the Hazelcast configuration:

- **hibernate.cache.hazelcast.native_client_hosts**: Set to the configured address
- **hibernate.cache.hazelcast.native_client_group**: Set to the configured group name
- **hibernate.cache.hazelcast.instance_name**: Set to the configured instance name
- **hibernate.cache.region_prefix**: Set to the configured region name

## Lifecycle Management

### Startup Sequence

The GuicedHazelcast module integrates with the GuicedInjection lifecycle management system:

1. The core GuicedInjection framework initializes
2. Vert.x is initialized
3. The `HazelcastPreStartup` service is executed to initialize the Hazelcast server (if enabled)
4. The `HazelcastClientPreStartup` service is executed to initialize the Hazelcast client
5. The Hibernate integration is configured through `HazelcastHibernateProperties`

### Shutdown Sequence

The shutdown sequence ensures proper cleanup of resources:

1. The `IGuicePreDestroy` hooks are executed
2. The Hazelcast client is shut down
3. The Hazelcast server is shut down (if it was started)

## Client and Server Configuration

### Server Configuration

The Hazelcast server is configured in `HazelcastPreStartup`:

1. A new `Config` object is created
2. Network configuration is set up
3. The address and group name are configured
4. Custom configurations are applied through the `IGuicedHazelcastServerConfig` SPI
5. If `startLocal` is true, multicast and auto-detection are disabled, and a local instance is created

### Client Configuration

The Hazelcast client is configured in `HazelcastClientPreStartup`:

1. A new `ClientConfig` object is created
2. Various client properties are set (heartbeat, timeout, etc.)
3. The address and group name are configured
4. Custom configurations are applied through the `IGuicedHazelcastClientConfig` SPI
5. A Hazelcast client instance is created

### Custom Configuration

Both the server and client configurations can be customized by implementing the appropriate SPI interface:

For server configuration:

```
// Example of a custom server configuration
public class CustomServerConfig implements IGuicedHazelcastServerConfig<CustomServerConfig> {
    @Override
    public Config buildConfig(Config serverConfig) {
        // Customize the server configuration
        serverConfig.setProperty("hazelcast.logging.type", "log4j2");
        return serverConfig;
    }
}
```

For client configuration:

```
// Example of a custom client configuration
public class CustomClientConfig implements IGuicedHazelcastClientConfig<CustomClientConfig> {
    @Override
    public ClientConfig buildConfig(ClientConfig clientConfig) {
        // Customize the client configuration
        clientConfig.setProperty("hazelcast.client.statistics.enabled", "true");
        return clientConfig;
    }
}
```

These implementations need to be registered as services using either the Java Module System or META-INF/services.

## Hibernate Integration

### Second-Level Cache

HazelcastHibernate automatically configures Hibernate to use Hazelcast as its second-level cache provider. This improves performance by caching entity data in memory, reducing database access.

The second-level cache is enabled by default with these properties:

```
hibernate.cache.use_second_level_cache=true
hibernate.cache.region.factory_class=org.hibernate.cache.jcache.internal.JCacheRegionFactory
hibernate.javax.cache.provider=com.hazelcast.client.cache.impl.HazelcastClientCachingProvider
```

### Query Cache

The query cache is also enabled by default, which caches the results of Hibernate queries:

```
hibernate.cache.use_query_cache=true
```

### Cache Regions

Cache regions can be configured using the `regionName` property:

```
// Set the region name
HazelcastProperties.setRegionName("myApplication");
```

This sets the `hibernate.cache.region_prefix` property, which prefixes all cache region names with the specified value.

If `useLocalRegionFactory` is set to true, the `HazelcastLocalCacheRegionFactory` is used instead of the default `HazelcastCacheRegionFactory`:

```
// Use local region factory
HazelcastProperties.setUseLocalRegionFactory(true);
```

## Common Use Cases

### Distributed Caching

GuicedHazelcast can be used as a distributed cache for your application:

1. Configure the Hazelcast client
2. Obtain the Hazelcast instance
3. Use the Hazelcast APIs for distributed maps, queues, etc.

Example code:

```
// Get the Hazelcast client instance
HazelcastInstance hazelcast = HazelcastClientPreStartup.clientInstance;

// Use a distributed map
IMap<String, User> userCache = hazelcast.getMap("userCache");
userCache.put("user123", new User("John Doe"));
User user = userCache.get("user123");
```

### Clustered Hibernate

HazelcastHibernate enables clustered Hibernate caching:

1. Configure the Hazelcast client
2. Let HazelcastHibernateProperties configure Hibernate
3. Use Hibernate as usual, with caching handled automatically

Example code:

```
// Configure Hazelcast
HazelcastProperties.setAddress("192.168.1.100:5701");
HazelcastProperties.setGroupName("production");

// Use Hibernate with caching
EntityManager em = entityManagerFactory.createEntityManager();
User user = em.find(User.class, 123); // Cached after first access
```

### Local Development

For local development, you can use a local Hazelcast instance:

```
// Start a local Hazelcast instance
HazelcastProperties.setStartLocal(true);
```

This disables multicast and auto-detection, creating a standalone Hazelcast instance that doesn't try to join a cluster.

## Best Practices

1. **Configure for Your Environment**: Set appropriate values for address, group name, and other properties based on your environment (development, testing, production).

2. **Use Custom Configuration**: Implement the `IGuicedHazelcastClientConfig` or `IGuicedHazelcastServerConfig` interfaces to customize the configuration for your specific needs.

3. **Consider Cache Eviction**: Configure appropriate eviction policies to prevent memory issues, especially for large datasets.

4. **Monitor Cache Usage**: Use Hazelcast's monitoring capabilities to track cache usage and performance.

5. **Tune Cache Regions**: Configure cache regions with appropriate settings for different entity types based on their access patterns.

6. **Use Query Cache Selectively**: Enable query caching only for frequently executed queries with relatively stable results.

7. **Handle Cluster Changes**: Be prepared for cluster topology changes and ensure your application can handle them gracefully.

8. **Secure Your Cluster**: In production environments, configure security settings to protect your Hazelcast cluster.

## Troubleshooting

### Common Issues

1. **Connection Failures**: If the client cannot connect to the server, check:
   - The address is correct
   - The group name matches
   - Network connectivity between client and server
   - Firewall settings

2. **Cache Not Working**: If caching doesn't seem to be working, check:
   - Second-level cache is enabled
   - The entity is marked as cacheable
   - The cache region is properly configured

3. **Out of Memory Errors**: If you experience out of memory errors, consider:
   - Configuring eviction policies
   - Reducing the cache size
   - Increasing the JVM heap size

4. **Cluster Split-Brain**: If the cluster experiences split-brain issues:
   - Configure a proper merge policy
   - Ensure network stability
   - Consider using a fixed set of members

### Debugging Tips

1. **Enable Hazelcast Logging**: Set the logging level to get more detailed information:

   ```
   System.setProperty("hazelcast.logging.level", "FINEST");
   ```

2. **Check Cluster State**: Use the Hazelcast Management Center to monitor the cluster state.

3. **Verify Cache Configuration**: Check the Hibernate cache configuration in the logs at startup.

4. **Test with a Local Instance**: For troubleshooting, use a local Hazelcast instance to isolate issues.

5. **Check System Properties**: Verify that system properties are correctly set and recognized.