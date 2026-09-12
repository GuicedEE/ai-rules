---
name: jwebmp-webawesome-pro
description: WebAwesome Pro premium component integration for JWebMP — combobox, date input/picker, file input, chart family (bar/line/pie/doughnut/radar/polar-area/scatter/bubble/sparkline), video/video-playlist, premium icons (WaIconFA), and toast notifications (WaToastContainer, WaToastDataService, angular-awesome WaToastService). Extends jwebmp-webawesome with these Pro-licensed form/data/media components. Use when working with WaCombobox, date pickers, file uploads, charts, video embeds, premium icons, or toast/notification banners in JWebMP applications.
metadata:
  short-description: WebAwesome Pro premium components
---

# JWebMP WebAwesome Pro

WebAwesome Pro integration for JWebMP — premium **form controls**, **charts**, **media**,
**icons**, and **toast notifications** that require a Web Awesome Pro licence. All Pro
components live under `com.jwebmp.webawesomepro.components.*`, extend `DivSimple<J>`
(CRTP fluent API, same as the base `jwebmp-webawesome` components), and pull in their
Angular directive via `@NgImportReference(..., reference = "angular-awesome")` +
`@NgImportModule(...)`.

## Component Index

| Component(s) | Package | Tag | Purpose |
|---|---|---|---|
| `WaCombobox` | `combobox` | `wa-combobox` | Typeahead/filterable single or multi-select input (`WaComboboxDirective`) |
| `WaDateInput` | `dateinput` | `wa-date-input` | Text field + pop-up calendar, ISO date/range values |
| `WaDatePicker` | `datepicker` | `wa-date-picker` | Inline calendar control (single/range selection) |
| `WaFileInput` | `fileinput` | `wa-file-input` | File upload control, single/multiple, `accept` filter |
| `WaChart`, `WaBarChart`, `WaLineChart`, `WaPieChart`, `WaDoughnutChart`, `WaRadarChart`, `WaPolarAreaChart`, `WaScatterChart`, `WaBubbleChart`, `WaSparkline` | `chart` | `wa-chart` / typed variants | Chart.js-backed chart family, sharing `WaChartBase` (label, description, axis labels, `legendPosition`, `stacked`) |
| `WaVideo`, `WaVideoPlaylist` | `video` | `wa-video`, `wa-video-playlist` | Video embed with custom controls/captions; playlist wrapper around multiple `WaVideo` |
| `WaIconFA` | `page.faicon` | (renders as `WaIcon`) | `WaIcon` subclass bound directly to FontAwesome 5/5 Pro icon enums (`IFontAwesomeIcon`, `FontAwesomeStyles`) |
| `WaToastContainer`, `WaToastItem`, `WaToastDataService` | `toast` | `wa-toast-container` | Toast/notification stack + programmatic service. **Container must render `<wa-toast-container>` (→ `WaToastContainerComponent`), not a bare `<wa-toast>`** (see below) |

## Core Features

- **Premium form controls** — combobox, date input/picker, file input
- **Charting** — full Chart.js-style chart family plus sparklines
- **Video** — single embeds and multi-video playlists
- **Premium Icons** — FontAwesome Pro icon binding via `WaIconFA`
- **Toast Notifications** — `<wa-toast>` / `<wa-toast-item>` wrapper backed by the `angular-awesome` `WaToastService`

## Combobox

```java
import com.jwebmp.webawesomepro.components.combobox.WaCombobox;
import com.jwebmp.webawesome.components.select.WaSelectOption;

WaCombobox<?> combobox = new WaCombobox<>("Search items")
        .setPlaceholder("Type to filter…")
        .setClearable(true)
        .setMultiple(true)
        .setAllowCreate(true);          // let users add new options by typing
combobox.add(new WaSelectOption<>().setValue("item1").setText("Item 1"));
combobox.add(new WaSelectOption<>().setValue("item2").setText("Item 2"));
combobox.setChangeEvent("onComboboxChange($event)");
```

Key attributes: `value`, `placeholder`, `disabled`, `clearable`, `multiple`, `size`,
`label`, `hint`, `required`, `form`, `inputValue`, `open`, `allowCreate`,
`autocapitalize`, `autocorrect`, `inputmode`, `enterkeyhint`, `spellcheck`. Events:
`wa-input`, `wa-change`, `wa-focus`, `wa-blur`, `wa-clear`, `wa-show`, `wa-hide`,
`wa-create` (fires when a new option is created via `allowCreate`). Slots: default
(`wa-option` children), `label`, `hint`, `start`, `end`, `clear-icon`.

