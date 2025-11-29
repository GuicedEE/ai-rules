# GuicedEE — Topic Index

Use this topic when you are working within the GuicedEE ecosystem. These guides cover GuicedEE services, functions, and integration patterns commonly used with Vert.x, Hibernate Reactive, and EntityAssist.

Guides
- Services — ./services/ (see representative docs like representations.md)
- Functions — ./functions/ (function helpers and utilities)

Subtopics
- Client Library — ./client/ (GuicedEE Inject Client specific rules, glossary, and examples)
- Vert.x Web Server — ./web/ (HTTP/HTTPS bootstrap, SPI configurators, router/server setup, env configuration)
- Guiced Vert.x Bridge — ./vertx/ (GuicedEE ↔ Vert.x integration rules, glossary, lifecycle/configuration/publisher guidance)

Recommended cross‑topics
- Backend/Hibernate (Reactive 7) — generative/backend/hibernate/README.md
- Data/EntityAssist — generative/data/entityassist/README.md
- Backend/Vert.x 5 — generative/backend/vertx/README.md
- Backend/JSpecify — generative/backend/jspecify/README.md

CI/CD standard (GitHub Actions)
- GuicedEE libraries should reuse the shared workflow `GuicedEE/Workflows/.github/workflows/projects.yml@master` with the `GuicedInjection` job.
- Required secrets: `USERNAME`, `USER_TOKEN`, `SONA_USERNAME`, `SONA_PASSWORD`. Pass `baseDir` and a descriptive `name` as inputs.
- Reference implementation:
```yaml
name: Maven Package
on:
  workflow_dispatch:
  push:
jobs:
  GuicedInjection:
    uses: GuicedEE/Workflows/.github/workflows/projects.yml@master
    with:
      baseDir: ''
      name: 'Guiced Injection'
    secrets:
      USERNAME: ${{secrets.USERNAME}}
      USER_TOKEN: ${{secrets.USER_TOKEN}}
      SONA_USERNAME: ${{secrets.SONA_USERNAME}}
      SONA_PASSWORD: ${{secrets.SONA_PASSWORD}}
```

See also
- Master index — generative/README.md
- RULES.md — Generative Topic Taxonomy; Document Modularity Policy
