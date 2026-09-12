---
name: jwebmp-webawesome
description: Full WebAwesome 3.x component library integration for JWebMP — layout primitives (WaPage, WaStack, WaCluster, WaGrid, WaSplit), form controls (WaInput, WaSelect, WaCheckbox, WaRadio, WaRange, WaSwitch, WaTextArea, WaNumberInput, WaTimeInput, WaKnownDate, WaColorPicker), display/data components (WaCard, WaBadge, WaTag, WaTree, WaTabGroup, WaAccordion, WaCarousel, WaAvatar, WaBreadcrumbs, WaProgressBar/Ring, WaSkeleton, WaSpinner, WaQRCode, formatters), overlays (WaDialog, WaDrawer, WaPopover, WaPopup, WaTooltip), and the WaIcon component (FontAwesome-family icon rendering). Use when working with any Web Awesome component, building WaPage-based layouts, or styling JWebMP UIs with Web Awesome tokens (space/border/typography/shadow/transition).
metadata:
  short-description: Full WebAwesome 3.x component library
---

# JWebMP WebAwesome

WebAwesome 3.x integration for JWebMP — a full CRTP-fluent Java component model over
the `<wa-*>` custom-element library (layout, forms, data display, overlays, and icons),
plus reusable "token capable" mixins for spacing/border/typography/shadow/transition
CSS custom properties. All components live under `com.jwebmp.webawesome.components.*`,
extend `DivSimple<J>`, and generate their Angular directive imports automatically via
`@NgImportReference`/`@NgImportModule`.

> **Not an icon-only library.** WebAwesome ships icons too (via `WaIcon`), but the bulk
> of the module is a complete UI component set — see the index below. For
> **premium/Pro-only** components (combobox, date input/picker, file input, charts,
> video, toast, FA-bound icons), see the companion `jwebmp-webawesome-pro` skill.

## Component Index

| Category | Components | Package |
|---|---|---|
| Layout primitives | `WaDiv`, `WaStack`, `WaCluster`, `WaGrid`, `WaSplit`, `WaFlank`, `WaFrame`, `WaZoomableFrame` | `components` (root), `zoom` |
| Page shell | `WaPage`, `WaPageHeader`, `WaPageBanner`, `WaPageSubHeader`, `WaPageMenu`, `WaPageContent`, `WaPageContentsMain(Header/Footer)`, `WaPageContentsAside`, `WaPageContentsNavigation(Header/Footer)`, `WaPageNavigationToggle(Icon)`, `WaPageFooter`, `WaPageSkipToContent`, `WaPageDialogWrapper` | `page` |
| Buttons | `WaButton`, `WaButtonGroup`, `WaSplitButton`, `WaDropDown`, `WaDropdownItem` | `button` |
| Forms — text/number | `WaInput`, `WaTextArea`, `WaNumberInput`, `WaTimeInput`, `WaKnownDate`, `WaColorPicker` | `input`, `textarea`, `numberinput`, `timeinput`, `knowndate`, `colorpicker` |
| Forms — choice | `WaCheckbox`, `WaCheckboxGroup`, `WaRadio`, `WaRadioGroup`, `WaSelect`, `WaSelectOption`, `WaSwitch`, `WaRange`, `WaRating` | `checkbox`, `radio`, `select`, `waswitch`, `range`, `rating` |
| Data display | `WaCard`, `WaBadge`, `WaTag`, `WaAvatar`, `WaAvatarGroup`, `WaCallout`, `WaTree`, `WaTreeItem`, `WaBreadcrumbs`, `WaBreadcrumbItem`, `WaDetails`, `WaAccordion`, `WaAccordionItem`, `WaTabGroup`, `WaTab`, `WaTabPanel`, `WaCarousel`, `WaCarouselItem`, `WaComparison`, `WaImageCompare`, `WaAnimatedImage` | `card`, `badge`, `tag`, `avatar`, `callout`, `tree`, `breadcrumb`, `details`, `accordion`, `tabgroup`, `carousel`, `comparison`, `imagecompare`, `animatedimage` |
| Feedback / status | `WaProgressBar`, `WaProgressRing`, `WaSkeleton`, `WaSpinner`, `WaRandomContent` | `progressbar`, `progressring`, `skeleton`, `spinner`, `randomcontent` |
| Overlays | `WaDialog`, `WaDrawer`, `WaPopover`, `WaPopup`, `WaTooltip` | `dialog`, `drawer`, `popover`, `popup`, `tooltip` |
| Formatters / display helpers | `WaFormatBytes`, `WaFormatDate`, `WaFormatNumber`, `WaRelativeTime`, `WaQRCode`, `WaCopyButton`, `WaText`, `WaMarkdown`, `WaInclude` | `formatbytes`, `formatdate`, `formatnumber`, `relativetime`, `qrcode`, `copybutton`, `text`, `markdown`, `include` |
| Structural / layout helpers | `WaSplitPanel`, `WaScroller`, `WaDivider`, `WaVariantContainer` | `splitpanel`, `scroller`, `divider`, `variant` |
| Reactive observers | `WaIntersectionObserver`, `WaMutationObserver`, `WaResizeObserver` | `observer` |
| Animation | `WaAnimation` | `animation` |
| Icons | `WaIcon` | `icon` |

