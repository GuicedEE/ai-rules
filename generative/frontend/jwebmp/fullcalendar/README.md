# FullCalendar (JWebMP Wrapper) — Topic Index

Use this topic when generating or maintaining the JWebMP FullCalendar wrapper (FullCalendar 6.1.19 with the official Angular plugin) under Java 25 LTS. Apply it with JWebMP Core/Client/TypeScript/Angular rules, CRTP fluent APIs, Log4j2 logging, and forward-only documentation-first workflow.

Scope and policy
- Documentation-first, forward-only; stage gates are auto-approved per blanket approval in PROMPT_ADOPT_EXISTING_PROJECT.md but must remain traceable in Pact/Guides/Implementation.
- Stack: Java 25 LTS, Maven, JWebMP Core/Client/TypeScript/Angular 20, FullCalendar 6.1.19, Log4j2, JSpecify nullness, CRTP setters (no builders).
- Generated Angular/TypeScript artifacts are read-only; adjust Java CRTP models (`FullCalendarOptions`, events, resources) and let JSON serialization feed the client.
- Architecture diagrams live under `../../../../../docs/architecture/` (context/container/component/sequence); keep rule changes aligned to observed code and diagrams.
- MCP: Mermaid MCP available at https://mcp.mermaidchart.com/mcp; load per selected engines (Junie, Copilot, ChatGPT, Codex, AI Assistant).

How to use this index
- Start with Overview, then follow the module relevant to your change. Keep glossary/prompt language alignment in sync.
- Anchor CRTP setters and JSON contract changes to diagrams and Pact entries before modifying code.

Topics
- Overview and scope — ./overview.rules.md
- Options, layout, and localization — ./options-and-layout.rules.md
- Events, sources, and resources — ./events-and-resources.rules.md
- Angular bridge and data flow — ./angular-integration.rules.md
- Testing and validation — ./testing.rules.md
- Release and migration notes — ./release-notes.md
- Glossary (topic-first) — ./GLOSSARY.md

See also
- Frontend index — ../../README.md
- JWebMP index — ../README.md and ../angular/README.md, ../client/README.md, ../typescript/README.md, ../core/README.md
- Angular language base and 20 override — ../../../language/angular/README.md and ../../../language/angular/angular-20.rules.md
- TypeScript language base — ../../../language/typescript/README.md
- Platform testing — ../../../platform/testing/README.md, ../../../platform/testing/jacoco.rules.md, ../../../platform/testing/java-micro-harness.rules.md, ../../../platform/testing/browserstack.rules.md
- CI/CD — ../../../platform/ci-cd/README.md and ../../../platform/ci-cd/providers/github-actions.md
