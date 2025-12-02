# JWebMP AgGrid Plugin Rules & Guides

**A comprehensive, modular rules repository for the JWebMP AG Grid Plugin** — v2.0.0

---

## Overview

The **JWebMP AgGrid Plugin** provides a Java-first, server-driven approach to building reactive data grids for modern web applications. This rules directory maintains the authoritative guidance for using, extending, and deploying AgGrid in JWebMP projects.

### Key Resources

- **Product & Architecture Contract**: [../../../../../../PACT.md](../../../../../../PACT.md)
- **Technology Rules**: [../../../../../../RULES.md](../../../../../../RULES.md)
- **How-To Guides**: [../../../../../../GUIDES.md](../../../../../../GUIDES.md)
- **Code Layout & Implementation**: [../../../../../../IMPLEMENTATION.md](../../../../../../IMPLEMENTATION.md)
- **Glossary (Topic-First)**: [./GLOSSARY.md](./GLOSSARY.md) — *canonical for AgGrid terminology*
- **Quick Reference**: [./QUICK_REFERENCE.md](./QUICK_REFERENCE.md) — *checklists, templates, troubleshooting*

---

## Module Index

### Core Concepts

1. **[grid-configuration.rules.md](./grid-configuration.rules.md)**
   - CRTP fluent API for grid setup
   - AgGridOptions, themes, row selection, pagination
   - Example: Creating a basic grid with sorting/filtering

2. **[column-definitions.rules.md](./column-definitions.rules.md)**
   - AgGridColumnDef structure
   - Built-in column types (text, number, date, boolean)
   - Custom column filtering and sorting

3. **[cell-renderers.rules.md](./cell-renderers.rules.md)**
   - Custom cell renderers as Angular components
   - Renderer registration and lifecycle
   - Built-in vs. custom examples (badges, buttons, links)

4. **[headers.rules.md](./headers.rules.md)**
   - Custom header components
   - Header filtering and grouping
   - Accessibility considerations

### Advanced Features

5. **[data-binding.rules.md](./data-binding.rules.md)**
   - Server-side data fetching (fetchData pattern)
   - WebSocket integration for real-time updates
   - Pagination and virtual scrolling

6. **[event-handling.rules.md](./event-handling.rules.md)**
   - Row selection callbacks (onRowSelectJS)
   - Cell click events, double-click handling
   - Custom event routing to server

7. **[styling-theming.rules.md](./styling-theming.rules.md)**
   - AG Grid community themes (alpine, balham, quartz, etc.)
   - Custom CSS overrides for grid layout and cell styling
   - Responsive grid design

8. **[validation.rules.md](./validation.rules.md)**
   - Server-side validation of grid requests (sort, filter, page params)
   - Bean Validation annotations on AgGridOptions
   - Error handling and user feedback

### Backend Integration

9. **[websocket-integration.rules.md](./websocket-integration.rules.md)**
   - WebSocket receivers extending WebSocketAbstractCallReceiver
   - GuicedEE service discovery and registration
   - Message serialization and routing

10. **[dependency-injection.rules.md](./dependency-injection.rules.md)**
    - GuicedEE IoC for grid instances
    - PageConfigurator pattern for plugin lifecycle
    - Accessing grid from service layer

### Frontend Integration

11. **[angular-component-integration.rules.md](./angular-component-integration.rules.md)**
    - Grid as Angular component (extends DivSimple<J>)
    - AgGridAngular module setup and imports
    - Lifecycle hooks (ngAfterViewInit, ngOnDestroy)

12. **[typescript-bindings.rules.md](./typescript-bindings.rules.md)**
    - JWebMP TypeScript client for grid API
    - Annotation-driven type generation
    - Strict TypeScript mode requirements

### Testing & Quality

13. **[testing-strategy.rules.md](./testing-strategy.rules.md)**
    - Unit tests for grid configuration
    - Integration tests with test harness (jwebmp-testlib)
    - WebSocket mock receiver testing

