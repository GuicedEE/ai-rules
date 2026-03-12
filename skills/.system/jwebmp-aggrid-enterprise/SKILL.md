---
name: jwebmp-aggrid-enterprise
description: AG Grid Enterprise integration for JWebMP with premium data grid features. Extends aggrid skill with row grouping, aggregation, pivoting, master/detail, server-side row model, Excel export, range selection, clipboard operations, status bar, charts integration, and advanced filtering. Requires AG Grid Enterprise license. Use when working with AG Grid Enterprise features, complex data grids, pivoting, grouping, or advanced grid capabilities.
metadata:
  short-description: AG Grid Enterprise premium features
---

# JWebMP AG Grid Enterprise

AG Grid Enterprise integration for JWebMP with premium data grid features.

## Premium Features

- **Row Grouping** — Group rows by columns
- **Aggregation** — Sum, avg, min, max, count
- **Pivoting** — Pivot data dynamically
- **Master/Detail** — Expandable row details
- **Server-Side Row Model** — Handle millions of rows
- **Excel Export** — Export to .xlsx
- **Range Selection** — Select cell ranges
- **Clipboard** — Copy/paste operations
- **Status Bar** — Aggregation status bar
- **Charts Integration** — Built-in charting

## Row Grouping

```java
gridOptions
    .setRowGroupPanelShow("always")
    .setGroupSelectsChildren(true)
    .setColumnDefs(List.of(
        new ColumnDef()
            .setField("country")
            .setRowGroup(true)
            .setHide(true),
        new ColumnDef()
            .setField("sales")
            .setAggFunc("sum")
    ));
```

## Aggregation

```java
new ColumnDef()
    .setField("amount")
    .setAggFunc("sum")  // sum, min, max, avg, count, first, last
    .setEnableValue(true);
```

## Pivoting

```java
gridOptions
    .setPivotMode(true)
    .setColumnDefs(List.of(
        new ColumnDef()
            .setField("country")
            .setPivot(true),
        new ColumnDef()
            .setField("year")
            .setRowGroup(true),
        new ColumnDef()
            .setField("sales")
            .setAggFunc("sum")
    ));
```

## Master/Detail

```java
gridOptions
    .setMasterDetail(true)
    .setDetailCellRendererParams(new DetailCellRendererParams()
        .setDetailGridOptions(detailGridOptions)
        .setGetDetailRowData(callbackFunction));
```

## Server-Side Row Model

```java
gridOptions
    .setRowModelType("serverSide")
    .setServerSideStoreType("full")  // full, partial
    .setCacheBlockSize(100)
    .setMaxBlocksInCache(10);
```

## Excel Export

```java
gridOptions.exportToExcel(new ExcelExportParams()
    .setFileName("data.xlsx")
    .setSheetName("Sheet1")
    .setAuthor("JWebMP")
    .setColumnWidth(100));
```

## Range Selection

```java
gridOptions
    .setEnableRangeSelection(true)
    .setEnableRangeHandle(true)
    .setEnableFillHandle(true);
```

## Status Bar

```java
gridOptions.setStatusBar(new StatusBarConfig()
    .setStatusPanels(List.of(
        new StatusPanelDef()
            .setStatusPanel("agTotalAndFilteredRowCountComponent"),
        new StatusPanelDef()
            .setStatusPanel("agAggregationComponent")
    )));
```

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>aggrid-enterprise</artifactId>
</dependency>
```

**Note:** Requires valid AG Grid Enterprise license.

## License Configuration

```java
GridOptions.setLicenseKey("your-license-key");
```

## References

- Module: `com.jwebmp.plugins.aggridenterprise`
- AG Grid Enterprise: 33.x
- Java: 25+
- License: Apache 2.0 (code), AG Grid Enterprise license required
- [AG Grid Enterprise](https://www.ag-grid.com/license-pricing/)
