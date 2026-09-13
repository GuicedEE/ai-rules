---
name: jwebmp-website-aside-routing
description: "Synchronize JWebMP WaPage main and named aside routes for per-page side panels and \"On this page\" navigation."
---

# JWebMP Website Aside Routing

Pattern for wiring a secondary, named Angular router-outlet ("aside") alongside the
primary content outlet inside a `WaPage`-based JWebMP/Angular site, so every top-level
page can optionally render a synchronized "On this page" side panel. This is the exact
pattern used by the `GuicedEE/website` and `JWebMP/website` modules.

## When to use this skill

- Building a JWebMP + WebAwesome (`WaPage`) documentation/marketing site with a
  persistent aside/sidebar area.
- Wanting the aside content to automatically switch when the user navigates between
  primary routes, without each page manually managing the aside.
- Replicating or extending the GuicedEE/JWebMP website navigation/aside architecture in
  a new or existing site module.

## Architecture overview

Two named router-outlets live inside the same `WaPage`:

- **`primary`** outlet (unnamed default) — rendered via `page.getMain().add(new RouterOutlet<>())`.
- **`aside`** outlet — rendered via `page.getAside().add(new RouterOutlet<>("aside"))`.

Each top-level page is a normal `@NgRoutable(path = "xxx")` component rendered into the
primary outlet. Pages that want a side panel get a **sibling component** in a
`pages/aside/` package, routed to the **same path** but targeting the `aside` outlet:

```java
@NgRoutable(path = "services")                    // primary outlet (default)
public class ServicesPage extends WebsitePage<ServicesPage> { ... }

@NgRoutable(path = "services", outlet = "aside")  // aside outlet
public class ServicesAsidePage extends DivSimple<ServicesAsidePage>
        implements INgComponent<ServicesAsidePage> { ... }
```

A boot-level component (`WebsiteBoot`) owns:
1. The `WaPage` shell with both `RouterOutlet`s.
2. A TypeScript `asideRoutes` map (primary path → aside path) generated via `fields()`.
3. A `Router.events` subscription (added via `onInit()`) that keeps the `aside` outlet
   in sync with the current primary route — activating the matching aside route when
   present, and clearing the `aside` outlet when the primary route has no aside.

Not every page needs an entry in `asideRoutes` — pages without an aside variant are
simply omitted, and the subscription removes any stale `aside` outlet content.

## 1. WaPage shell wiring (`WebsiteBoot`)

```java
@NgComponent("myapp-app")
@NgRoutable(path = "")
@NgImportReference(value = "Router, NavigationStart, NavigationEnd", reference = "@angular/router")
@NgImportReference(value = "inject", reference = "@angular/core")
@NgImportReference(value = "filter", reference = "rxjs/operators")
@NgImportReference(value = "DOCUMENT", reference = "@angular/common")
public class WebsiteBoot extends DivSimple<WebsiteBoot> implements INgComponent<WebsiteBoot> {
    public WebsiteBoot() {
        WaPage<?> page = new WaPage<>();
        // ... header / menu / navigation wiring ...

        page.getMain().add(new RouterOutlet<>());       // primary outlet
        page.getAside().add(new RouterOutlet<>("aside")); // named aside outlet

        add(page);
    }
```

`WaPage` exposes `getMain()`/`getAside()` slots that map onto the WebAwesome page
layout regions (`main`/`aside` slots of `wa-page`).

## 2. Declare the aside route map + navigating flag

In `fields()`:

```java
@Override
public List<String> fields() {
    var f = new ArrayList<>(INgComponent.super.fields());
    f.add("private router: Router = inject(Router);");
    f.add("private _asideNavigating = false;");
    f.add("private document = inject(DOCUMENT);");
    f.add("""
            private asideRoutes: Record<string, string> = {
                'home': 'home',
                'services': 'services',
                'modules': 'modules',
                'cloud': 'cloud'
                // primaryPath: asidePath — only list paths that HAVE an aside page
            };""");
    return f;
}
```

Both sides of the map are normally identical strings (the primary path segment used
also as the aside path), but they can differ if the aside route uses a different path.
Use `/`-joined multi-segment paths (e.g. `'guides/end-to-end'`) for nested routes —
join on `'/'` when building the URL tree.

