# Persistence & EntityAssist

## Overview
Persistence relies on Hibernate Reactive 7 + EntityAssist helpers to stream FSDM rows while respecting Postgres constraints. This document captures the host’s CRTP query builders, classification joins, and reactive session patterns.

## Usage
- Always obtain a `Mutiny.Session` via `ActivityMasterDBModule`/`ActivityMasterDestinationDBModule` so connection pools configured in host metadata (`src/main/resources/META-INF`) are reused.
- Compose persistence mutations sequentially (e.g., `session.withTransaction(...)` combined with `onItem().call(...)`) to respect Mutiny’s single-execution requirement; do not block via `.await()`.
- Hydrate DTOs with EntityAssist helpers (`rules/generative/data/entityassist/README.md`) and the canonical query builder hierarchies under `src/main/java/com/guicedee/activitymaster/fsdm/db`.

## Inputs/Outputs/Constraints
- CRTP query builders return `(J)this` with `@SuppressWarnings("unchecked")`, ensuring callers can chain filters, classification selectors, and column projections without casting (`rules/generative/backend/fluent-api/README.md`).
- Classification joins (e.g., `AddressXClassification`, `ArrangementXRules`) must be resolved by the shared helpers referenced in the host `GUIDES.md`; mutate them only through the provided pipelines so security traces remain intact.
- Mapping to DTOs/reports must honor Postgres type definitions from `src/main/resources/META-INF` (e.g., `enterprise.sql`, `classification.sql`), matching the host ERD for the FSDM domain.
- Lazy fetching from entity relationships must chain the originating `Mutiny.Session` fetch result (e.g., `session.fetch(entity)`) so every lookup uses the session that opened it, and document that joins may require lazy fetches consistently.

## Performance & Constraints
- Favor streaming `Mutiny.multi` flows over loading entire entity graphs. Apply `onItem().call(...)` to sequence builder operations and avoid parallel session usage.
- Use `EntityAssist` to batch hydration and minimize repeated classification lookups.
- Document any schema changes (new tables/columns) by updating the host ERD and referencing it here via cross-links to keep diagrams and queries synchronized.

## See also
- `../README.md` for the topic index.
- `../../backend/hibernate/README.md`, `../../backend/guicedee/persistence/README.md`, `../../data/entityassist/README.md` for deeper persistence warnings.
