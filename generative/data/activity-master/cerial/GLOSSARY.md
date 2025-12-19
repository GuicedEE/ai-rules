# Glossary — Activity Master Cerial (Topic-First)

Glossary precedence
- Topic glossaries override host entries for this scope. Host GLOSSARY.md should link here; copy only enforced names.
- CRTP fluent strategy enforced; avoid builders on service APIs.

Canonical terms
- Cerial Master: Activity Master addon for serial port registration, classification, and lifecycle.
- SerialConnectionPort: Resource item type representing a COM port.
- ComPort: Classification grouping for COM ports.
- ComPortNumber: Classification value representing the COM port number.
- ComPortDeviceType: Classification value indicating port type (e.g., Device, Scanner).
- ComPortStatus: Classification value for current port status.
- BaudRate / BufferSize / DataBits / StopBits / Parity: Port configuration classifications.
- ComPortAllowedCharacters / ComPortEndOfMessage: Message boundary classifications.
- ComPortConnection: Domain projection holding COM port configuration and IDs; mapped from classifications.
- RegisteredANewConnection / ClosedANewConnection: Event types emitted on port lifecycle changes.
- SendMessageToComPort / Message / MessageReceivedFromComPort: Event/resource types for COM port messaging.

LLM interpretation guidance
- When adding APIs, use CRTP-style fluent setters returning `(J) this`; annotate with `@SuppressWarnings("unchecked")` when needed.
- Logging defaults to Lombok `@Log4j2`; keep trace/debug/info/error messages consistent and avoid other Lombok logging annotations.
- Treat unannotated types as non-null unless JSpecify annotations specify otherwise.
