# JWebMP Angular AI Guide

## Introduction

This guide provides comprehensive information for AI systems to generate Angular 20 TypeScript applications using JWebMP (Java Web Markup Processor). It covers the integration between JWebMP's TypescriptClient and AngularModule components, including all interfaces, annotations, configurations, and elements necessary for successful code generation.

JWebMP's Angular integration allows developers to create Angular applications using pure Java code, which is then compiled to TypeScript. This guide is intended for AI systems that need to understand the framework's architecture and generate code that follows JWebMP's design patterns and best practices for Angular 20 applications.

Important policy for generators and maintainers (JWebMP + Angular):
- Generated TypeScript/HTML is a build output and must not be hand-edited. Make changes in the Java source that feeds the generator.
- Some projects disable separate Angular component generation entirely; for those, render dialogs, tables, and other UI directly from Java (JWebMP) within page/components or cell renderers. Do not introduce separate TS/HTML components for missing views (e.g., “missing graders stations”).
- Never propose edits to checked-in generated site/bundle files.
- Avoid inline string HTML in Java. Always express markup using JWebMP components (Div, Paragraph, Span, Table, H1–H6, etc.).

## JWebMP Angular Architecture Overview

JWebMP's Angular integration consists of two main modules:

1. **TypescriptClient**: Provides interfaces and annotations for converting Java classes to TypeScript, including data types, components, services, and directives.
2. **AngularModule**: Handles the compilation of Java classes to TypeScript and configures the Angular application.

These modules work together to enable the development of Angular applications using Java, with automatic conversion to TypeScript during the build process.

## TypescriptClient Module

The TypescriptClient module provides the foundation for converting Java classes to TypeScript. It includes interfaces, annotations, and utility classes for defining Angular components, services, and data types.

### Key Interfaces

#### INgDataType

The `INgDataType` interface is used to define TypeScript data types. It provides methods for converting Java fields to TypeScript properties and handling type mappings.

```java
public interface INgDataType<J extends INgDataType<J>> extends IComponent<J>, IJsonRepresentation<J> {
    // Methods for generating TypeScript field declarations
    default List<String> fields();
    default String typeField(Class fieldType, Field field);
    default void renderFieldTS(StringBuilder out, String fieldName, Class fieldType, Field field, boolean array);
    
    // Methods for handling component references
    default List<NgComponentReference> getComponentReferences();
    default List<NgComponentReference> renderFieldReference(String fieldName, Class fieldType, Field field, boolean array);
    
    // Methods for handling imports
    default Map<String, String> imports();
}
```

#### IComponent

The `IComponent` interface is the base interface for all Angular components in JWebMP. It provides methods for rendering TypeScript code and managing component references.

```java
public interface IComponent<J extends IComponent<J>> {
    // Methods for rendering TypeScript code
    default String renderClassTs();
    default List<String> fields();
    
    // Methods for handling imports
    default Map<String, String> imports();
    default List<NgComponentReference> getComponentReferences();
}
```

#### INgComponent

The `INgComponent` interface is used to define Angular components. It extends `IComponent` and provides methods specific to Angular components.

```java
public interface INgComponent<J extends INgComponent<J>> extends IComponent<J> {
    // Methods for handling component configuration
    default String selector();
    default String templateUrl();
    default String styleUrls();
    default String[] imports();
    default String[] providers();
}
```

#### INgModule

The `INgModule` interface is used to define Angular modules. It provides methods for configuring module imports, exports, declarations, and providers.

```java
public interface INgModule<J extends INgModule<J>> extends IComponent<J> {
    // Methods for handling module configuration
    default String[] imports();
    default String[] exports();
    default String[] declarations();
    default String[] providers();
    
    // Method for setting the application
    void setApp(INgApp<?> app);
}
```

#### INgDataService

The `INgDataService` interface is used to define Angular services. It provides methods for configuring service dependencies and functionality.

```java
public interface INgDataService<J extends INgDataService<J>> extends IComponent<J> {
    // Methods for handling service configuration
    default String[] providedIn();
    default String[] imports();
}
```

#### INgDirective

The `INgDirective` interface is used to define Angular directives. It provides methods for configuring directive selectors and behavior.

```java
public interface INgDirective<J extends INgDirective<J>> extends IComponent<J> {
    // Methods for handling directive configuration
    default String selector();
    default String[] inputs();
    default String[] outputs();
}
```

