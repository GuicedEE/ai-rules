# Button Component Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

## Overview

`<wa-button>` is an interactive element that represents an action. It supports multiple variants, appearances, and sizes. It can also render as a link when `href` is provided.

All inputs accept string values in templates for compatibility. Boolean inputs must be explicitly bound using Angular syntax (e.g. `[disabled]="true"`).

---

## Variants

```html
<wa-button variant="neutral">Neutral</wa-button>
<wa-button variant="brand">Brand</wa-button>
<wa-button variant="success">Success</wa-button>
<wa-button variant="warning">Warning</wa-button>
<wa-button variant="danger">Danger</wa-button>
```

## Appearance

```html
<wa-button appearance="accent" variant="neutral">Accent</wa-button>
<wa-button appearance="outlined" variant="neutral">Outlined</wa-button>
<wa-button appearance="filled" variant="neutral">Filled</wa-button>
<wa-button appearance="plain" variant="neutral">Plain</wa-button>
```

## Sizes

```html
<wa-button size="small">Small</wa-button>
<wa-button size="medium">Medium</wa-button>
<wa-button size="large">Large</wa-button>
```

## Pill Buttons

```html
<wa-button size="small" [pill]="true">Small</wa-button>
<wa-button size="medium" [pill]="true">Medium</wa-button>
<wa-button size="large" [pill]="true">Large</wa-button>
```

## Link Buttons

```html
<wa-button href="https://example.com/">Link</wa-button>
<wa-button href="https://example.com/" target="_blank">New Window</wa-button>
<wa-button href="/assets/logo.svg" download="logo.svg">Download</wa-button>
```

## Custom Width

```html
<wa-button size="small" style="width: 100%">Small</wa-button>
<wa-button size="medium" style="width: 100%">Medium</wa-button>
<wa-button size="large" style="width: 100%">Large</wa-button>
```

## Prefix and Suffix Icons

```html
<wa-button>
  <wa-icon slot="prefix" name="gear"></wa-icon>
  Settings
</wa-button>

<wa-button>
  <wa-icon slot="suffix" name="undo"></wa-icon>
  Refresh
</wa-button>

<wa-button>
  <wa-icon slot="prefix" name="link"></wa-icon>
  <wa-icon slot="suffix" name="arrow-up-right-from-square"></wa-icon>
  Open
</wa-button>
```

## Caret

```html
<wa-button [caret]="true">Dropdown</wa-button>
```

## Loading

```html
<wa-button variant="brand" [loading]="true">Loading...</wa-button>
```

## Disabled

```html
<wa-button variant="brand" [disabled]="true">Disabled</wa-button>
```

## Styling Custom Variants

```html
<wa-button class="pink">Pink Button</wa-button>
```

```css
wa-button.pink::part(base) {
  background: #ff1493;
  color: white;
  border-radius: 6px;
}
```

## Attributes & Bindings

### Native Style Inputs

In addition to component-specific inputs, the following style-related inputs are also supported and map to Web Awesome CSS custom properties:

| Input                     | Binds to CSS Custom Property |
| ------------------------- | ---------------------------- |
| `[display]`               | `--display`                  |
| `[backgroundColor]`       | `--background-color`         |
| `[backgroundColorHover]`  | `--background-color-hover`   |
| `[backgroundColorActive]` | `--background-color-active`  |
| `[borderColor]`           | `--border-color`             |
| `[borderColorHover]`      | `--border-color-hover`       |
| `[borderColorActive]`     | `--border-color-active`      |
| `[textColor]`             | `--text-color`               |
| `[textColorHover]`        | `--text-color-hover`         |
| `[textColorActive]`       | `--text-color-active`        |

| Attribute                                                                         | Type    | Binding                  | Description                             |
| --------------------------------------------------------------------------------- | ------- | ------------------------ | --------------------------------------- |
| `variant`                                                                         | string  | `string or [variant]`    | The button theme. Default is `inherit`. |
| `appearance`                                                                      | string  | `string or [appearance]` | Visual style. Default is `accent`.      |
| `size`                                                                            | string  | `string or [size]`       | Button size. Default is `inherit`.      |
| `pill`                                                                            | boolean | `[pill]`                 | Rounded edges.                          |
| `caret`                                                                           | boolean | `[caret]`                | Adds a dropdown indicator.              |
| `disabled`                                                                        | boolean | `[disabled]`             | Disables the button.                    |
| `loading`                                                                         | boolean | `[loading]`              | Shows a spinner.                        |
| `type`                                                                            | string  | `string or [type]`       | Button type. Defaults to `button`.      |
| `name`                                                                            | string  | `string or [name]`       | Form data name.                         |
| `value`                                                                           | string  | `string or [value]`      | Form data value.                        |
| `href`                                                                            | string  | `string or [href]`       | Link destination. Renders `<a>`.        |
| `target`                                                                          | string  | `string or [target]`     | Where to open the link.                 |
| `rel`                                                                             | string  | `string or [rel]`        | `rel` attribute for link.               |
| `download`                                                                        | string  | `string or [download]`   | Download filename.                      |
| `form`, `formAction`, `formEnctype`, `formMethod`, `formNoValidate`, `formTarget` | various | appropriate binding      | Form behavior overrides.                |

## Events

| Event         | Description                                                         |
| ------------- | ------------------------------------------------------------------- |
| `(waBlur)`    | Fires when the button loses focus (bubbles from native `blur`).     |
| `(waFocus)`   | Fires when the button receives focus (bubbles from native `focus`). |
| `(waInvalid)` | Emitted when form validation fails.                                 |

> ℹ️ The internal emitters are named `blurEvent` and `focusEvent` to avoid clashing with the native methods. Emitted when form validation fails. | Form validation failed. |

## Methods

| Method    | Description              |
| --------- | ------------------------ |
| `click()` | Programmatically clicks. |
| `focus()` | Focuses the button.      |
| `blur()`  | Blurs the button.        |

## Slots

| Slot    | Description                |
| ------- | -------------------------- |
| default | The button label.          |
| prefix  | Left-aligned icon/element  |
| suffix  | Right-aligned icon/element |

## Styling via CSS Parts

| Part      | Description         |
| --------- | ------------------- |
| `base`    | Button container    |
| `prefix`  | Prefix slot wrapper |
| `label`   | Label span          |
| `suffix`  | Suffix slot wrapper |
| `caret`   | Dropdown icon       |
| `spinner` | Spinner container   |

## CSS Custom Properties

* `--display`
* `--background-color`, `--background-color-hover`, `--background-color-active`
* `--border-color`, `--border-color-hover`, `--border-color-active`
* `--text-color`, `--text-color-hover`, `--text-color-active`

---

📌 For consistent implementation, refer to the [Web Awesome Angular Rules](../../../RULES.md).
