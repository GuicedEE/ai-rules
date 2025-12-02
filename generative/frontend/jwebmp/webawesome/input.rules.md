# WaInput — WebAwesome (JWebMP Wrapper)

`WaInput<J extends WaInput<J>>` wraps the `wa-input` custom element and exposes form-friendly attributes plus slot hooks. Use CRTP setters; avoid builders and inline HTML.

Core attributes
- `type` (text, password, email, number, etc.), `value` or `defaultValue` (defaults if `value` unset).
- Styling: `size` (`InputSize`), `appearance` (`InputAppearance`), `pill`, `backgroundColor`, `borderColor`, `borderWidth`, `boxShadow`.
- Labels and hints: `label`, `hint`, `with-label`, `with-hint`; slots `label`, `hint`, `start`, `end`, `clear-icon`, `show-password-icon`, `hide-password-icon`.
- Behavior: `clearable` (`with-clear`), `placeholder`, `readonly`, `disabled`, `password-toggle`, `password-visible`, `without-spin-buttons`.
- Forms: `form`, `required`, `pattern`, `minlength`, `maxlength`, `min`, `max`, `step`, `name` (set when differing from default), `autofocus`, `autocomplete`, `autocapitalize`, `autocorrect`, `enterkeyhint`, `spellcheck`, `inputmode`.
- Data binding: `bind(variableName)` adds `[(ngModel)]` attribute for Angular integration.

## Number Input
- Use `type="number"` with `min`, `max`, `step`, and optionally `noSpinButtons` (renders `without-spin-buttons`).
- Keep `value` numeric strings only; validation errors should surface through `wa-invalid` handlers at the form level.
- Avoid mixing `defaultValue` and `value`; prefer `defaultValue` for SSR defaults when two-way binding will later override.

Patterns
- Use CRTP setters returning `(J) this`; keep class non-final for extension.
- Slot helpers already set `slot` attributes; avoid double-setting.
- Align prompt language to “WaInput” and defer visual behavior to `../../webawesome/input.rules.md`.

See also
- Button — ./button.rules.md
- Layout — ./cluster.rules.md, ./stack.rules.md
- Base WebAwesome input details — ../../webawesome/input.rules.md
- Testing — ./testing.rules.md
