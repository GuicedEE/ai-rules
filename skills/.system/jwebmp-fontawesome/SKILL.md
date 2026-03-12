---
name: jwebmp-fontawesome
description: FontAwesome icon integration for JWebMP with 6,000+ free icons. Provides typed icon components, CSS classes, solid/regular/brands styles, sizing, rotation, animation, stacking, and duotone support. Use when working with FontAwesome icons, adding icons to components, styling icons, or implementing icon-based UIs in JWebMP applications.
metadata:
  short-description: FontAwesome 6 free icon integration
---

# JWebMP FontAwesome

FontAwesome 6 free icon integration for JWebMP with 6,000+ icons.

## Core Features

- **6,000+ Free Icons** — Solid, Regular, Brands styles
- **Typed Icon Components** — Type-safe icon usage
- **CSS Utilities** — Sizing, rotation, animation
- **Icon Stacking** — Layer multiple icons
- **Duotone Support** — Two-tone icons
- **Auto CDN/NPM** — Flexible loading

## Quick Start

### Basic Icon Usage

```java
import com.jwebmp.plugins.fontawesome.icons.*;

Icon icon = new Icon()
    .setIconClass(FontAwesomeIcons.FA_HOME)
    .setStyle(IconStyle.SOLID)
    .setSize(IconSize.LG);

page.getBody().add(icon);
```

### Icon with Text

```java
Button<?, ?> btn = new Button<>();
btn.add(new Icon().setIconClass(FontAwesomeIcons.FA_DOWNLOAD));
btn.add(new Span<>().setText(" Download"));
```

## Icon Styles

```java
// Solid (fas)
new Icon().setIconClass(FontAwesomeIcons.FA_HOME).setStyle(IconStyle.SOLID);

// Regular (far)
new Icon().setIconClass(FontAwesomeIcons.FA_HEART).setStyle(IconStyle.REGULAR);

// Brands (fab)
new Icon().setIconClass(FontAwesomeIcons.FA_GITHUB).setStyle(IconStyle.BRANDS);
```

## Icon Sizing

```java
icon.setSize(IconSize.XS);     // Extra small
icon.setSize(IconSize.SM);     // Small
icon.setSize(IconSize.LG);     // Large
icon.setSize(IconSize.X2);     // 2x
icon.setSize(IconSize.X3);     // 3x
icon.setSize(IconSize.X5);     // 5x
icon.setSize(IconSize.X10);    // 10x
```

## Icon Utilities

### Rotation

```java
icon.setRotation(IconRotation.ROTATE_90);
icon.setRotation(IconRotation.ROTATE_180);
icon.setRotation(IconRotation.FLIP_HORIZONTAL);
icon.setRotation(IconRotation.FLIP_VERTICAL);
```

### Animation

```java
icon.setAnimation(IconAnimation.SPIN);
icon.setAnimation(IconAnimation.PULSE);
```

### Fixed Width

```java
icon.setFixedWidth(true);  // Consistent width for lists
```

## Icon Stacking

```java
IconStack stack = new IconStack();
stack.add(new Icon()
    .setIconClass(FontAwesomeIcons.FA_SQUARE)
    .setStackSize(IconStackSize.STACK_2X));
stack.add(new Icon()
    .setIconClass(FontAwesomeIcons.FA_FLAG)
    .setStackSize(IconStackSize.STACK_1X)
    .setInverse(true));
```

## Common Icons

### Navigation
- `FA_HOME`, `FA_BARS`, `FA_SEARCH`, `FA_USER`

### Actions
- `FA_PLUS`, `FA_MINUS`, `FA_EDIT`, `FA_TRASH`, `FA_SAVE`

### Media
- `FA_PLAY`, `FA_PAUSE`, `FA_STOP`, `FA_VOLUME_UP`

### Social
- `FA_FACEBOOK`, `FA_TWITTER`, `FA_GITHUB`, `FA_LINKEDIN`

### Files
- `FA_FILE`, `FA_FILE_PDF`, `FA_FILE_EXCEL`, `FA_FILE_WORD`

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>fontawesome</artifactId>
</dependency>
```

## JPMS Module

```java
module com.jwebmp.plugins.fontawesome {
    requires transitive com.jwebmp.core;
    exports com.jwebmp.plugins.fontawesome;
    exports com.jwebmp.plugins.fontawesome.icons;
}
```

## References

- Module: `com.jwebmp.plugins.fontawesome`
- FontAwesome: 6.x
- Java: 25+
- License: Apache 2.0
- [FontAwesome Docs](https://fontawesome.com/docs)
