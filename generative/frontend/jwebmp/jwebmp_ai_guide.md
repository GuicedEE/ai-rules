# JWebMP Components and Runtime Systems Generation Guide

## Introduction

JWebMP (Java Web Markup Processor) is a powerful Java-based web framework that enables developers to create rich web applications using pure Java code. This guide provides comprehensive information for AI systems to generate JWebMP components and runtime systems, focusing on JWebMP-Core, JWebMP-Client, and JWebMP Vert.X integration.

This guide is intended for AI systems that need to generate code for JWebMP applications, understand the framework's architecture, and create components that follow JWebMP's design patterns and best practices.

Important policy for generators and maintainers (JWebMP projects):
- Do not touch or propose edits to generated artifacts (compiled TS, HTML, site bundles). Treat all generated files as read-only build outputs.
- We do not generate or reference separate TS/HTML components for missing views. Render dialogs, tables, and similar UI directly from Java (JWebMP) in the appropriate page/component or cell renderer. Example: a “missing graders stations” view must be produced directly from Java renderers, not via a standalone TS/HTML component.
- If any Angular/TypeScript output exists, it is generated from Java sources. Never hand-edit generated TS/HTML; make changes in Java so the generator produces the desired result.
- Avoid inline string HTML in Java. Always express markup using JWebMP components (Div, Paragraph, Span, Table, H1–H6, etc.).

## JWebMP Architecture Overview

JWebMP follows a component-based architecture that allows developers to create web applications using Java objects that represent HTML elements and their behaviors. The framework consists of three main modules:

1. **JWebMP-Core**: The foundation of the framework, providing base classes, components, and utilities for building web applications.
2. **JWebMP-Client**: Handles client-side functionality, including AJAX calls, page configuration, and client-server communication.
3. **JWebMP Vert.X**: Integrates with the Vert.x reactive framework to provide high-performance, non-blocking I/O operations and WebSocket support.

## JWebMP-Core Components

### Base Components

JWebMP-Core provides a rich set of base components that represent HTML elements and their behaviors. These components are the building blocks for creating web applications.

#### Component Hierarchy

The component hierarchy in JWebMP starts with the `Component` class, which is the base class for all UI components. Components can be nested to create complex UI structures.

```java
import com.jwebmp.core.base.html.Div;
import com.jwebmp.core.base.html.H1;
import com.jwebmp.core.base.html.Paragraph;

// Create a container div
Div container = new Div();

// Add a heading
H1 heading = new H1("Welcome to JWebMP");
container.add(heading);

// Add a paragraph
Paragraph paragraph = new Paragraph("This is a simple example of JWebMP components.");
container.add(paragraph);
```

#### Component Features

Components can have features attached to them, which add specific behaviors or functionality:

```java
import com.jwebmp.core.base.html.Div;
import com.jwebmp.core.events.click.ClickAdapter;

Div clickableDiv = new Div();
clickableDiv.addFeature(new ClickAdapter()
    .setOnClickFunction("alert('Div clicked!');"));
```

### Events

JWebMP provides a comprehensive event system that allows components to respond to user interactions:

```java
import com.jwebmp.core.base.html.Button;
import com.jwebmp.core.events.click.ClickAdapter;

Button submitButton = new Button("Submit");
submitButton.addEvent(new ClickAdapter()
    .setOnClickFunction("console.log('Button clicked');")
    .setPreventDefault(true));
```

### Page Configuration

Pages in JWebMP are configured using annotations and the `Page` class:

```java
import com.jwebmp.core.Page;
import com.jwebmp.core.annotations.PageConfiguration;

@PageConfiguration(
    title = "My JWebMP Application",
    description = "A sample JWebMP application",
    author = "JWebMP Developer"
)
public class MyPage extends Page {
    public MyPage() {
        // Page initialization
    }
}
```

## JWebMP-Client Integration

