📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

# Divider Rules (`wa-divider`)

Dividers visually separate or group elements. The Angular wrapper for `wa-divider` provides attribute binding, style control, and vertical/horizontal orientation support.

---

## Selector

```ts
wa-divider
```

## Inputs

| Input      | Type    | Description                                          |
| ---------- | ------- | ---------------------------------------------------- |
| `vertical` | boolean | Whether the divider is vertical. Default is `false`. |

### Style Inputs

All CSS custom properties from the Web Awesome component are supported as Angular-style inputs applied to the host:

| Input     | Maps to     | Description                         |
| --------- | ----------- | ----------------------------------- |
| `color`   | `--color`   | The color of the divider.           |
| `width`   | `--width`   | The thickness/width of the divider. |
| `spacing` | `--spacing` | Space around the divider.           |

These can be passed as strings, e.g.,

```html
<wa-divider [width]="'4px'" [color]="'tomato'" [spacing]="'2rem'"></wa-divider>
```

---

## Outputs

None.

---

## Angular Usage Examples

### Horizontal Divider with Custom Width

```html
<wa-divider [width]="'4px'"></wa-divider>
```

### Vertical Divider Inside a Flex Container

```html
<div style="display: flex; align-items: center; height: 2rem;">
  First
  <wa-divider vertical [spacing]="'1rem'"></wa-divider>
  Middle
  <wa-divider vertical [spacing]="'1rem'"></wa-divider>
  Last
</div>
```

### Menu with Divider

```html
<wa-menu style="max-width: 200px;">
  <wa-menu-item value="1">Option 1</wa-menu-item>
  <wa-menu-item value="2">Option 2</wa-menu-item>
  <wa-menu-item value="3">Option 3</wa-menu-item>
  <wa-divider></wa-divider>
  <wa-menu-item value="4">Option 4</wa-menu-item>
</wa-menu>
```

---

## Notes

* `vertical` is a boolean input and should be bound using Angular syntax (e.g. `[vertical]="true"`).
* The directive does not emit events.
* All style inputs support both binding and string literals.

---

## Related

* [Menu Rules](./menu.rules.md)
