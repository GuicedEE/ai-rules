# JWebMP Angular — Release Notes (Forward-Only)

Summary (current)
- Enforce Angular 20 base rules with TypeScript language alignment.
- Hosting documented for Vert.x 5 STOMP/WebSocket bridge at `/eventbus`, `/toBus.*`, `/toStomp.*`.
- CRTP fluent API strategy reinforced (no Lombok builders on fluent types); Log4j2-only logging.
- Generation pipeline captured with flag gating (`JWEBMP_PROCESS_ANGULAR_TS`), `ConfigureImportReferences`, `NpmrcConfigurator`, and migration guidance toward `TypeScriptCompiler`.
- Testing guidance includes Jacoco, Java Micro Harness, and planned BrowserStack coverage.

Breaking changes (forward-only stance)
- Deprecated anchors for prior Angular versions are not retained; consumers must adopt Angular 20 rules.
- Generated artifacts remain read-only; workflows relying on manual TS edits are unsupported.
- Security responsibilities for WebSocket/STOMP are explicit at application layer; no default auth is provided.

Upgrade notes
- Ensure projects load Angular 20 language rules and update prompts accordingly.
- Validate WebSocket listeners for auth/validation; align route trees with new generation contracts.
- Regenerate docs/links in host projects to point to this topic index and glossary precedence.
