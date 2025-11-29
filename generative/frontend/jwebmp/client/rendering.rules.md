# Rendering & Component Model — JWebMP Client

Scope
- How consumers model components/attributes/events and render them to browser output with resource references.

Rules
- **CRTP fluent APIs**: Components and attributes use CRTP chaining (`Component<J extends Component<J>>`). Do not introduce builders on these APIs.
- **Component extensibility**: Keep components non-final to allow host extension; preserve generic self-types on setters.
- **Renderer behavior**: Renderers traverse children, attributes, and events, collecting `CSSReference`/`JavascriptReference` for output. Avoid inline HTML strings; use component classes instead.
- **Resources**: Manage CSS/JS via reference objects rather than embedding; ensure references are serialized alongside markup.
- **JPMS alignment**: Keep exports/opens aligned to renderer and component packages to support serialization/reflection without overexposure.
- **Testing**: Validate render output structure and reference collection; favor deterministic ordering for references to aid snapshot tests.

See also
- Topic index — README.md
- Integration & JPMS — configuration.rules.md
- Fluent API — ../../backend/fluent-api/README.md
