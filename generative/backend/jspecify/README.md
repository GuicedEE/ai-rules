# JSpecify — Nullness Annotations (Java)

Use JSpecify to add precise, tool-friendly nullness contracts to your Java APIs and implementations. It enables static analysis (IDE/compiler plugins) to catch null-related defects early and document intent without runtime cost.

Audience: Java library and service authors; consumers who want clear nullness semantics.

---

## What is JSpecify
- A set of standard, tool-agnostic annotations for nullness in Java.
- Key concepts:
  - @NullMarked at package or class level: default all references are non-null unless annotated otherwise.
  - @Nullable for values that may be null.
  - Type-use annotations for generics and arrays.
- JSpecify itself provides annotations only; validation is performed by IDEs/compilers/static analyzers that understand them.

References
- Homepage: https://jspecify.dev/
- Spec/FAQ: https://jspecify.dev/docs

---

## When to use
- Public APIs (libraries or services) where caller expectations must be unambiguous.
- Codebases adopting a “non-null by default” policy (@NullMarked) to prevent accidental nulls.
- Interoperability with Kotlin/TypeScript or cross-service contracts where nullability must be explicit.

---

## Versions and compatibility
- Java: recommended Java 17+ (works with earlier versions supporting type-use annotations).
- Analyzers/IDEs: JetBrains IntelliJ, Error Prone, Checker Framework, and other tools are adding/offer support. Check your toolchain docs.
- Runtime: annotations are CLASS/bytecode-only, no runtime behavior by default.

---

## Setup

Maven (annotations as compileOnly):
```xml
<dependency>
  <groupId>org.jspecify</groupId>
  <artifactId>jspecify</artifactId>
  <version>1.0.0</version>
  <scope>provided</scope>
</dependency>
```

Gradle (Kotlin DSL):
```kotlin
dependencies {
  compileOnly("org.jspecify:jspecify:1.0.0")
  annotationProcessor("org.jspecify:jspecify:1.0.0") // if your analyzer requires
}
```

Javac usage (example flags vary by analyzer):
- Error Prone: enable the nullness checker and configure JSpecify semantics.
- Checker Framework: use the Nullness Checker with JSpecify mode.

Consult your analyzer’s documentation for exact flags.

---

## Rules and guides in this topic
- Rules — ./jspecify.rules.md
- Examples — ./examples.md

See also (related Structural topics)
- Lombok — ../lombok/README.md
- MapStruct — ../mapstruct/README.md
- Logging — ../logging/README.md

Architecture cross-links
- DDD — ../../architecture/ddd/README.md

Back-links
- Master Backend index — ../README.md
- Repository RULES — ../../../RULES.md (see anchors in root RULES.md)
