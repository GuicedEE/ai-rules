# JSpecify Nullness Rules

Overview
- Apply JSpecify annotations (`@org.jspecify.annotations.NonNull`, `@Nullable`) to clarify CRTP return types and service loader contracts.
- Prefer annotating method signatures and type parameters; match existing patterns in classes like `Page`.
- Keep generics explicit on public APIs to avoid raw types when chaining components/features.

Guidance
- When overriding CRTP setters (e.g., `setTiny`, `addFeature`), annotate return types as `@NonNull` and preserve `(J) this` casts.
- For ServiceLoader-facing types (e.g., `IPageConfigurator` implementations), mark inputs that must not be null to prevent downstream NPEs during render.
- Avoid adding nullness annotations to generated/third-party types; wrap them instead.
- No additional module-info entries are needed solely for JSpecify.

See also
- Topic index: ./README.md
- Enterprise rules: ../../backend/jspecify/README.md
- Component APIs: ./jwebmp-core-rendering.rules.md