## Date Input / Date Picker

```java
import com.jwebmp.webawesomepro.components.dateinput.WaDateInput;
import com.jwebmp.webawesomepro.components.datepicker.WaDatePicker;
import com.jwebmp.webawesomepro.components.datepicker.DatePickerMode;

// Text field + pop-up calendar — value is ISO YYYY-MM-DD (or YYYY-MM-DD/YYYY-MM-DD for ranges)
new WaDateInput<>().setValue("2026-07-02").setRequired(true);

// Inline calendar, no text field
new WaDatePicker<>().setMode(DatePickerMode.Range).setMin("2026-01-01").setMax("2026-12-31");
```

Both share Web Awesome's calendar internals: dynamic `day-YYYY-MM-DD` slots for custom
day rendering, `previous-icon`/`next-icon`/`header`/`footer` slots, and (for
`WaDateInput`) `label`/`hint`/`start`/`end`/`clear-icon`/`expand-icon` slots plus
`--show-duration`/`--hide-duration` CSS custom properties. Events include
`wa-clear`, `wa-show`/`wa-after-show`, `wa-hide`/`wa-after-hide`, `wa-invalid`, and
(picker-only) `wa-focus-day` / `wa-view-change`.

## File Input

```java
import com.jwebmp.webawesomepro.components.fileinput.WaFileInput;

WaFileInput<?> upload = new WaFileInput<>()
        .setLabel("Upload document")
        .setAccept(".doc,.docx,.pdf")
        .setMultiple(false)
        .setRequired(true);
```

Integrates with Angular forms via `ControlValueAccessor` (value type `FileList`).
Slots: `label`, `hint`, `button` (custom trigger). Events: `wa-change`, `wa-focus`,
`wa-blur`.

## Charts

```java
import com.jwebmp.webawesomepro.components.chart.WaBarChart;
import com.jwebmp.webawesomepro.components.chart.LegendPosition;

WaBarChart<?> chart = new WaBarChart<>()
        .setLabel("Monthly Revenue")
        .setXAxisLabel("Month")
        .setYAxisLabel("USD")
        .setLegendPosition(LegendPosition.Bottom)
        .setStacked(true);
```

`WaChartBase` supplies the shared `label`, `description`, `xAxisLabel`, `yAxisLabel`,
`legendPosition`, `stacked` properties to every typed chart
(`WaBarChart`, `WaLineChart`, `WaPieChart`, `WaDoughnutChart`, `WaRadarChart`,
`WaPolarAreaChart`, `WaScatterChart`, `WaBubbleChart`, `WaSparkline`). For a fully
custom config, use the low-level `WaChart` wrapper directly:

```java
new WaChart<>().setConfig("{\"type\":\"bar\",\"data\":{...}}").setPlugins("...");
```

## Video / Video Playlist

```java
import com.jwebmp.webawesomepro.components.video.WaVideo;
import com.jwebmp.webawesomepro.components.video.WaVideoPlaylist;
import com.jwebmp.webawesomepro.components.video.VideoControls;

WaVideo<?> clip = new WaVideo<>().setControls(VideoControls.Full)
        .setThumbnails("/media/preview.vtt");

WaVideoPlaylist<?> playlist = new WaVideoPlaylist<>();
playlist.add(clip);
playlist.add(new WaVideo<>());
```

Events: `timeupdate`, `play`, `pause`, `volumechange`, `error`, `ended`,
`loadedmetadata` (plus `wa-video-change` on the playlist). Slots: default
(`<source>`/`<track>` children), `controls-start`, `controls-after-play`,
`poster-icon`, `play-icon`, `pause-icon`, `volume-icon`, `mute-icon`,
`fullscreen-icon`, `exit-fullscreen-icon`. CSS custom properties:
`--controls-color`, `--controls-background`, `--poster-play-button-background`.

## Premium Icons (`WaIconFA`)