JWebMP-Client handles client-side functionality, including AJAX calls, page configuration, and client-server communication.

### AJAX Functionality

JWebMP provides built-in AJAX functionality for asynchronous communication with the server:

```java
import com.jwebmp.core.base.ajax.AjaxCall;
import com.jwebmp.core.base.ajax.AjaxResponse;
import com.jwebmp.core.base.html.Button;
import com.jwebmp.core.events.click.ClickAdapter;

Button ajaxButton = new Button("Load Data");
ajaxButton.addEvent(new ClickAdapter() {
    @Override
    public void onClick(AjaxCall call, AjaxResponse response) {
        // Handle the AJAX request
        response.addComponent(new Div().setText("Data loaded successfully!"));
    }
});
```

### Client-Side Functionality

JWebMP-Client provides functionality for client-side operations and communication:

```java
import com.jwebmp.core.base.html.Div;
import com.jwebmp.core.base.html.attributes.GlobalAttributes;
import com.jwebmp.core.base.html.interfaces.GlobalFeatures;

public class ClientComponent extends Div implements GlobalFeatures {
    
    public ClientComponent() {
        // Set client-side attributes
        addAttribute(GlobalAttributes.Id, "client-component");
        addAttribute(GlobalAttributes.Class, "client-component");
    }
    
    // Add client-side event handling
    public void addClientSideEvent(String eventName, String eventHandler) {
        addAttribute("on" + eventName, eventHandler);
    }
}
```

## JWebMP Vert.X Integration

JWebMP integrates with Vert.x to provide high-performance, non-blocking I/O operations and WebSocket support.

### Setting Up Vert.x Integration

To set up Vert.x integration in a JWebMP application:

```java
import com.jwebmp.vertx.JWebMPVertx;
import io.vertx.core.Vertx;

public class Application {
    public static void main(String[] args) {
        IGuiceContext.inject();
    }
}
```

### WebSocket Communication

JWebMP Vert.x provides WebSocket support for real-time communication:

```java
import com.jwebmp.vertx.JWebMPWebSocket;
import io.vertx.core.http.ServerWebSocket;

public class WebSocketHandler extends JWebMPWebSocket {
    @Override
    public void handleWebSocket(ServerWebSocket webSocket) {
        // Handle WebSocket connection
        webSocket.textMessageHandler(message -> {
            // Process incoming message
            webSocket.writeTextMessage("Received: " + message);
        });
    }
}
```

### Event Bus Integration

Vert.x provides an event bus for communication between different parts of the application:

```java
import com.jwebmp.vertx.implementations.VertXEventBusBridgeIWebSocket;
import io.vertx.core.Vertx;
import io.vertx.core.eventbus.EventBus;

public class EventBusExample {
    public void setupEventBus(Vertx vertx) {
        EventBus eventBus = vertx.eventBus();
        
        // Register a consumer
        eventBus.consumer("address", message -> {
            System.out.println("Received message: " + message.body());
        });
        
        // Send a message
        eventBus.publish("address", "Hello from JWebMP!");
    }
}
```

## Best Practices for Generating JWebMP Components

When generating JWebMP components and runtime systems, follow these best practices:

1. **Component Structure**: Follow the component hierarchy with proper nesting and organization.
2. **Event Handling**: Use the appropriate event adapters for handling user interactions.
3. **Client-Side Integration**: Implement proper client-side functionality using JWebMP-Client features.
4. **Vert.x Integration**: Leverage Vert.x for high-performance, reactive applications.
5. **Code Organization**: Organize code into logical packages and follow Java naming conventions.
6. **Documentation**: Include comprehensive documentation for generated components.

## Common Patterns for JWebMP Components

### Form Components

Form components follow a specific pattern in JWebMP:

