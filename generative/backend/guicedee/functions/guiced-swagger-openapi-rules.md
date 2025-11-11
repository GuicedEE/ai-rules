# GuicedSwagger and GuicedSwaggerUI Framework Guidelines

This document provides comprehensive guidelines for using the GuicedSwagger and GuicedSwaggerUI frameworks, including package structure, configuration, usage patterns, and best practices.

## Table of Contents

1. [Overview](#overview)
2. [Package Structure](#package-structure)
3. [Configuration](#configuration)
   - [OpenAPI Configuration](#openapi-configuration)
   - [Swagger UI Configuration](#swagger-ui-configuration)
4. [Integration with Vert.x](#integration-with-vertx)
5. [Customizing OpenAPI Documentation](#customizing-openapi-documentation)
6. [Accessing Swagger UI](#accessing-swagger-ui)
7. [Common Use Cases](#common-use-cases)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

## Overview

GuicedSwagger and GuicedSwaggerUI provide integration with OpenAPI and Swagger UI for GuicedEE applications. These frameworks allow you to:

- Automatically generate OpenAPI documentation from your JAX-RS resources
- Serve OpenAPI documentation in both JSON and YAML formats
- Provide a user-friendly Swagger UI interface for exploring and testing your API
- Customize the OpenAPI documentation through configuration

The frameworks are designed to work together but can also be used independently:
- **GuicedSwagger**: Generates and serves OpenAPI documentation
- **GuicedSwaggerUI**: Serves the Swagger UI interface

## Package Structure

### GuicedSwagger

The GuicedSwagger module follows a modular package structure:

```
com.guicedee.guicedservlets.openapi
├── implementations                # Implementation classes
│   ├── OpenAPIModule.java        # Guice module for OpenAPI
│   ├── OpenAPIProvider.java      # Provider for OpenAPI instance
│   ├── OpenAPIRouter.java        # Router for serving OpenAPI docs
│   └── GuicedOpenApiScanner.java # Scanner for OpenAPI resources
└── services                       # Service interfaces
    └── IGuicedSwaggerConfiguration.java # SPI for configuration
```

### GuicedSwaggerUI

The GuicedSwaggerUI module has a simpler structure:

```
com.guicedee.servlets.swaggerui
└── SwaggerUIRegistration.java    # Router for serving Swagger UI
```

## Configuration

### OpenAPI Configuration

GuicedSwagger provides several ways to configure the OpenAPI documentation:

1. **Configuration Files**: Place an `openapi.yaml` or `openapi.json` file in your classpath or file system
2. **SPI Implementation**: Implement the `IGuicedSwaggerConfiguration` interface to customize the configuration programmatically

Example of implementing `IGuicedSwaggerConfiguration`:

```
public class CustomSwaggerConfig implements IGuicedSwaggerConfiguration {
    @Override
    public OpenAPIConfiguration config(OpenAPIConfiguration config) {
        // Cast to SwaggerConfiguration for more options
        SwaggerConfiguration swaggerConfig = (SwaggerConfiguration) config;
        
        // Set basic info
        swaggerConfig.setTitle("My API");
        swaggerConfig.setVersion("1.0.0");
        swaggerConfig.setDescription("API documentation for my application");
        
        // Set server URL
        swaggerConfig.setServerUrl("https://api.example.com");
        
        // Configure security schemes
        swaggerConfig.addSecurityScheme("bearerAuth", 
            new SecurityScheme()
                .type(SecurityScheme.Type.HTTP)
                .scheme("bearer")
                .bearerFormat("JWT"));
        
        return swaggerConfig;
    }
}
```

Register your implementation in `META-INF/services/com.guicedee.guicedservlets.openapi.services.IGuicedSwaggerConfiguration` or in your module-info.java:

```
provides com.guicedee.guicedservlets.openapi.services.IGuicedSwaggerConfiguration 
    with com.example.CustomSwaggerConfig;
```

### Swagger UI Configuration

The Swagger UI is configured to look for OpenAPI documentation at `/openapi.json` by default. You can customize this by modifying the `swagger-initializer.js` file in your resources.

## Integration with Vert.x

Both GuicedSwagger and GuicedSwaggerUI integrate with Vert.x Web for serving documentation and UI:

1. **OpenAPIRouter**: Configures routes for serving OpenAPI documentation at `/openapi.json` and `/openapi.yaml`
2. **SwaggerUIRegistration**: Configures a route for serving Swagger UI at `/swagger/*`

These routers are automatically registered with Vert.x through the `VertxRouterConfigurator` SPI.

## Customizing OpenAPI Documentation

### Using Annotations

You can use standard OpenAPI annotations in your JAX-RS resources to customize the documentation:

```
@Path("/users")
@Tag(name = "Users", description = "User management operations")
public class UserResource {
    
    @GET
    @Operation(
        summary = "Get all users",
        description = "Returns a list of all users in the system"
    )
    @APIResponse(
        responseCode = "200",
        description = "List of users",
        content = @Content(
            mediaType = "application/json",
            schema = @Schema(implementation = UserList.class)
        )
    )
    public Response getAllUsers() {
        // Implementation
    }
    
    @POST
    @Operation(
        summary = "Create a new user",
        description = "Creates a new user in the system"
    )
    @APIResponse(
        responseCode = "201",
        description = "User created successfully"
    )
    @APIResponse(
        responseCode = "400",
        description = "Invalid user data"
    )
    public Response createUser(User user) {
        // Implementation
    }
}
```

### Using Configuration

You can also customize the documentation through the `IGuicedSwaggerConfiguration` interface as shown in the [Configuration](#configuration) section.

## Accessing Swagger UI

Once your application is running, you can access the Swagger UI at:

```
http://your-server:port/swagger/
```

The UI will automatically load the OpenAPI documentation from `/openapi.json` and display it in a user-friendly interface.

## Common Use Cases

### RESTful API Documentation

The most common use case is documenting RESTful APIs:

1. Add OpenAPI annotations to your JAX-RS resources
2. Configure GuicedSwagger with basic information about your API
3. Access the Swagger UI to explore and test your API

### API Testing

Swagger UI provides a convenient way to test your API:

1. Navigate to the Swagger UI
2. Expand an operation
3. Fill in the required parameters
4. Click "Execute" to send the request
5. View the response

### API Client Generation

The OpenAPI documentation can be used to generate client libraries:

1. Access the OpenAPI specification at `/openapi.json` or `/openapi.yaml`
2. Use tools like OpenAPI Generator to generate client libraries in various languages

## Best Practices

1. **Use Descriptive Operation IDs**: Provide unique and descriptive operation IDs for each endpoint to make the documentation more readable and to generate better client code.

2. **Document Response Schemas**: Always document the structure of response objects using the `@Schema` annotation to provide clear information about what clients can expect.

3. **Include Examples**: Add examples to your documentation to help users understand how to use your API.

4. **Document Error Responses**: Document all possible error responses and their meanings to help clients handle errors properly.

5. **Use Tags**: Organize your API operations into logical groups using tags to make the documentation more navigable.

6. **Keep Documentation Updated**: Ensure that your OpenAPI documentation stays in sync with your actual API implementation.

7. **Secure Sensitive Endpoints**: Consider restricting access to Swagger UI in production environments or securing it behind authentication.

8. **Customize for Your Audience**: Tailor the documentation to your audience, providing more details for complex operations and keeping simple operations concise.

## Troubleshooting

### Common Issues

1. **OpenAPI Documentation Not Generated**: Ensure that your JAX-RS resources are properly annotated and that the GuicedSwagger module is included in your dependencies.

2. **Swagger UI Not Available**: Check that the GuicedSwaggerUI module is included in your dependencies and that the `/swagger/*` route is properly configured.

3. **Custom Configuration Not Applied**: Verify that your `IGuicedSwaggerConfiguration` implementation is properly registered as a service.

4. **Missing Information in Documentation**: Check that you've properly annotated your resources and that the scanner is configured to scan all relevant packages.

### Debugging Tips

1. **Enable Verbose Logging**: Set the logging level to get more detailed information about the OpenAPI generation process.

2. **Check Configuration Files**: Verify that your `openapi.yaml` or `openapi.json` files are in the correct location and have the correct format.

3. **Inspect Generated Documentation**: Access the raw OpenAPI documentation at `/openapi.json` to inspect what's being generated.

4. **Test with a Simple Resource**: Start with a simple, well-documented resource to verify that the basic functionality is working.