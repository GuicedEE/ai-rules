---
name: guicedee-cdi
description: "Bridge Jakarta CDI annotations, scopes, BeanManager lookups, and CDI libraries into GuicedEE's Guice container."
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

## Scope boundaries

The built-in `BindScopeProvision` maps `@Singleton` and `@ApplicationScoped` to a singleton in the local injector. It does not replicate objects across nodes or automatically implement CDI request/session lifetimes. Custom scopes need an actual `Scope` binding and application-owned entry/exit.

The shaded Guice implementation supports a scope annotation on an injected constructor parameter or field. This wraps the existing binding scope and caches by consuming injection group, scope annotation, and dependency key. Method-injection and provider-method parameters do not have this local-scope behavior. Register custom scope meta-annotations through `ScopeAnnotationProvider` and concrete scope bindings through `BindScopeProvider`; a meta-annotation alone is insufficient.

## Module requirements

- Module must `requires com.guicedee.cdi;`.
- The CDI module is loaded automatically — no `provides` needed in your application module.
- Injection packages must `opens` to `com.google.guice`.


