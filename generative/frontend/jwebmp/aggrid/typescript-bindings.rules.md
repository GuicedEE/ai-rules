# TypeScript Bindings & Angular Integration Rules

**Type-safe backend-to-frontend data contracts**

---

## Overview

TypeScript bindings provide compile-time type safety for communication between Java backend and Angular frontend via generated interfaces and data classes.

---

## Generated TypeScript Interfaces

### Automatic Generation Strategy

```bash
# Using OpenAPI / Swagger codegen
mvn openapi:generate -Dexec.mainClass=io.swagger.codegen.cli.SwaggerCodegen

# Or using custom Maven plugin
mvn generate-sources
```

### Generated Grid Options Interface

```typescript
// auto-generated from Java AgGridOptions
export interface IAgGridOptions {
  // Core
  id?: string;
  locale?: IAgGridLocale;
  enableRtl?: boolean;
  
  // Columns
  columnDefs: IColumnDef[];
  autoSizeStrategy?: IAutoSizeStrategy;
  
  // Data
  rowData?: any[];
  datasource?: IServerSideDatasource;
  
  // Pagination
  pagination?: boolean;
  paginationPageSize?: number;
  
  // Selection
  rowSelection?: 'single' | 'multiple';
  suppressRowClickSelection?: boolean;
  
  // Features
  enableFilter?: boolean;
  enableSort?: boolean;
  enableGrouping?: boolean;
  
  // Callbacks
  onRowSelectJS?: (rowData: any) => void;
  onCellClickedJS?: (cellData: ICellClickedEvent) => void;
  onFirstDataRendered?: () => void;
  
  // Custom
  [key: string]: any;
}

export interface IColumnDef {
  field: string;
  headerName: string;
  type?: 'text' | 'number' | 'boolean' | 'date';
  width?: number;
  minWidth?: number;
  resizable?: boolean;
  sortable?: boolean;
  filter?: boolean;
  cellRenderer?: any; // Angular component reference
  headerComponent?: any; // Angular component reference
}

export interface ICellClickedEvent {
  rowData: any;
  colDef: IColumnDef;
  rowIndex: number;
}

export interface IServerSideDatasource {
  getRows(params: IGetRowsParams): Promise<IGetRowsResult>;
}

export interface IGetRowsParams {
  startRow: number;
  endRow: number;
  sortModel: ISortModel[];
  filterModel: IFilterModel;
}

export interface IGetRowsResult {
  rowData: any[];
  rowCount?: number;
}

export interface ISortModel {
  colId: string;
  sort: 'asc' | 'desc';
}

export interface IFilterModel {
  [colId: string]: IFilterCondition;
}

export interface IFilterCondition {
  filterType: string;
  type?: string;
  filter?: any;
  filterTo?: any;
  operator?: 'AND' | 'OR';
  conditions?: IFilterCondition[];
}
```

### Generated Response Types

```typescript
// From server AjaxResponse<T>
export interface IAjaxResponse<T> {
  status: number;
  successful: boolean;
  responseStatus: string;
  responseText?: string;
  response: T;
  responseObject?: T;
  exception?: string;
  exceptionType?: string;
  timestamp?: Date;
}

// Paginated response
export interface IPagedResponse<T> {
  content: T[];
  page: number;
  pageSize: number;
  totalElements: number;
  totalPages: number;
  hasMore: boolean;
  sortModel: ISortModel[];
}

// WebSocket update
export interface IGridUpdate<T> {
  type: 'ADD' | 'UPDATE' | 'REMOVE' | 'REFRESH';
  rows: T[];
  rowIndexes?: number[];
}
```

---

## Angular Component Integration

### Type-Safe Grid Wrapper