`WaIconFA` (in `com.jwebmp.webawesomepro.components.page.faicon`) is a thin `WaIcon`
subclass that binds directly to FontAwesome 5 / FontAwesome 5 Pro icon enums instead of
a raw string name — use it when you already depend on `jwebmp-fontawesome-pro` icon
constants and want them rendered through the Web Awesome `<wa-icon>` element:

```java
import com.jwebmp.webawesomepro.components.page.faicon.WaIconFA;
import com.jwebmp.plugins.fontawesome5pro.FontAwesome5ProIcons;
import com.jwebmp.plugins.fontawesome5.options.FontAwesomeStyles;

new WaIconFA<>(FontAwesome5ProIcons.HOUSE, FontAwesomeStyles.SHARP_DUOTONE);
```

## Toast Notifications

Toasts are **always created programmatically at runtime** — there is no static/SSR-authored
`<wa-toast-item>` content. The stack is rendered once, and notifications are pushed into it via
the injected `WaToastService` from `angular-awesome`.

### ⚠️ #1 reason toasts never show: wrong container element

The service-driven flow has **two different Angular declarations** with confusingly similar names:

| Rendered element | Angular declaration | Subscribes to `WaToastService.toasts$`? |
|---|---|---|
| `<wa-toast-container>` | **`WaToastContainerComponent`** | ✅ **Yes** — renders one `<wa-toast-item>` per notification |
| `<wa-toast>` | `WaToastDirective` | ❌ **No** — passive wrapper around the native element only |

`WaToastService.show(...)` (and `success/warning/danger/brand/neutral`) push toasts onto the
`toasts$` observable. **Only `WaToastContainerComponent` (`<wa-toast-container>`) listens to that
observable and renders the items.** A bare `<wa-toast>` element (`WaToastDirective`) is *not* wired
to the service — if the container renders `<wa-toast>` instead of `<wa-toast-container>`, every
`show()` call succeeds silently and **nothing ever appears**. This is the exact cause of "the
wrapper never shows any toast."

> **Rule:** `WaToastContainer` **must emit `<wa-toast-container>`** (mapped to
> `WaToastContainerComponent`), and that component **must be imported** by the hosting
> `@NgComponent` / `@NgApp`. Never rely on a plain `<wa-toast>` for service-driven toasts.

### 1. Place a single container near the app root

```java
import com.jwebmp.webawesomepro.components.toast.WaToastContainer;

new WaToastContainer<>()
    .setPlacement("top-end"); // placement is the only meaningful input
```

Must render **`<wa-toast-container placement="top-end"></wa-toast-container>`**, hydrated
client-side by `WaToastContainerComponent` (selector `wa-toast-container`, imported from
`angular-awesome`). The component internally renders the native `<wa-toast>` stack and one
`<wa-toast-item>` per visible toast, wiring `(wa-after-hide)` back to `WaToastService.close(id)`.

- Mount it **exactly once**, in an **always-rendered shell** (e.g. the root `@NgApp` template),
  **not** inside a lazily-loaded route that may be inactive when a toast fires.
- Valid `placement` values: `top-start | top-center | top-end | bottom-start | bottom-center | bottom-end`.
- `--gap` (spacing between stacked items) and `--width` (stack width) are native CSS custom
  properties on the inner `<wa-toast>` — set them with `addStyle("--gap", "var(--wa-space-l)")` /
  `addStyle("--width", "28rem")`, **not** via a `gap`/`width` attribute.
- `closable` behaviour is built into the native `<wa-toast-item>` close button; there is nothing to configure.

### 2. Depend on `WaToastDataService` wherever you need to trigger a toast

```java
import com.jwebmp.webawesomepro.components.toast.WaToastDataService;

// on any @NgComponent that needs to show toasts
@NgDataServiceReference(WaToastDataService.class)
public class MyComponent { /* ... */ }
```

