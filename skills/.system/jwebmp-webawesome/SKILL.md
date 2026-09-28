---
name: jwebmp-webawesome
description: "Build and style JWebMP WebAwesome components, WaPage layouts, forms, overlays, and theme tokens."
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
| Data display | `WaCard`, `WaBadge`, `WaTag`, `WaAvatar`, `WaAvatarGroup`, `WaCallout`, `WaTree`, `WaTreeItem`, `WaBreadcrumbs`, `WaBreadcrumbItem`, `WaDetails`, `WaAccordion`, `WaAccordionItem`, `WaTabGroup`, `WaTab`, `WaTabPanel`, `WaCarousel`, `WaCarouselItem`, `WaComparison`, `WaImageCompare`, `WaImage`, `WaAnimatedImage` | `card`, `badge`, `tag`, `avatar`, `callout`, `tree`, `breadcrumb`, `details`, `accordion`, `tabgroup`, `carousel`, `comparison`, `imagecompare`, `image`, `animatedimage` |
| Feedback / status | `WaProgressBar`, `WaProgressRing`, `WaSkeleton`, `WaSpinner`, `WaRandomContent` | `progressbar`, `progressring`, `skeleton`, `spinner`, `randomcontent` |
| Overlays | `WaDialog`, `WaDrawer`, `WaPopover`, `WaPopup`, `WaTooltip` | `dialog`, `drawer`, `popover`, `popup`, `tooltip` |
| Page copy and typography | `WaText`, `WaMarkdown` | `text`, `markdown` |
| Formatters / display helpers | `WaFormatBytes`, `WaFormatDate`, `WaFormatNumber`, `WaRelativeTime`, `WaQRCode`, `WaCopyButton`, `WaInclude` | `formatbytes`, `formatdate`, `formatnumber`, `relativetime`, `qrcode`, `copybutton`, `include` |
| Structural / layout helpers | `WaSplitPanel`, `WaScroller`, `WaDivider`, `WaVariantContainer` | `splitpanel`, `scroller`, `divider`, `variant` |
| Reactive observers | `WaIntersectionObserver`, `WaMutationObserver`, `WaResizeObserver` | `observer` |
| Animation | `WaAnimation` | `animation` |
| Icons | `WaIcon` | `icon` |

## Page text (`WaText`)

Default to `WaText` for visible prose in a WebAwesome-authored page: headings,
paragraphs, captions, supporting copy, and styled links. It renders a semantic
HTML tag with the `waText` directive. Set both the tag and the matching
WebAwesome typography preset; `new WaText<>()` alone defaults to a plain
`<div>` and does not select a body or heading size.

```java
import com.jwebmp.webawesome.components.text.WaText;

WaText<?> heading = new WaText<>().setTag("h2")
        .setWaHeading("m").setText("Recent activity");
WaText<?> body = new WaText<>().setTag("p")
        .setWaBody("m").setText("Updates from your team.");
WaText<?> caption = new WaText<>().setTag("span")
        .setWaCaption("s").setWaColorText("quiet").setText("Updated today");
```

Use `setWaLongform(...)` for long-form prose and `setWaLink(...)` on an
`a` tag for a styled text link. Use `WaMarkdown` when the content contains
Markdown or rich inline formatting. Keep text owned by controls in their
components (`WaButton`, `WaInput`, `WaSelectOption`, etc.), and preserve
specialized semantic elements when their behavior matters. Avoid generic
`Paragraph`, `Span`, `DivSimple`, or bare text as the default authoring choice
for ordinary page copy. See `JWebMP/plugins/webawesome/src/main/java/com/jwebmp/webawesome/components/text/WaText.java`
and `JWebMP/plugins/webawesome/rules/generative/frontend/jwebmp/webawesome/text.rules.md`.

## Page images (`WaImage`)

Default to `WaImage` for ordinary still images in a WebAwesome-authored page.
It extends JWebMP `Image`, renders a native `<img>`, and exposes Web Awesome
space and border token helpers. Web Awesome does not have a `<wa-image>`
custom element. Supply useful alternative text; use an empty `alt` only for a
decorative image.

```java
import com.jwebmp.webawesome.components.image.WaImage;

WaImage<?> photo = new WaImage<>("/images/field.jpg", "A field at sunrise");
card.withImage(photo); // WaCard accepts Image, so WaImage fits its image slot.
```

Use `WaAnimatedImage` when a GIF/WEBP needs play and pause controls, `WaAvatar`
for a person or organization avatar, and `WaComparison` or the legacy
`WaImageCompare` for a before/after comparison. Keep `Image` for non-WebAwesome
pages or APIs that require the exact core type. See
`JWebMP/plugins/webawesome/rules/generative/frontend/jwebmp/webawesome/image.rules.md`.

## Icons (`WaIcon`)

`WaIcon` renders `<wa-icon>`. For shipped Font Awesome icons, choose a
style-specific free enum (`FontAwesomeFreeSolidIcons`,
`FontAwesomeFreeRegularIcons`, `FontAwesomeFreeBrandsIcons`) or a Pro/Pro+
family enum such as `FontAwesomeVellumIcons`. Inspect the enum for the constant;
never guess a name or assume a style exists in another family. Pass the name,
family, and variant from the **same** enum value, including when using plain
`WaIcon`:

```java
import com.jwebmp.webawesome.components.icon.WaIcon;
import com.jwebmp.plugins.fontawesome5.icons.FontAwesomeFreeSolidIcons;

var icon = FontAwesomeFreeSolidIcons.house;
WaIcon<?> waIcon = new WaIcon<>(icon.toAngularIconAttributeName(),
                                 icon.getFamily(), icon.getVariant());
waIcon.setLabel("Home");
```

When `web-awesome-pro` is available, `new WaIconFA<>(icon)` performs this
mapping automatically; `new WaIconFA<>(icon, IconVariant.Thin)` validates the
requested variant. For Vellum, use `FontAwesomeVellumIcons` and Solid. See the
`jwebmp-fontawesome` and `jwebmp-fontawesome-pro` skills for the catalogs.

Do not render Font Awesome icons as `<i>`/`<i/>`, JWebMP `Italic`, or an `<i>`
with `fa-*` CSS classes. Use `WaIcon`, `WaIconFA`, or the `FontAwesome` component.
Raw strings and `setFamily(String)` are for explicitly custom Kit uploads or
application icon libraries without catalog entries, after verifying the asset.
This icon rule does not restrict ordinary italic text.

`WaIcon` also supports `library`, custom SVG `src`, accessible `label`,
`IconCanvas` (`fixed`, `auto`, `square`, `roomy`), `IconFlip`, and styling
setters including `setColor`, `setFontSize`, `setPrimaryColor`, and
`setSecondaryColor`. Theme colours such as `var(--wa-color-text-normal)` remain
CSS strings. Verify the selected licensed pack and version are present in the
Kit or installed assets; an enum proves catalog membership, not delivery.

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
