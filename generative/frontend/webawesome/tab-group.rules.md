# Tab Group Component Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

## Component: `<wa-tab-group>`

### Description

Organizes content into panels, showing one at a time. Tabs are linked to panels via the `panel` and `name` attributes. Supports scrollable, closable, and repositionable tabs.

### Angular Integration

* **Wrapper Selector:** `waTabGroup`
* **Inputs:**

  * `active: string` — name of the currently active tab panel.
  * `placement: 'top' | 'bottom' | 'start' | 'end'` — sets the position of tabs.
  * `activation: 'auto' | 'manual'` — configures keyboard activation behavior.
  * `withoutScrollControls: boolean` — disables the scroll arrows. Reflects to `without-scroll-controls`.
* **Outputs:**

  * `tabShow: Event` — emitted when a tab becomes active.
  * `tabHide: Event` — emitted when a tab becomes inactive.
* **Styling Inputs:**

  * `indicatorColor: string` → sets `--indicator-color`
  * `trackColor: string` → sets `--track-color`
  * `trackWidth: string` → sets `--track-width`

These are bound directly as CSS custom properties on the host element.

### Content Projection

* Tabs use the `nav` slot.
* Panels use the default slot.

---

## Component: `<wa-tab>`

### Angular Integration

* **Wrapper Selector:** `waTab`
* **Inputs:**

  * `panel: string` — required; links to the corresponding tab panel.
  * `disabled: boolean` — disables the tab.
* **Styling Inputs:**

  * `activeTabColor: string` → sets `--active-tab-color`

---

## Component: `<wa-tab-panel>`

### Angular Integration

* **Wrapper Selector:** `waTabPanel`
* **Inputs:**

  * `name: string` — required; unique name of this panel.
  * `active: boolean` — if true, panel is visible.
  * `lazy: boolean` — when true and no `<ng-template waTabContent>` is provided, the panel lazily attaches/detaches its projected DOM based on active state. Note: this defers DOM presence only; Angular child components may still be instantiated. Use `<ng-template waTabContent>` for true deferred instantiation.
* **Styling Inputs:**

  * `padding: string` → sets `--padding`

---

## Notes

* Tabs and panels must reside within the same `wa-tab-group`.
* Ensure the `panel` attribute of each `<wa-tab>` matches the `name` of a `<wa-tab-panel>`.
* Support for advanced UX patterns like:

  * `placement="bottom|start|end"`
  * `closable` tabs via DOM manipulation and `wa-icon-button`
  * scrollable navigation with optional scroll buttons
  * `activation="manual"` for accessibility

### Lazy Loading Options

There are two ways to optimize tab panel initialization:

1) Template-based true lazy instantiation (preferred): Wrap content inside `<ng-template waTabContent>`. The content is only instantiated when the tab becomes active for the first time.

```html
<wa-tab-panel name="info">
  <ng-template waTabContent>
    <app-heavy-component></app-heavy-component>
  </ng-template>
  <!-- Nothing is created until the panel becomes active -->
  <!-- Subsequent activations reuse the created view -->
</wa-tab-panel>
```

2) DOM-only lazy attach/detach: Set `[lazy]="true"` on the panel without using a template. Inactive panels keep their projected nodes detached from the DOM to reduce layout/paint work, but Angular children may already be instantiated.

```html
<wa-tab-panel name="settings" [lazy]="true">
  <app-medium-component></app-medium-component>
</wa-tab-panel>
```

---

## Example Usage

```html
<wa-tab-group [active]="activeTab" placement="top">
  <wa-tab panel="info">Info</wa-tab>
  <wa-tab panel="settings">Settings</wa-tab>

  <!-- True lazy using template -->
  <wa-tab-panel name="info">
    <ng-template waTabContent>
      Info content
    </ng-template>
  </wa-tab-panel>

  <!-- DOM-only lazy using [lazy] -->
  <wa-tab-panel name="settings" [lazy]="true">Settings content</wa-tab-panel>
</wa-tab-group>
```

You can use `[(ngModel)]="activeTab"` to bind `active` tab name if two-way binding is required.

---

## CSS Parts Reference

| Part                                                                               | Description                |
| ---------------------------------------------------------------------------------- | -------------------------- |
| `base`                                                                             | Wrapper for all components |
| `nav`                                                                              | Tab navigation container   |
| `tabs`                                                                             | Wrapper for tab buttons    |
| `body`                                                                             | Wrapper for tab panels     |
| `scroll-button`, `scroll-button-start`, `scroll-button-end`, `scroll-button__base` | Scroll controls            |

---

## Dependencies

Automatically includes:

* `<wa-icon>`
* `<wa-icon-button>`
* `<wa-tab>`
* `<wa-tab-panel>`
