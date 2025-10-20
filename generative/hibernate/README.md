# Hibernate 7 Reactive Topic Index

This directory contains standards and guides for Hibernate Reactive 7.x using Mutiny and Vert.x 5 in JPMS-aware projects. Use this index to navigate directly to the relevant modular document. Choose this topic when your host project specifies Hibernate Reactive 7 or when prompts reference Mutiny.Session/SessionFactory, Uni chaining, or non-blocking persistence.

## How to use this index
- Prefer the modular entries below for quick, AI-friendly guidance.
- Start with the Overview, then jump to Transactions, CRUD, Testing, or Threading as needed.
- If a prompt mentions a specific pattern (e.g., withTransaction, Testcontainers, anti-patterns), open that specific modular page.

## Modular Core (recommended)
- Overview — ./hibernate-7-reactive-overview.md
- Setup & Configuration — ./hibernate-7-reactive-setup.md
- SessionFactory — ./hibernate-7-reactive-session-factory.md
- Transactions — ./hibernate-7-reactive-transactions.md
- CRUD Patterns — ./hibernate-7-reactive-crud.md
- Testing (Testcontainers) — ./hibernate-7-reactive-testing.md
- Threading & Context — ./hibernate-7-reactive-threading.md
- Anti-Patterns — ./hibernate-7-reactive-antipatterns.md

## Notes
- This topic uses modular entry files optimized for generative AI; monolithic deep-dive docs have been removed per the Document Modularity Policy.
- Each modular page includes quick start snippets, patterns, and see-also links back to this index and to RULES.md where applicable.
- For upgrade specifics from older versions, see the upgrade guide if present in this folder.
