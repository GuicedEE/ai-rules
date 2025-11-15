### 📘 `wa-badge.rules.md`

**Angular Wrapper Guidelines for `<wa-badge>` (Web Awesome)**

---

## 📝 Purpose

Wrap the `<wa-badge>` Web Component inside an Angular 19 directive to allow declarative usage, input/output binding, and integration with Angular templates.

---

## 🧹 Global Rule Notes

> 🛠️ Web Awesome Angular Integration uses global assumptions for **selectors**, **boolean attributes**, and **custom style properties**:
>
> * Tag selectors will **match the Web Component tag name** (e.g. `wa-badge`, not `app-wa-badge`)
> * Boolean attributes should only render when `true`, and never appear as `false`, `null`, or `undefined`
> * Angular inputs should map to Web Awesome CSS custom properties (e.g. `@Input() backgroundColor → --background-color`)
> * For most components, Angular acts as a declarative wrapper; Web Awesome manages rendering
> * Use `<ng-content>` for projection — do **not** use `label`, `innerHtml`, or `TemplateRef` unless explicitly required by a complex pattern
> * These rules apply to **all Web Awesome components except** patterns (`wa-page`, etc.) and inputs/selects, which have specialized lifecycles or bindings
> * Ensure `CUSTOM_ELEMENTS_SCHEMA` is enabled in all modules using these components

---

## 🎯 Component Goals

* Represent `<wa-badge>` as an Angular declarative directive
* Bind attributes: `variant`, `appearance`, `pill`, `pulse`
* Enable Angular-style class and style bindings
* Allow slot projection for content via native tag
* Support CSS variable binding via `[style]`
* Ensure `@Directive({ selector: 'wa-badge' })` is respected in Angular library builds

---

## 🔧 Inputs

```ts
@Input() variant: 'brand' | 'neutral' | 'success' | 'warning' | 'danger' | 'inherit' = 'inherit';
@Input() appearance: 'accent' | 'filled' | 'outlined' = 'accent';
@Input() pill?: boolean | null;
@Input() pulse?: boolean | null;
@Input() fontSize?: string; // Optional font-size override (var token or fixed size)

@Input() backgroundColor?: string; // --background-color
@Input() borderColor?: string;     // --border-color
@Input() textColor?: string;       // --text-color
```

---

## 🛠️ Implementation

```ts
import { Input, ElementRef, OnInit, inject } from '@angular/core';
import { Directive, Renderer2 } from '@angular/core';

@Directive({
  selector: 'wa-badge',
  standalone: true
})
export class WaBadgeDirective implements OnInit {
  @Input() variant: 'brand' | 'neutral' | 'success' | 'warning' | 'danger' | 'inherit' = 'inherit';
  @Input() appearance: 'accent' | 'filled' | 'outlined' = 'accent';
  @Input() pill?: boolean | null;
  @Input() pulse?: boolean | null;
  @Input() fontSize?: string;

  @Input() backgroundColor?: string;
  @Input() borderColor?: string;
  @Input() textColor?: string;

  el = inject(ElementRef);
  renderer = inject(Renderer2);

  ngOnInit() {
    const nativeEl = this.el.nativeElement as HTMLElement;

    this.setAttr('variant', this.variant);
    this.setAttr('appearance', this.appearance);
    this.setBoolAttr('pill', this.pill);
    this.setBoolAttr('pulse', this.pulse);

    if (this.fontSize) nativeEl.style.fontSize = this.fontSize;
    if (this.backgroundColor) nativeEl.style.setProperty('--background-color', this.backgroundColor);
    if (this.borderColor) nativeEl.style.setProperty('--border-color', this.borderColor);
    if (this.textColor) nativeEl.style.setProperty('--text-color', this.textColor);
  }

  private setAttr(name: string, value: string | null) {
    if (value != null) {
      this.renderer.setAttribute(this.el.nativeElement, name, value);
    }
  }

  private setBoolAttr(name: string, value: boolean | null | undefined) {
    if (value) {
      this.renderer.setAttribute(this.el.nativeElement, name, '');
    }
  }
}
```

---

## 💏 Slots

* Default slot only (badge content)
* No named slots required

---

## 📏 Sizing

* Size is font-relative
* Allow `fontSize` input (accepts CSS size or `--wa-font-size-*` tokens)

---

## 💡 Usage Examples

### Static Badge

```html
<wa-badge variant="brand">Brand</wa-badge>
```

### Angular Enhanced Badge

```html
<wa-badge variant="warning" appearance="outlined" [pill]="true" [pulse]="true" [textColor]="'red'">
  4
</wa-badge>
```

### With Font Token

```html
<wa-badge variant="success" [fontSize]="'var(--wa-font-size-s)'">✓</wa-badge>
```

---

📉 This directive-based rule ensures full rendering, styling, and usage support of `<wa-badge>` in Angular applications using a minimal declarative approach.

> 📌 Reminder: ensure your Angular module enables `CUSTOM_ELEMENTS_SCHEMA` to allow tag selectors like `<wa-badge>` to be recognized without error.
