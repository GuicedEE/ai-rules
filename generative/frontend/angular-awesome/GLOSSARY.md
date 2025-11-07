# Angular Awesome Glossary (Web Awesome for Angular)

Purpose
- Topic-first glossary for Angular integration of Web Awesome custom elements (“wa-*”).
- Applies to all files in rules/generative/frontend/angular-awesome/.
- Precedence: this glossary overrides the root glossary and any generic web components guidance for Angular Awesome scope.
- Goal: reduce duplication, standardize wording, and guide LLM interpretation for consistent Angular wrappers and usage.

Scope
- Covers Angular usage of Web Awesome custom elements via native tags (e.g., <wa-button>) and/or thin Angular standalone directive wrappers.
- Defines binding, events, styling, forms, SSR, and interop policies that component rule files reference.

Integration Model
- Native custom elements are consumed in Angular templates as-is. For DX and strict typing, Angular standalone directive wrappers may be provided per component.
- When wrappers are present:
  - Selectors match the custom element tag (e.g., wa-button).
  - Inputs/outputs mirror component attributes/events.
  - Internals bridge HTML attributes and JS-only properties at runtime via ElementRef/Renderer.
- When wrappers are not present:
  - CUSTOM_ELEMENTS_SCHEMA must be enabled in the Angular app or feature module to avoid template diagnostics.
  - Attribute and property binding semantics remain the same.

Binding Rules
- Prefer attribute-equivalent @Input() bindings for simple values that map to HTML attributes (string/number/enum).
- Use property binding for booleans. Do not pass “true”/“false” as strings for boolean inputs.
- JS-only properties (e.g., keyframes, currentTime) are set programmatically on the element instance (e.g., el.nativeElement.keyframes = ...).
- Provide string fallbacks where underlying components accept CSSNumberish or string tokens (e.g., duration="200" or [duration]="200").

Boolean Binding Policy
- Always bind booleans using [prop]="expr".
- Examples:
  - [disabled]="isDisabled"
  - [loading]="true"
  - [pill]="formStyle.pill"
- Avoid bare attributes for booleans (disabled, loading) unless the component explicitly documents boolean-attribute-only semantics.

Attribute vs Property Bridging
- Attributes are set once on init and updated on changes: renderer.setAttribute(nativeEl, name, valueString).
- JS-only properties must be assigned directly on the element: (nativeEl as any).keyframes = keyframes.
- When both an attribute and a JS property exist, the JS property takes precedence for dynamic control.

Events
- Web Awesome emits CustomEvents (often named wa-*) that bubble; Angular templates subscribe via (eventName)="handler()".
- When wrappers expose outputs to avoid reserved/native name collisions, prefer suffixed output names (e.g., blurEvent, focusEvent) instead of blur/focus.
- Typical event bindings:
  - (wa-start), (wa-finish), (wa-cancel) for animation lifecycle
  - (waInvalid) for validity failures (or the underlying event name when present)
- Do not rename semantic wa-* events unless necessary to avoid Angular native collisions.

Slots and CSS Parts
- Slot usage:
  - default: primary content
  - prefix/suffix: leading/trailing adornments (e.g., icons)
  - separator and other component-specific named slots
- CSS parts are styled with ::part(...). Do not rely on internal structure beyond documented parts.
- Prefer host classes and CSS custom properties for theming over deep selectors.

CSS Custom Properties
- Angular inputs MAY map to CSS custom properties for theming (e.g., [textColor] → --text-color).
- When mapping:
  - Use kebab-case for the CSS custom property.
  - Set via style.setProperty on the custom element to avoid specificity issues.
  - Keep mappings documented in each component’s rules file.

Forms Policy
- Default: template-driven with [(ngModel)]. Name attribute is required when using ngModel inside a form.
- Reactive forms: allowed ONLY when the specific component rules explicitly state support for formControl/formControlName.
  - Example: Checkbox supports reactive forms (per component rules).
  - Example: Input does NOT support reactive forms; use ngModel only (per component rules).
- Do not invent [(checked)] two-way bindings; use ngModel for two-way state where supported.

