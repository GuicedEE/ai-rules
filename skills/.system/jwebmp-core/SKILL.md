---
name: jwebmp-core
description: Strongly-typed HTML/CSS/JS component model for Java — the heart of JWebMP. Provides typed HTML elements, CSS builder, server-driven events, dual rendering (HTML/JSON), CRTP fluent API, and page configurators. Use when working with JWebMP Core features, HTML component creation, CSS styling, event handling, page configuration, or any JWebMP page/component development tasks.
metadata:
  short-description: JWebMP Core framework development
---

# JWebMP Core

Comprehensive guide for working with JWebMP Core — the strongly-typed HTML/CSS/JS component model for Java.

## Core Concepts

### Dual Rendering Modes

Every JWebMP component serves dual purposes:
- `toString(true)` renders as **HTML** with all queued CSS/JS
- `toString()` renders as **JSON** for AJAX/API responses

### Component Hierarchy (CRTP Pattern)

JWebMP uses an 11-layer CRTP (Curiously Recurring Template Pattern) chain:

```
ComponentBase → ComponentHierarchyBase → ComponentHTMLBase →
ComponentHTMLAttributeBase → ComponentHTMLOptionsBase → ComponentStyleBase →
ComponentThemeBase → ComponentDataBindingBase → ComponentDependencyBase →
ComponentFeatureBase → ComponentEventBase → Component → Your subclass
```

## Quick Start

### Creating a Simple Page

```java
Page<?> page = new Page<>();
Div<?, ?, ?> container = new Div<>();
container.add(new Paragraph<>().setText("Welcome to JWebMP"));
page.getBody().add(container);

String html = page.toString(true);  // Full HTML
String json = page.toString();      // JSON representation
```

### Serving with Vert.x (Optional)

```java
@PageConfiguration(url = "/")
public class HomePage extends Page<HomePage> {
    public HomePage() {
        getBody().add(new H1<>().setText("Hello from JWebMP"));
    }
}
```

Register in `module-info.java`:
```java
provides com.jwebmp.core.services.IPage with my.app.HomePage;
```

### Event Handling

Events **must be named classes** (no lambdas/anonymous inner classes):

```java
public class ButtonClickEvent extends OnClickAdapter {
    public ButtonClickEvent(Component component) {
        super(component);
    }

    @Override
    public void onClick(AjaxCall<?> call, AjaxResponse<?> response) {
        response.addComponent(new Paragraph<>().setText("Clicked!"));
    }
}

// Attach to component
button.addEvent(new ButtonClickEvent(button));
```

### CSS Styling

```java
Div<?, ?, ?> styled = new Div<>();
styled.getCss()
      .getBackground().setBackgroundColor$(ColourNames.AliceBlue);
styled.getCss()
      .getBorder().setBorderWidth(new MeasurementCSSImpl(1, MeasurementTypes.Pixels));
styled.getCss()
      .getFont().setFontSize(new MeasurementCSSImpl(14, MeasurementTypes.Pixels));
```

### Feature System

Features **must be named classes**:

```java
public class TooltipFeature extends Feature<TooltipOptions, TooltipFeature> {
    public TooltipFeature(IComponentHierarchyBase<?, ?> component) {
        super("tooltip", component);
        getOptions().setPlacement("top");
    }

    @Override
    protected void assignFunctionalityToComponent() {
        addQuery(getComponent().asBase().getJQueryID() + "tooltip(" + getOptions() + ");");
    }
}
```

## HTML Elements

All HTML5 elements available as typed classes:

### Common Elements
- `Div`, `Span`, `Paragraph` (flow content)
- `H1`–`H6` (headings)
- `Table`, `TableRow`, `TableHeaderCell`, `TableDataCell`
- `Form`, `Input*` (22 typed input variants)
- `Select`, `Option`, `OptionGroup`
- `List` (ul/ol), `ListItem`
- `Link`, `Image`, `Button`

### Semantic Elements
- `Header`, `Footer`, `Nav`, `Section`, `Article`, `Aside`

### Input Types
- `InputTextType`, `InputEmailType`, `InputNumberType`, `InputDateType`
- `InputFileType`, `InputCheckBoxType`, `InputRadioType`
- And 15+ more specialized input types

## Page Configuration

### IPageConfigurator SPI

```java
public class AnalyticsConfigurator implements IPageConfigurator<AnalyticsConfigurator> {
    @Override
    public IPage<?> configure(IPage<?> page) {
        page.addJavaScriptReference(new JavascriptReference("analytics", 1.0, "analytics.js"));
        return page;
    }

    @Override
    public Integer sortOrder() {
        return 500;  // After core configurators
    }
}
```

Register via `module-info.java`:
```java
provides com.jwebmp.core.services.IPageConfigurator with my.app.AnalyticsConfigurator;
```

### Render-Ordering SPIs

