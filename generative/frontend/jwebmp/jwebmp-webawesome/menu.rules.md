## Angular Wrapper Rules for `wa-menu`, `wa-menu-item`, and `wa-menu-label`

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

---

### 🧩 `wa-menu`

#### Selector

```ts
selector: 'wa-menu'
```

#### Angular Bindings

| Input  | Description      |          |         |             |
| ------ | ---------------- | -------- | ------- | ----------- |
| `size` | One of \`'small' | 'medium' | 'large' | 'inherit'\` |

#### Outputs

| Output   | Description                  |
| -------- | ---------------------------- |
| `select` | Emits the selected menu item |

> Note: The `wa-select` native event will be re-emitted as an Angular `@Output()` named `select`.

#### Slots (No Angular Mapping Needed)

* `(default)` - Wraps `wa-menu-item`, `wa-menu-label`, or `wa-divider`

#### Styling Inputs

Supports Angular-style inputs for these CSS custom properties on the host element:

* `--padding`
* `--margin`
* `--border-radius`
* `--background`
* `--box-shadow`
* `--border`
* `--font-size`

---

### 🧩 `wa-menu-item`

#### Selector

```ts
selector: 'wa-menu-item'
```

#### Angular Bindings

| Input         | Description                                    |
| ------------- | ---------------------------------------------- |
| `type`        | `'normal'` or `'checkbox'`                     |
| `checked`     | Boolean, reflects whether the item is toggled  |
| `value`       | String value to identify the item              |
| `loading`     | Boolean, true if the item is showing a spinner |
| `disabled`    | Boolean, disables selection                    |
| `label`       | Plain text label override                      |
| `withSubmenu` | Boolean, applies SSR-only submenu indication   |

> Checkbox state should be managed with `ngModel` bound to the `checked` attribute.

#### Outputs

| Output       | Description                     |
| ------------ | ------------------------------- |
| `blurEvent`  | Emits when the item loses focus |
| `focusEvent` | Emits when the item gains focus |

> Emits `blur` and `focus` as `blurEvent` and `focusEvent` respectively to avoid method name collisions.

#### Styling Inputs

Supports Angular-style inputs for these CSS custom properties on the host element:

* `--background-color-hover`
* `--text-color-hover`
* `--submenu-offset`
* `--padding`
* `--margin`
* `--font-size`

#### Slots

| Slot           | Usage                                |
| -------------- | ------------------------------------ |
| `(default)`    | Menu item content                    |
| `prefix`       | Icon or label before content         |
| `suffix`       | Icon or badge after content          |
| `submenu`      | Nested `wa-menu` for submenu         |
| `checked-icon` | Icon used when checkbox is checked   |
| `submenu-icon` | Icon indicating submenu availability |

---

### 🧩 `wa-menu-label`

#### Selector

```ts
selector: 'wa-menu-label'
```

#### Angular Bindings

*None.*

#### Slots

| Slot        | Description               |
| ----------- | ------------------------- |
| `(default)` | Content of the menu label |

#### Styling Inputs

Supports Angular-style inputs for these CSS custom properties on the host element:

* `--padding`
* `--font-size`
* `--color`
* `--margin`

---

### 📋 Notes

* Menu interactions should **not** use reactive forms. Use plain `ngModel` where necessary.
* Avoid binding to complex objects for menu values—use strings or identifiers.
* Only one level of submenus is recommended for accessibility.
* Event handling for selection should occur on `wa-menu`, not `wa-menu-item`.

---

### ✅ Example Usage

```html
<wa-menu (select)="onSelect($event)">
  <wa-menu-label>Options</wa-menu-label>
  <wa-menu-item value="cut">Cut</wa-menu-item>
  <wa-menu-item value="copy">Copy</wa-menu-item>
  <wa-menu-item type="checkbox" [(ngModel)]="checkedItem">Paste</wa-menu-item>
</wa-menu>
```
