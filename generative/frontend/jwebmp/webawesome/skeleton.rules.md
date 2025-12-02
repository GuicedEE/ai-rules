# WaSkeleton — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-skeleton` loading placeholders. Aligns with ../../webawesome/skeleton.rules.md.

Usage
- Place in clusters/stacks where loading states are needed; configure effect (`SkeletonEffect`), shape, and size via fluent setters.

Patterns
- Keep CRTP chaining; swap with real content once loaded.