SSR and Hydration
- Angular SSR/Hydration works with custom elements. Follow these practices:
  - Avoid accessing element instance properties before the view is hydrated; set attributes first.
  - Provide SSR hint flags where a component’s markup differs when a label or hint is present (e.g., withLabel, withHint).
  - Defer assignment of JS-only properties to ngAfterViewInit or in a zone-stable callback.
- Prefer standalone directives to avoid needing CUSTOM_ELEMENTS_SCHEMA in strictly typed SSR builds.

Performance and Interop
- Initialize attributes/inline styles in ngOnInit or ngOnChanges with minimal change detection churn.
- Use one-time attribute setup where possible; reserve frequent updates for JS properties (which are faster for runtime control).
- Integrate with IntersectionObserver for visibility-triggered behaviors, not change detection loops.
- Avoid querying internal parts; interact only via documented attributes, properties, events, parts, and slots.

Accessibility
- Ensure accessible labels for inputs/controls (label input or projected content).
- Provide aria-attributes when applicable; don’t duplicate semantics already provided by components.
- Breadcrumb containers should have label or aria-label describing the nav landmark.

Security
- Do not bind unsanitized HTML to slots or properties that accept raw HTML.
- Limit dynamic style/property application to documented, supported inputs and CSS custom properties.

LLM Interpretation Guidance
- When asked to create or modify an Angular Awesome wrapper:
  - Use a standalone directive that selects the wa-* tag and mirrors documented attributes/outputs.
  - Map simple values to attributes; map booleans via property binding; assign JS-only properties directly to the element.
  - Expose the underlying element via a readonly getter (e.g., nativeEl) when programmatic control is needed.
  - Provide event outputs matching emitted CustomEvent names unless collisions require alternative naming (e.g., blurEvent).
  - Do not invent reactive forms support. Only implement if the component rules explicitly include it.
- When generating examples:
  - Show boolean bindings with [prop]="...".
  - Include at least one slot example and one CSS part snippet where relevant.
  - Prefer minimal, declarative examples; move dynamic/imperative control to a short method snippet.
- When choosing between attribute and property:
  - Attribute = stable, declarative configuration.
  - Property = dynamic, runtime control; prefer in lifecycle after view init.

Component Rules Routing (examples)
- Animation: rules/generative/frontend/angular-awesome/animation.rules.md
- Button: rules/generative/frontend/angular-awesome/button.rules.md
- Checkbox: rules/generative/frontend/angular-awesome/checkbox.rules.md
- Input: rules/generative/frontend/angular-awesome/input.rules.md
- Breadcrumbs: rules/generative/frontend/angular-awesome/breadcrumbs.rules.md
- Naming convention: each wa-* component has a corresponding .rules.md file colocated under rules/generative/frontend/angular-awesome/.

Examples

- Boolean inputs and slots
  <wa-button variant="brand" [loading]="isSaving">
    <wa-icon slot="prefix" name="gear"></wa-icon>
    Save
  </wa-button>

- Animation with dynamic property control
  <wa-animation #anim name="flip" [playbackRate]="2">
    <div class="box"></div>
  </wa-animation>
  <button (click)="startAnim(anim)">Play</button>

  // In component
  startAnim(animRef: ElementRef<HTMLElement> | any) {
    const el = (animRef?.nativeElement ?? animRef) as any;
    el.play = true;
  }

- CSS parts
  wa-button.pink::part(base) {
    background: #ff1493;
    color: white;
    border-radius: 6px;
  }

Glossary Terms (anchor wording)
- Angular Awesome: Angular usage of Web Awesome custom elements via native tags or thin standalone directive wrappers.
- JS-only property: A property that cannot be configured via HTML attribute and must be set on the element instance (e.g., keyframes, currentTime).
- Slot: A named insertion point in a custom element (default, prefix, suffix, separator, etc.).
- CSS Part: A styleable shadow part exposed by the component, targeted via ::part(name).
- CSS Custom Property Mapping: Angular inputs that mirror and set --custom-properties on the custom element for theming.
- Template-driven Forms Default: Use [(ngModel)] unless the component rule explicitly states reactive support.
- Event Collision Mitigation: Use renamed outputs (e.g., blurEvent) to avoid collisions with native element methods.

