# Migration & Upgrade Rules

**Version upgrade paths, breaking changes, deprecation policy**

---

## Overview

AgGrid plugin maintains backward compatibility across minor versions while allowing breaking changes in major versions.

---

## Versioning Strategy

### Semantic Versioning

```
2.0.0-SNAPSHOT
│ │ │
│ │ └─ Patch: Bug fixes, no breaking changes
│ └─── Minor: New features, backward compatible
└───── Major: Breaking changes allowed
```

### Version Support Matrix

| Version | Release Date | Support Status | End of Life |
|---------|--------------|----------------|-------------|
| 2.x | Dec 2024 | **Current** | Dec 2026 |
| 1.x | 2023 | **Maintenance** | Dec 2024 |
| 0.x | 2022 | **Unsupported** | Dec 2022 |

---

## Breaking Changes Policy

### Major Version (2.0 → 3.0)

Breaking changes allowed and documented:

1. **Method signature changes** (adding required parameters)
2. **Class hierarchy changes** (removing intermediate classes)
3. **Configuration structure changes** (renaming options)
4. **Default behavior changes** (e.g., pagination enabled by default)

### Migration Path Required

Every breaking change MUST include:

```markdown
## Breaking Changes in 3.0

### Removed: `getGridOptions()` method
- **Before**: `grid.getGridOptions()`
- **After**: `grid.getOptions()`
- **Reason**: Consistency with AgGrid naming (options, not gridOptions)
- **Migration Tool**: Run `mvn versions:set -DnewVersion=3.0.0` then follow IDE hints

### Changed: `OnRowSelectJS` return type
- **Before**: `void onRowSelectJS(RowData row)`
- **After**: `Uni<Void> onRowSelectJS(RowData row)`
- **Reason**: Support non-blocking callbacks
- **Migration**: Wrap logic in `Uni.createFromItem()`

### Deprecated: `setFilterModel()` in 2.5 (removed in 3.0)
- **Before**: `grid.setFilterModel(filterMap)`
- **Alternative**: `grid.getOptions().setFilter(true)` + use column-level filters
- **Migration Timeline**: 2.5 (2 releases) → 3.0 (removed)
```

---

## Backward Compatibility

### Minor Versions (2.0 → 2.1)

No breaking changes. All new features are:

1. **Additive**: New methods, not changed signatures
2. **Optional**: Default values for new parameters
3. **Documented**: Migration guide if behavior changes

```java
// Version 2.0
public void setPageSize(int pageSize) {
  this.pageSize = pageSize;
}

// Version 2.1 (backward compatible)
public void setPageSize(int pageSize) {
  setPageSize(pageSize, false); // Default: no auto-refresh
}

public void setPageSize(int pageSize, boolean autoRefresh) {
  this.pageSize = pageSize;
  if (autoRefresh) {
    refresh(); // New optional behavior
  }
}
```

---

## Upgrade Guide: 1.x → 2.0

### Step 1: Update Maven Dependency

```xml
<!-- Before -->
<dependency>
    <groupId>com.jwebmp.plugins</groupId>
    <artifactId>aggrid</artifactId>
    <version>1.5.0</version>
</dependency>

<!-- After -->
<dependency>
    <groupId>com.jwebmp.plugins</groupId>
    <artifactId>aggrid</artifactId>
    <version>2.0.0</version>
</dependency>
```

### Step 2: Update Java API Calls

```java
// Before (1.x)
AgGrid grid = new AgGrid<>()
  .setGridId("orders")
  .setGridOptions(new AgGridOptions()
    .setRowData(List.of(...))
    .setPageSize(50));

// After (2.0)
AgGrid<?> grid = new AgGrid<>()
  .setId("orders")
  .setOptions(new AgGridOptions()
    .rowData(List.of(...))
    .pageSize(50));
```

### Step 3: Update Column Definitions

```java
// Before (1.x)
new AgGridColumnDef()
  .setField("name")
  .setHeaderName("Customer Name")
  .setType("text")
  .setWidth(200);

// After (2.0) — CRTP fluent API
new AgGridColumnDef()
  .field("name")
  .headerName("Customer Name")
  .type("text")
  .width(200);
```

### Step 4: Update TypeScript Bindings

```typescript
// Before (1.x)
interface IGridOptions {
  rowData: any[];
  pageSize?: number;
}

// After (2.0) — Strict typing
import { IAgGridOptions, IColumnDef } from '@jwebmp/aggrid';

const options: IAgGridOptions = {
  rowData: [],
  columnDefs: [] as IColumnDef[]
};
```

### Step 5: Update WebSocket Receivers

```java
// Before (1.x)
public class GridEventReceiver extends WebSocketReceiver {
  @Override
  public AjaxResponse<String> onCall(GridEventMessage message) {
    // Synchronous logic
    return new AjaxResponse<>(true);
  }
}

// After (2.0) — Non-blocking
public class GridEventReceiver extends WebSocketAbstractCallReceiver<GridEventMessage, String> {
  @Override
  public Uni<AjaxResponse<String>> onCall(GridEventMessage message) {
    return Uni.createFromItem(message)
      .onItem().invoke(m -> handleEvent(m))
      .onItem().transform(m -> new AjaxResponse<>(true));
  }
}
```