## 3. Auto-sync the aside outlet on navigation

In `onInit()`, subscribe to router `NavigationEnd` events and reconcile the `aside`
outlet against the `asideRoutes` map. Guard re-entrancy with `_asideNavigating` since
the sync itself triggers another `NavigationEnd`:

```java
@Override
public List<String> onInit() {
    var init = new ArrayList<>(INgComponent.super.onInit());
    init.add("""
            this.router.events.pipe(filter(e => e instanceof NavigationEnd)).subscribe((e: any) => {
                if (this._asideNavigating) return;
                const navEnd = e as NavigationEnd;
                const parsedUrl = this.router.parseUrl(navEnd.urlAfterRedirects);
                const primarySegments = parsedUrl.root.children['primary']?.segments || [];
                const primaryPath = primarySegments.map((s: any) => s.path).join('/');
                const asidePath = this.asideRoutes[primaryPath];
                const currentAside = parsedUrl.root.children['aside'];
                const currentAsidePath = currentAside?.segments?.map((s: any) => s.path).join('/') || null;

                if (asidePath && currentAsidePath !== asidePath) {
                    this._asideNavigating = true;
                    const asideSegments = asidePath.split('/');
                    const tree = this.router.createUrlTree([{outlets: {aside: asideSegments}}], {relativeTo: null as any});
                    tree.root.children['primary'] = parsedUrl.root.children['primary'];
                    tree.queryParams = parsedUrl.queryParams;
                    tree.fragment = parsedUrl.fragment;
                    this.router.navigateByUrl(tree, {replaceUrl: true})
                        .then(() => this._asideNavigating = false)
                        .catch(() => this._asideNavigating = false);
                } else if (!asidePath && currentAside) {
                    this._asideNavigating = true;
                    delete parsedUrl.root.children['aside'];
                    this.router.navigateByUrl(parsedUrl, {replaceUrl: true})
                        .then(() => this._asideNavigating = false)
                        .catch(() => this._asideNavigating = false);
                }
            });""");
    return init;
}
```

Key behaviors:
- **Activate**: if the current primary path has a mapped aside path and the aside
  outlet isn't already showing it, build a new `UrlTree` with `outlets: {aside: [...]}`,
  re-attach the existing `primary` children, preserve query params/fragment, and
  `navigateByUrl(tree, {replaceUrl: true})` (no new history entry, no scroll jump).
- **Deactivate**: if the current primary path has no aside mapping but an `aside`
  outlet is still active (e.g. user navigated from a page with an aside to one
  without), delete the `aside` child from the parsed tree and navigate to it.
- Always reset `_asideNavigating` in both `.then()` and `.catch()` to avoid deadlocking
  the sync on a failed navigation.

## 4. Primary page component

Extend a shared `WebsitePage<J>` base (or your own) so pages get consistent layout,
helper methods (`section()`, `headingText()`, etc.), and — importantly — **slugified
section IDs** so aside anchor links can `scrollIntoView` to them:

```java
@NgComponent("myapp-services")
@NgRoutable(path = "services")
public class ServicesPage extends WebsitePage<ServicesPage> implements INgComponent<ServicesPage> {
    public ServicesPage() {
        getMain().add(section("Overview", "JPMS Service Modules", "..."));
        // section() auto-assigns section.setID(slugify(eyebrow-or-title))
    }
}
```

The `WebsitePage.section(...)` helper slugifies the eyebrow/title into an element `id`
(e.g. "How to use" → `how-to-use`) — the aside page's anchor links target these ids.

## 5. Aside page component (`pages/aside/XxxAsidePage.java`)

Create a **sibling class in a dedicated `pages/aside` package**, same route path,
`outlet = "aside"`, rendering an `<aside>` element with sticky positioning and
"On this page" scroll-spy links:

