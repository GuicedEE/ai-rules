## Include Component Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

The `wa-include` component allows embedding external HTML content into the page using a declarative Web Component approach. The wrapper directive should preserve all asynchronous behavior and provide support for configuration and load/error monitoring.

### Angular Selector

```ts
waInclude
```

### Binding Inputs

| Input          | Type      | Description                                                    |                 |                               |
| -------------- | --------- | -------------------------------------------------------------- | --------------- | ----------------------------- |
| `src`          | `string`  | The URL to fetch content from. Required.                       |                 |                               |
| `mode`         | \`'cors'  | 'no-cors'                                                      | 'same-origin'\` | Optional. Defaults to `cors`. |
| `allowScripts` | `boolean` | Whether to allow embedded scripts to execute. Default `false`. |                 |                               |

These map directly to the native attributes of the `<wa-include>` Web Component.

### Output Events

| Output    | Payload                           | Description                                    |
| --------- | --------------------------------- | ---------------------------------------------- |
| `waLoad`  | `CustomEvent<void>`               | Fired when the content is successfully loaded. |
| `waError` | `CustomEvent<{ status: number }>` | Fired when loading fails with error detail.    |

> ⚠️ These event bindings use native DOM event names and must be mapped carefully to Angular output emitters.

### Usage Example

```html
<wa-include
  waInclude
  [src]="includeUrl"
  [mode]="'cors'"
  [allowScripts]="true"
  (waLoad)="onLoad()"
  (waError)="onError($event.detail.status)"
></wa-include>
```

### Styling

This component does not expose its own styling via CSS custom properties. Use external container styling as needed.

### Behavior Notes

* Content is fetched and inserted asynchronously via `fetch()`.
* The content is inserted into the light DOM of the component.
* Cached across instances for the same `src`.
* Be cautious with `allowScripts`: included code is executed as-is and can lead to XSS.

### Directive Notes

* This directive does **not** require `ngModel` or two-way binding.
* No reactive forms support is needed.
* Use Angular's standard property binding for configuration.
* All events should use `Event.AT_TARGET` to ensure filtering only on the element.

### Dependencies

This directive depends on:

* No other directives
* Global configuration for content URL trust may be required (e.g. CSP)

### Accessibility

Ensure that embedded content meets accessibility standards and provides alternative content or fails gracefully.

---

✅ Ready for generation and packaging in the Web Awesome Angular library.
