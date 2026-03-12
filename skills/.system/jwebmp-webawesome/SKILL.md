---
name: jwebmp-webawesome
description: WebAwesome icon integration for JWebMP — modern, open-source icon library. Provides 1,500+ icons with solid/regular styles, sizing, rotation, animation, and CSS utilities. Drop-in FontAwesome alternative with fresh designs. Use when working with WebAwesome icons, modern icon designs, or as FontAwesome alternative in JWebMP applications.
metadata:
  short-description: WebAwesome icon integration
---

# JWebMP WebAwesome

WebAwesome icon integration for JWebMP — modern icon library.

## Core Features

- **1,500+ Icons** — Modern, fresh designs
- **FontAwesome Compatible** — Drop-in replacement
- **Solid/Regular Styles**
- **CSS Utilities** — Sizing, rotation, animation
- **Open Source** — MIT licensed icons

## Quick Start

```java
import com.jwebmp.webawesome.icons.*;

Icon icon = new Icon()
    .setIconClass(WebAwesomeIcons.WA_HOME)
    .setStyle(IconStyle.SOLID)
    .setSize(IconSize.LG);
```

## Icon Styles

```java
// Solid
icon.setStyle(IconStyle.SOLID);

// Regular
icon.setStyle(IconStyle.REGULAR);
```

## Sizing & Utilities

Same as FontAwesome:
```java
icon.setSize(IconSize.LG);
icon.setRotation(IconRotation.ROTATE_90);
icon.setAnimation(IconAnimation.SPIN);
icon.setFixedWidth(true);
```

## Installation

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
