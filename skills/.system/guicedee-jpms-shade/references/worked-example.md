# Worked Example: graphql-java + java-dataloader

The GuicedEE `graphql` module (`com.guicedee.vertx.graphql`) required two automatic modules pulled
transitively by `io.vertx:vertx-web-graphql`:
- `com.graphqljava` (from `com.graphql-java:graphql-java`)
- `org.dataloader` (from `com.graphql-java:java-dataloader`)

Both were converted to named `com.guicedee.modules.services` shades.

## Facts discovered
- Vert.x `5.1.0` → `vertx-web-graphql` declares `graphql.java.version = 26.0`.
- `graphql-java:26.0` manifest `Automatic-Module-Name: com.graphqljava`; it **internally relocates**
  ANTLR (`graphql.org.antlr.*`) and Guava (`graphql.com.google.common.*`) — those are NOT exported.
- `graphql-java:26.0` compile deps: `java-dataloader:6.0.0`, `reactive-streams:1.0.3`, `jspecify:1.0.0`.
- `java-dataloader:6.0.0` manifest `Automatic-Module-Name: org.dataloader`; deps: `reactive-streams`,
  `jspecify`. Packages: `org.dataloader[.annotations|.impl|.instrumentation|.reactive|.registries|.scheduler|.stats|.stats.context]`.

## Result module descriptors
```
org.dataloader
  requires transitive org.reactivestreams
  requires static org.jspecify
  exports org.dataloader (+ 8 subpackages)

com.graphqljava
  requires transitive org.dataloader
  requires transitive org.reactivestreams
  requires static org.jspecify
  exports graphql + ~46 public packages (NOT graphql.com.google.* / graphql.org.antlr.*)
```

## Files touched
- Created `GuicedEE/services/Libraries/java-dataloader/` (pom + `src/moditect/module-info.java`).
- Created `GuicedEE/services/Libraries/graphql-java/` (depends on the shaded `java-dataloader`,
  excludes `java-dataloader`/`reactive-streams`/`jspecify` from upstream `graphql-java`).
- `Versioner`: `graphql.java.version=26.0`, `java.dataloader.version=6.0.0`, `reactive.streams.version=1.0.3`.
- `StandaloneBOM`: managed upstream `graphql-java`, `java-dataloader`, `reactive-streams`.
- `guicedee-bom`: managed `com.guicedee.modules.services:graphql-java` and `:java-dataloader`.
- Root `DevSuite/pom.xml` `services` profile: added both modules.
- `services/services.md`: added a GraphQL mapping table.
- `graphql/pom.xml`: excluded `graphql-java` + `java-dataloader` from `vertx-web-graphql`, added
  `com.guicedee.modules.services:graphql-java`. The `module-info.java` was unchanged (same module names).

## Validation that confirmed success
- `mvn -N install` of Versioner, StandaloneBOM, guicedee-bom (SNAPSHOTs must be refreshed first).
- `mvn install` of `java-dataloader` then `graphql-java` shades → BUILD SUCCESS.
- `jar --describe-module` showed both named modules with the expected `requires`/`exports`.
- `mvn -o clean compile` of `graphql` → compiled with `[debug release 25 module-path]`, BUILD SUCCESS.

## Key lesson
The consumer's `module-info.java` already said `requires com.graphqljava; requires org.dataloader;`.
Because the shades reuse the upstream Automatic-Module-Name verbatim, the descriptor needed no edit —
only the POM dependency wiring changed, swapping automatic JARs for named modules.

## Runtime gotcha caught by the GraphQL tests (relocated Guava → java.logging)
First pass compiled and `jar --describe-module` was clean, but the GuicedEE `graphql` module tests
failed at runtime with:
```
IllegalAccessError: class graphql.com.google.common.collect.Platform (in module com.graphqljava)
cannot access class java.util.logging.Logger (in module java.logging) because module com.graphqljava
does not read module java.logging
```
graphql-java relocates Guava under `graphql.com.google.*`, and `Platform` uses
`java.util.logging.Logger`. As an automatic module graphql-java implicitly read every module; as a
named module it does not. Fix: add `requires java.logging;` to the `com.graphqljava` module-info,
rebuild the shade, reinstall. The GuicedEE graphql suite then went 7/7, and the ActivityMaster cerial
GraphQL integration test (real DB) passed 4/4. Lesson: ALWAYS run the consumer integration tests
after shading — compile-time checks cannot catch missing JDK `requires` for relocated code.

