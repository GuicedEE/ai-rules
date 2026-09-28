---
name: jwebmp-fontawesome
description: "Use current Free Solid, Regular, and Brands icon enums with JWebMP FontAwesome or WebAwesome icons."
metadata:
  short-description: Font Awesome 7.3.1 free icon catalogs
---

# JWebMP Font Awesome Free

Use the Java source in `JWebMP/plugins/fontawesome` as the API reference. The
7.3.1 free catalogs in `com.jwebmp.plugins.fontawesome5.icons` are
`FontAwesomeFreeSolidIcons`, `FontAwesomeFreeRegularIcons`, and
`FontAwesomeFreeBrandsIcons`. Their membership is style-specific; an icon in
Solid need not be free in Regular. These implement `IFontAwesomeFreeIcon` and
carry the icon name, `IconFamily`, `IconVariant`, and npm package. Inspect the
chosen enum for the constant instead of inventing a name.

`FontAwesomeIcons` and `FontAwesomeBrandIcons` retain old aliases for existing
code but do not prove availability in a particular current style. Prefer the
style-specific enums for new work. The source catalog and refresh script are
`JWebMP/plugins/fontawesome/scripts/icon-catalog.json` and
`JWebMP/plugins/fontawesome/scripts/generate-icon-enums.py`.

```java
import com.jwebmp.plugins.fontawesome5.FontAwesome;
import com.jwebmp.plugins.fontawesome5.icons.FontAwesomeFreeRegularIcons;
import com.jwebmp.plugins.fontawesome5.options.FontAwesomeStyles;

var icon = new FontAwesome<>(FontAwesomeStyles.Classic,
                             FontAwesomeFreeRegularIcons.heart);
```

For WebAwesome, render `<wa-icon>` through `WaIcon`, carrying all three values
from the same catalog icon. When `web-awesome-pro` is available, `WaIconFA`
sets family and default variant automatically:

```java
var catalogIcon = FontAwesomeFreeRegularIcons.heart;
var waIcon = new WaIcon<>(catalogIcon.toAngularIconAttributeName(),
                          catalogIcon.getFamily(), catalogIcon.getVariant());
// With web-awesome-pro: new WaIconFA<>(catalogIcon);
```

Never implement a Font Awesome icon as a raw `<i>`/`<i/>` tag, `Italic`, a
CSS `fa-*` class on an `<i>`, or an unverified string name. Use an icon
component and an enum constant. This rule concerns icons, not italic text.
For an explicitly custom Kit icon or application icon library with no catalog
entry, use the documented custom name/library/source after verifying the asset.
