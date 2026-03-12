---
name: jwebmp-fontawesome-pro
description: FontAwesome Pro integration for JWebMP with 30,000+ premium icons. Extends jwebmp-fontawesome with Light, Thin, Sharp, Duotone, Sharp Duotone styles, icon kits, and premium features. Requires FontAwesome Pro license. Use when working with FontAwesome Pro icons, premium styles, icon kits, or advanced icon features in JWebMP applications.
metadata:
  short-description: FontAwesome Pro premium icon integration
---

# JWebMP FontAwesome Pro

FontAwesome Pro integration for JWebMP with 30,000+ premium icons.

## Core Features

- **30,000+ Premium Icons**
- **Additional Styles** — Light, Thin, Sharp, Duotone, Sharp Duotone
- **Icon Kits** — Custom icon sets
- **Premium Features** — Advanced duotone, custom uploads

## Additional Styles

```java
// Light (fal)
icon.setStyle(IconStyle.LIGHT);

// Thin (fat)
icon.setStyle(IconStyle.THIN);

// Sharp Solid (fass)
icon.setStyle(IconStyle.SHARP_SOLID);

// Sharp Regular (fasr)
icon.setStyle(IconStyle.SHARP_REGULAR);

// Duotone (fad)
icon.setStyle(IconStyle.DUOTONE);

// Sharp Duotone (fasds)
icon.setStyle(IconStyle.SHARP_DUOTONE);
```

## Duotone Styling

```java
Icon duotone = new Icon()
    .setIconClass(FontAwesomeIcons.FA_STAR)
    .setStyle(IconStyle.DUOTONE)
    .setPrimaryColor("#FFD700")
    .setSecondaryColor("#FFA500")
    .setSecondaryOpacity(0.4);
```

## Icon Kits

Requires FontAwesome Pro license and kit token:

```java
@PluginConfiguration(
    kitToken = "your-kit-token"
)
public class FontAwesomeProConfig { }
```

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>fontawesome-pro</artifactId>
</dependency>
```

**Note:** Requires valid FontAwesome Pro subscription.

## References

- Module: `com.jwebmp.plugins.fontawesomepro`
- FontAwesome Pro: 6.x
- Java: 25+
- License: Apache 2.0 (code), FontAwesome Pro license required
- [FontAwesome Pro](https://fontawesome.com/plans)