```java
package com.myapp.website.pages.aside;

@NgComponent("myapp-services-aside")
@NgRoutable(path = "services", outlet = "aside")
public class ServicesAsidePage extends DivSimple<ServicesAsidePage>
        implements INgComponent<ServicesAsidePage> {
    public ServicesAsidePage() {
        setTag("aside");
        addClass("page-aside");
        addStyle("position:sticky");
        addStyle("top:var(--wa-spacing-large)");
        addStyle("padding:0 var(--wa-spacing-large) var(--wa-spacing-large) var(--wa-spacing-large)");
        addStyle("min-width:14rem");

        var heading = new WaText<>();
        heading.setTag("div");
        heading.setWaCaption("s");
        heading.setWaFontWeight("semibold");
        heading.addClass("hero-eyebrow");
        heading.setText("On this page");
        add(heading);

        var list = new DivSimple<>();
        list.setTag("ul");
        list.addStyle("list-style:none");
        list.addStyle("padding:0");
        list.addStyle("margin:var(--wa-spacing-small) 0 0 0");
        list.addStyle("display:flex");
        list.addStyle("flex-direction:column");
        list.addStyle("gap:var(--wa-spacing-x-small)");

        list.add(asideLink("how-to-use", "How to use"));
        list.add(asideLink("apache-commons", "Apache Commons"));
        // one asideLink(anchorId, label) per section() id on the primary page
        add(list);
    }

    private DivSimple<?> asideLink(String anchorId, String label) {
        var li = new DivSimple<>();
        li.setTag("li");
        var link = new Link<>();
        link.setTag("a");
        link.addAttribute("href", "javascript:void(0)");
        link.addAttribute("onclick",
                "document.getElementById('" + anchorId + "').scrollIntoView({behavior:'smooth'})");
        link.setText(label);
        li.add(link);
        return li;
    }
}
```

Optional variants seen in the real websites:
- Add a `WaInput` filter/search box at the top with `(wa-input)`/`(wa-clear)` bound to a
  `methods()` handler that shows/hides matching cards (see `ServicesAsidePage`).
  Register the filtering method via `methods()`:

  ```java
  @Override
  public List<String> methods() {
      var m = new ArrayList<String>();
      m.add("""
              onFilterChange(event: any) {
                  const query = (event?.target?.value || '').toLowerCase().trim();
                  const cards = document.querySelectorAll('wa-card[appearance="outlined"]');
                  cards.forEach((card: any) => {
                      const text = card.textContent?.toLowerCase() || '';
                      card.style.display = (!query || text.includes(query)) ? '' : 'none';
                  });
              }
              """);
      return m;
  }
  ```
- For dynamic/data-driven asides (e.g. tree of frameworks/plugins), build a `WaTree`/
  `WaTreeItem` list instead of a flat `<ul>`, iterating over a catalog map.

## 6. Registering a new page + aside pair — checklist

1. Create `pages/XxxPage.java` with `@NgRoutable(path = "xxx")`, extending your shared
   `WebsitePage<J>` base, using `section(...)` for each content block so ids exist.
2. (Optional) Create `pages/aside/XxxAsidePage.java` with
   `@NgRoutable(path = "xxx", outlet = "aside")`, `setTag("aside")`,
   `addClass("page-aside")`, and one `asideLink(id, label)` per section id.
3. Add `'xxx': 'xxx'` to the `asideRoutes` map in `WebsiteBoot.fields()` **only if** the
   aside page exists — omit the entry to leave the page aside-less.
4. Add a menu entry (`createRouterTreeItem("/xxx", "Label", "icon")`) in both the
   sidebar `menu` tree and the burger-menu `navigation` tree inside `WebsiteBoot`.
5. Both `XxxPage` and `XxxAsidePage` must be discoverable by the JWebMP Angular
   component/route scanner (same module, annotated with `@NgComponent`/`@NgRoutable`) —
   no manual route table registration is required beyond the `asideRoutes` TS map used
   purely for outlet synchronization.

## 7. Hiding the aside panel entirely when a route has no aside

`WaPage` (WebAwesome `wa-page`) reserves layout space for the `aside` slot via a
`--aside-width` CSS custom property, so an **empty** `[slot='aside']` (no matching
`aside` route) would otherwise leave a blank gap on desktop/tablet even though the
`RouterOutlet` itself rendered nothing. The websites already collapse this for
**mobile** unconditionally:

```css
wa-page[view='mobile'] {
    --menu-width: 0px;
    --aside-width: 0px;
}
wa-page[view='mobile'] > [slot='aside'] {
    display: none;
}
```