- `RenderBeforeLinks` / `RenderAfterLinks` — CSS insertion points
- `RenderBeforeScripts` / `RenderAfterScripts` — Script insertion points
- `RenderBeforeDynamicScripts` / `RenderAfterDynamicScripts` — Dynamic script points

## Event System

### Available Event Adapters (50+)

- `OnClickAdapter`, `OnChangeAdapter`, `OnSubmitAdapter`
- `OnDragAdapter`, `OnDropAdapter`
- `OnKeyDownAdapter`, `OnKeyUpAdapter`, `OnKeyPressAdapter`
- `OnMouseEnterAdapter`, `OnMouseLeaveAdapter`
- `OnFocusAdapter`, `OnBlurAdapter`
- And 40+ more event types

### Event Service SPIs

Each event type has a corresponding `ServiceLoader` SPI:
- `IOnClickService`, `IOnChangeService`, `IOnSubmitService`, etc.

## CSS Builder Packages

| Package | Properties |
|---|---|
| `css.backgrounds` | background-color, background-image, background-repeat |
| `css.borders` | border-width, border-style, border-color, border-radius |
| `css.fonts` | font-family, font-size, font-weight, font-style |
| `css.margins` | margin-top, margin-right, margin-bottom, margin-left |
| `css.padding` | padding-top, padding-right, padding-bottom, padding-left |
| `css.displays` | display, visibility, overflow, position, float |
| `css.text` | text-align, text-decoration, text-transform, line-height |
| `css.heightwidth` | height, width, min-height, max-width |
| `css.measurement` | MeasurementCSSImpl — px, em, rem, %, vw, vh |

## JPMS Module

```java
module com.jwebmp.core {
    requires transitive com.jwebmp.client;
    requires transitive com.guicedee.client;
    requires transitive com.guicedee.vertx;
    requires transitive com.fasterxml.jackson.databind;

    exports com.jwebmp.core;
    exports com.jwebmp.core.base;
    exports com.jwebmp.core.base.html;
    exports com.jwebmp.core.base.html.inputs;
    exports com.jwebmp.core.events.*;
    exports com.jwebmp.core.htmlbuilder.css.*;

    uses IPage;
    uses IPageConfigurator;
    uses IEventConfigurator;
}
```

## Common Patterns

### Building a Form

```java
Form<?, ?> form = new Form<>();
form.add(new Label<>().setText("Name:"));
form.add(new InputTextType<>().setName("name").setRequired(true));
form.add(new Label<>().setText("Email:"));
form.add(new InputEmailType<>().setName("email").setRequired(true));
form.add(new Button<>().setText("Submit"));
form.addEvent(new FormSubmitEvent(form));
```

### Building a Table

```java
Table<?, ?, ?, ?> table = new Table<>();
TableHeaderGroup<?, ?> header = new TableHeaderGroup<>();
TableRow<?, ?> headerRow = new TableRow<>();
headerRow.add(new TableHeaderCell<>().setText("Name"));
headerRow.add(new TableHeaderCell<>().setText("Email"));
header.add(headerRow);
table.add(header);

TableBodyGroup<?, ?> body = new TableBodyGroup<>();
for (User user : users) {
    TableRow<?, ?> row = new TableRow<>();
    row.add(new TableDataCell<>().setText(user.getName()));
    row.add(new TableDataCell<>().setText(user.getEmail()));
    body.add(row);
}
table.add(body);
```

### AJAX Pipeline

```java
public class AjaxHandler extends OnClickAdapter {
    @Override
    public void onClick(AjaxCall<?> call, AjaxResponse<?> response) {
        // Access request data
        String param = call.getParameters().get("key");

        // Modify DOM
        response.addComponent(new Div<>().setText("New content"));

        // Add reactions
        response.addReaction(new AjaxResponseReaction<>(ReactionType.REDIRECT, "/newpage"));
    }
}
```

## Important Constraints

1. **Events must be named classes** — No anonymous inner classes or lambdas
2. **Features must be named classes** — Framework uses class identity for deduplication
3. **Child constraints enforced at compile time** — Type-safe component hierarchy
4. **Page configurators are optional** — Pages work without any configurators

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.core</groupId>
  <artifactId>core</artifactId>
</dependency>
```

Version managed by JWebMP BOM.

## Key Classes

- `Page` — Top-level HTML page
- `Component` — Base for all HTML elements
- `Feature` — Wraps JS library with typed options
- `Event` — Server-driven event handler
- `CSSComponent` — CSS-only component (no HTML tag)
- `DataAdapter` — Bridges server data to JSON
- `ContentSecurityPolicy` — CSP header builder

## References

- Module: `com.jwebmp.core`
- Java: 25+
- Dependencies: JWebMP Client, GuicedEE, Vert.x 5, Jackson
- License: Apache 2.0
