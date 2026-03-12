# JWebMP Core CSS Properties Reference

Complete reference of CSS builder packages and properties.

## css.backgrounds

- `setBackgroundColor$(ColourNames)` — Background color
- `setBackgroundImage$(String)` — Background image URL
- `setBackgroundRepeat$(BackgroundRepeat)` — Repeat mode
- `setBackgroundPosition$(BackgroundPosition)` — Background position
- `setBackgroundSize$(BackgroundSize)` — Background size
- `setBackgroundAttachment$(BackgroundAttachment)` — Attachment mode
- `setBackgroundOrigin$(BackgroundOrigin)` — Origin box
- `setBackgroundClip$(BackgroundClip)` — Clipping box

## css.borders

- `setBorderWidth$(MeasurementCSSImpl)` — Border width (all sides)
- `setBorderTopWidth$(MeasurementCSSImpl)` — Top border width
- `setBorderRightWidth$(MeasurementCSSImpl)` — Right border width
- `setBorderBottomWidth$(MeasurementCSSImpl)` — Bottom border width
- `setBorderLeftWidth$(MeasurementCSSImpl)` — Left border width
- `setBorderStyle$(BorderStyles)` — Border style (solid, dashed, dotted, etc.)
- `setBorderColor$(ColourNames)` — Border color
- `setBorderRadius$(MeasurementCSSImpl)` — Border radius (all corners)
- `setBorderTopLeftRadius$(MeasurementCSSImpl)` — Top-left radius
- `setBorderTopRightRadius$(MeasurementCSSImpl)` — Top-right radius
- `setBorderBottomLeftRadius$(MeasurementCSSImpl)` — Bottom-left radius
- `setBorderBottomRightRadius$(MeasurementCSSImpl)` — Bottom-right radius

## css.colours

Predefined `ColourNames` enum:
- `AliceBlue`, `AntiqueWhite`, `Aqua`, `Aquamarine`, `Azure`
- `Beige`, `Bisque`, `Black`, `BlanchedAlmond`, `Blue`
- `BlueViolet`, `Brown`, `BurlyWood`
- `CadetBlue`, `Chartreuse`, `Chocolate`, `Coral`
- ... and 140+ more named colors

## css.displays

- `setDisplay$(DisplayTypes)` — Display type (block, inline, flex, grid, etc.)
- `setVisibility$(Visibility)` — Visibility (visible, hidden, collapse)
- `setOverflow$(Overflow)` — Overflow (visible, hidden, scroll, auto)
- `setOverflowX$(Overflow)` — Horizontal overflow
- `setOverflowY$(Overflow)` — Vertical overflow
- `setPosition$(Positions)` — Position (static, relative, absolute, fixed, sticky)
- `setTop$(MeasurementCSSImpl)` — Top offset
- `setRight$(MeasurementCSSImpl)` — Right offset
- `setBottom$(MeasurementCSSImpl)` — Bottom offset
- `setLeft$(MeasurementCSSImpl)` — Left offset
- `setFloat$(FloatTypes)` — Float (left, right, none)
- `setClear$(ClearTypes)` — Clear (left, right, both, none)
- `setZIndex$(Integer)` — Z-index stacking order
- `setOpacity$(Double)` — Opacity (0.0 to 1.0)

## css.fonts

- `setFontFamily$(String)` — Font family
- `setFontSize$(MeasurementCSSImpl)` — Font size
- `setFontWeight$(FontWeight)` — Font weight (normal, bold, 100-900)
- `setFontStyle$(FontStyle)` — Font style (normal, italic, oblique)
- `setFontVariant$(FontVariant)` — Font variant (small-caps, etc.)
- `setLineHeight$(MeasurementCSSImpl)` — Line height
- `setLetterSpacing$(MeasurementCSSImpl)` — Letter spacing
- `setWordSpacing$(MeasurementCSSImpl)` — Word spacing

## css.margins

- `setMargin$(MeasurementCSSImpl)` — Margin (all sides)
- `setMarginTop$(MeasurementCSSImpl)` — Top margin
- `setMarginRight$(MeasurementCSSImpl)` — Right margin
- `setMarginBottom$(MeasurementCSSImpl)` — Bottom margin
- `setMarginLeft$(MeasurementCSSImpl)` — Left margin

## css.padding