14. **[code-quality.rules.md](./code-quality.rules.md)**
    - Jacoco coverage targets (≥80%)
    - SonarQube quality gates
    - Code style and naming conventions

### Deployment & CI/CD

15. **[cicd-integration.rules.md](./cicd-integration.rules.md)**
    - GitHub Actions workflow for Maven build
    - Automated test and coverage reporting
    - Artifact publishing to Maven Central

16. **[performance.rules.md](./performance.rules.md)**
    - Grid initialization optimization (<500ms target)
    - Virtual scrolling and server-side pagination
    - WebSocket batch updates (50+ updates/sec)
    - Memory management and leak prevention

17. **[security.rules.md](./security.rules.md)**
    - CSRF protection with Spring Security
    - XSS prevention with Angular sanitization
    - Input validation and parameterized queries
    - Access control and audit logging

18. **[typescript-bindings.rules.md](./typescript-bindings.rules.md)**
    - Generated TypeScript interfaces from Java
    - OpenAPI/Swagger code generation
    - Type-safe Angular service integration
    - Consumer-driven contract testing

19. **[migration-and-upgrade.rules.md](./migration-and-upgrade.rules.md)**
    - Semantic versioning strategy
    - Breaking changes policy and migration paths
    - Upgrade guide: 1.x → 2.0
    - Deprecation timeline
    - Version upgrade checklist

### Quick Reference & Troubleshooting

20. **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)**
    - Development checklists and templates
    - Code snippets for common tasks
    - Performance quick wins
    - Security checklist

21. **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**
    - Common issues and diagnosis steps
    - WebSocket connection problems
    - Performance optimization tips
    - Security issue solutions
    - Testing and deployment troubleshooting

### Topic Glossary

- **[GLOSSARY.md](./GLOSSARY.md)** — Canonical terminology for AgGrid and JWebMP integration

---

## Common Scenarios & Quick Links

### "I want to build a CRUD grid with a custom status column"
→ Start with [grid-configuration.rules.md](./grid-configuration.rules.md), then [cell-renderers.rules.md](./cell-renderers.rules.md)

### "I need real-time data updates when the server changes"
→ Read [data-binding.rules.md](./data-binding.rules.md) + [websocket-integration.rules.md](./websocket-integration.rules.md) + [performance.rules.md](./performance.rules.md) (batch updates)

### "How do I handle row selection and trigger server actions?"
→ See [event-handling.rules.md](./event-handling.rules.md)

### "I want to customize the grid look and feel"
→ Consult [styling-theming.rules.md](./styling-theming.rules.md)

### "How do I test my grid component?"
→ Follow [testing-strategy.rules.md](./testing-strategy.rules.md)

### "I need to optimize grid performance for 10K+ rows"
→ Read [performance.rules.md](./performance.rules.md) (virtual scrolling, pagination, WebSocket batching)

### "How do I secure the grid data and prevent attacks?"
→ See [security.rules.md](./security.rules.md) (CSRF, XSS, validation, access control)

### "I'm upgrading from AgGrid v1.x to v2.0"
→ Follow [migration-and-upgrade.rules.md](./migration-and-upgrade.rules.md) (breaking changes, step-by-step guide)

### "How do I generate TypeScript bindings for my grid API?"
→ See [typescript-bindings.rules.md](./typescript-bindings.rules.md) (OpenAPI, type-safe services)

### "I want to set up CI/CD for grid development"
→ Read [cicd-integration.rules.md](./cicd-integration.rules.md) (GitHub Actions, Maven Central publishing)

---

## Related Enterprise Rules

The AgGrid plugin integrates with multiple enterprise rule topics. Host projects using AgGrid should link to:

