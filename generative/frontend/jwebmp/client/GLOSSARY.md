# Glossary — JWebMP Client (Topic-First)

Use this glossary when generating or maintaining JWebMP Client rules. Do not duplicate terms in host glossaries; link to this file or related topic glossaries instead.

Glossary precedence
- Topic glossaries override root definitions for their scope.
- Copy only enforced Prompt Language Alignment mappings into host glossaries; otherwise link back here.

Terms
- **CRTP Components** — Component hierarchy uses `Component<J extends Component<J>>` style chaining for fluent setters; builders are out of scope.
- **JWebMP Client** — The client-side service/framework library that models HTML components, renders them, and handles AJAX flows without requiring the full JWebMP core; consumed by host applications.
- **Interception Keys** — ServiceLoader-discovered bindings for AJAX/Data/Site interceptors supplied by the client library; used to wrap requests/responses.
- **Call Scope** — Request-scoped bindings for `AjaxCall` and `AjaxResponse` to isolate per-request data during interception.
- **Mutiny** — Preferred reactive library (`Uni`, `Multi`) for async flows; avoid mixing with other reactive types on the same API.
- **Log4j2 Defaults** — Logging policy aligned with GuicedEE; avoid introducing alternative logging frameworks.
- **JSpecify** — Nullness annotations used for API contracts; treat unannotated parameters as non-null unless rules specify otherwise.
