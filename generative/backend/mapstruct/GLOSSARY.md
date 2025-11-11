# MapStruct — Topic Glossary (Priority over root glossary)

Scope
- Minimal canonical terms for MapStruct in this topic. When this topic is referenced, these terms and directives take precedence over the root glossary. Keep entries concise and route to rules/guides for detail.

LLM interpretation guidance (how to apply these terms)
- Processor setup
  - Always configure the annotation processor (maven-compiler/gradle annotationProcessor). For JPMS, ensure mapper packages are opened to org.mapstruct.processor.
  - When using GuicedEE coordinates (com.guicedee.services:mapstruct), module name is org.mapstruct; behavior is identical to upstream with modular packaging.
- Mapper style
  - Prefer interface mappers annotated with @Mapper; compose mappings via default methods or helper mappers via uses = { … }.
  - For update operations, prefer in-place mapping via @MappingTarget rather than creating new objects when domain semantics require mutation.
- Null handling
  - Select NullValuePropertyMappingStrategy/NullValueMappingStrategy per domain; default is often fine, but set explicitly for clarity.
  - Avoid returning null collections/optionals; prefer empty instances (align with repository-wide conventions).
- Unrelated parameters and services (preferred: @Context)
  - For passing services, caches, cycle trackers, or any auxiliary state that is not part of the source/target domain model, prefer @Context parameters.
  - @Context provides a stable mechanism to thread unrelated items through mapping calls, including nested/iterable mappings.
  - Do not misuse source parameters solely to pass services; use @Context for those unrelated items.
- Expression vs helpers
  - Prefer dedicated helper methods (default or @Named) over expression strings, unless trivial constants/expressions.
- Inheritance and config
  - Promote reuse with @MapperConfig, @InheritConfiguration/@InheritInverseConfiguration across families of mappers.
- Builders and records
  - Configure @Mapper(builder = @Builder(...)) for builder-backed targets; ensure build method is named correctly. Records are supported directly (no builder).
- Mapping control and conditions
  - Use @Condition to guard property mapping; use @MappingControl for deeper behaviors (deep clone, ignore cycles) as needed.
- Collections and nested mapping
  - Use IterableMapping and MapMapping when specific element mappings, qualifiers, or null strategies are needed.

Routing
- Topic index — ./README.md
- Guide — ./mapstruct-6.md
- JSpecify nullness (Java interop) — ../jspecify/README.md

Canonical terms

- @Mapper
  - Meaning: Declares a mapper interface; MapStruct generates its implementation.
  - LLM: generate interface mappers; expose INSTANCE via Mappers.getMapper(...) only for simple apps; prefer DI where a framework exists.

- @Mapping
  - Meaning: Defines a source-to-target property mapping or mapping rule (different name, constant, ignore, expression).
  - LLM: use for name mismatches, constants, expressions; avoid complex expressions—extract helpers.

- @Mappings (legacy)
  - Meaning: Legacy container for multiple @Mapping; not required in modern MapStruct.
  - LLM: prefer multiple @Mapping annotations directly.

- @BeanMapping(ignoreByDefault = true)
  - Meaning: Start from an ignore-everything baseline; map only explicitly listed properties.
  - LLM: use for tight control or DTO projections.

- @InheritConfiguration / @InheritInverseConfiguration
  - Meaning: Reuse mapping configuration from another method; invert mappings for reverse conversion.
  - LLM: model pairs of DTO↔Entity conversions with inverse config; centralize rules.

- @MapperConfig
  - Meaning: Shared config for multiple mappers (componentModel, null strategies, builder, etc.).
  - LLM: create a single config per domain layer or project for consistent behavior.

- @Context (preferred for unrelated items)
  - Meaning: Pass unrelated items (services, caches, cycle tracker, formatting context) through mapping calls, including nested mappings.
  - LLM: prefer @Context for non-domain parameters. Example usage:
    - CycleAvoidingMappingContext to avoid graph recursion
    - Service lookups/converters
    - Request-scoped metadata
  - Do not add such items as source parameters; keep the signature semantically focused on source/target.