#### INgApp

The `INgApp` interface is used to define Angular applications. It provides methods for configuring the application's bootstrap component, assets, scripts, and stylesheets.

```java
public interface INgApp<J extends INgApp<J>> {
    // Methods for handling application configuration
    Class<?> getAnnotation();
    String[] assets();
    String[] scripts();
    String[] stylesheets();
    DevelopmentEnvironments getRunningEnvironment();
}
```

### Key Annotations

#### NgDataType

The `NgDataType` annotation is used to mark Java classes that should be converted to TypeScript data types. It provides options for configuring the generated TypeScript.

```java
@Target({TYPE})
@Retention(RUNTIME)
@Inherited
public @interface NgDataType {
    DataTypeClass value() default DataTypeClass.Interface;
    boolean exports() default true;
    String name() default "";
    String returnType() default "";
    
    enum DataTypeClass {
        Class,
        Function,
        Enum,
        AbstractClass,
        Interface,
        Const;
    }
}
```

#### NgComponent

The `NgComponent` annotation is used to mark Java classes that should be converted to Angular components. It provides options for configuring the component's selector, template, and styles.

```java
@Target({TYPE})
@Retention(RUNTIME)
@Inherited
public @interface NgComponent {
    String value(); // Component selector
    String templateUrl() default "";
    String[] styleUrls() default {};
    boolean standalone() default false;
    String[] imports() default {};
    String[] providers() default {};
}
```

#### NgModule

The `NgModule` annotation is used to mark Java classes that should be converted to Angular modules. It provides options for configuring the module's imports, exports, declarations, and providers.

```java
@Target({TYPE})
@Retention(RUNTIME)
@Inherited
public @interface NgModule {
    String[] imports() default {};
    String[] exports() default {};
    String[] declarations() default {};
    String[] providers() default {};
    boolean standalone() default false;
}
```

#### NgDataService

The `NgDataService` annotation is used to mark Java classes that should be converted to Angular services. It provides options for configuring the service's scope and dependencies.

```java
@Target({TYPE})
@Retention(RUNTIME)
@Inherited
public @interface NgDataService {
    String providedIn() default "root";
    String[] imports() default {};
}
```

#### NgDirective

The `NgDirective` annotation is used to mark Java classes that should be converted to Angular directives. It provides options for configuring the directive's selector and behavior.

```java
@Target({TYPE})
@Retention(RUNTIME)
@Inherited
public @interface NgDirective {
    String selector();
    String[] inputs() default {};
    String[] outputs() default {};
}
```

#### NgApp

The `NgApp` annotation is used to mark Java classes that should be converted to Angular applications. It provides options for configuring the application's bootstrap component and other settings.

```java
@Target({TYPE})
@Retention(RUNTIME)
@Inherited
public @interface NgApp {
    String value(); // Application name
    Class<?> bootComponent(); // Bootstrap component
    String[] assets() default {};
    String[] scripts() default {};
    String[] stylesheets() default {};
}
```

### Utility Classes

#### DynamicData

The `DynamicData` class is a utility for passing dynamic data between Java and TypeScript. It implements `INgDataType` and provides methods for adding data.

```java
@NgDataType
public final class DynamicData implements INgDataType<DynamicData>, IJsonRepresentation<DynamicData> {
    private List<Object> out = new ArrayList<>();
    
    public DynamicData addData(INgDataType<?>... out) {
        this.out.addAll(Arrays.asList(out));
        return this;
    }
    
    public DynamicData addData(Object out) {
        this.out.addAll(Arrays.asList(out));
        return this;
    }
    
    public List<Object> getOut() {
        return out;
    }
}
```

## AngularModule

The AngularModule handles the compilation of Java classes to TypeScript and configures the Angular application. It includes the TypeScript compiler, configuration classes, and utilities for managing Angular-specific features.

### JWebMPTypeScriptCompiler

The `JWebMPTypeScriptCompiler` class is responsible for compiling Java classes to TypeScript. It provides methods for rendering different Angular components and configuring the Angular application.

