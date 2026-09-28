---
name: jwebmp-fontawesome-pro
description: "Use licensed Font Awesome 7.3.1 Pro and Pro+ family catalogs, styles, and icon kits in JWebMP."
metadata:
  short-description: Font Awesome Pro and Pro+ icon catalogs
---

# JWebMP Font Awesome Pro

Use the Java source in `JWebMP/plugins/fontawesome-pro` as the API reference.
Current catalogs are family-specific enums in
`com.jwebmp.plugins.fontawesome5pro`, for example `FontAwesomeClassicIcons`,
`FontAwesomeDuotoneIcons`, `FontAwesomeSharpIcons`,
`FontAwesomeSharpDuotoneIcons`, and `FontAwesomeVellumIcons`. Other Pro+ packs
have their own enums. Each implements `IFontAwesomeFamilyIcon` and exposes
`getFamily()`, `getVariant()`, `getSupportedVariants()`, and
`requireVariant(IconVariant)`. Check that a constant belongs to the selected
family and style. Pro+ packs have different icon lists; do not assume a
Classic or legacy Pro name exists in Vellum, Jelly, Mosaic, or another pack.

`FontAwesome5ProIcons` is the compatibility union. It has 4,099 original enum
constants and 673 new names inherited from `FontAwesome5ProAdditionalIcons`.
The inherited names are `FontAwesomeClassicIcons` fields and do not occur in
`FontAwesome5ProIcons.values()` or `valueOf()`. Prefer family catalogs for new
code and enumeration. The canonical source and regeneration script are
`JWebMP/plugins/fontawesome-pro/scripts/icon-catalog.json` and
`JWebMP/plugins/fontawesome-pro/scripts/generate-icon-enums.py`.

```java
import com.jwebmp.plugins.fontawesome5.options.IconVariant;
import com.jwebmp.plugins.fontawesome5pro.FontAwesomeVellumIcons;
import com.jwebmp.plugins.fontawesome5pro.FontAwesomeSharpIcons;

var vellum = FontAwesomeVellumIcons.address_card; // Vellum Solid only
vellum.requireVariant(IconVariant.Solid);
FontAwesomeSharpIcons.house.requireVariant(IconVariant.Thin);
```

For WebAwesome, use `WaIconFA` when `web-awesome-pro` is present. It selects
the family and default style from the enum, and its variant overload checks
availability. A plain `WaIcon` must use the enum's name, family, and variant:

```java
new WaIconFA<>(FontAwesomeVellumIcons.address_card);
new WaIconFA<>(FontAwesomeSharpIcons.house, IconVariant.Thin);
var icon = FontAwesomeVellumIcons.address_card;
new WaIcon<>(icon.toAngularIconAttributeName(), icon.getFamily(), icon.getVariant());
```

Never render a Font Awesome icon with raw `<i>`/`<i/>`, `Italic`, or a guessed
`fa-*` class or string name. An enum value verifies membership in the 7.3.1
catalog; the Kit or installed assets must also include that licensed pack and
version. For an explicitly custom Kit upload without a catalog constant,
verify the asset and use its documented custom name/library/source.