### Frontend & Framework Rules
- **JWebMP Core**: [../../jwebmp/README.md](../../jwebmp/README.md) — component lifecycle, page configurators
- **JWebMP Client**: [../../jwebmp/client/README.md](../../jwebmp/client/README.md) — interception, rendering, reactive patterns
- **JWebMP TypeScript**: [../../jwebmp/typescript/README.md](../../jwebmp/typescript/README.md) — type generation, client-side APIs
- **Angular 20**: [../../../language/angular/angular-20.rules.md](../../../language/angular/angular-20.rules.md) — component lifecycle, modules, RxJS
- **Web Components**: [../../webcomponents/README.md](../../webcomponents/README.md) — shadow DOM, custom elements (if using AG Grid Web Components variant)

### Backend Rules
- **Vert.x 5**: [../../../backend/vertx/README.md](../../../backend/vertx/README.md) — non-blocking I/O, WebSocket
- **GuicedEE**: [../../../backend/guicedee/README.md](../../../backend/guicedee/README.md) — dependency injection, service discovery
- **Fluent API (CRTP)**: [../../../backend/fluent-api/crtp.rules.md](../../../backend/fluent-api/crtp.rules.md) — type-safe builders
- **Logging**: [../../../language/java/logging.md](../../../language/java/logging.md) — Log4j2 configuration
- **JSpecify**: [../../../language/java/jspecify.md](../../../language/java/jspecify.md) — nullness annotations

### Data & Persistence
- **Hibernate (ORM)**: [../../../backend/hibernate/README.md](../../../backend/hibernate/README.md) — entity mapping, queries (for data fetching)
- **Reactive Persistence**: [../../../backend/guicedee/persistence/README.md](../../../backend/guicedee/persistence/README.md) — async data access

### Testing
- **Java Testing**: [../../../platform/testing/README.md](../../../platform/testing/README.md) — JUnit 5, test harness
- **Coverage (Jacoco)**: [../../../platform/testing/coverage.md](../../../platform/testing/coverage.md) — coverage configuration

### Platform & DevOps
- **CI/CD (GitHub Actions)**: [../../../platform/ci-cd/providers/github-actions.md](../../../platform/ci-cd/providers/github-actions.md)
- **Secrets & Config**: [../../../platform/secrets-config/env-variables.md](../../../platform/secrets-config/env-variables.md)

---

## Glossary & Terminology

### Topic-First Glossary Policy

**This repository maintains the authoritative glossary for AgGrid terminology.** Host projects adopting AgGrid **MUST link to this topic glossary** for all AgGrid-specific terms rather than duplicating them.

- **Host Project Glossary Integration**: Host projects should include an anchor in their root `GLOSSARY.md` that reads:
  ```markdown
  ## AgGrid Terminology
  
  For AgGrid-specific terms (grid, renderer, column definition, etc.), see the topic glossary:
  [AgGrid Topic Glossary](./rules/generative/frontend/jwebmp/aggrid/GLOSSARY.md)
  ```

- **Enforced Prompt Language Alignment** (copied to host projects):
  - `AgGrid` = Java class wrapping AG Grid (e.g., `new AgGrid().setHeight("500px")`)
  - `AgGridOptions` = Configuration object serialized to Angular
  - `AgGridColumnDef` = Column definition (Java → JSON → AG Grid ColDef)
  - `ICellRenderer` = Custom cell renderer interface
  - `WebSocketAbstractCallReceiver` = Backend handler for grid events

For complete glossary, see [GLOSSARY.md](./GLOSSARY.md).

---

## Fluent API Strategy: CRTP

This plugin uses **CRTP (Curiously Recurring Template Pattern)** for type-safe fluent APIs. See [grid-configuration.rules.md](./grid-configuration.rules.md) for patterns and examples.

**Key Constraint**: No Lombok `@Builder` on grid classes; use manual CRTP setters instead.

---

## Documentation & Practices

### Alignment with Rules Repository Policies

All content in this rules directory adheres to:

