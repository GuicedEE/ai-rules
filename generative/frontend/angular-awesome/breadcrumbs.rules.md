### 🌐 `wa-breadcrumb.rules.md`

**Angular 19 Directive Rules for `<wa-breadcrumb>` and `<wa-breadcrumb-item>` Web Components**

---

## 🔎 Purpose

These directives provide Angular-native integration for breadcrumb navigation using Web Awesome components.

* `<wa-breadcrumb>`: Wrapper to contain navigation items
* `<wa-breadcrumb-item>`: Represents a link or step in the navigation path
* Fully supports slots, href navigation, and icon or text-based separators
* Leverages native Angular binding patterns for accessibility and logic

---

## ✔️ Supported `@Input()` Bindings

### `wa-breadcrumb`

| Input   | Type     | HTML Attribute | Notes                                 |
| ------- | -------- | -------------- | ------------------------------------- |
| `label` | `string` | `label`        | Screen-reader label for accessibility |

### `wa-breadcrumb-item`

| Input    | Type                                        | HTML Attribute | Notes                                                          |
| -------- | ------------------------------------------- | -------------- | -------------------------------------------------------------- |
| `href`   | `string \| undefined`                       | `href`         | Link to navigate to when clicked                               |
| `target` | `'_blank' \| '_parent' \| ... \| undefined` | `target`       | Link target behavior                                           |
| `rel`    | `string`                                    | `rel`          | Relationship for link behavior, default: `noreferrer noopener` |

---

## 📸 Slot Usage

### `<wa-breadcrumb>` Slots:

| Slot      | Description                                               |
| --------- | --------------------------------------------------------- |
| default   | One or more `<wa-breadcrumb-item>` elements               |
| separator | Optional separator (icon, text, or element) between items |

### `<wa-breadcrumb-item>` Slots:

| Slot      | Description                          |
| --------- | ------------------------------------ |
| default   | The label text or projected content  |
| prefix    | Icon or element before the label     |
| suffix    | Icon or element after the label      |
| separator | Optional per-item separator override |

---

## 🔧 Directive Implementation Notes

### `wa-breadcrumb` Selector

```ts
@Directive({
  selector: 'wa-breadcrumb',
  standalone: true
})
```

### `wa-breadcrumb-item` Selector

```ts
@Directive({
  selector: 'wa-breadcrumb-item',
  standalone: true
})
```

---

## 🎨 Styling

Customize prefix/suffix/separator colors using `::part()` selectors:

```css
wa-breadcrumb-item::part(separator) {
  color: pink;
}
wa-breadcrumb-item::part(prefix),
wa-breadcrumb-item::part(suffix) {
  color: currentColor;
}
```

Control layout and behavior via:

* CSS variables (in host or inherited context)
* Scoped classes per breadcrumb hierarchy

---

## 🔄 Examples

```html
<wa-breadcrumb label="Site Navigation">
  <wa-breadcrumb-item href="/home">
    <wa-icon slot="prefix" name="house" variant="solid"></wa-icon>
    Home
  </wa-breadcrumb-item>

  <wa-breadcrumb-item href="/home/products">
    Products
  </wa-breadcrumb-item>

  <wa-breadcrumb-item href="/home/products/widgets">
    Widgets
    <wa-icon slot="suffix" name="star" variant="solid"></wa-icon>
  </wa-breadcrumb-item>
</wa-breadcrumb>
```

### Custom Separators

```html
<wa-breadcrumb>
  <wa-icon slot="separator" name="angles-right" variant="solid"></wa-icon>
  <wa-breadcrumb-item>Level 1</wa-breadcrumb-item>
  <wa-breadcrumb-item>Level 2</wa-breadcrumb-item>
  <wa-breadcrumb-item>Current</wa-breadcrumb-item>
</wa-breadcrumb>
```

---

## 🔼 Dependencies

* `<wa-icon>` (for prefix/suffix/separator icons)
* `<wa-dropdown>`, `<wa-menu>`, `<wa-button>` (optional for advanced breadcrumbs)

---

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).