```typescript
import { Component, Input, ViewChild, AfterViewInit, OnDestroy } from '@angular/core';
import { AgGridAngular } from 'ag-grid-angular';
import { IAgGridOptions, IColumnDef, IServerSideDatasource } from './models';

@Component({
  selector: 'app-data-grid',
  template: `
    <ag-grid-angular
      #agGrid
      class="ag-theme-alpine"
      [gridOptions]="gridOptions"
      [columnDefs]="columnDefs"
      [rowData]="rowData"
      [defaultColDef]="defaultColDef"
      [datasource]="datasource"
      (gridReady)="onGridReady($event)"
    ></ag-grid-angular>
  `,
  styles: [`
    .ag-theme-alpine { height: 500px; }
  `]
})
export class DataGridComponent implements AfterViewInit, OnDestroy {
  @ViewChild('agGrid') agGrid!: AgGridAngular;
  
  @Input() gridOptions: Partial<IAgGridOptions> = {};
  @Input() columnDefs: IColumnDef[] = [];
  @Input() rowData: any[] = [];
  @Input() datasource?: IServerSideDatasource;
  
  readonly defaultColDef = {
    sortable: true,
    filter: true,
    resizable: true
  };
  
  ngAfterViewInit(): void {
    if (this.agGrid) {
      // Grid initialization complete
      this.agGrid.api.sizeColumnsToFit();
    }
  }
  
  onGridReady(event: any): void {
    // Grid ready event
  }
  
  ngOnDestroy(): void {
    if (this.agGrid) {
      this.agGrid.api.destroy();
    }
  }
}
```

### Type-Safe Service Integration

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { IAjaxResponse, IPagedResponse, IGridUpdate } from './models';

@Injectable({ providedIn: 'root' })
export class GridDataService {
  constructor(private http: HttpClient) {}
  
  fetchGridData(
    gridId: string,
    page: number,
    pageSize: number,
    sortModel: ISortModel[],
    filterModel: IFilterModel
  ): Observable<IAjaxResponse<IPagedResponse<any>>> {
    const params = {
      gridId,
      page,
      pageSize,
      sort: JSON.stringify(sortModel),
      filter: JSON.stringify(filterModel)
    };
    
    return this.http.get<IAjaxResponse<IPagedResponse<any>>>(
      '/api/grid/data',
      { params }
    );
  }
  
  subscribeToGridUpdates(gridId: string): Observable<IGridUpdate<any>> {
    // WebSocket subscription or Server-Sent Events
    return new Observable(observer => {
      const ws = new WebSocket(`wss://api.example.com/grid/${gridId}`);
      
      ws.onmessage = (event) => {
        const update: IGridUpdate<any> = JSON.parse(event.data);
        observer.next(update);
      };
      
      ws.onerror = (error) => observer.error(error);
      ws.onclose = () => observer.complete();
      
      return () => ws.close();
    });
  }
}
```

---

## Java-to-TypeScript Type Mapping

### Scalar Types

| Java | TypeScript |
|------|-----------|
| `String` | `string` |
| `int`, `long`, `double`, `float` | `number` |
| `boolean` | `boolean` |
| `java.util.Date` | `Date` |
| `LocalDateTime` | `Date` |
| `UUID` | `string` |
| `BigDecimal` | `number` |

### Collection Types

| Java | TypeScript |
|------|-----------|
| `List<T>` | `T[]` |
| `Set<T>` | `T[]` |
| `Map<K, V>` | `{ [key: K]: V }` |
| `Optional<T>` | `T \| null` |

### Complex Types

```typescript
// Java enum
public enum OrderStatus { PENDING, APPROVED, SHIPPED, DELIVERED }

// TypeScript
export enum OrderStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  SHIPPED = 'SHIPPED',
  DELIVERED = 'DELIVERED'
}

// Java record
public record OrderRow(long orderId, String customerName, BigDecimal amount, OrderStatus status) {}

// TypeScript
export interface IOrderRow {
  orderId: number;
  customerName: string;
  amount: number;
  status: OrderStatus;
}
```

---

## API Contract Testing

### Consumer-Driven Contracts (CDC)

```typescript
// orders.spec.ts
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { GridDataService } from './grid-data.service';
import { IAjaxResponse } from './models';