- `setPadding$(MeasurementCSSImpl)` — Padding (all sides)
- `setPaddingTop$(MeasurementCSSImpl)` — Top padding
- `setPaddingRight$(MeasurementCSSImpl)` — Right padding
- `setPaddingBottom$(MeasurementCSSImpl)` — Bottom padding
- `setPaddingLeft$(MeasurementCSSImpl)` — Left padding

## css.heightwidth

- `setHeight$(MeasurementCSSImpl)` — Height
- `setWidth$(MeasurementCSSImpl)` — Width
- `setMinHeight$(MeasurementCSSImpl)` — Minimum height
- `setMaxHeight$(MeasurementCSSImpl)` — Maximum height
- `setMinWidth$(MeasurementCSSImpl)` — Minimum width
- `setMaxWidth$(MeasurementCSSImpl)` — Maximum width

## css.text

- `setTextAlign$(TextAlignments)` — Text alignment (left, right, center, justify)
- `setTextDecoration$(TextDecorations)` — Text decoration (underline, overline, line-through, none)
- `setTextTransform$(TextTransformations)` — Text transform (uppercase, lowercase, capitalize)
- `setVerticalAlign$(VerticalAlign)` — Vertical alignment
- `setWhiteSpace$(WhiteSpace)` — White space handling
- `setTextIndent$(MeasurementCSSImpl)` — Text indentation
- `setTextShadow$(String)` — Text shadow
- `setColor$(ColourNames)` — Text color

## css.lists

- `setListStyleType$(ListStyleType)` — List marker type (disc, circle, square, decimal, etc.)
- `setListStylePosition$(ListStylePosition)` — List marker position (inside, outside)
- `setListStyleImage$(String)` — Custom list marker image

## css.tables

- `setBorderCollapse$(BorderCollapse)` — Border collapse (collapse, separate)
- `setBorderSpacing$(MeasurementCSSImpl)` — Border spacing
- `setTableLayout$(TableLayout)` — Table layout (auto, fixed)
- `setCaptionSide$(CaptionSide)` — Caption position (top, bottom)
- `setEmptyCells$(EmptyCells)` — Empty cell display (show, hide)

## css.outline

- `setOutlineWidth$(MeasurementCSSImpl)` — Outline width
- `setOutlineStyle$(OutlineStyles)` — Outline style
- `setOutlineColor$(ColourNames)` — Outline color
- `setOutlineOffset$(MeasurementCSSImpl)` — Outline offset

## css.measurement

`MeasurementCSSImpl` constructor:

```java
new MeasurementCSSImpl(value, MeasurementTypes)
```

`MeasurementTypes` enum:
- `Pixels` — px
- `Percent` — %
- `Em` — em
- `Rem` — rem
- `ViewportWidth` — vw
- `ViewportHeight` — vh
- `ViewportMin` — vmin
- `ViewportMax` — vmax
- `Centimeters` — cm
- `Millimeters` — mm
- `Inches` — in
- `Points` — pt
- `Picas` — pc

## Usage Example

```java
Div<?, ?, ?> styled = new Div<>();

// Background
styled.getCss()
      .getBackground().setBackgroundColor$(ColourNames.AliceBlue);

// Border
styled.getCss()
      .getBorder()
      .setBorderWidth$(new MeasurementCSSImpl(1, MeasurementTypes.Pixels))
      .setBorderStyle$(BorderStyles.Solid)
      .setBorderColor$(ColourNames.Navy)
      .setBorderRadius$(new MeasurementCSSImpl(5, MeasurementTypes.Pixels));

// Font
styled.getCss()
      .getFont()
      .setFontSize$(new MeasurementCSSImpl(14, MeasurementTypes.Pixels))
      .setFontWeight$(FontWeight.Bold)
      .setFontFamily$("Arial, sans-serif");

// Spacing
styled.getCss()
      .getMargins()
      .setMargin$(new MeasurementCSSImpl(10, MeasurementTypes.Pixels));
styled.getCss()
      .getPadding()
      .setPadding$(new MeasurementCSSImpl(15, MeasurementTypes.Pixels));

// Dimensions
styled.getCss()
      .getHeightWidth()
      .setWidth$(new MeasurementCSSImpl(300, MeasurementTypes.Pixels))
      .setHeight$(new MeasurementCSSImpl(200, MeasurementTypes.Pixels));

// Display
styled.getCss()
      .getDisplays()
      .setDisplay$(DisplayTypes.Flex)
      .setPosition$(Positions.Relative);
```
