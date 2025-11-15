# Java — Language Topic Index

This directory provides Java language guidance aligned to LTS baselines and AI-friendly project setup. Choose the version-specific rules for enforceable conventions, toolchains, and migration notes.

How to use this index
- Pick your baseline (17, 21, or 25) and apply the corresponding rules.
- Use toolchains to enforce the Java version in build and CI (see ./build-tooling.md).
- Link to backend stack topics (Vert.x, Hibernate, Security) for framework-specific guidance.

Versions
- Java 17 LTS — ./java-17.rules.md
- Java 21 LTS — ./java-21.rules.md
- Java 25 LTS — ./java-25.rules.md

Notes
- Default to GA features only; avoid preview features unless explicitly justified and consistently enabled across build, run, and test.
- Prefer JPMS (module-info.java) for library modules; keep clear boundaries and exports.
- Align nullness with JSpecify when interoperating with Kotlin or enforcing null contracts.

See also
- Language index — ../README.md
- Build Tooling — ./build-tooling.md
- Backend category index — ../../backend/README.md
- Vert.x 5 — ../../backend/vertx/README.md
- Security (Reactive) — ../../backend/security-reactive/README.md
- Logging — ../../backend/logging/README.md
- JSpecify — ../../backend/jspecify/README.md
- Platform: Security & Auth — ../../platform/security-auth/README.md
- Platform: Secrets & Config — ../../platform/secrets-config/README.md