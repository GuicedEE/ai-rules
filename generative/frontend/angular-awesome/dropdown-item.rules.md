# Dropdown Item Rules

Defines usage rules for WebAwesome Dropdown Item.

## Overview
- Tag: `<wa-dropdown-item>`
- Purpose: Represents an item inside `<wa-dropdown>` menus. Supports standard item, checkbox, and submenu behaviors.
- React wrapper: WaDropdownItem (onFocus, onBlur native events)
- Status: experimental (per types)
- Since: 3.0

## Attributes / Properties
- `type: 'standard' | 'checkbox' | 'submenu'` — Item type. Default: `standard`.
- `checked: boolean` — When `type='checkbox'`, indicates selection.
- `disabled: boolean` — Disables item interaction.
- `value: string` — Optional value used by parent logic (e.g., wa-dropdown selection handling).
- `href: string` — Optional link target; renders as anchor when provided.
- `target: string` — Anchor target (e.g., `_blank`).
- `rel: string` — Anchor rel.

Note: The exact attribute names may differ depending on the base web component; align with official docs if they diverge. The React typing emphasizes slots and CSS parts; events are native focus/blur.

## Slots
- default — Visible label/content.
- `icon` — Optional icon before the label (e.g., `<wa-icon>`).
- `details` — Supplementary info aligned after the label.
- `submenu` — Nested items to create submenus (typically other `<wa-dropdown-item>` elements).

## Events
- `focus` — Emitted when the item gains focus.
- `blur` — Emitted when the item loses focus.

## CSS Parts
- `checkmark` — Checkmark icon (a `<wa-icon>`) for checkbox items.
- `icon` — Icon slot container.
- `label` — Label slot container.
- `details` — Details slot container.
- `submenu-icon` — Submenu indicator icon (`<wa-icon>` element).
- `submenu` — Submenu container.

## Accessibility
- Ensure keyboard navigation via Arrow keys is supported by the parent menu/dropdown.
- Provide discernible text for screen readers in the label.
- Checkbox items should reflect `aria-checked` where appropriate.

## Usage Example
```html
<wa-dropdown>
  <wa-button slot="trigger" caret>Actions</wa-button>
  <div>
    <wa-dropdown-item>Standard</wa-dropdown-item>
    <wa-dropdown-item type="checkbox" checked>
      <span slot="icon"><wa-icon name="check"></wa-icon></span>
      Checkbox
    </wa-dropdown-item>
    <wa-dropdown-item type="submenu">
      More
      <div slot="submenu">
        <wa-dropdown-item>Nested A</wa-dropdown-item>
        <wa-dropdown-item disabled>Nested B</wa-dropdown-item>
      </div>
    </wa-dropdown-item>
  </div>
</wa-dropdown>
```

## Integration Notes
- When consuming selection from a dropdown, prefer listening to the parent `(wa-select)` event and reading `event.detail.item`.
- In frameworks that reserve `focus`/`blur` names, alias to `focusEvent`/`blurEvent` to avoid conflicts.