describe('GridDataService Contract', () => {
  let service: GridDataService;
  let httpMock: HttpTestingController;
  
  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [GridDataService]
    });
    service = TestBed.inject(GridDataService);
    httpMock = TestBed.inject(HttpTestingController);
  });
  
  afterEach(() => httpMock.verify());
  
  it('should fetch grid data with correct structure', (done) => {
    // Act
    service.fetchGridData('orders', 0, 10, [], {}).subscribe((response) => {
      // Assert
      expect(response).toEqual(jasmine.objectContaining({
        status: 200,
        successful: true,
        response: jasmine.objectContaining({
          content: jasmine.any(Array),
          page: jasmine.any(Number),
          totalElements: jasmine.any(Number)
        })
      } as IAjaxResponse<any>));
      done();
    });
    
    // Verify request structure
    const req = httpMock.expectOne('/api/grid/data');
    expect(req.request.method).toBe('GET');
    expect(req.request.params.get('gridId')).toBe('orders');
    expect(req.request.params.get('page')).toBe('0');
    
    // Respond with mock data
    req.flush({
      status: 200,
      successful: true,
      response: {
        content: [{ id: 1, name: 'Order 1' }],
        page: 0,
        pageSize: 10,
        totalElements: 25,
        totalPages: 3,
        hasMore: true
      }
    });
  });
});
```

---

## OpenAPI / Swagger Specification

### Generate from Java

```java
@Configuration
public class SpringDocConfiguration {
  
  @Bean
  public OpenAPI customOpenAPI() {
    return new OpenAPI()
      .info(new Info()
        .title("AgGrid API")
        .version("2.0.0-SNAPSHOT")
        .description("Data Grid API Contract"));
  }
  
  @Bean
  public GroupedOpenApi publicApi() {
    return GroupedOpenApi.builder()
      .group("public")
      .pathsToMatch("/api/grid/**")
      .build();
  }
}

// Endpoint documentation
@RestController
@RequestMapping("/api/grid")
@Tag(name = "Grid", description = "Grid data operations")
public class GridController {
  
  @GetMapping("/{gridId}/data")
  @Operation(summary = "Fetch grid data", description = "Retrieve paginated grid data")
  public ResponseEntity<AjaxResponse<PagedResponse<Object>>> getGridData(
    @PathVariable String gridId,
    @RequestParam int page,
    @RequestParam int pageSize,
    @RequestParam(required = false) String sort,
    @RequestParam(required = false) String filter
  ) {
    // Implementation
    return ResponseEntity.ok(new AjaxResponse<>());
  }
}
```

### Generated TypeScript Client

```bash
# Generate from OpenAPI spec
npx @openapitools/openapi-generator-cli generate \
  -i http://localhost:8080/v3/api-docs \
  -g typescript-angular \
  -o ./src/app/api

# Auto-generated files
# - api/grid.service.ts
# - model/grid-options.ts
# - model/paged-response.ts
# - index.ts (exports all)
```

---

## Null Safety & Type Guards

### Strict Null Checking

```typescript
// Enable in tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "strictNullChecks": true,
    "strictPropertyInitialization": true,
    "strictBindCallApply": true,
    "strictFunctionTypes": true,
    "noImplicitThis": true,
    "noImplicitAny": true
  }
}

// Type guard functions
export function isOrderRow(obj: any): obj is IOrderRow {
  return (
    typeof obj.orderId === 'number' &&
    typeof obj.customerName === 'string' &&
    typeof obj.amount === 'number' &&
    Object.values(OrderStatus).includes(obj.status)
  );
}

// Usage
const data: unknown = JSON.parse(jsonString);
if (isOrderRow(data)) {
  console.log(data.orderId); // Type-safe: number
}
```

---

## Best Practices

### ✅ DO

- Generate TypeScript from Java sources (OpenAPI, MCP protoc)
- Use `interface` for data models, `type` for unions
- Implement type guards for runtime validation
- Test API contracts bidirectionally (CDC)
- Version API contracts alongside code
- Use `IXxx` prefix for interface names
- Validate deserialized data at boundaries

### ❌ DO NOT

- Use `any` type in production code
- Manually duplicate Java types in TypeScript
- Skip null/undefined checks
- Assume server response structure
- Break API contracts without migration
- Use untyped `Object` or `{}` for data models

---

## Related Documents

- **[Data Binding](./data-binding.rules.md)** — Server communication
- **[Angular Integration](./angular-component-integration.rules.md)** — Frontend components