```java
import com.jwebmp.core.base.html.Form;
import com.jwebmp.core.base.html.Input;
import com.jwebmp.core.base.html.Button;

public class UserForm extends Form {
    private Input nameInput;
    private Input emailInput;
    private Button submitButton;
    
    public UserForm() {
        nameInput = new Input("text");
        nameInput.setPlaceholder("Enter your name");
        
        emailInput = new Input("email");
        emailInput.setPlaceholder("Enter your email");
        
        submitButton = new Button("Submit");
        
        add(nameInput);
        add(emailInput);
        add(submitButton);
    }
}
```

### Data Tables

Data tables are commonly used for displaying tabular data:

```java
import com.jwebmp.core.base.html.Table;
import com.jwebmp.core.base.html.Thead;
import com.jwebmp.core.base.html.Tbody;
import com.jwebmp.core.base.html.Tr;
import com.jwebmp.core.base.html.Th;
import com.jwebmp.core.base.html.Td;

public class UserTable extends Table {
    public UserTable(List<User> users) {
        // Create table header
        Thead thead = new Thead();
        Tr headerRow = new Tr();
        headerRow.add(new Th("Name"));
        headerRow.add(new Th("Email"));
        thead.add(headerRow);
        
        // Create table body
        Tbody tbody = new Tbody();
        for (User user : users) {
            Tr row = new Tr();
            row.add(new Td(user.getName()));
            row.add(new Td(user.getEmail()));
            tbody.add(row);
        }
        
        add(thead);
        add(tbody);
    }
}
```

### Navigation Components

Navigation components such as menus and navigation bars:

```java
import com.jwebmp.core.base.html.Nav;
import com.jwebmp.core.base.html.Ul;
import com.jwebmp.core.base.html.Li;
import com.jwebmp.core.base.html.Link;

public class NavigationMenu extends Nav {
    public NavigationMenu() {
        Ul menuList = new Ul();
        
        Li homeItem = new Li();
        Link homeLink = new Link("#home", "Home");
        homeItem.add(homeLink);
        
        Li aboutItem = new Li();
        Link aboutLink = new Link("#about", "About");
        aboutItem.add(aboutLink);
        
        Li contactItem = new Li();
        Link contactLink = new Link("#contact", "Contact");
        contactItem.add(contactLink);
        
        menuList.add(homeItem);
        menuList.add(aboutItem);
        menuList.add(contactItem);
        
        add(menuList);
    }
}
```

## Advanced Topics

### Custom Components

Creating custom components with JWebMP-Core:

```java
import com.jwebmp.core.base.html.Div;
import com.jwebmp.core.base.html.H1;
import com.jwebmp.core.base.html.attributes.GlobalAttributes;

public class DashboardComponent extends Div {
    private String title = "Dashboard";
    private Div contentDiv;
    
    public DashboardComponent() {
        // Add CSS class
        addClass("dashboard");
        
        // Add heading
        H1 heading = new H1(title);
        add(heading);
        
        // Add content container
        contentDiv = new Div();
        contentDiv.addClass("dashboard-content");
        add(contentDiv);
    }
    
    // Method to add content to the dashboard
    public DashboardComponent addContent(com.jwebmp.core.base.ComponentBase component) {
        contentDiv.add(component);
        return this;
    }
    
    // Getters and setters
    public String getTitle() {
        return title;
    }
    
    public DashboardComponent setTitle(String title) {
        this.title = title;
        return this;
    }
}
```

### State Management

Implementing state management in JWebMP applications:

