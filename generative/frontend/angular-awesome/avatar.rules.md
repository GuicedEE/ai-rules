### 🧑‍🎨 `wa-avatar.rules.md`

**Angular 19 Directive Rules for `<wa-avatar>` Web Component**

> ℹ️ This is a standalone component rule file for `wa-avatar`.
> It references the shared [Web Awesome Base Rules](../../../RULES.md) and assumes global assets are preconfigured.


---

## 🎯 Purpose

Provide a lightweight Angular directive wrapper around the `wa-avatar` Web Component that:

* Uses the native `wa-avatar` tag selector (not `app-wa-avatar`)
* Supports binding to attributes like `image`, `initials`, `label`, `shape`, and `loading`
* Ensures boolean attribute omission when not set
* Enables projection of custom icons via `<ng-content>` into the `slot="icon"`
* Allows `[style.fontSize]` and `[style.--size]` for avatar sizing
* Ensures custom properties like `--background-color`, `--text-color` apply correctly
* Leverages `ElementRef` and `Renderer2` to manage attributes imperatively

---

## ✅ Supported `@Input()` Bindings

| Input             | Type       | HTML Attribute | Notes                      |                     |                     |
| ----------------- | ---------- | -------------- | -------------------------- | ------------------- | ------------------- |
| `image`           | `string`   | `image`        | Sets avatar image URL      |                     |                     |
| `label`           | `string`   | `label`        | Required for accessibility |                     |                     |
| `initials`        | `string`   | `initials`     | Shown if no image          |                     |                     |
| `shape`           | \`'circle' | 'square'       | 'rounded'\`                | `shape`             | Default is `circle` |
| `loading`         | \`'lazy'   | 'eager'\`      | `loading`                  | Defaults to `eager` |                     |
| `fontSize`        | `string`   | *CSS style*    | Applied as `font-size`     |                     |                     |
| `size`            | `string`   | *CSS variable* | Applied via `--size`       |                     |                     |
| `backgroundColor` | `string`   | *CSS variable* | `--background-color`       |                     |                     |
| `textColor`       | `string`   | *CSS variable* | `--text-color`             |                     |                     |

---

## 🧩 Slot Support

### Projected Content:

* `<ng-content select="[slot=icon]"></ng-content>` should allow custom icons.
* All other content is ignored or should fallback to native rendering logic.

---

## 🔧 Directive Implementation Notes

### Selector:

```ts
@Directive({
  selector: 'wa-avatar',
  standalone: true
})
```

### Setup Lifecycle:

Use `ngOnInit()` to attach attributes and CSS custom properties:

```ts
this.setAttr('image', this.image);
this.setAttr('label', this.label);
this.setAttr('initials', this.initials);
this.setAttr('shape', this.shape);
this.setAttr('loading', this.loading);
this.setStyle('--size', this.size);
this.setStyle('--background-color', this.backgroundColor);
this.setStyle('--text-color', this.textColor);
if (this.fontSize) this.el.nativeElement.style.fontSize = this.fontSize;
```

### Boolean Attributes:

N/A for `wa-avatar`, but future props should follow:

```ts
if (this.pill) this.renderer.setAttribute(...);
```

---

## 🎨 Styling Support

Allow Angular bindings for:

* `[style.--size]="'3rem'"`
* `[style.--background-color]="'#ccc'"`
* `[style.--text-color]="'black'"`

Also allow `[style.fontSize]` for responsive scaling.

---

## 🔁 Examples

```html
<wa-avatar image="avatar.jpg" label="User photo"></wa-avatar>
<wa-avatar initials="MA" label="Initials only"></wa-avatar>
<wa-avatar shape="square" label="Square avatar"></wa-avatar>
<wa-avatar [style.--size]="'4rem'" [style.--background-color]="'lightgray'"></wa-avatar>
<wa-avatar label="Custom icon">
  <wa-icon slot="icon" name="dog" variant="solid"></wa-icon>
</wa-avatar>
```

---

## 📎 Dependencies

* Requires `<wa-icon>` component when using projected `slot="icon"`

---

## ✅ Status

**Stable** under Angular 19 with `standalone: true`, `CUSTOM_ELEMENTS_SCHEMA`, and native shadow DOM rendering.

---

📌 This rule file (avatar.rules.md) should reside alongside the directive source. It is self-contained, but expects the global styles, loader, and schema setup as outlined in the base rules.
