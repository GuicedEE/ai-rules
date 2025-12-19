# WaPageHeader Rules

**Version:** 1.0  
**Status:** ✅ Complete (Phase 2)  
**Last Updated:** December 3, 2025  
**Location:** Enterprise Rules Repository

---

## Overview

**WaPageHeader** is a layout container that provides the main header area of a WaPage. It typically contains the site logo, main navigation, search functionality, and other top-level content.

### Purpose
- Provide a fixed or sticky header area at the top of the page
- Contain logo, title, search, user account menu, and other top-level controls
- Establish visual hierarchy and page identity
- Support responsive behavior

### Place in Hierarchy
```
WaPage
└── WaPageHeader (slot: "header")
    └── [Your custom header content]
```

---

## JWebMP Java Class

- **Canonical Name:** `com.jwebmp.webawesomepro.components.page.WaPageHeader`
- **Module:** `com.jwebmp.webawesomepro`
- **Extends:** `DivSimple<J>`
- **HTML Tag:** `<header slot="header">`
- **Pattern:** CRTP

---

## Usage Patterns (CRTP Fluent API)

### Access via Parent
```java
WaPage page = new WaPage();
WaPageHeader header = page.getHeader();

header.add(new Image().setSrc("logo.png"))
    .add(new Heading(1, "My Application"))
    .add(new SearchBox());
```

### Direct Instantiation
```java
WaPageHeader header = new WaPageHeader()
    .add(new Image().setSrc("logo.png"))
    .add(new Heading(1, "Page Title"))
    .add(new UserMenu());
```

---

## Inputs & Outputs (Angular Directive)

WaPageHeader is accessed as a slot in the `WaPageDirective` and doesn't directly expose @Input/@Output properties.

### Usage in Angular Templates

```html
<wa-page>
  <header waPageHeader class="bg-white shadow">
    <img src="assets/logo.png" alt="Company Logo" />
    <h1>Dashboard</h1>
    <nav>
      <a href="/home">Home</a>
      <a href="/products">Products</a>
    </nav>
  </header>
</wa-page>
```

---

## Slot Projection

WaPageHeader is itself a slot in WaPage. Content is projected directly into the header element.

### Named Slot in WaPage
- **Attribute Selector:** `[waPageHeader]`
- **HTML Slot Name:** `"header"`
- **Optional:** No

---

## Styling & Theming

### CSS Custom Properties

```css
header[slot="header"] {
  position: sticky;
  top: 0;
  background-color: var(--header-bg-color, #fff);
  border-bottom: 1px solid var(--border-color, #ddd);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  z-index: 100;
}
```

---

## Accessibility

- **Role:** `banner` (implicit for top-level `<header>`)
- **Keyboard Navigation:** Tab through all interactive elements
- **Screen Reader:** Semantic `<nav>` for navigation menus

---

## See Also

- **Index:** [Component Rules Index](README.md)
- **Parent:** [WaPage Rules](wa-page.rules.md)
- **Library Docs:** Library root `docs/rules/wa-page-header.rules.md`

---

**Last Updated:** December 3, 2025  
**Status:** ✅ Complete  
**Approval:** Blanket approval (Phase 2)
