---
name: jwebmp-easing
description: jQuery Easing plugin integration for JWebMP providing smooth animation easing functions. Supports 30+ easing functions (easeInOutQuad, easeInOutCubic, easeInOutElastic, etc.) for animations, transitions, and scrolling. Use when working with animations, smooth transitions, scroll effects, or custom easing functions in JWebMP applications.
metadata:
  short-description: jQuery Easing animation functions
---

# JWebMP Easing

jQuery Easing plugin integration for JWebMP providing smooth animation easing functions.

## Core Features

- **30+ Easing Functions**
- **jQuery Integration**
- **Custom Animations**
- **Smooth Transitions**

## Easing Functions

### Linear
- `linear`

### Quad
- `easeInQuad`, `easeOutQuad`, `easeInOutQuad`

### Cubic
- `easeInCubic`, `easeOutCubic`, `easeInOutCubic`

### Quart
- `easeInQuart`, `easeOutQuart`, `easeInOutQuart`

### Quint
- `easeInQuint`, `easeOutQuint`, `easeInOutQuint`

### Sine
- `easeInSine`, `easeOutSine`, `easeInOutSine`

### Expo
- `easeInExpo`, `easeOutExpo`, `easeInOutExpo`

### Circ
- `easeInCirc`, `easeOutCirc`, `easeInOutCirc`

### Elastic
- `easeInElastic`, `easeOutElastic`, `easeInOutElastic`

### Back
- `easeInBack`, `easeOutBack`, `easeInOutBack`

### Bounce
- `easeInBounce`, `easeOutBounce`, `easeInOutBounce`

## Usage

```java
// In JavaScript/jQuery animation
component.addQuery("$(element).animate({ opacity: 1 }, 1000, 'easeInOutQuad');");
```

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>easing</artifactId>
</dependency>
```

## References

- Module: `com.jwebmp.plugins.easing`
- Java: 25+
- License: Apache 2.0
- [jQuery Easing](http://gsgd.co.uk/sandbox/jquery/easing/)