```java
import com.jwebmp.core.base.interfaces.IComponentHierarchyBase;
import com.jwebmp.core.events.change.ChangeAdapter;
import java.util.ArrayList;
import java.util.List;

public class StateManager<T> {
    private T state;
    private List<StateChangeListener<T>> listeners = new ArrayList<>();
    
    public StateManager(T initialState) {
        this.state = initialState;
    }
    
    public T getState() {
        return state;
    }
    
    public void setState(T newState) {
        T oldState = this.state;
        this.state = newState;
        notifyListeners(oldState, newState);
    }
    
    public void addListener(StateChangeListener<T> listener) {
        listeners.add(listener);
    }
    
    public void removeListener(StateChangeListener<T> listener) {
        listeners.remove(listener);
    }
    
    private void notifyListeners(T oldState, T newState) {
        for (StateChangeListener<T> listener : listeners) {
            listener.onStateChanged(oldState, newState);
        }
    }
    
    // Attach state change to a component
    public <J extends IComponentHierarchyBase<?,?>> J bindToComponent(J component, 
                                                                    String eventName, 
                                                                    StateUpdater<T> updater) {
        component.addEvent(new ChangeAdapter() {
            @Override
            public void onChange() {
                setState(updater.update(getState()));
            }
        });
        return component;
    }
    
    // Functional interfaces for state management
    public interface StateChangeListener<T> {
        void onStateChanged(T oldState, T newState);
    }
    
    public interface StateUpdater<T> {
        T update(T currentState);
    }
}
```

### WebSocket Real-time Updates

Implementing real-time updates with WebSockets:

```java
import com.jwebmp.vertx.JWebMPVertx;
import io.vertx.core.Vertx;
import io.vertx.core.http.HttpServer;
import io.vertx.core.http.ServerWebSocket;

public class RealTimeUpdates {
    private Vertx vertx;
    private HttpServer server;
    
    public void start() {
        vertx = Vertx.vertx();
        server = vertx.createHttpServer();
        
        server.webSocketHandler(webSocket -> {
            // Handle WebSocket connection
            webSocket.textMessageHandler(message -> {
                // Process incoming message
                broadcastMessage(message);
            });
        });
        
        server.listen(8080);
    }
    
    private void broadcastMessage(String message) {
        // Broadcast message to all connected clients
        // Implementation depends on how you track connected clients
    }
}
```

## Conclusion

This guide provides a comprehensive overview of generating JWebMP components and runtime systems, focusing on JWebMP-Core, JWebMP-Client, and JWebMP Vert.X integration. By following the patterns, best practices, and examples provided in this guide, AI systems can effectively generate high-quality JWebMP code that follows the framework's design principles and leverages its powerful features.

## References

- [JWebMP Official Documentation](https://jwebmp.com/documentation)
- [Vert.x Documentation](https://vertx.io/docs/)

## Inline HTML Policy: Use Components Only

Avoid inline string HTML anywhere in Java when building JWebMP UIs. Represent all markup with JWebMP components. This ensures correctness, safety, accessibility, theming, and generator compatibility.

Don’t (inline HTML strings):
```java
Div container = new Div();
container.setText("<h1>Dashboard</h1><p>Welcome, user.</p>"); // ❌ inline HTML
container.add(new Div().setText("<span class='badge'>3</span>")); // ❌ injecting tags as text
```

Do (compose with components):
```java
Div container = new Div();
container.add(new H1("Dashboard"));
container.add(new Paragraph("Welcome, user."));
Span badge = new Span("3");
badge.addClass("badge");
container.add(badge);
```

Tables (example):
```java
Table table = new Table();
THead thead = new THead();
TR header = new TR();
header.add(new TH("Name"));
header.add(new TH("Status"));
thead.add(header);

TBody tbody = new TBody();
TR row = new TR();
row.add(new TD("Station A"));
TD status = new TD();
status.add(new Span("Missing").addClass("status status-missing"));
row.add(status);

tbody.add(row);

table.add(thead);
table.add(tbody);
```

Rare exception:
- It is acceptable to set plain text without tags (the framework will escape it). Do not include HTML tags in setText values.
- When interoperating with third-party sanitized HTML, wrap it in a dedicated component/renderer that handles sanitization and explicitly documents the source and guarantees. Prefer component composition instead.

Notes:
- This policy aligns with “do not touch generated artifacts” and “no separate TS/HTML” rules. All UI must be produced from Java components/cell renderers so generators can produce consistent outputs.
