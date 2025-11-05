# WebAwesome Components Index

This directory contains component-specific rule files for the WebAwesome UI component set used with JWebMP. Use this index to navigate directly to the relevant component rules. Host projects should reference this directory when the framework/topic is “WebAwesome.”

## How to use this index
- Choose this framework/topic only if your host project uses WebAwesome.
- Click a component link below to open its rule file.
- If a request mentions a variant (e.g., “number input”) and there is no dedicated file, follow the subsection link under the broader rule (see Input → Number Input).

## Components

- Animated Image — ./animated-image.rules.md
- Animation — ./animation.rules.md
- Avatar — ./avatar.rules.md
- Badge — ./badge.rules.md
- Breadcrumbs — ./breadcrumbs.rules.md
- Breadcrumb Item — ./breadcrumb-item.rules.md
- Button — ./button.rules.md
- Button Group — ./buttongroup.rules.md
- Callout — ./callout.rules.md
- Card — ./card.rules.md
- Carousel — ./carousel.rules.md
- Carousel Item — ./carousel.rules.md#carousel-item
- Checkbox — ./checkbox.rules.md
- Color Picker — ./color-picker.rules.md
- Comparison — ./comparison.rules.md
- Copy Button — ./copy-button.rules.md
- Details — ./details.rules.md
- Dialog — ./dialog.rules.md
- Divider — ./divider.rules.md
- Drawer — ./drawer.rules.md
- Dropdown — ./dropdown.rules.md
- Dropdown Item — ./dropdown-item.rules.md
- Format Bytes — ./format-bytes.rules.md
- Format Date — ./format-date.rules.md
- Format Number — ./format-number.rules.md
- Icon — ./icon.rules.md
- Include — ./include.rules.md
- Input — ./input.rules.md
  - Number Input (subsection) — ./input.rules.md#number-input
- Intersection Observer — ./intersection-observer.rules.md
- Mutation Observer — ./mutation-observer.rules.md
- Option — ./option.rules.md
- Page — ./page.rules.md
- Popover — ./popover.rules.md
- Popup — ./popup.rules.md
- Progress Bar — ./progress-bar.rules.md
- Progress Ring — ./progress-ring.rules.md
- QR Code — ./qr-code.rules.md
- Radio — ./radio.rules.md
- Radio Group — ./radio-group.rules.md
- Rating — ./rating.rules.md
- Relative Time — ./relative-time.rules.md
- Resize Observer — ./resize-observer.rules.md
- Scroller — ./scroller.rules.md
- Select — ./select.rules.md
- Skeleton — ./skeleton.rules.md
- Slider — ./slider.rules.md
- Spinner — ./spinner.rules.md
- Split Panel — ./split-panel.rules.md
- Switch — ./switch.rules.md
- Tab — ./tab.rules.md
- Tab Group — ./tab-group.rules.md
- Tab Panel — ./tab-panel.rules.md
- Tag — ./tag.rules.md
- Textarea — ./textarea.rules.md
- Tooltip — ./tooltip.rules.md
- Tree — ./tree.rules.md
- Tree Item — ./tree-item.rules.md
- Zoomable Frame — ./zoomable-frame.rules.md

### Legacy (not part of React 3.0.0 wrappers but may exist in WebAwesome web components)
- Icon Button — ./icon-button.rules.md
- Menu — ./menu.rules.md

## Notes
- Group: Frontend → Standard — ../README.md
- Rule files use the .rules.md suffix and live alongside example files (.example.md).
- This README is an index and overview; authoritative details live in each component’s rule file.

### Prompt Language Alignment (enforced)
- When prompting for WebAwesome components, use the WebAwesome-aligned component names to avoid ambiguity and ensure correct routing:
  - “button” → use “WaButton” (see: ./button.rules.md)
  - “icon button” → use “WaIconButton” (see: ./icon-button.rules.md)
  - “input” → use “WaInput” (see: ./input.rules.md)
  - “row” (layout) → use “WaCluster”
  - “column/stack” (layout) → use “WaStack”
- If a request mentions a variant and there is no dedicated file, follow the subsection link under the broader rule (e.g., WaInput → Number Input: ./input.rules.md#number-input).
- Copy these aligned names into your project’s GLOSSARY.md so prompts and documents share the same terminology (see: ../../../GLOSSARY.md).