```java
public class JWebMPTypeScriptCompiler {
    // Constructor
    public JWebMPTypeScriptCompiler(INgApp<?> app);
    
    // Methods for rendering TypeScript
    public StringBuilder renderDataTypeTS(NgApp ngApp, File srcDirectory, INgDataType<?> component, Class<?> requestingClass);
    public StringBuilder renderServiceProviderTS(NgApp ngApp, File srcDirectory, INgServiceProvider<?> component, Class<?> requestingClass);
    public StringBuilder renderProviderTS(NgApp ngApp, File srcDirectory, INgProvider<?> component, Class<?> requestingClass);
    public StringBuilder renderServiceTS(NgApp ngApp, File srcDirectory, INgDataService<?> component, Class<?> requestingClass);
    public StringBuilder renderDirectiveTS(NgApp ngApp, File srcDirectory, INgDirective<?> component, Class<?> requestingClass);
    public StringBuilder renderComponentTS(NgApp ngApp, File srcDirectory, INgComponent<?> component, Class<?> requestingClass);
    public StringBuilder renderModuleTS(NgApp ngApp, File srcDirectory, INgModule<?> component, Class<?> requestingClass);
    public StringBuilder renderAppTS(INgApp<?> appNgApp);
    
    // Methods for configuring the Angular application
    private void processPackageJsonFile(File file, Class<? extends INgApp<?>> appClass, String packageTemplate, ObjectMapper om, Map<String, String> dependencies, Map<String, String> devDependencies, Map<String, String> overrideDependencies, File packageJsonFile);
    private void processTypeScriptConfigFiles(File file, Class<? extends INgApp<?>> appClass);
    private void processPolyfillFile(File file, Class<? extends INgApp<?>> appClass);
    private void processAppConfigFile(File file, ScanResult scan, Class<? extends INgApp<?>> appClass);
    
    // Methods for processing Angular components
    private void processNgModuleFiles(File currentApp, ClassInfo a, ScanResult scan, Class<? extends INgApp<?>> appClass, INgApp<?> app, File finalSrcDirectory);
    private boolean processStandaloneComponent(File currentApp, NGApplication<?> application, ClassInfo aClass, CallScoper callScoper, INgApp<?> app, Class<? extends INgApp<?>> appClass, File finalSrcDirectory);
    private void processNgDirectiveFiles(File currentApp, ClassInfo a, ScanResult scan, Class<? extends INgApp<?>> appClass, File finalSrcDirectory);
    private void processNgDataServiceFiles(File currentApp, ClassInfo a, ScanResult scan, Class<? extends INgApp<?>> appClass, File finalSrcDirectory);
    private void processNgProviderFiles(File currentApp, ClassInfo a, ScanResult scan, Class<? extends INgApp<?>> appClass, File finalSrcDirectory);
    private void processNgDataTypeFiles(File currentApp, ClassInfo a, ScanResult scan, Class<? extends INgApp<?>> appClass, File finalSrcDirectory);
    private void processNgServiceProviderFiles(File currentApp, ClassInfo a, ScanResult scan, Class<? extends INgApp<?>> appClass, File finalSrcDirectory);
    
    // Methods for building and deploying
    public static void installDependencies(File appBaseDirectory);
    public static void installAngular(File appBaseDirectory);
}
```

### Configuration Annotations

#### NgAsset

The `NgAsset` annotation is used to define assets for the Angular application.

```java
@Target({TYPE})
@Retention(RUNTIME)
@Inherited
public @interface NgAsset {
    String value();
    String name() default "";
    String[] replaces() default {};
}
```

#### NgStyleSheet

The `NgStyleSheet` annotation is used to define stylesheets for the Angular application.

```java
@Target({TYPE})
@Retention(RUNTIME)
@Inherited
public @interface NgStyleSheet {
    String value();
    String name() default "";
    String[] replaces() default {};
    int sortOrder() default 0;
}
```

#### NgScript

The `NgScript` annotation is used to define scripts for the Angular application.

```java
@Target({TYPE})
@Retention(RUNTIME)
@Inherited
public @interface NgScript {
    String value();
    String name() default "";
    String[] replaces() default {};
    int sortOrder() default 0;
}
```

#### NgPolyfill

The `NgPolyfill` annotation is used to define polyfills for the Angular application.

```java
@Target({TYPE})
@Retention(RUNTIME)
@Inherited
public @interface NgPolyfill {
    String value();
}
```

#### TsDependency

The `TsDependency` annotation is used to define TypeScript dependencies for the Angular application.

```java
@Target({TYPE})
@Retention(RUNTIME)
@Inherited
public @interface TsDependency {
    String value();
    String version();
    String name() default "";
    boolean overrides() default false;
}
```

