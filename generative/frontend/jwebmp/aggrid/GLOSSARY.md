# AgGrid Topic Glossary

**Canonical terminology for JWebMP AgGrid plugin**

---

## Core Components

### AgGrid
The Java wrapper class for AG Grid. Extends `DivSimple<J>` and implements `INgComponent<J>`. Provides CRTP fluent API for configuration. Example: `new MyGrid().setHeight("600px").enableRowSelection("single")`.

**Related**: CRTP, Fluent API, IComponent

### AgGridOptions
POJO that serializes to JSON for Angular template binding. Specifies grid-level configuration: pagination, row selection, theming, filtering, sorting. Example: `gridOptions.put("pagination", true)`.

**Related**: Grid Configuration, JSON Serialization

### AgGridColumnDef
Column definition object. Specifies field, header, type, width, filter, sort, and custom renderer. Example: `new AgGridColumnDef().setField("status").setCellRenderer(StatusBadgeRenderer.class)`.

**Related**: Column Types, Filtering, Sorting, Cell Renderer

---

## Rendering & Display

### ICellRenderer
Interface for custom cell rendering. Extends `IComponent<C>`. Implements rendering logic for grid cells. Example: `StatusBadgeRenderer implements ICellRenderer<StatusBadgeRenderer>`.

**Related**: Cell Rendering, Component Lifecycle, Angular Integration

### Cell Renderer
Concrete implementation of `ICellRenderer`. Angular component that renders a grid cell. Examples: `StatusBadgeRenderer`, `ActionsRenderer`, `CurrencyRenderer`.

**Related**: Custom Components, Cell Display

### Header Component
Custom header component extending `IComponent`. Renders column headers with custom logic (filtering, grouping, sorting). Example: `SalaryHeaderComponent`.

**Related**: Column Customization, Headers

### Content Child (Renderer Registration)
Process of registering custom renderers with JWebMP codegen. Occurs via `@NgComponentReference` annotations. Ensures Angular component metadata generated.

**Related**: Component Registration, JWebMP Codegen

---

## Data Management

### fetchData Pattern
Standard method signature for retrieving grid rows. Returns `Uni<List<T>>` or `CompletableFuture<List<T>>`. Non-blocking; called by grid to load initial/refreshed data. Example: `public Uni<List<Order>> fetchData()`.

**Related**: Async Patterns, Pagination, Real-Time Updates

### Row Data
Array of objects to be displayed as grid rows. Each object's properties map to column definitions. Example: `List<OrderRecord> rowData = new ArrayList<>()`.

**Related**: Data Binding, Column Definitions

### Column Definitions
Array/list of `AgGridColumnDef` objects. Specifies structure and behavior of grid columns. Example: `List<AgGridColumnDef> columns = ...`.

**Related**: Column Configuration, Grid Structure

### Server-Side Data
Data fetched from database via repository/service. Respects server-side filtering, sorting, pagination. Example: `orderRepository.findPage(pageIndex, pageSize)`.

**Related**: Async Data Fetching, Pagination

---

## Events & Interaction

### Row Selection
User action of selecting one or more grid rows. Modes: `"single"` (one row), `"multiple"` (multiple rows). Triggered via `onRowSelectJS(rowId)` callback.

**Related**: Event Handling, User Interaction

### Cell Click Event
User clicking a grid cell. Handled via `onCellClickedJS(rowId, column)` callback. May trigger navigation, drill-down, or action.

**Related**: Event Handling, Cell Interaction

### WebSocket Receiver
Backend handler extending `WebSocketAbstractCallReceiver`. Receives and processes real-time grid events from client. Example: `GridDataUpdateReceiver`.

**Related**: Real-Time Updates, Async Communication, GuicedEE

### Event Handler
Method on grid class responding to grid events. Receives event parameters and performs server-side actions. Example: `public void onRowSelectJS(String rowId)`.

**Related**: Event Processing, User Actions

---

## Backend Integration

### Dependency Injection (IoC)
Process of injecting services into grid components via `@Inject` annotation. Enables access to repositories, services, utilities. Example: `@Inject private OrderService orderService;`.

**Related**: GuicedEE, Service Access, Components

### Page Configurator
Lifecycle hook (`IPageConfigurator<T>`) for initializing grids during page render. Auto-discovered via SPI. Allows grids to be added to page with pre-configured state.

**Related**: Lifecycle, Plugin Integration

### Service Layer
Business logic tier providing data, validation, and domain operations. Injected into grid for `fetchData()` and event handlers. Example: `OrderService`, `EmployeeRepository`.

**Related**: Architecture, Data Access

### WebSocket Integration
Real-time bidirectional communication between client and server. Enables server-pushed grid updates without client polling. Example: Broadcasting order changes to all connected monitoring grids.

**Related**: Real-Time Updates, GuicedEE, Vert.x

---

## Frontend/Angular

### Angular Component Lifecycle
Sequence of hooks called during component initialization and destruction: `preBuild()`, `init()`, `postBuild()`, `onDestroy()`. Allows configuration and cleanup at appropriate times.

**Related**: Component Integration, Resource Management

### Change Detection
Angular mechanism for detecting and reflecting property/state changes. Strategies: `Default` (check all), `OnPush` (input-only). Important for performance with large grids.

