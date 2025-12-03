# Component Rules Index

**Version:** 1.0  
**Effective Date:** December 3, 2025  
**Composition:** Modular component-specific rules (one file per component)  
**Location:** Enterprise Rules Repository (rules/generative/frontend/jwebmp/webawesome-pro/)

---

## Overview

This directory contains modular, component-specific rules files for the WebAwesome Pro library. Each file follows a consistent template covering overview, JWebMP Java class, usage patterns, inputs/outputs, slot projection, styling, accessibility, and cross-references.

### Purpose
- **Single Component per File:** Each rule file documents one component in depth
- **Topic-First Design:** Components are grouped by domain (layout, form, etc.)
- **Enterprise Rule Links:** Each rule links to relevant enterprise rules (Java, Angular, etc.)
- **Forward-Only Evolution:** Rules are updated; old versions are not maintained

---

## Component Rules Files

### Phase 2: Core Layout Components ✅

| Component | File | Status | Phase | Description |
|-----------|------|--------|-------|-------------|
| **WaPage** | [wa-page.rules.md](wa-page.rules.md) | ✅ Complete | 2 | Primary layout container with 18 sub-components (11 layout, 7 control) |
| **WaPageHeader** | [wa-page-header.rules.md](wa-page-header.rules.md) | ✅ Complete | 2 | Main header area |

### Phase 3: Form Input Components (Planned)

| Component | File | Status | Phase | Description |
|-----------|------|--------|-------|-------------|
| **WaInput** | [wa-input.rules.md](wa-input.rules.md) | ⏳ Planned | 3 | Form input field component |
| **WaSelect** | [wa-select.rules.md](wa-select.rules.md) | ⏳ Planned | 3 | Dropdown select component |
| **WaButton** | [wa-button.rules.md](wa-button.rules.md) | ⏳ Planned | 3 | Action button component |

### Phase 3: Layout Components (Planned)

| Component | File | Status | Phase | Description |
|-----------|------|--------|-------|-------------|
| **WaCluster** | [wa-cluster.rules.md](wa-cluster.rules.md) | ⏳ Planned | 3 | Horizontal layout container |
| **WaStack** | [wa-stack.rules.md](wa-stack.rules.md) | ⏳ Planned | 3 | Vertical layout container |
| **WaIconButton** | [wa-icon-button.rules.md](wa-icon-button.rules.md) | ⏳ Planned | 3 | Icon-only button component |

---

## Component Rule File Template

Each component rule file follows this standard structure:

```markdown
# WaComponent Rules

## Overview
[Purpose, key use cases, place in component hierarchy]

## JWebMP Java Class
- Canonical name: `com.jwebmp.webawesomepro.components.<domain>.WaComponent`
- Module: `com.jwebmp.webawesomepro`
- Extends: `ComponentBase`

## Usage Patterns (CRTP Fluent API)
[Code examples using CRTP fluent setters]

## Inputs & Outputs (Angular Directive)
[For Angular: @Input properties (camelCase), @Output EventEmitters (past-tense verbs)]

## Slot Projection
[Named slots for ng-content; semantic HTML attributes (e.g., `[waComponentSlot]`)]

## Styling & Theming
[CSS custom properties, WebAwesome variant support]

## Accessibility
[ARIA roles, keyboard navigation, screen-reader considerations]

## See Also
[Parent index, related rules, architecture reference]
```

---

## Cross-Links to Enterprise Rules Repository

When implementing components, reference these enterprise rules for language/framework guidance:

**Frontend & Components:**
- WebAwesome Components: `rules/generative/frontend/webawesome/README.md`
- JWebMP Client: `rules/generative/frontend/jwebmp/client/README.md`
- Angular (Base): `rules/generative/language/angular/README.md`
- Angular Awesome: `rules/generative/frontend/angular-awesome/README.md`

**Backend & Infrastructure:**
- GuicedEE Client: `rules/generative/backend/guicedee/client/README.md`
- Fluent API (CRTP): `rules/generative/backend/fluent-api/crtp.rules.md`
- Logging (Log4j2): `rules/generative/backend/logging/README.md`

**Build & Language:**
- Java 25 LTS: `rules/generative/language/java/java-25.rules.md`
- TypeScript: `rules/generative/language/typescript/README.md`

**Architecture & Process:**
- Documentation-as-Code: `rules/generative/architecture/README.md`
- TDD: `rules/generative/architecture/tdd/README.md`

---

## Phase Progression

### Phase 1: Foundation ✅ (Complete)
- Architecture documentation (C4, sequences, ERD)
- PACT, RULES, GLOSSARY, GUIDES, IMPLEMENTATION
- Strategic docs are tightly interlinked

### Phase 2: WaPage Component ✅ (Complete)
- WaPage primary layout with 18 sub-components
- 13 comprehensive JUnit 5 tests (80%+ coverage)
- Angular integration via angular-awesome
- 2 component rule files created (WaPage, WaPageHeader; others referenced in wa-page.rules.md)

### Phase 3: Additional Enterprise Components (Next)
- Create rule files for WaInput, WaSelect, WaButton (form components)
- Create rule files for WaCluster, WaStack, WaIconButton (layout components)
- Implement component wrappers following WaPage CRTP pattern
- Add unit tests for each component
- Update GUIDES.md with component-specific examples

### Phase 4: Production Release (Future)
- Complete Phase 3 implementation
- GitHub Actions CI/CD pipeline
- Release to Maven Central

---

**Last Updated:** December 3, 2025  
**Version:** 1.0  
**Status:** Phase 2 Complete (2 rules created); Phase 3 Planned  
**Approval:** Blanket approval (Enterprise Rules)