- @BeforeMapping / @AfterMapping
  - Meaning: Hooks to run before/after generated mapping logic; can accept @Context and/or @MappingTarget.
  - LLM: use for initialization, normalization, or post-processing that the generator cannot express succinctly.

- @MappingTarget
  - Meaning: Indicates in-place update into an existing target instance (void return).
  - LLM: prefer for patch/update semantics and performance when domain rules require mutation.

- @Named / @Qualifier / @QualifiedByName
  - Meaning: Tag helper methods for targeted use in @Mapping(qualifiedByName=...) or via custom qualifier annotations.
  - LLM: use for disambiguation and reusable conversions.

- IterableMapping / MapMapping
  - Meaning: Configure element mappings, qualifiers, and null strategies for collections/maps.
  - LLM: provide element mapper methods or qualifiers; avoid implicit conversions that hide errors.

- @Condition
  - Meaning: Predicate controlling whether a mapping should occur for a given source value.
  - LLM: centralize commonly used guards (e.g., isNotEmpty).

- @SubclassMapping
  - Meaning: Explicitly map inheritance hierarchies to targets per subtype.
  - LLM: list subtype mappings when polymorphism is present; ensure exhaustive coverage.

- @MappingControl
  - Meaning: Configure mapping behavior at a fine-grained level (e.g., DeepClone).
  - LLM: opt-in where needed; do not apply unnecessarily.

- Builder configuration (@Mapper(builder = ...))
  - Meaning: Directs MapStruct how to construct targets via builders (build method name, disableBuilder, etc.).
  - LLM: set buildMethod to the actual builder method (build, create, etc.).

- Null strategies
  - NullValueMappingStrategy: how to handle null sources (RETURN_NULL or RETURN_DEFAULT).
  - NullValuePropertyMappingStrategy: handling per property (IGNORE/SET_TO_NULL).
  - LLM: choose explicitly; align with repository-wide null-return policies (prefer empty collections over null).

- uses = { HelperMapper.class }
  - Meaning: Compose mappers or helpers for nested/element mapping.
  - LLM: factor conversions and reuse across mapper interfaces.

- componentModel
  - Meaning: Integration with DI (e.g., "spring", "cdi", "jsr330"); default is "default" (no DI framework).
  - LLM: set to match the project’s DI (e.g., "jsr330" or "spring").

- Mapping update vs create
  - Meaning: Update methods mutate existing targets (@MappingTarget); create methods return new instances.
  - LLM: pick per domain semantics and performance needs; ensure helpers exist for both paths if required.

Patterns and directives

- Unrelated items → prefer @Context
  - When introducing services, caches, state holders, or cycle trackers, pass them via @Context. This supports nested/iterable mappings and avoids polluting the domain method signatures.
  - Example:
    ```java
    public interface UserMapper {
      UserDto toDto(User user, @Context Locale locale, @Context UserService svc);
    }
    ```

- Update methods for patch semantics
  - Use void update(@MappingTarget Target t, Source s, @Context ...) to avoid reallocation and preserve identity/invariants managed by ORM.

- Helper extraction
  - Prefer @Named helpers or default methods over long expressions; qualify with @QualifiedByName where multiple conversions exist.

- Null handling hygiene
  - Prefer empty collections/optionals; encode null strategies explicitly; rely on @Condition for conditional mapping.

- Inheritance
  - Use @InheritConfiguration to DRY common rules; @InheritInverseConfiguration for reverse; @SubclassMapping for polymorphic mapping.

Prompt alignment
- When this topic is selected in prompts:
  - Ensure annotation processor is configured; for JPMS, open mapper packages to org.mapstruct.processor.
  - Prefer @Context for unrelated items (services/caches/cycle contexts) and for nested mapping propagation.
  - Model update methods with @MappingTarget for patch workflows; use create methods otherwise.
  - Use @MapperConfig to consolidate mapper settings (componentModel, null strategies, builder).
  - Prefer helpers (@Named/@QualifiedByName) over inline expressions; set null strategies and conditions explicitly.

See also
- Topic index — ./README.md
- Guide — ./mapstruct-6.md
- JSpecify (nullness) — ../jspecify/README.md
- Lombok interop — ../lombok/README.md