## Icons (`WaIcon`)

Icons are **not** a separate `Icon`/`IconStyle` API — they're the `WaIcon` component,
which renders a Web Awesome `<wa-icon>` and supports FontAwesome family/variant names,
custom SVG sources, or a registered icon library:

```java
import com.jwebmp.webawesome.components.icon.WaIcon;

WaIcon<?> icon = new WaIcon<>("house");            // name only
icon.setFamily("sharp-duotone");                     // FontAwesome family
icon.addAttribute("label", "Home");                  // accessible label
```

Constructor overloads accept `(name)`, `(name, family)`, or `(name, family, variant)`.
Key attributes: `name`, `family` (FontAwesome family, e.g. `classic`, `sharp-duotone`,
`brands`), `variant` (`regular`/`solid`/etc. within a family), `library` (registered
custom icon set), `src` (SVG URL for fully custom icons), `label`, `canvas`
(`IconCanvas`: unset = fixed 1.25em×1em, `auto`, `square`, `roomy`). Styling setters:
`setColor`, `setBackgroundColor`, `setFontSize`, `setPrimaryColor`/`setPrimaryOpacity`,
`setSecondaryColor`/`setSecondaryOpacity` (duotone). Animation CSS custom properties
(`--flip-angle`, `--beat-scale`, `--bounce-anticipation`, `--wag-angle`,
`--float-height`, etc.) are set via `addStyle(name, value)`. For FontAwesome-enum-bound
icons (rather than raw string names), see `WaIconFA` in the `jwebmp-webawesome-pro`
skill.

## Layout example (page shell + stack/cluster/grid)

```java
import com.jwebmp.webawesome.components.page.WaPage;
import com.jwebmp.webawesome.components.WaStack;
import com.jwebmp.webawesome.components.WaCluster;
import com.jwebmp.webawesome.components.WaGrid;
import com.jwebmp.webawesome.components.PageSize;
import com.jwebmp.core.base.angular.services.RouterOutlet;

WaPage<?> page = new WaPage<>();
page.getMain().setPageSize(PageSize.ExtraSmall);
page.getHeader().add(/* nav */ new WaCluster<>());
page.getMenu().add(/* tree */ new WaStack<>());
page.getMain().add(new RouterOutlet<>());
page.getAside().add(new RouterOutlet<>("aside"));
```

`WaStack` (vertical), `WaCluster` (horizontal wrap), `WaGrid` (auto-fit grid),
`WaSplit` (two-pane split), and `WaFlank` (icon+content flank layout) all implement
`GapCapable`/`SpaceTokenCapable` — use `.setGap(PageSize.Medium)` and friends.
See the `jwebmp-website-aside-routing` skill for the full `WaPage` main+aside
router-outlet pattern used by the GuicedEE/JWebMP marketing sites.

## Form controls example

```java
import com.jwebmp.webawesome.components.input.WaInput;
import com.jwebmp.webawesome.components.select.WaSelect;
import com.jwebmp.webawesome.components.select.WaSelectOption;
import com.jwebmp.webawesome.components.checkbox.WaCheckbox;
import com.jwebmp.webawesome.components.waswitch.WaSwitch;

WaInput<?> search = new WaInput<>().setPlaceholder("Search…").setClearable(true);

WaSelect<?> select = new WaSelect<>();
select.add(new WaSelectOption<>().setValue("a").setText("Option A"));

WaCheckbox<?> agree = new WaCheckbox<>().setText("I agree");

WaSwitch<?> toggle = new WaSwitch<>().setName("darkMode");
```

## Token-capable mixins

Most components implement one or more of: `SpaceTokenCapable` (`--wa-space-*` padding/
margin helpers), `BorderTokenCapable` (`--wa-border-*` width/radius/color),
`TypographyTokenCapable` (`--wa-font-*` size/weight), `ShadowTokenCapable`,
`TransitionTokenCapable`, `GapCapable` (flex/grid gap), `AlignVerticalCapable`,
`SplitCapable`, `ComponentGroupTokenCapable`, `VariantCapable` (`Variant`: `Brand`,
`Neutral`, `Success`, `Warning`, `Danger`), `ColourCapable`/`ColourIntensity`. These are
interface mixins on the `J`-typed CRTP builder — call the matching setter regardless of
which concrete component you're on, e.g. `.setPadding(WaSpaceToken.SpaceM)` on any
`SpaceTokenCapable<J>`.

## Sizing & common enums

```java
import com.jwebmp.webawesome.components.Size;      // component sizing: ExtraSmall..ExtraLarge / Small..Large aliases
import com.jwebmp.webawesome.components.PageSize;   // page-level sizing used by WaPage slots, WaGrid gap, etc.
import com.jwebmp.webawesome.components.Variant;    // Brand | Neutral | Success | Warning | Danger
import com.jwebmp.webawesome.components.button.Appearance; // Filled | Outlined | Plain, etc.
```

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>webawesome</artifactId>
</dependency>
```

## References

- Module: `com.jwebmp.plugins.webawesome`
- Java: 25+
- License: Apache 2.0