#### TsDevDependency

The `TsDevDependency` annotation is used to define TypeScript development dependencies for the Angular application.

```java
@Target({TYPE})
@Retention(RUNTIME)
@Inherited
public @interface TsDevDependency {
    String value();
    String version();
}
```

## Annotation Processing Mechanism

JWebMP uses a sophisticated annotation processing mechanism to generate Angular applications from Java code. The process involves scanning for classes with specific annotations, processing them to generate TypeScript files, and organizing them into the appropriate directory structure.

### Scanning for Annotated Classes

The `JWebMPTypeScriptCompiler` uses ClassGraph to scan for classes with specific annotations. Here's a simplified overview of how it works:

```java
// Get the scan result from the Guice context
ScanResult scan = IGuiceContext.instance().getScanResult();

// Process NgModule classes
scan.getClassesWithAnnotation(NgModule.class)
    .stream()
    .forEach(a -> {
        // Process each NgModule class
        processNgModuleFiles(currentApp, a, scan, appClass, app, finalSrcDirectory);
    });

// Process standalone components
if (app instanceof NGApplication<?> application) {
    scan.getClassesWithAnnotation(NgComponent.class)
        .stream()
        .filter(a -> !a.isAbstract() && !a.isInterface())
        .filter(a -> a.loadClass().getAnnotation(NgComponent.class).standalone())
        .distinct()
        .forEach(aClass -> {
            // Process each standalone component
            processStandaloneComponent(currentApp, application, aClass, callScoper, app, appClass, finalSrcDirectory);
        });
}

// Process other Angular elements
scan.getClassesWithAnnotation(NgDirective.class).stream().forEach(a -> {
    processNgDirectiveFiles(currentApp, a, scan, appClass, finalSrcDirectory);
});

scan.getClassesWithAnnotation(NgDataService.class).stream().forEach(a -> {
    processNgDataServiceFiles(currentApp, a, scan, appClass, finalSrcDirectory);
});

scan.getClassesWithAnnotation(NgProvider.class).stream().forEach(a -> {
    processNgProviderFiles(currentApp, a, scan, appClass, finalSrcDirectory);
});

scan.getClassesWithAnnotation(NgDataType.class).stream().forEach(a -> {
    processNgDataTypeFiles(currentApp, a, scan, appClass, finalSrcDirectory);
});

scan.getClassesWithAnnotation(NgServiceProvider.class).stream().forEach(a -> {
    processNgServiceProviderFiles(currentApp, a, scan, appClass, finalSrcDirectory);
});
```

### Processing Annotated Classes

For each annotated class, the `JWebMPTypeScriptCompiler` calls a specific processing method based on the annotation type. These methods load the class, create an instance of it, and then call the appropriate rendering method to generate the TypeScript code.

For example, the `processNgDataTypeFiles` method processes classes with the `NgDataType` annotation:

```java
private void processNgDataTypeFiles(File currentApp, ClassInfo a, ScanResult scan, Class<? extends INgApp<?>> appClass, File finalSrcDirectory) {
    try {
        // Load the class
        Class<?> aClass = a.loadClass();
        
        // Check if it implements INgDataType
        if (INgDataType.class.isAssignableFrom(aClass)) {
            // Create an instance of the class
            INgDataType<?> component = (INgDataType<?>) aClass.getDeclaredConstructor().newInstance();
            
            // Get the NgApp annotation
            NgApp ngApp = aClass.getAnnotation(NgApp.class);
            
            // Render the TypeScript code
            StringBuilder sb = renderDataTypeTS(ngApp, finalSrcDirectory, component, aClass);
            
            // Write the TypeScript file
            String tsFilename = getTsFilename(aClass);
            File tsFile = new File(finalSrcDirectory.getCanonicalPath() + "/" + tsFilename);
            FileUtils.writeStringToFile(tsFile, sb.toString(), UTF_8, false);
        }
    } catch (Exception e) {
        log.error("Unable to process NgDataType file", e);
    }
}
```

### File Generation Process

The `JWebMPTypeScriptCompiler` generates the following files and directories for an Angular application:

