---
name: guicedee-cdi
description: "Jakarta CDI bridge for GuicedEE: maps CDI annotations (@Inject, @Named, @ApplicationScoped, @Qualifier) to Guice equivalents, provides BeanManager adapter, CDIProvider registration, GuiceCDIBeanManager lookup API, and scope bridging. Use when using Jakarta CDI annotations with Guice, accessing CDI.current(), performing BeanManager lookups, or bridging CDI-annotated libraries into GuicedEE."
metadata:
  short-description: Jakarta CDI annotation bridge for GuicedEE / Guice
---

# GuicedEE CDI

Lightweight Jakarta CDI bridge for GuicedEE applications.

## Core Concept

Maps CDI annotations (`@Inject`, `@Named`, `@ApplicationScoped`, `@Qualifier`) to their Guice equivalents, provides a `BeanManager` adapter backed by the Guice injector, and registers itself as the Jakarta `CDIProvider` — so CDI-annotated code runs seamlessly inside a Guice-managed container.

## Required Flow

1. Add `com.guicedee:cdi` dependency.
2. Annotate your classes with standard Jakarta CDI annotations:
   ```java
   @jakarta.enterprise.context.ApplicationScoped
   public class GreetingService {
       public String greet(String name) {
           return "Hello, " + name + "!";
       }
   }
   ```
3. Inject anywhere via `@Inject`:
   ```java
   public class WelcomeResource {
       @jakarta.inject.Inject
       private GreetingService greeter;
   }
   ```
4. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.cdi;
   }
   ```
5. Bootstrap GuicedEE — CDI module loads automatically:
   ```java
   IGuiceContext.registerModuleForScanning.add("my.app");
   IGuiceContext.instance().inject();
   ```

## Annotation Mapping

| CDI Annotation | Guice Equivalent |
|---|---|
| `@jakarta.inject.Inject` | `@com.google.inject.Inject` |
| `@jakarta.inject.Named` | `Names.named()` |
| `@jakarta.inject.Singleton` | Guice `SINGLETON` scope |
| `@jakarta.enterprise.context.ApplicationScoped` | Guice `SINGLETON` scope |
| `@jakarta.inject.Qualifier` | Guice binding annotation |

## CDI Provider Chain

```java
CDI.current()
 → JakartaCDIProvider.getCDI()
   → GuicedCDI.select(Class<T>)
     → IGuiceContext.get(Class<T>)  // Guice injector lookup
```

## BeanManager

The `GuiceCDIBeanManager` provides a simplified bean lookup API:

```java
@Inject
private GuiceCDIBeanManager beanManager;

MyService svc = beanManager.getBean(MyService.class);
MyService svc = beanManager.getBean(MyService.class, "primary"); // @Named
boolean exists = beanManager.containsBean(MyService.class);
```

## SPI Providers

| SPI | Purpose |
|---|---|
| `BindScopeProvision` | `@Singleton`, `@ApplicationScoped` → `SINGLETON` |
| `InjectionPointProvision` | `@Inject`, `@Named`, `@PostConstruct` detection |
| `BindingAnnotationsProvision` | `@Qualifier` as binding annotation |
| `NamedAnnotationProvision` | `jakarta.inject.Named` → `Names.named()` |
| `InjectorAnnotationsProvision` | `jakarta.inject.Inject` recognition |

## Non-Negotiable Constraints

- Module must `requires com.guicedee.cdi;`.
- The CDI module is loaded automatically — no `provides` needed in your application module.
- Injection packages must `opens` to `com.google.guice`.


