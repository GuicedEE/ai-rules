---
name: guicedee-swagger-ui
description: "Browsable Swagger UI for GuicedEE with Vert.x 5: auto-mounted at /swagger/, reads from /openapi.json endpoint, zero code configuration, companion to the openapi module. Use when adding a browsable API documentation UI to a GuicedEE application."
metadata:
  short-description: Browsable Swagger UI for GuicedEE REST APIs
---

# GuicedEE Swagger UI

Browsable Swagger UI for the GuicedEE / Vert.x stack.

## Core Concept

Add the dependency and a fully functional Swagger UI is mounted at `/swagger/` automatically — it reads from your `/openapi.json` endpoint out of the box, with zero code required.

## Required Flow

1. Add `com.guicedee:guiced-swagger-ui` dependency (pair with `openapi` for spec generation):
   ```xml
   <dependency>
     <groupId>com.guicedee</groupId>
     <artifactId>guiced-swagger-ui</artifactId>
   </dependency>
   <dependency>
     <groupId>com.guicedee</groupId>
     <artifactId>openapi</artifactId>
   </dependency>
   ```
2. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.swaggerui;
       requires com.guicedee.openapi; // for spec generation
   }
   ```
3. Bootstrap GuicedEE — Swagger UI is available automatically:
   ```java
   IGuiceContext.registerModuleForScanning.add("my.app");
   IGuiceContext.instance().inject();
   // Browse to http://localhost:8080/swagger/
   ```

## Features

- Auto-mounted at `/swagger/` via `VertxRouterConfigurator` SPI
- Reads `/openapi.json` endpoint by default
- Fully bundled Swagger UI static assets served from the module
- Zero configuration required

## Non-Negotiable Constraints

- Module must `requires com.guicedee.swaggerui;`.
- Pair with `openapi` module for automatic spec generation.
- Requires the `web` module for HTTP server (pulled in transitively).
- The module is registered automatically — no `provides` needed.


