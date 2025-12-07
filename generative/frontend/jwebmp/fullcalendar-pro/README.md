# FullCalendar Pro (JWebMP Extension) — Topic Index

Use this topic when maintaining the JWebMP wrapper that extends FullCalendar 6.1.19 with the official Pro resource/timeline plugins and the GuicedEE client wiring described in the host module. The documents here assume the same stage-gated, forward-only workflow enforced by the Rules Repository and rely on the architecture diagrams under `docs/architecture/` for context.

Scope and policy
- Documentation-first, forward-only, and CRTP-driven: keep every change aligned with `rules/PROMPT_ADOPT_EXISTING_PROJECT.md`, `PACT.md`, and the architecture/diagram sources, then update the loop helpers (`GLOSSARY.md`, `RULES.md`, `GUIDES.md`, `IMPLEMENTATION.md`) in the same change set.
- Stack: Java 25 LTS + Maven, JWebMP Core/Client/TypeScript/Angular 20, GuicedEE client wiring, CRTP fluent APIs (no Lombok `@Builder`), Log4j2, JSpecify nullness, Jacoco, Java Micro Harness, BrowserStack, and GitHub Actions (see the relevant `rules/generative/` topics for each).
- FullCalendar Pro augments the base wrapper (`rules/generative/frontend/jwebmp/fullcalendar/README.md`) with premium plugins (resourceDayGrid, resourceTimeGrid, resourceTimeline, adaptive) plus the Angular template hooks that surface GuicedEE resources/events via WebSocket listeners.
- Architecture diagrams live in `docs/architecture/c4-context.md`, `c4-container.md`, `c4-component-fullcalendar-pro.md`, `sequence-package-fullcalendar.md`, `sequence-runtime-wiring.md`, and `erd-core-domain.md`. Use the Mermaid MCP server at `https://mcp.mermaidchart.com/mcp` when regenerating diagrams.
- Prompt Reference: `docs/PROMPT_REFERENCE.md` records the selected stacks and must be loaded before drafting new instructions for this topic.

Topics
- Overview & purpose — `./overview.rules.md`
- Options, layout, and template hooks — `./options-and-layout.rules.md`
- Event/resourcing & WebSocket flows — `./events-and-resources.rules.md`
- Angular integration & subscription wiring — `./angular-integration.rules.md`
- Testing and validation strategy — `./testing.rules.md`
- Release notes & migration guidance — `./release-notes.md`
- Glossary (topic-first) — `./GLOSSARY.md`

See also
- Frontend index — `../../README.md`
- JWebMP base index — `../README.md`
- FullCalendar wrapper — `../fullcalendar/README.md`
- Angular language base & Angular 20 override — `../../../language/angular/README.md`, `../../../language/angular/angular-20.rules.md`
- TypeScript language rules — `../../../language/typescript/README.md`
- Platform testing — `../../../platform/testing/README.md`, `../../../platform/testing/jacoco.rules.md`, `../../../platform/testing/java-micro-harness.rules.md`, `../../../platform/testing/browserstack.rules.md`
- CI/CD & GitHub Actions — `../../../platform/ci-cd/README.md`, `../../../platform/ci-cd/providers/github-actions.md`
- Logging — `../../../backend/logging/LOGGING_RULES.md`
- GuicedEE client wiring — `../../../backend/guicedee/client/README.md`