---

## Testing Upgrade Impact

### Regression Test Suite

```java
@SpringBootTest
public class UpgradeRegressionTest {
  
  @Autowired
  private AgGridTestHarness harness;
  
  @Test
  public void testLegacy1xGrid() throws Exception {
    // Verify old API still works (1.x compat mode)
    AgGrid<?> grid = new AgGrid<>()
      .setId("test")
      .setOptions(new AgGridOptions().rowData(List.of()));
    
    assertThat(grid).isNotNull();
    assertThat(grid.getId()).isEqualTo("test");
  }
  
  @Test
  public void testNew2xApi() {
    // Test new 2.0 fluent API
    AgGrid<?> grid = new AgGrid<>()
      .id("test2")
      .options(new AgGridOptions().rowData(List.of()));
    
    assertThat(grid).isNotNull();
  }
}
```

---

## Deprecation Timeline

### Deprecation Policy

1. **Announce**: New feature added, old method marked `@Deprecated`
2. **Support**: 2 minor releases (e.g., v2.5, v2.6) with deprecation warning
3. **Remove**: Next major release (v3.0)

### Example Deprecation Cycle

```java
// Version 2.0 (introduced in 2.1)
/**
 * @deprecated Use {@link #getOptions()} instead.
 * This method will be removed in version 3.0.
 * See migration guide: https://...
 */
@Deprecated(since = "2.1", forRemoval = true)
public AgGridOptions getGridOptions() {
  return this.options;
}

// Version 2.1, 2.2, 2.3 (still available with deprecation warnings)
// Version 3.0 (removed entirely)
```

---

## Database Schema Migrations

### If AgGrid manages persistence

```sql
-- v1.5 → v2.0 schema migration
-- Migration: 001_upgrade_to_v2.sql

-- Add new columns for 2.0 features
ALTER TABLE grid_cache
  ADD COLUMN batch_size INT DEFAULT 50,
  ADD COLUMN auto_refresh BOOLEAN DEFAULT false;

-- Create index for performance optimization (new in 2.0)
CREATE INDEX idx_grid_id_timestamp ON grid_cache(grid_id, created_at);

-- Backfill default values
UPDATE grid_cache SET batch_size = 50 WHERE batch_size IS NULL;
UPDATE grid_cache SET auto_refresh = false WHERE auto_refresh IS NULL;
```

### Liquibase Configuration

```yaml
databaseChangeLog:
  - changeSet:
      id: upgrade-to-v2-0
      author: jwebmp-team
      changes:
        - addColumn:
            tableName: grid_cache
            columns:
              - column:
                  name: batch_size
                  type: INT
                  defaultValue: 50
              - column:
                  name: auto_refresh
                  type: BOOLEAN
                  defaultValue: false
        - createIndex:
            indexName: idx_grid_id_timestamp
            tableName: grid_cache
            columns:
              - column:
                  name: grid_id
              - column:
                  name: created_at
```

---

## Upgrade Checklist

```markdown
## Upgrading to AgGrid v2.0

- [ ] Update Maven dependency: 1.5.0 → 2.0.0
- [ ] Run `mvn clean verify` (full test suite)
- [ ] Update AgGrid Java API calls (setGridId → setId)
- [ ] Update column definitions (setters → fluent)
- [ ] Update WebSocket receivers (sync → Uni<>)
- [ ] Update TypeScript imports and types
- [ ] Run migration test suite
- [ ] Update database schema (if applicable)
- [ ] Update Angular component lifecycle
- [ ] Verify grid rendering in browser
- [ ] Load test with production dataset
- [ ] Verify WebSocket updates work
- [ ] QA sign-off
- [ ] Deploy to staging
- [ ] Monitor for issues (24h)
- [ ] Deploy to production
```

---

## Version Detection

### Runtime Version Check

```java
@Component
public class AgGridVersionChecker {
  
  public String getAgGridVersion() {
    try {
      Package pkg = AgGrid.class.getPackage();
      String version = pkg.getImplementationVersion();
      return version != null ? version : "unknown";
    } catch (Exception e) {
      return "error";
    }
  }
  
  public boolean isVersion2orAbove() {
    String version = getAgGridVersion();
    return version.startsWith("2.") || version.startsWith("3.");
  }
}

// Usage
AgGridVersionChecker checker = IGuiceContext.get(AgGridVersionChecker.class);
if (checker.isVersion2orAbove()) {
  // Use new 2.0+ API
  grid.options(new AgGridOptions());
} else {
  // Use legacy API
  grid.setGridOptions(new AgGridOptions());
}
```

---

## Related Documents

- **[Code Quality](./code-quality.rules.md)** — Regression testing
- **[Testing Strategy](./testing-strategy.rules.md)** — Test patterns
- **[../../../../../../PACT.md](../../../../../../PACT.md)** — Product versioning strategy
