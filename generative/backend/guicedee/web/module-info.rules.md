# Module Configuration & JPMS — GuicedEE Vert.x Web

Java Module System (JPMS) configuration for modules using GuicedEE Vert.x Web.

## module-info.java for Consumers

```java
module com.example.web.api {
    // Requirements
    requires com.guicedee.vertx.web;
    requires transitive com.guicedee.vertx;
    requires com.google.guice;

    // SPI Usage
    uses com.guicedee.vertx.web.spi.VertxRouterConfigurator;

    // SPI Implementations
    provides com.guicedee.vertx.web.spi.VertxRouterConfigurator
        with com.example.web.api.routes.ApiRoutesConfigurator;
}
```

## Requirement Options

### `requires` (Standard)

Use when your module imports classes but consumers don't need those imports.

```java
requires com.guicedee.vertx.web;
```

### `requires transitive` (Re-export)

Use when your module re-exports classes or consumers depend directly.

```java
requires transitive com.guicedee.vertx.web;
```

## Transitive Dependencies

When you require `com.guicedee.vertx.web`, these are automatically available:

```
com.guicedee.vertx.web (transitive):
  → com.guicedee.vertx
  → io.vertx.web
  → io.vertx.core
```

## SPI Registration Pattern

```java
module com.example.web.routes {
    requires com.guicedee.vertx.web;

    uses com.guicedee.vertx.web.spi.VertxRouterConfigurator;

    provides com.guicedee.vertx.web.spi.VertxRouterConfigurator
        with com.example.web.routes.UserRoutesConfigurator,
             com.example.web.routes.AdminRoutesConfigurator;
}
```

## Exports & Opens

### `exports` (Public Packages)

```java
module com.example.web.api {
    requires com.guicedee.vertx.web;
    exports com.example.web.api.spi;
}
```

### `opens` (Reflection for Guice)

```java
module com.example.web {
    requires com.guicedee.vertx.web;
    requires com.google.guice;

    opens com.example.web.routes to com.google.guice;
}
```

## Anti-Patterns

❌ **Don't:** Declare `uses com.guicedee.client.services.lifecycle.IGuiceModule`

```java
// WRONG - GuicedInjection handles this automatically
module com.example.web {
    uses com.guicedee.client.services.lifecycle.IGuiceModule;
}
```

❌ **Don't:** Create circular module dependencies

❌ **Don't:** Export internal implementation packages

## Validation Checklist

- [ ] All `requires` declarations present
- [ ] SPI implementations registered via `provides ... with`
- [ ] Internal packages NOT exported
- [ ] Guice packages `opens`'d for reflection
- [ ] No circular dependencies
- [ ] Build succeeds on Java 25

## See Also

- [spi-configurators.rules.md](spi-configurators.rules.md) — SPI interface definitions
- [lifecycle.rules.md](lifecycle.rules.md) — Module discovery at startup