1. **main.ts**: The entry point for the Angular application, which bootstraps the application.
2. **index.html**: The HTML file that hosts the Angular application.
3. **app/app.config.ts**: The configuration file for the Angular application.
4. **app/components/**: Directory for Angular components.
5. **app/services/**: Directory for Angular services.
6. **app/directives/**: Directory for Angular directives.
7. **app/models/**: Directory for Angular data types.
8. **assets/**: Directory for static assets like images, fonts, etc.
9. **styles/**: Directory for global stylesheets.
10. **package.json**: Configuration file for npm dependencies.
11. **tsconfig.json**: Configuration file for TypeScript compilation.

The directory structure follows Angular's recommended structure, making it easy to navigate and maintain.

## Step-by-Step Guide for Generating Angular 20 Applications

### 1. Define the Angular Application

Create a Java class that implements `INgApp` and is annotated with `@NgApp`. This class will be the entry point for your Angular application.

```java
@NgApp(value = "my-app", bootComponent = AppComponent.class)
public class MyAngularApp implements INgApp<MyAngularApp> {
    @Override
    public Class<?> getAnnotation() {
        return AppComponent.class;
    }
    
    @Override
    public String[] assets() {
        return new String[]{"assets/logo.png"};
    }
    
    @Override
    public String[] scripts() {
        return new String[]{"scripts/custom.js"};
    }
    
    @Override
    public String[] stylesheets() {
        return new String[]{"styles/custom.css"};
    }
    
    @Override
    public DevelopmentEnvironments getRunningEnvironment() {
        return DevelopmentEnvironments.Development;
    }
}
```

### 2. Create the Bootstrap Component

Create a Java class that implements `INgComponent` and is annotated with `@NgComponent`. This class will be the bootstrap component for your Angular application.

```java
@NgComponent(value = "app-root", standalone = true)
public class AppComponent extends DivSimple<AppComponent> implements INgComponent<AppComponent> {
    public AppComponent() {
        add(new H1("Welcome to My Angular App"));
        add(new Paragraph("This is a simple example of a JWebMP Angular component."));
    }
    
    @Override
    public String[] imports() {
        return new String[]{"CommonModule"};
    }
}
```

### 3. Define Data Types

Create Java classes that implement `INgDataType` and are annotated with `@NgDataType`. These classes will be converted to TypeScript interfaces or classes.

```java
@NgDataType
public class User implements INgDataType<User> {
    private String name;
    private String email;
    private int age;
    
    // Getters and setters
}
```

### 4. Create Services

Create Java classes that implement `INgDataService` and are annotated with `@NgDataService`. These classes will be converted to Angular services.

```java
@NgDataService
public class UserService implements INgDataService<UserService> {
    private final HttpClient httpClient;
    
    public UserService(HttpClient httpClient) {
        this.httpClient = httpClient;
    }
    
    public Observable<User[]> getUsers() {
        return httpClient.get<User[]>("/api/users");
    }
}
```

### 5. Create Components

Create Java classes that implement `INgComponent` and are annotated with `@NgComponent`. These classes will be converted to Angular components.

```java
@NgComponent(value = "app-user-list", standalone = true)
public class UserListComponent extends DivSimple<UserListComponent> implements INgComponent<UserListComponent> {
    private final UserService userService;
    
    public UserListComponent(UserService userService) {
        this.userService = userService;
        
        add(new H2("User List"));
        
        // Create a list of users
        UL<?, ?> userList = new UL<>();
        add(userList);
        
        // Add a placeholder for users
        userList.add(new LI<>().setText("Loading users..."));
    }
    
    @Override
    public String[] imports() {
        return new String[]{"CommonModule", "UserService"};
    }
}
```

### 6. Create Directives

Create Java classes that implement `INgDirective` and are annotated with `@NgDirective`. These classes will be converted to Angular directives.

```java
@NgDirective(selector = "[appHighlight]")
public class HighlightDirective implements INgDirective<HighlightDirective> {
    @Override
    public String[] inputs() {
        return new String[]{"appHighlight"};
    }
}
```

### 7. Create Modules

Create Java classes that implement `INgModule` and are annotated with `@NgModule`. These classes will be converted to Angular modules.

```java
@NgModule(
    imports = {"CommonModule", "HttpClientModule"},
    declarations = {"UserListComponent", "HighlightDirective"},
    exports = {"UserListComponent"}
)
public class UserModule implements INgModule<UserModule> {
    private INgApp<?> app;
    
    @Override
    public void setApp(INgApp<?> app) {
        this.app = app;
    }
}
```

### 8. Compile to TypeScript

Use the `JWebMPTypeScriptCompiler` to compile your Java classes to TypeScript.

```java
public class AngularCompiler {
    public static void main(String[] args) {
        INgApp<?> app = new MyAngularApp();
        JWebMPTypeScriptCompiler compiler = new JWebMPTypeScriptCompiler(app);
        compiler.renderAppTS(app);
    }
}
```

## Common Patterns and Edge Cases

### Component Hierarchies

JWebMP supports complex component hierarchies through its component-based architecture. You can create nested components by adding child components to parent components:

```java
@NgComponent(value = "app-parent", standalone = true)
public class ParentComponent extends DivSimple<ParentComponent> implements INgComponent<ParentComponent> {
    public ParentComponent() {
        add(new H1("Parent Component"));
        
        // Add child component
        add(new ChildComponent());
    }
    
    @Override
    public String[] imports() {
        return new String[]{"CommonModule", "ChildComponent"};
    }
}

@NgComponent(value = "app-child", standalone = true)
public class ChildComponent extends DivSimple<ChildComponent> implements INgComponent<ChildComponent> {
    public ChildComponent() {
        add(new H2("Child Component"));
    }
    
    @Override
    public String[] imports() {
        return new String[]{"CommonModule"};
    }
}
```

### State Management

For state management, you can use Angular 20's built-in signal-based state management or integrate with external state management libraries like NgRx:

```java
@NgComponent(value = "app-counter", standalone = true)
public class CounterComponent extends DivSimple<CounterComponent> implements INgComponent<CounterComponent> {
    public CounterComponent() {
        add(new H2("Counter with Signals"));
        
        // Create a counter display using signals
        Paragraph counterDisplay = new Paragraph("Count: {{ count() }}");
        add(counterDisplay);
        
        // Create increment button
        Button incrementButton = new Button("Increment");
        incrementButton.addAttribute("(click)", "increment()");
        add(incrementButton);
    }
    
    @Override
    public String[] imports() {
        return new String[]{"CommonModule"};
    }
}
```

### Routing

For routing, you can use Angular's Router module:

```java
@NgComponent(value = "app-root", standalone = true)
public class AppComponent extends DivSimple<AppComponent> implements INgComponent<AppComponent> {
    public AppComponent() {
        add(new H1("My Angular App"));
        
        // Create navigation
        UL<?, ?> nav = new UL<>();
        nav.addClass("nav");
        
        LI<?> homeLink = new LI<>();
        homeLink.add(new Anchor<>().setText("Home").addAttribute("routerLink", "/home"));
        nav.add(homeLink);
        
        LI<?> usersLink = new LI<>();
        usersLink.add(new Anchor<>().setText("Users").addAttribute("routerLink", "/users"));
        nav.add(usersLink);
        
        add(nav);
        
        // Add router outlet
        DivSimple<?> routerOutlet = new DivSimple<>();
        routerOutlet.addAttribute("router-outlet", "");
        add(routerOutlet);
    }
    
    @Override
    public String[] imports() {
        return new String[]{"CommonModule", "RouterModule"};
    }
}
```

### Dependency Injection

Angular's dependency injection system is fully supported in JWebMP. You can inject services into components, directives, and other services:

```java
@NgComponent(value = "app-user-list", standalone = true)
public class UserListComponent extends DivSimple<UserListComponent> implements INgComponent<UserListComponent> {
    private final UserService userService;
    private final LoggingService loggingService;
    
    public UserListComponent(UserService userService, LoggingService loggingService) {
        this.userService = userService;
        this.loggingService = loggingService;
        
        loggingService.log("UserListComponent initialized");
        
        add(new H2("User List"));
        
        // Create a list of users
        UL<?, ?> userList = new UL<>();
        add(userList);
        
        // Add a placeholder for users
        userList.add(new LI<>().setText("Loading users..."));
    }
    
    @Override
    public String[] imports() {
        return new String[]{"CommonModule", "UserService", "LoggingService"};
    }
}
```

## Best Practices for Generating Angular 20 Applications

1. **Component Structure**: Follow Angular's component-based architecture, with each component responsible for a specific part of the UI.
2. **Standalone Components**: Use standalone components (introduced in Angular 14 and enhanced in Angular 20) for better tree-shaking and performance.
3. **Reactive State Management**: Leverage Angular 20's built-in state management based on signals for reactive applications.
4. **Dependency Injection**: Use Angular's dependency injection system for managing component dependencies.
5. **Type Safety**: Leverage TypeScript's type system for better code quality and developer experience.
6. **Modular Design**: Organize your application into feature modules for better maintainability and lazy loading.
7. **Server-Side Rendering**: Consider using Angular's server-side rendering capabilities for better performance and SEO.
8. **Web Components**: Use Angular's web components integration for creating reusable components that can be used outside of Angular.

## Angular 20 Specific Features

Angular 20, released in May 2025, includes several key improvements over previous versions:

1. **Reactive State Management Framework**: Built-in state management solution based on signals.
2. **Hydration Improvements**: Zero-flicker hydration with intelligent state reconciliation.
3. **Micro-Frontend Architecture Support**: Native tooling for module federation and micro-frontends.
4. **Enhanced Developer Experience**: Improved error messages, debugging tools, and performance insights.
5. **Streamlined Dependency Injection**: Simplified DI system with improved tree-shaking.
6. **Web Components Integration**: Better support for creating and consuming web components.

When generating Angular 20 applications, make sure to leverage these features for optimal performance and developer experience.

## Examples

### Basic Component

```java
@NgComponent(value = "app-counter", standalone = true)
public class CounterComponent extends DivSimple<CounterComponent> implements INgComponent<CounterComponent> {
    public CounterComponent() {
        add(new H2("Counter"));
        
        // Create a counter display
        Paragraph counterDisplay = new Paragraph("Count: 0");
        counterDisplay.addAttribute("id", "counter-display");
        add(counterDisplay);
        
        // Create increment button
        Button incrementButton = new Button("Increment");
        incrementButton.addAttribute("(click)", "increment()");
        add(incrementButton);
    }
    
    @Override
    public String[] imports() {
        return new String[]{"CommonModule"};
    }
}
```

### Service with HTTP Client

```java
@NgDataService
public class DataService implements INgDataService<DataService> {
    private final HttpClient httpClient;
    
    public DataService(HttpClient httpClient) {
        this.httpClient = httpClient;
    }
    
    public Observable<Object> getData() {
        return httpClient.get("/api/data");
    }
    
    public Observable<Object> postData(Object data) {
        return httpClient.post("/api/data", data);
    }
    
    @Override
    public String[] imports() {
        return new String[]{"HttpClient", "Observable"};
    }
}
```

### Reactive Form Component

```java
@NgComponent(value = "app-user-form", standalone = true)
public class UserFormComponent extends Form<UserFormComponent> implements INgComponent<UserFormComponent> {
    public UserFormComponent() {
        addAttribute("[formGroup]", "userForm");
        addAttribute("(ngSubmit)", "onSubmit()");
        
        // Create form fields
        DivSimple<?> formGroup = new DivSimple<>();
        formGroup.addClass("form-group");
        
        // Name field
        Label nameLabel = new Label("Name");
        nameLabel.setFor("name");
        formGroup.add(nameLabel);
        
        Input nameInput = new Input("text");
        nameInput.setID("name");
        nameInput.addAttribute("formControlName", "name");
        nameInput.addClass("form-control");
        formGroup.add(nameInput);
        
        // Email field
        Label emailLabel = new Label("Email");
        emailLabel.setFor("email");
        formGroup.add(emailLabel);
        
        Input emailInput = new Input("email");
        emailInput.setID("email");
        emailInput.addAttribute("formControlName", "email");
        emailInput.addClass("form-control");
        formGroup.add(emailInput);
        
        // Submit button
        Button submitButton = new Button("Submit");
        submitButton.setType("submit");
        submitButton.addClass("btn btn-primary");
        
        add(formGroup);
        add(submitButton);
    }
    
    @Override
    public String[] imports() {
        return new String[]{"ReactiveFormsModule", "FormGroup", "FormControl", "Validators"};
    }
}
```

## Conclusion

This guide provides a comprehensive overview of generating Angular 20 TypeScript applications using JWebMP. By following the patterns, best practices, and examples provided in this guide, AI systems can effectively generate high-quality Angular code that follows JWebMP's design principles and leverages Angular 20's powerful features.

## References

- [JWebMP Official Documentation](https://jwebmp.com/documentation)
- [Angular 20 Documentation](https://angular.io/docs)
- [TypeScript Documentation](https://www.typescriptlang.org/docs)