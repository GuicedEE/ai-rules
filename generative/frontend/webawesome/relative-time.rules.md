## Relative Time Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Overview

The `wa-relative-time` component displays a localized phrase indicating the relative time from a given date to now. It supports automatic updates, multiple formatting styles, and localization.

---

### Selector

```ts
@Directive({
  selector: 'wa-relative-time[ngModel]'
})
export class WaRelativeTimeDirective { ... }
```

---

### Bindings

#### Inputs

| Input     | Type                            | Description                                                               |
| --------- | ------------------------------- | ------------------------------------------------------------------------- |
| `ngModel` | `string \| Date`                | Binds to the `date` attribute. Must be a valid ISO 8601 string or `Date`. |
| `format`  | `'long' \| 'short' \| 'narrow'` | Changes how the time is displayed.                                        |
| `numeric` | `'auto' \| 'always'`            | Controls how precise the phrase is ("yesterday" vs "1 day ago").          |
| `lang`    | `string`                        | Sets the locale used for formatting (e.g. `'en-US'`, `'de'`, `'zh-CN'`).  |
| `sync`    | `boolean`                       | When `true`, updates the output automatically as time passes.             |

#### Styling Inputs

Supports these Angular-style inputs for styling, mapped to CSS custom properties on the host element:

| Input     | CSS Property |
| --------- | ------------ |
| `display` | `--display`  |

> Note: The native element has no additional visual properties beyond standard layout/display concerns. Custom styling is rarely needed, but `--display` is exposed for advanced layout control.

---

### Outputs

| Output       | Description                           |
| ------------ | ------------------------------------- |
| `blurEvent`  | Fired when the component loses focus. |
| `focusEvent` | Fired when the component gains focus. |

---

### Notes

* This directive must bind via `[(ngModel)]` to the `date` attribute — no reactive forms, signals, or other state mechanisms are used.
* Ensure that date values passed in as strings are in valid ISO 8601 format for consistent parsing across browsers.
* Avoid ambiguous date formats like `03/04/2020`; instead use `2020-04-03T00:00:00Z`.

---

### Example Usage

```html
<wa-relative-time
  [(ngModel)]="createdAt"
  format="short"
  numeric="auto"
  lang="en-US"
  [sync]="true"
  (blurEvent)="onBlur()"
  (focusEvent)="onFocus()"
  [display]="'inline-block'"
></wa-relative-time>
```
