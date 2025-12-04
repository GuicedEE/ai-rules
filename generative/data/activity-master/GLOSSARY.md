# Activity Master Topic Glossary (Topic-First)

Glossary precedence
- Use this glossary as the Activity Master topic authority; host glossaries should link here instead of duplicating definitions.
- Defer to linked stack glossaries (GuicedEE, Vert.x 5, Hibernate Reactive 7, platform testing/observability) for shared terms.

Canonical terms
| Term | Definition | References |
| --- | --- | --- |
| Activity Master Client | Reactive SPI client exposing CRTP builders and service interfaces for systems, enterprises, classifications, and security tokens. | ./client/README.md |
| System token cache | In-memory cache keyed by system name and enterprise UUID used by the client to avoid repeated token fetches. | ./client/token-cache.rules.md; ./interface_hierarchies.md; src/main/java/com/guicedee/activitymaster/fsdm/client/services/IActivityMasterService.java |
| Enterprise bootstrap | Sequence that registers or updates an enterprise, provisions system metadata, and wires GuicedEE bindings. | ./client/lifecycle.rules.md; ../../../../docs/architecture/sequence-system-load.md |
| CRTP query builders | Curiously Recurring Template Pattern builders that return `(J)` to enforce type-safe chaining across warehouse tables and query layers. | ./client/builders.rules.md; ../../backend/fluent-api/crtp.rules.md |
| Classification data concept | Domain concept describing classification metadata, values, and relationships used in rule and arrangement builders. | ./client/builders.rules.md; ../../data/entityassist/README.md |

Prompt alignment
- Use canonical names (Activity Master Client, System token cache, CRTP query builders) in prompts and code comments for consistency across engines.
- Mention the Mermaid MCP server when referencing diagrams stored under ../../../../docs/architecture/.

Traceability
- Keep references between this glossary, RULES.md, GUIDES.md, IMPLEMENTATION.md, docs/architecture/*, and the client rules files to close the documentation loop.
