# Kotlin — Language Topic Index

This directory provides Kotlin-focused backend guidance optimized for AI-assisted code generation and human maintenance. Use it when your host project targets the JVM and prefers Kotlin for services, libraries, or reactive applications.

## How to use this index
- Prefer the modular entry below for quick, enforceable guidance.
- Start with the consolidated rules, then branch to stack-specific guidance from linked backend topics (e.g., Vert.x 5, Security, Logging).
- When interoperating with Java modules, align null-safety with JSpecify rules and use Gradle Kotlin DSL consistently.

## Modular Core (recommended)
- Overview & Consolidated Rules — ./kotlin.rules.md

## Notes
- This topic follows the Document Modularity Policy: lean, linkable, and task-oriented. Deep-dive narratives are avoided; instead, rules and quick-start patterns are provided.
- Kotlin interop with Java-centric libraries (Hibernate Reactive, MapStruct, Lombok) is addressed via constraints and adapters instead of mirroring Java-only features.
- Native-first policy: prefer Kotlin stdlib and kotlinx.* (serialization, coroutines, datetime) over third-party libraries. Use alternatives (e.g., Jackson) only when required by shared infrastructure or external SDKs.

## See also
- Backend category index — ../../backend/README.md
- Vert.x 5 — ../../backend/vertx/README.md
- Security (Reactive) — ../../backend/security-reactive/README.md
- Logging — ../../backend/logging/README.md
- MapStruct — ../../backend/mapstruct/README.md
- JSpecify — ../../backend/jspecify/README.md
- Platform: Security & Auth — ../../platform/security-auth/README.md
- Platform: Secrets & Config — ../../platform/secrets-config/README.md