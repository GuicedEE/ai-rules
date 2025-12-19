# WaPage Rules

**Version:** 1.0  
**Status:** ✅ Complete (Phase 2)  
**Last Updated:** December 3, 2025  
**Location:** Enterprise Rules Repository

---

## Overview

**WaPage** is the **primary layout container** for the WebAwesome Pro library. It provides a responsive, semantic page structure with support for headers, navigation, main content, sidebars, and footers. WaPage is the parent component that orchestrates 18 sub-components (11 layout containers + 7 control components) to create modern, accessible page layouts.

### Purpose
- Organize complex page layouts with semantic HTML structure
- Support responsive design with mobile breakpoints and navigation toggles
- Provide accessibility features (ARIA landmarks, skip-to-content links)
- Integrate with Angular directives for reactive property binding

### Place in Hierarchy
```
WaPage (root layout)
├── WaPageBanner (slot: "banner")
├── WaPageHeader (slot: "header")
├── WaPageSubHeader (slot: "subheader")
├── WaPageContentsNavigationHeader (slot: "navigation-header")
├── WaPageContentsNavigation (slot: "navigation")
├── WaPageContentsNavigationFooter (slot: "navigation-footer")
├── WaPageContentsMainHeader (slot: "main-header")
├── WaPageContentsMain (slot: "main") — Primary content
├── WaPageContentsMainFooter (slot: "main-footer")
├── WaPageContentsAside (slot: "aside")
├── WaPageFooter (slot: "footer")
├── WaPageSkipToContent (slot: "skip-to-content")
├── WaPageMenu (slot: "menu")
├── WaPageNavigationToggle (slot: "navigation-toggle")
├── WaPageNavigationToggleIcon (slot: "navigation-toggle-icon")
├── WaPageDialogWrapper (slot: "dialog-wrapper")
└── WaPageContent (default slot)
```

---

## JWebMP Java Class

- **Canonical Name:** `com.jwebmp.webawesomepro.components.page.WaPage`
- **Fully Qualified Class:** `com.jwebmp.webawesomepro.components.page.WaPage<J extends WaPage<J>>`
- **Module:** `com.jwebmp.webawesomepro`
- **Extends:** `ComponentBase<T>` (JWebMP core)
- **Pattern:** CRTP (Curiously Recurring Template Pattern)

### Locations
- **Source File:** `src/main/java/com/jwebmp/webawesomepro/components/page/WaPage.java`
- **Test File:** `src/test/java/com/jwebmp/webawesomepro/components/page/WaPageTest.java`
- **Library Docs:** Library root `docs/rules/wa-page.rules.md` (mirrors this file)

---

## Usage Patterns (CRTP Fluent API)

### Basic Instantiation
```java
import com.jwebmp.webawesomepro.components.page.WaPage;

// Create a WaPage with fluent API
WaPage page = new WaPage()
    .setMobileBreakpoint("920px")
    .setNavOpen(false)
    .setMenuWidth("15rem")
    .setAsideWidth("20rem");

// Add content
page.getHeader().add(new Heading(1, "My App"));
page.getMainContent().add(new Paragraph("Hello, World!"));
page.getAside().add(new Sidebar());
```

### Sub-Component Access (Lazy Initialization)
```java
// Sub-components are created on-demand via getter methods
WaPageHeader header = page.getHeader();
WaPageContentsNavigation nav = page.getNavigation();
WaPageContentsMain main = page.getMainContent();
WaPageContentsAside aside = page.getAside();
WaPageFooter footer = page.getFooter();
```

### Navigation Control
```java
// Show/hide navigation drawer (mobile-friendly)
page.showNavigation();
page.hideNavigation();
page.toggleNavigation();
```

---

## Inputs & Outputs (Angular Directive)

### @Input Properties (Property Binding)

The Angular `WaPageDirective` exposes these properties as `@Input()` for reactive binding:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `mobileBreakpoint` | string \| number | `"768px"` | Breakpoint threshold for mobile/desktop view |
| `navOpen` | boolean | `false` | Whether navigation drawer is initially open |
| `view` | "mobile" \| "desktop" | `"desktop"` | Current view mode |
| `disableSticky` | string | `""` | Set if sticky positioning disabled |
| `navigationPlacement` | "start" \| "end" | `"start"` | Position of navigation drawer |
| `menuWidth` | string | `"15rem"` | CSS: `--menu-width` |
| `mainWidth` | string | `"auto"` | CSS: `--main-width` |
| `asideWidth` | string | `"20rem"` | CSS: `--aside-width` |

### @Output Events (Event Binding)

| Event | Payload Type | Description |
|-------|--------------|-------------|
| `navToggle` | `boolean` | Navigation drawer toggled; emits new state |

---

## Slot Projection

WaPage uses Angular's `ng-content` with attribute selectors for semantic content projection.

### Named Slots (Attribute Selectors)

| Slot Attribute | Purpose | Optional |
|---|---|---|
| `[waPageBanner]` | Top banner area | Yes |
| `[waPageHeader]` | Main header | No |
| `[waPageSubHeader]` | Secondary header | Yes |
| `[waPageContentsNavigation]` | Main navigation | No |
| **(default)** | Primary page content | No |
| `[waPageContentsAside]` | Sidebar | Yes |
| `[waPageFooter]` | Page footer | No |

---

## Styling & Theming

### CSS Custom Properties

| Property | Purpose | Default |
|----------|---------|---------|
| `--menu-width` | Navigation drawer width | `15rem` |
| `--main-width` | Main content width | `auto` |
| `--aside-width` | Sidebar width | `20rem` |

### Responsive Behavior

- **Mobile** (< breakpoint): Navigation drawer hidden by default
- **Desktop** (>= breakpoint): Navigation always visible

---

## Accessibility

### ARIA Landmarks & Roles

- `<header>` → `banner` role
- `<nav>` → `navigation` role
- `<main>` → `main` role
- `<aside>` → `complementary` role
- `<footer>` → `contentinfo` role

### Keyboard Navigation

- **Tab/Shift+Tab:** Focus through interactive elements
- **Enter:** Activate buttons, follow links
- **Escape:** Close navigation drawer

### Screen Reader Support

- Skip-to-content link available
- Semantic landmarks for navigation
- ARIA labels on toggle buttons

---

## Integration with Enterprise Rules

- [WebAwesome Components](../webawesome/README.md)
- [JWebMP Client](../jwebmp/client/README.md)
- [Angular (Base)](../../language/angular/README.md)
- [Angular Awesome](../angular-awesome/README.md)
- [GuicedEE Client](../../backend/guicedee/client/README.md)
- [Fluent API (CRTP)](../../backend/fluent-api/crtp.rules.md)
- [Java 25 LTS](../../language/java/java-25.rules.md)
- [Documentation-as-Code](../../architecture/README.md)

---

## See Also

- **Index:** [Component Rules Index](README.md)
- **Related:** [WaPageHeader](wa-page-header.rules.md)
- **Library Docs:** Library root `docs/rules/wa-page.rules.md`
- **Tests:** `src/test/java/com/jwebmp/webawesomepro/components/page/WaPageTest.java`

---

**Last Updated:** December 3, 2025  
**Version:** 1.0  
**Status:** ✅ Production Ready  
**Approval:** Blanket approval (Phase 2 complete)