Extend the same idea to **desktop/tablet** by driving a CSS class off an Angular
signal that tracks the actual aside outlet activation —
don't rely on `:empty`/`:has()` selectors, since the `<router-outlet>` leaves a
comment-node placeholder that makes empty-state selectors unreliable across browsers.

### 7.1 Track aside-active state as a signal

Add a signal field alongside the existing router/aside fields:

```java
@Override
public List<String> fields() {
    var f = new ArrayList<>(INgComponent.super.fields());
    f.add("private router: Router = inject(Router);");
    f.add("private _asideNavigating = false;");
    f.add("asideActive = signal(false);"); // drives the no-aside CSS class
    f.add("""
            private asideRoutes: Record<string, string> = {
                'home': 'home',
                'services': 'services'
            };""");
    return f;
}
```

(`signal` must already be imported via `@NgImportReference(value = "signal", reference = "@angular/core")`.)

### 7.2 Track the actual outlet activation

Replace the aside outlet construction from section 1 with event bindings:

```java
var asideOutlet = new RouterOutlet<>("aside");
asideOutlet.addAttribute("(activate)", "asideActive.set(true)");
asideOutlet.addAttribute("(deactivate)", "asideActive.set(false)");
asideOutlet.addAttribute("(attach)", "asideActive.set(true)");
asideOutlet.addAttribute("(detach)", "asideActive.set(false)");
page.getAside().add(asideOutlet);
```

Do not set the signal from the requested route mapping. A cancelled, rejected, or
failed navigation may leave the old outlet active or leave it empty. The outlet
activation/deactivation events reflect what actually rendered; attach/detach cover
route reuse. Keep the navigation guard reset in both success and failure handlers.
See the [Angular RouterOutlet events](https://angular.dev/api/router/RouterOutlet).

### 7.3 Bind the class onto the `wa-page` element

Since `WaPage<?> page` is a plain JWebMP component, bind an Angular class attribute
directly on it in the constructor:

```java
page.addAttribute("[class.no-aside]", "!asideActive()");
```

### 7.4 Collapse the layout in CSS

Add to `components.css` (next to the existing mobile rule):

```css
/* Desktop/tablet: collapse the aside column when the current route has no aside */
wa-page.no-aside {
    --aside-width: 0px;
}
wa-page.no-aside > [slot='aside'] {
    display: none;
}
```

This mirrors the existing `wa-page[view='mobile']` rule but is driven by the route
state instead of the viewport, and composes cleanly with it — on mobile the aside is
always hidden regardless of `no-aside`; on desktop/tablet it now only reserves space
when a route actually has aside content.

### 7.5 Why not pure CSS (`:empty`)?

- `<router-outlet>` always renders as an element with a following comment/text node
  for its activated component (or nothing when inactive), so `[slot='aside']:empty`
  is inconsistent across zones/renderers and won't reliably reflect "no aside route
  active".
- Driving it from the outlet activation signal adds a small event
  binding and keeps the CSS class aligned with the actual outlet activation.
- If you don't use Angular signals in your component base, a plain boolean field with
  manual change detection (`this.cdr.markForCheck()`) or a `BehaviorSubject` + `async`
  pipe works identically — the important part is deriving it from actual outlet events, including route reuse.

## Gotchas

- `relativeTo: null as any` is required when calling `createUrlTree` with only an
  `outlets` command — otherwise Angular tries to resolve relative to the currently
  activated route, which breaks when no primary route is currently matched in that
  branch.
- Always re-attach `tree.root.children['primary']`, `queryParams`, and `fragment` from
  the originally parsed URL before navigating — otherwise the primary content
  disappears or query state is lost when only the aside changes.
- The aside path in the map can be multi-segment (`'guides/end-to-end'`); split on `/`
  before passing to `outlets: {aside: [...]}` so Angular treats it as nested segments,
  not a single URL-encoded segment.
- Use `{replaceUrl: true}` for the sync navigation so it doesn't pollute browser
  history or fight the back button.
- Keep the `_asideNavigating` guard — without it the programmatic aside navigation
  re-triggers `NavigationEnd`, causing infinite navigation loops.
