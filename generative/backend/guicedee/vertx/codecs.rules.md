# Codec Strategy

Manage Vert.x codecs through `CodecRegistry` to keep payload handling deterministic and avoid duplicates.

- Registration flow:
  - `VertXPreStartup` scans registry entries and calls `CodecRegistry` to register codecs on the Vert.x instance.
  - Registry key is derived from payload type; keep names stable to prevent duplicate-registration exceptions.
- Use `DynamicCodec` for JSON-backed payloads when a concrete codec is not provided; favor Jackson object mapper configuration from GuicedEE.
- Do not manually register codecs in application code if the type is already discovered by `VertxEventRegistry`.
- For custom codecs:
  - Keep them stateless and thread-safe.
  - Honor JSpecify annotations on payloads to preserve nullness expectations.
  - Log at debug when skipping or reusing existing codecs.
- Payload conversion:
  - JsonObject payloads convert to DTOs via `IJsonRepresentation.getObjectMapper()`; ensure DTO fields are serializable and stable.
  - Avoid mixing POJO and raw JsonObject handling for the same address to keep codec selection unambiguous.
- Testing: cover codec registration paths with round-trip tests (encode/decode) and ensure registry rejects duplicates gracefully.

See also: ./event-definitions.rules.md, ./publishers.rules.md, generative/backend/vertx/README.md (codec guidance).