1. **Specification-Driven Design (SDD)**: Every feature has a specification document
2. **Documentation-as-Code**: Diagrams as Mermaid/PlantUML text (version-controlled)
3. **Forward-Only Policy**: Deprecated features removed cleanly; no legacy stubs
4. **Topic-First Glossary**: Terms defined once here; linked everywhere else
5. **TDD/BDD**: Tests written first; acceptance criteria in rules

### File Naming Conventions

- `*.rules.md` — Topic-scoped rules and patterns
- `GLOSSARY.md` — Canonical terms for this topic
- `../../../GUIDES.md` — How-to examples (in host project, links to these rules)
- `../../../IMPLEMENTATION.md` — Code layout, key files (in host project)

### Link Format

- **Within this rules dir**: Relative paths (e.g., `[grid-configuration.rules.md](./grid-configuration.rules.md)`)
- **To enterprise rules**: Relative to rules root (e.g., `[JWebMP](../../jwebmp/README.md)`)
- **From host project docs**: Link via submodule path (e.g., `[AgGrid Rules](./rules/generative/frontend/jwebmp/aggrid/README.md)`)

---

## AI Assistant Guidance

### When to Reference This Rules Directory

Use these rules when:
- Generating AgGrid configuration code (CRTP fluent API)
- Creating custom cell renderers or headers
- Setting up WebSocket integration for real-time grids
- Debugging grid rendering or event handling
- Writing tests for grid components
- Integrating with Angular, Vert.x, or GuicedEE

### Prompt Language Alignment

When prompting an AI assistant to generate AgGrid code, use precise terminology from [GLOSSARY.md](./GLOSSARY.md):

- Say **"AgGrid"** (not "grid", "ag-grid", "data grid")
- Say **"AgGridOptions"** (not "grid config", "grid settings")
- Say **"AgGridColumnDef"** (not "column config", "column definition")
- Say **"ICellRenderer"** (not "custom cell", "renderer", "component")
- Say **"WebSocketAbstractCallReceiver"** (not "event handler", "listener")

Example prompt:
> Create a CRUD grid using AgGrid with a custom ICellRenderer for status badges. Use WebSocket integration for real-time updates when the server broadcasts changes.

---

## Document Metadata

- **Version**: 1.0
- **Created**: December 2, 2025
- **Last Updated**: December 2, 2025
- **Location**: `rules/generative/frontend/jwebmp/aggrid/`
- **Scope**: JWebMP AgGrid Plugin Rules & Guides
- **Target Audience**: Java developers, frontend engineers, architects
- **Related Prompts**:
  - [PROMPT_ADOPT_EXISTING_PROJECT.md](../../../../../../PROMPT_ADOPT_EXISTING_PROJECT.md) (for host projects)
  - [PROMPT_LIBRARY_RULES_UPDATE.md](../../../../../../PROMPT_LIBRARY_RULES_UPDATE.md) (for rules maintenance)

---

## Quick Navigation

| Audience | Start Here |
|----------|-----------|
| **New Users** | [grid-configuration.rules.md](./grid-configuration.rules.md) |
| **Backend Developer** | [websocket-integration.rules.md](./websocket-integration.rules.md) |
| **Frontend Developer** | [angular-component-integration.rules.md](./angular-component-integration.rules.md) |
| **QA / Test Engineer** | [testing-strategy.rules.md](./testing-strategy.rules.md) |
| **DevOps / Release** | [cicd-integration.rules.md](./cicd-integration.rules.md) |

---

## See Also

- **Product Intent & Architecture**: [PACT.md](../../../../../../PACT.md)
- **Technology Rules**: [RULES.md](../../../../../../RULES.md)
- **Implementation Guide**: [IMPLEMENTATION.md](../../../../../../IMPLEMENTATION.md)
- **Architecture Diagrams**: [docs/architecture/README.md](../../../../../../docs/architecture/README.md)
- **AI Reference**: [docs/PROMPT_REFERENCE.md](../../../../../../docs/PROMPT_REFERENCE.md)