**Related**: Angular Performance, RxJS, Subscriptions

### RxJS Subscription
Observable subscription from reactive data source. Must be unsubscribed in `onDestroy()` to prevent memory leaks. Example: `dataService.getUpdates().subscribe(...)`.

**Related**: Reactive Patterns, Memory Management

### Template Binding
Angular template syntax for binding data to DOM. Examples: `[gridOptions]="gridOptions"`, `(gridReady)="onGridReady($event)"`.

**Related**: Angular Templating, Data Binding

---

## Configuration & Theming

### Grid Theme
Predefined stylesheet for grid appearance. Options: `"ag-theme-alpine"`, `"ag-theme-balham"`, `"ag-theme-quartz"`, `"ag-theme-material"`. Example: `grid.setTheme("ag-theme-alpine")`.

**Related**: Styling, Customization

### CSS Variables
Customizable theme properties (colors, sizing, fonts) exposed as CSS custom properties. Example: `--ag-header-background-color`, `--ag-row-height`.

**Related**: Theming, Styling

### Pagination
Grid display mode limiting rows per page. Server provides one page at a time. Example: `grid.enablePagination(25)` for 25 rows/page.

**Related**: Performance, Data Loading

### Virtual Scrolling
Optimization for very large datasets. Grid renders only visible rows; loads more as user scrolls. Example: For 100K+ row datasets.

**Related**: Performance, Large Datasets

---

## Testing & Quality

### Unit Test
Test for individual component/method behavior. Example: Testing `fetchData()` with mocked repository.

**Related**: Testing Strategy, Quality Assurance

### Integration Test
Test for component interactions with dependencies. Example: Testing grid with real database via test harness.

**Related**: Testing Strategy, Quality Assurance

### Code Coverage
Percentage of code exercised by tests. Target: ≥80% (measured by Jacoco). Example: 85% coverage indicates strong test suite.

**Related**: Quality Assurance, Testing

### Jacoco
Code coverage tool measuring test coverage. Integrated into Maven build. Enforces minimum coverage thresholds.

**Related**: Quality Assurance, Build Tools

---

## Architecture & Design

### CRTP (Curiously Recurring Template Pattern)
Type-safe fluent API pattern. Subclasses return own type from setters. Example: `MyGrid extends AgGrid<MyGrid>` ensures `setHeight()` returns `MyGrid`, not `AgGrid`.

**Related**: Fluent API, Type Safety, Design Pattern

### Fluent API
Method chaining pattern for readable configuration. Example: `grid.setHeight("600px").setTheme("ag-theme-alpine").enableRowSelection("multiple")`.

**Related**: Builder Pattern, Code Readability

### Component-Driven Architecture
Design where UI composed of reusable, self-contained components. AgGrid cell renderers exemplify this pattern.

**Related**: Modularity, Reusability

### Reactive Patterns
Programming style using observables and streams (`Uni<T>`, `Multi<T>`, RxJS). Non-blocking, composable, handles async naturally.

**Related**: Async Programming, Vert.x

---

## Related Glossaries

For terms not defined here, consult:
- **JWebMP Core**: [../../jwebmp/GLOSSARY.md](../../jwebmp/GLOSSARY.md)
- **Angular 20**: [../../../language/angular/GLOSSARY.md](../../../language/angular/GLOSSARY.md)
- **Vert.x**: [../../../backend/vertx/GLOSSARY.md](../../../backend/vertx/GLOSSARY.md)
- **GuicedEE**: [../../../backend/guicedee/GLOSSARY.md](../../../backend/guicedee/GLOSSARY.md)

---

## LLM Interpretation Guidance

### Prompt Language Alignment

When prompting an AI assistant, use these exact terms to ensure precise code generation:

| Concept | Correct Term | Avoid |
|---------|-------------|-------|
| Grid wrapper class | `AgGrid` | "grid", "ag-grid", "data grid" |
| Configuration object | `AgGridOptions` | "grid config", "settings", "options" |
| Column spec | `AgGridColumnDef` | "column config", "column definition" |
| Custom cell display | `ICellRenderer` | "custom cell", "renderer", "component" |
| Server event receiver | `WebSocketAbstractCallReceiver` | "event handler", "listener", "receiver" |
| Row data array | `rowData` | "rows", "data", "records" |
| Column specs array | `columnDefs` | "columns", "column definitions" |
| Real-time communication | `WebSocket integration` | "AJAX polling", "HTTP events", "push" |

---

## Document Metadata

- **Scope**: JWebMP AgGrid Plugin terminology
- **Version**: 1.0
- **Created**: December 2, 2025
- **Topic-First Policy**: This glossary is authoritative for AgGrid terms. Host projects MUST link to this topic glossary rather than duplicating definitions.
- **Enforced Terms**: Terms listed under "Prompt Language Alignment" MUST be copied to host project glossary; all other terms should be linked.

---

## See Also

- **AgGrid Plugin Rules**: [README.md](./README.md)
- **Architecture Decisions**: [../../../../../../PACT.md](../../../../../../PACT.md)
- **Technology Rules**: [../../../../../../RULES.md](../../../../../../RULES.md)