Dependencies
- Web Awesome core custom elements must be available/registered at runtime before use (typically via imports or a loader).
- For icon slots, ensure <wa-icon> is available.
- Some patterns (e.g., observers, programmatic control) require imperative code in the host component/service.

Compliance
- Follow per-component rules for attributes, events, slots, CSS parts, and property mappings.
- Respect this glossary’s precedence to resolve conflicts (e.g., forms support defaults).
- Do not access private internals; rely only on documented API surface.

---
## Component Index and Routing

The following Angular Awesome components are covered in this directory. Each bullet points to the canonical rules file; examples live alongside as *.example.md.

### Controls and Inputs
- wa-button — ./button.rules.md
- wa-buttongroup — ./buttongroup.rules.md
- wa-input — ./input.rules.md
- wa-textarea — ./textarea.rules.md
- wa-checkbox — ./checkbox.rules.md
- wa-radio — ./radio.rules.md
- wa-radio-group — ./radio-group.rules.md
- wa-select — ./select.rules.md
- wa-option — ./option.rules.md
- wa-switch — ./switch.rules.md
- wa-slider — ./slider.rules.md
- wa-color-picker — ./color-picker.rules.md

### Data Display and Status
- wa-badge — ./badge.rules.md
- wa-card — ./card.rules.md
- wa-avatar — ./avatar.rules.md
- wa-tag — ./tag.rules.md
- wa-progress-bar — ./progress-bar.rules.md
- wa-progress-ring — ./progress-ring.rules.md
- wa-skeleton — ./skeleton.rules.md
- wa-spinner — ./spinner.rules.md
- wa-rating — ./rating.rules.md
- wa-qr-code — ./qr-code.rules.md
- wa-details — ./details.rules.md
- wa-divider — ./divider.rules.md
- wa-callout — ./callout.rules.md
- wa-comparison — ./comparison.rules.md
- wa-icon — ./icon.rules.md

### Navigation and Structure
- wa-breadcrumb — ./breadcrumbs.rules.md
- wa-breadcrumb-item — ./breadcrumb-item.rules.md
- wa-menu — ./menu.rules.md
- wa-tab — ./tab.rules.md
- wa-tab-panel — ./tab-panel.rules.md
- wa-tab-group — ./tab-group.rules.md
- wa-page — ./page.rules.md
- wa-include — ./include.rules.md
- wa-tree — ./tree.rules.md
- wa-tree-item — ./tree-item.rules.md

### Overlays and Popups
- wa-dialog — ./dialog.rules.md
- wa-drawer — ./drawer.rules.md
- wa-popover — ./popover.rules.md
- wa-popup — ./popup.rules.md
- wa-tooltip — ./tooltip.rules.md
- wa-dropdown — ./dropdown.rules.md
- wa-dropdown-item — ./dropdown-item.rules.md
- wa-copy-button — ./copy-button.rules.md

### Media, Layout, and Effects
- wa-animated-image — ./animated-image.rules.md
- wa-animation — ./animation.rules.md
- wa-carousel — ./carousel.rules.md
- wa-split-panel — ./split-panel.rules.md
- wa-scroller — ./scroller.rules.md
- wa-zoomable-frame — ./zoomable-frame.rules.md

### Formatting and Time
- wa-format-number — ./format-number.rules.md
- wa-format-date — ./format-date.rules.md
- wa-format-bytes — ./format-bytes.rules.md
- wa-relative-time — ./relative-time.rules.md

### Observers and Utilities
- wa-intersection-observer — ./intersection-observer.rules.md
- wa-mutation-observer — ./mutation-observer.rules.md
- wa-resize-observer — ./resize-observer.rules.md
- wa-include — ./include.rules.md

### Conventions
- Rules files: one per component as {name}.rules.md; examples in {name}.example.md.
- Tag naming: all components use the wa-* prefix in templates (e.g., &lt;wa-button&gt;). Where in doubt, consult the respective rules file's selector section.
- Forms support: defaults derive from this glossary; per-component rules may explicitly broaden or restrict support.

### Routing Anchors
- Controls and Inputs, Data Display and Status, Navigation and Structure, Overlays and Popups, Media, Layout, and Effects, Formatting and Time, Observers and Utilities.
