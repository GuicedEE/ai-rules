# File Input Component Rules

📌 These rules align with the enterprise standards and the WebAwesome Angular wrapper in this project. See group index: ../README.md and framework index: ./README.md

## Overview

`<wa-file-input>` lets users select files via click or drag-and-drop. It supports single or multiple selection, accept filters, and SSR-friendly label/hint rendering.

Important:
- Boolean attributes must be bound with Angular syntax (e.g., `[multiple]="true"`).
- Prefer accessible labels via the `label` attribute or `label` slot.

---

## Inputs

- `size`: `'small' | 'medium' | 'large'` (default: `medium`)
- `label`: `string`
- `hint`: `string`
- `multiple`: `boolean`
- `accept`: `string` — comma-separated list of unique file type specifiers
- `required`: `boolean`
- `with-label`: `boolean` — SSR hint to render label slot in initial HTML
- `with-hint`: `boolean` — SSR hint to render hint slot in initial HTML

## Events

- `input` — when file selection changes
- `change` — when files are added or removed (committed)
- `focus` — dropzone focus
- `blur` — dropzone blur
- `wa-invalid` — constraint validation failed

## Slots

- `label` — file input label (alternative to `label` prop)
- `hint` — hint text (alternative to `hint` prop)
- `dropzone` — custom content inside the dropzone area
- `file-icon` — custom icon for non-image files

## CSS Parts

- `label`, `hint`, `base`, `dropzone`, `dropzone-icon`, `dropzone-text`, `file-list`, `file`, `file-thumbnail`, `file-image`, `file-icon`, `file-details`, `file-name`, `file-size`, `remove-button`

## Angular Usage

```html
<!-- Single file -->
<wa-file-input label="Upload a file" accept="image/*"></wa-file-input>

<!-- Multiple files with hint and validation -->
<wa-file-input
  size="large"
  label="Upload images"
  hint="PNG or JPG only"
  accept="image/png, image/jpeg"
  [multiple]="true"
  [required]="true">
</wa-file-input>
```

## Notes

- When using `accept`, ensure values are valid unique file type specifiers.
- Listen to `wa-invalid` for custom validation flows.
