---
name: guicedee-webservices
description: "Build GuicedEE SOAP/JAX-WS services with CXF, WSDL bindings, interceptors, MTOM, and WS-Security."
metadata:
  short-description: SOAP web services with Apache CXF conventions inside GuicedEE
---

# GuicedEE Web Services

SOAP web services using Apache CXF conventions inside GuicedEE.

## Core Concept

Build SOAP services using standard JAX-WS annotations (`@WebService`, `@WebMethod`, `@WebParam`, `@WebResult`) and configure endpoints, bindings, interceptors, and WS-Security in the same way you would with CXF. Works alongside GuicedEE Vert.x Web and REST/OpenAPI modules.

## Required Flow

1. Add `com.guicedee:web-services` and `requires com.guicedee.webservices;`.
2. Define the service contract:
   ```java
   @WebService(targetNamespace = "http://example.com/hello", name = "HelloService")
   public interface HelloService {
       @WebMethod(operationName = "sayHello")
       @WebResult(name = "greeting")
       String sayHello(@WebParam(name = "name") String name);
   }
   ```
3. Implement the service:
   ```java
   @WebService(endpointInterface = "com.example.ws.HelloService",
               serviceName = "HelloService",
               portName = "HelloPort",
               targetNamespace = "http://example.com/hello")
   public class HelloServiceImpl implements HelloService {
       @Override
       public String sayHello(String name) { return "Hello " + name; }
   }
   ```
4. Enable scanning of the implementation package. `WebServicePostStartup` discovers concrete `@WebService` classes, obtains Guice-managed instances, and publishes through CXF's Vert.x transport. Use `WSContext` for explicit endpoint registration when scanning is insufficient; do not publish a duplicate endpoint from another startup hook.
5. For WSDL-first, use the CXF codegen plugin (`cxf-codegen-plugin`).

## Features

- JAX-WS code-first or WSDL-first
- CXF configuration: addresses, bindings (SOAP 1.1/1.2), interceptors, logging
- MTOM for binary attachments
- WS-Security (WSS4J)
- Guice DI friendly: bind implementations via SPI/lifecycle
- JPMS + ServiceLoader discovery

## Non-Negotiable Constraints

- Use standard JAX-WS annotations for service contracts.
- Endpoint publishing should be done during `IGuicePostStartup`.
- SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).

