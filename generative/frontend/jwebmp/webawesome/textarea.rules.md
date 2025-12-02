# WaTextArea — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-textarea` multi-line inputs. Aligns with ../../webawesome/textarea.rules.md.

Usage
- Add to clusters/stacks; configure label/hint slots, value/defaultValue, resize (`TextAreaResize`), appearance (`TextAreaAppearance`), rows/cols, maxlength/minlength, disabled/readonly/required, and form association via fluent setters.
- Use `withLabel`/`withHint` when server-rendering slots; bind to Angular models with `bind()` if needed.

Patterns
- Keep CRTP chaining; avoid builders.
- Avoid inline HTML; use components for label/hint content.
