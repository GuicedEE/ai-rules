# Dependency & Integration Map

Library scope: JWebMP Typescript Client Library that scans Ng* annotations and renders Angular 20 metadata. This map shows trusted boundaries and upstream/downstream dependencies observed in the code.

```mermaid
flowchart LR
    Host[JWebMP host app<br/>annotated classes]:::trusted
    Library[[Typescript Client Library]]:::trusted
    AnnPkg[/Ng* annotations<br/>interfaces/]:::trusted
    Scanner[AnnotationHelper<br/>ClassGraph scan]:::trusted
    Config[Configuration builders<br/>(ComponentConfiguration,<br/>AbstractNgConfiguration)]:::trusted
    Renderer[Render helpers<br/>renderOnInit/Fields/etc.]:::trusted
    Guice[GuicedEE / Guice]:::infra
    Vertx[Vert.x worker pool]:::infra
    ClassGraph[ClassGraph]:::infra
    Log4j2[Log4j2 + Lombok @Log4j2]:::infra
    TSChain[Angular TypeScript build chain]:::consumer

    Host --> AnnPkg
    AnnPkg --> Scanner
    Scanner --> Config
    Config --> Renderer
    Renderer --> TSChain

    Library --> Guice
    Library --> Vertx
    Scanner --> ClassGraph
    Library --> Log4j2

    classDef trusted fill:#0b7285,stroke:#053743,stroke-width:1,color:#f8f9fa;
    classDef infra fill:#f6f1eb,stroke:#8b6a3c,stroke-width:1,color:#2c1b0f;
    classDef consumer fill:#e3fafc,stroke:#0b7285,stroke-width:1,color:#0b7285;
```

Trust boundaries
- Host app annotations are inputs; scanning and rendering occur inside trusted library/Guice/Vert.x workers.
- Generated TypeScript is a build-time artifact consumed by the downstream Angular toolchain; do not treat it as runtime input.
- Logging stays within Log4j2; no external network calls are present in the observed code.

Dependencies (observed in code)
- Internal: Ng* annotation packages, `AnnotationHelper`, `AnnotationsMap`, configuration builders, render helpers.
- External libraries: GuicedEE/Guice lifecycle, Vert.x blocking worker execution, ClassGraph scanning, Lombok (CRTP + `@Log4j2`), Log4j2 backend.
- CI/build: Maven + Java 25; GitHub Actions workflow `.github/workflows/maven-package.yml` invokes GuicedEE shared workflow.
