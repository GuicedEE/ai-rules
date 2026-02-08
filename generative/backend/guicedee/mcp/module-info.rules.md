# JPMS and module-info Rules - GuicedEE MCP Server

Purpose: standardize Java module declarations and SPI wiring for MCP server assemblies.

## Baseline module structure
- Keep protocol, transport, and capability providers in separate JPMS modules when feasible:
  - `com.guicedee.mcp.protocol`
  - `com.guicedee.mcp.transport.http`
  - `com.guicedee.mcp.transport.stdio`
  - `com.guicedee.mcp.capabilities`
  - `com.guicedee.mcp.server` (assembly)
- Keep public exports minimal; do not export internal implementation packages.

## Example module-info.java (assembly module)
```java
module com.guicedee.mcp.server {
    requires com.google.guice;
    requires com.guicedee.client;
    requires com.guicedee.vertx;
    requires com.guicedee.vertx.web;
    requires io.vertx.core;
    requires io.vertx.web;
    requires org.jspecify;

    uses com.guicedee.vertx.web.spi.VertxRouterConfigurator;

    provides com.guicedee.client.services.lifecycle.IGuiceModule
        with com.guicedee.mcp.server.runtime.McpServerModule;
    provides com.guicedee.client.services.interfaces.IGuicePreStartup
        with com.guicedee.mcp.server.runtime.McpPreStartup;
    provides com.guicedee.client.services.interfaces.IGuicePostStartup
        with com.guicedee.mcp.server.runtime.McpPostStartup;
    provides com.guicedee.client.services.interfaces.IGuicePreDestroy
        with com.guicedee.mcp.server.runtime.McpPreDestroy;
}
```

## SPI registration rules
- Register GuicedEE lifecycle providers through `provides ... with ...` in `module-info.java`.
- Do not add `uses com.guicedee.client.services.lifecycle.IGuiceModule`; GuicedEE inject infrastructure already handles this discovery path.
- Keep transport configurators and capability providers discoverable through explicit SPI contracts.
- Use the existing GuicedEE SPI interfaces directly; do not create duplicate local interface definitions for lifecycle/SPI types.

## Reflection and nullness
- Use `opens` only where runtime reflection is required by DI serialization/introspection.
- Default modules to `@NullMarked` and annotate nullable contracts explicitly.

## Dependency boundaries
- Keep protocol module free from transport-specific dependencies.
- Keep capability providers free from edge/proxy infrastructure classes.
- Prevent cyclic module dependencies; enforce boundary checks in CI.

See also: `../web/module-info.rules.md`, `../inject/README.md`, `../../../language/java/java-25.rules.md`.
