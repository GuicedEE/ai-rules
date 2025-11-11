# Page Component – Angular Wrapper Documentation

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

## Overview

The `<wa-page>` component is a comprehensive layout container that structures web pages with rich support for slots and responsive navigation. The Angular wrapper must support full slot projection, input bindings for layout control, and imperative methods for toggling the navigation drawer.

---

## ✅ Inputs

| Input                 | Type                    | Description                                                        |
| --------------------- | ----------------------- | ------------------------------------------------------------------ |
| `mobileBreakpoint`    | `string \| number`      | Breakpoint for collapsing nav into drawer (e.g., `768px`, `50ch`). |
| `navOpen`             | `boolean`               | Controls mobile nav drawer state.                                  |
| `view`                | `'mobile' \| 'desktop'` | Read-only view mode based on `mobileBreakpoint`.                   |
| `disableSticky`       | `string`                | Space-separated list of sticky sections to disable.                |
| `navigationPlacement` | `'start' \| 'end'`      | Placement of mobile nav drawer.                                    |

---

## 🎨 Style Inputs

Set these as standard Angular inputs to simplify usage. The directive will bind them to the correct CSS custom properties on the host:

| Input Name        | Description                         | Underlying CSS Variable |
| ----------------- | ----------------------------------- | ----------------------- |
| `menuWidth`       | Width of the navigation/menu column | `--menu-width`          |
| `mainWidth`       | Width of the main content area      | `--main-width`          |
| `asideWidth`      | Width of the aside column           | `--aside-width`         |
| `bannerHeight`    | Height of the banner area           | `--banner-height`       |
| `headerHeight`    | Height of the header                | `--header-height`       |
| `subheaderHeight` | Height of the subheader             | `--subheader-height`    |

These inputs let developers use familiar Angular property binding:

```html
<wa-page [menuWidth]="'15rem'" [asideWidth]="'20rem'" [headerHeight]="'64px'"></wa-page>
```

No need to bind directly to `style` unless required.

---

## 📦 Slot Selectors

Use `ng-content select="..."` to bind to component slots:

| Slot Name                | Selector Attribute             |
| ------------------------ | ------------------------------ |
| default (main content)   | *(no selector)*                |
| `banner`                 | `[waPageBanner]`               |
| `header`                 | `[waPageHeader]`               |
| `subheader`              | `[waPageSubheader]`            |
| `navigation-header`      | `[waPageNavigationHeader]`     |
| `navigation`             | `[waPageNavigation]`           |
| `navigation-footer`      | `[waPageNavigationFooter]`     |
| `main-header`            | `[waPageMainHeader]`           |
| `main-footer`            | `[waPageMainFooter]`           |
| `aside`                  | `[waPageAside]`                |
| `footer`                 | `[waPageFooter]`               |
| `skip-to-content`        | `[waPageSkipToContent]`        |
| `menu`                   | `[waPageMenu]`                 |
| `navigation-toggle`      | `[waPageNavigationToggle]`     |
| `navigation-toggle-icon` | `[waPageNavigationToggleIcon]` |
| `dialog-wrapper`         | `[waPageDialogWrapper]`        |

---

## 🧠 Methods

These are available via `@ViewChild()` or directly from the native element:

* `showNavigation()` – Opens mobile nav drawer.
* `hideNavigation()` – Closes mobile nav drawer.
* `toggleNavigation()` – Toggles nav drawer.

---

## 💡 Usage Guidelines

* Elements with `data-toggle-nav` trigger mobile nav drawer.
* Add `disableNavigationToggle="true"` to suppress default hamburger.
* Use `[view]` attribute (auto-reflected) for responsive style rules.
* Use `wa-desktop-only` and `wa-mobile-only` classes to conditionally show/hide content.
* Style slots individually using `[slot='name'] { ... }` CSS selectors.
* The page includes an accessible "Skip to content" link. Customize this via the `skip-to-content` slot using `[waPageSkipToContent]` to support i18n or custom phrasing.
* The `dialog-wrapper` slot can be used to project modals or floating layers that need to appear above the layout structure.

---

## 🧩 Example Usage (Angular Template)

```html
<wa-page
  [mobileBreakpoint]="920"
  [navOpen]="navDrawerOpen"
  [disableSticky]="'aside header'"
  [menuWidth]="'15rem'"
  [asideWidth]="'20rem'"
  [bannerHeight]="'40px'"
  [headerHeight]="'64px'"
  [subheaderHeight]="'32px'"
>
  <span waPageSkipToContent>Jump to main content</span>
  <div waPageBanner>Banner here</div>
  <header waPageHeader>Header content</header>
  <nav waPageSubheader>Breadcrumbs or nav controls</nav>
  <nav waPageNavigation>Links and actions</nav>
  <main>Main content projects here</main>
  <footer waPageFooter>Footer goes here</footer>
  <div waPageDialogWrapper>
    <!-- Modals go here -->
  </div>
</wa-page>
```

---

This documentation is auto-generated alongside the README, spec file, and example for the Web Awesome Angular wrapper directive for `<wa-page>`.