Generated TypeScript API (delegates 1:1 to `angular-awesome`'s `WaToastService`):

```ts
toastDataService.success("Saved!");
toastDataService.warning("Check your input");
toastDataService.danger("Something went wrong");
toastDataService.brand("New feature available");
toastDataService.neutral("FYI");

const id = toastDataService.show("Custom message", { variant: "success", duration: 3000 });
toastDataService.update(id, { message: "Updated message" });
toastDataService.close(id);   // or remove(id) — alias
toastDataService.clearAll();  // or clear() — alias
```

### 3. Configure the stack (max visible, default duration, ordering)

**`max`, `duration`, and `newestOnTop` are NOT attributes of `<wa-toast>`/`<wa-toast-container>`** and
are **not** inputs of `WaToastDirective`/`WaToastContainerComponent`. Do not try to set them via
`WaToastContainer` setters — they don't exist there for exactly this reason. They are app-wide
`ToastConfig` settings consumed only by `WaToastService`, configured one of two ways:

```ts
// Option A: at bootstrap (main.ts / app.config.ts)
providers: [ provideWaToasts({ max: 5, duration: 5000, newestOnTop: true, placement: 'top-end' }) ]

// Option B: at runtime, via the generated data service
toastDataService.setConfig({ max: 5, newestOnTop: true });
```

Defaults (`DEFAULT_TOAST_CONFIG`): `placement: 'top-end'`, `max: 5`, `duration: 5000`,
`newestOnTop: true`.

**Auto-dismiss is owned by the service, not the item.** `WaToastContainerComponent` renders each
`<wa-toast-item>` with `duration="0"` (so the native element never self-dismisses) and instead lets
`WaToastService` run the timer using the per-toast `duration` (falling back to `ToastConfig.duration`).
`duration: 0` on a `show(...)` call therefore makes a **sticky** toast that stays until `close(id)`
or the user clicks the close button. Extra toasts beyond `max` are queued FIFO and shown as space frees.

### Troubleshooting: "toasts never appear"

Work through this checklist — one of these is almost always the cause:

1. **Container renders `<wa-toast-container>`, not `<wa-toast>`.** Confirm the generated DOM contains
   `<wa-toast-container>` (→ `WaToastContainerComponent`). A bare `<wa-toast>` (→ `WaToastDirective`)
   is not subscribed to the service and will show nothing. *This is the most common cause.*
2. **`WaToastContainerComponent` is imported** by the hosting `@NgApp`/`@NgComponent` (via the
   `angular-awesome` import reference/module). If it isn't imported, `<wa-toast-container>` renders as
   an unknown element and silently does nothing.
3. **Exactly one container is mounted in an always-rendered shell.** If the only container lives in a
   lazy/inactive route, the subscription isn't alive when `show()` fires.
4. **A single, shared `WaToastService` instance.** It is `providedIn: 'root'`. Do **not** re-list
   `WaToastService` in a component's `providers` — that creates a second instance the mounted container
   is not listening to, so pushes go to the wrong subject. `provideWaToasts(...)` (which only provides
   the `WA_TOAST_CONFIG` token) is safe; re-providing the service itself is not.
5. **Valid `variant`/`size`.** Variants: `brand | success | warning | danger | neutral`. Sizes:
   `small | medium | large`. An invalid value can throw inside the native element and abort rendering.
6. **Web Awesome components are registered/defined** on the client (the Pro bundle is loaded). If the
   custom elements aren't defined, `<wa-toast-container>` never upgrades.
7. **Message is non-empty.** `show("")` enqueues an empty toast that may be visually indistinguishable.

### Common mistakes to avoid

- ❌ Rendering a plain `<wa-toast>` (`WaToastDirective`) as the app-level container and expecting
  service-driven toasts to appear — only `<wa-toast-container>` (`WaToastContainerComponent`) is wired
  to `WaToastService`.
- ❌ Adding `setMax()` / `setDuration()` / `setNewestOnTop()` to `WaToastContainer` — these were
  removed because they rendered inert HTML attributes with zero effect. Use `setConfig()` instead.
- ❌ Re-providing `WaToastService` in a child injector — it must stay a root singleton so the mounted
  container and your callers share one instance.
- ❌ Authoring `<wa-toast-item>` elements as static page content — toasts are always pushed via the
  service; there is no renderable `WaToastItem` HTML component, only a `WaToastItem` DTO used for
  Angular data-type codegen.
- ❌ Using variant strings that don't match Web Awesome 3.10 (`brand | success | warning | danger | neutral`)
  or sizes (`xs | s | m | l | xl | small | medium | large`).

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>webawesome-pro</artifactId>
</dependency>
```

## References

- Module: `com.jwebmp.plugins.webawesomepro`
- Java: 25+
- License: Apache 2.0
