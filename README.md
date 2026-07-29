[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![pub version](https://img.shields.io/badge/version-0.1.4-blue)](pubspec.yaml)

# custom_data_table

A feature-rich, themeable Flutter data table with:

- Pagination, multi-column sorting, column filtering
- Row selection with select-all checkbox
- Frozen/sticky columns (static and runtime)
- Inline cell editing with validation
- Bulk row actions with confirmation dialogs
- Column resizing, reordering, and visibility control
- Export hooks: CSV, Excel, PDF, and Print
- Row expansion (expandable rows)
- Conditional row and cell formatting
- Virtual scrolling for large datasets
- 10 built-in style presets (Orbit, Classic, Modern, Pro, Minimal, Vivid, Carbon, Frost, Atlas, Prism)
- `CustomDataTableLight` — lean read-only variant for dialogs and panels

![Screenshot](https://placeholder.com/screenshot.png)

---

## Install

### From pub.dev (when published)

```yaml
dependencies:
  custom_data_table: ^0.1.4
```

### From GitHub

```yaml
dependencies:
  custom_data_table:
    git:
      url: https://github.com/arifnoumankhan/custom-data-table.git
      ref: v0.1.4   # or main for latest
```

### Local path (development)

```yaml
dependencies:
  custom_data_table:
    path: ../custom_data_table
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

```dart
import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    return CustomDataTable(
      title: 'My Customers',
      columns: const [
        TableColumn(key: 'id',    header: '#',      width: 60),
        TableColumn(key: 'name',  header: 'Name',   width: 160),
        TableColumn(key: 'email', header: 'Email',  width: 220),
        TableColumn(key: 'status', header: 'Status', width: 120),
      ],
      data: const [
        {'id': 1, 'name': 'Alice',   'email': 'alice@example.com',   'status': 'Active'},
        {'id': 2, 'name': 'Bob',     'email': 'bob@example.com',     'status': 'Inactive'},
        {'id': 3, 'name': 'Charlie', 'email': 'charlie@example.com', 'status': 'Pending'},
      ],
      perPage: 10,
      currentPage: _page,
      lastPage: 1,
      onNext: (p) => setState(() => _page = p),
      onPrev: (p) => setState(() => _page = p),
      showActions: true,
      actions: const [TableActionEdit(), TableActionDelete()],
      onActionTap: (ctx, rowIndex, action, rowData) {
        debugPrint('Tapped $action on row $rowIndex');
      },
    );
  }
}
```

---

## CustomDataTable Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `columns` | `List<TableColumn>` | required | Column definitions (use with `data`) |
| `data` | `List<Map<String, dynamic>>` | required | Row data maps keyed by `TableColumn.key` |
| `headers` | `List<String>?` | — | Legacy: plain header strings (use with `rows`) |
| `rows` | `List<List<dynamic>>?` | — | Legacy: positional row values |
| `perPage` | `int` | required | Current rows-per-page value (must match a [PaginationPerPageOption.value] or appears as a custom dropdown entry) |
| `currentPage` | `int` | required | Current page number |
| `lastPage` | `int` | required | Total number of pages |
| `perPageOptions` | `List<PaginationPerPageOption>?` | [PaginationPerPageOption.defaults] | Dropdown entries for the page-size picker |
| `paginationLabels` | `PaginationControlLabels?` | English defaults | Localizable strings for the pagination row |
| `showPerPageDropdown` | `bool` | `true` | Show the page-size dropdown when [onPerPageChanged] is set |
| `onNext` | `void Function(int)?` | — | Called when Next / Last page is tapped |
| `onPrev` | `void Function(int)?` | — | Called when Prev / First page is tapped |
| `onPerPageChanged` | `void Function(int)?` | — | Called when the page-size dropdown changes (`0` = all rows, if supported) |
| `hidePagination` | `bool` | `false` | Hide the pagination row entirely |
| `title` | `String?` | — | Table title shown in the toolbar |
| `showTitleToolbar` | `bool` | `true` | When `false`, hides the entire title toolbar (title, style picker, search, export) |
| `showExportButtons` | `bool` | `true` | Show the export popup menu icon |
| `exportFilename` | `String?` | — | Filename hint passed to export callbacks |
| `onExportCsv` | `Function?` | — | Called with `(data, headers)` for CSV export |
| `onExportExcel` | `Function?` | — | Called with `(data, headers)` for Excel export |
| `onExportPdf` | `Function?` | — | Called with `(data, headers, title)` for PDF export |
| `onPrintPdf` | `Function?` | — | Called with `(data, headers, title)` for print |
| `showActions` | `bool` | `false` | Show the row-level actions column |
| `actions` | `List<TableAction>?` | — | Action descriptors for the actions column |
| `actionWidgets` | `List<Widget>?` | — | Raw widgets appended to each action cell |
| `actionsColumnWidth` | `double` | `60` | Width of the actions column |
| `onActionTap` | `ActionCallback?` | — | `(context, rowIndex, actionKey, rowData)` |
| `onCellTap` | `CellTapCallback?` | — | `(context, rowIndex, colIndex, value)` |
| `isLoading` | `bool` | `false` | Show loading overlay on the data area |
| `loadingWidget` | `Widget?` | — | Custom loading widget; default is `CircularProgressIndicator` |
| `emptyStateWidget` | `Widget?` | — | Custom empty state; default shows inbox icon |
| `enableSorting` | `bool` | `true` | Enable column-header sort |
| `enableMultiSort` | `bool` | `false` | Allow sorting by multiple columns |
| `maxSortColumns` | `int` | `3` | Maximum columns in multi-sort |
| `showSearch` | `bool` | `true` | Show the search field |
| `searchHint` | `String?` | `'Search...'` | Placeholder text in the search field |
| `onSearch` | `Function(String)?` | — | Called after the debounce when search changes |
| `isLocalSearch` | `bool` | `false` | Filter `data` locally instead of delegating to `onSearch` |
| `searchDebounceDuration` | `Duration` | 300 ms | Debounce delay for search and filter changes |
| `filterableColumns` | `List<String>?` | — | Column keys that get auto-generated filter dropdowns |
| `enableRowSelection` | `bool` | `false` | Show checkboxes for row selection |
| `showSelectAllCheckbox` | `bool` | `true` | Show select-all checkbox in the header |
| `onRowsSelected` | `Function?` | — | `(selectedIndices, selectedData)` |
| `showRowNumbers` | `bool` | `false` | Prepend a row-number column |
| `columnVisibility` | `Map<String, bool>?` | — | Per-key column show/hide map |
| `showColumnVisibilityMenu` | `bool` | `false` | Show column visibility toggle menu in toolbar |
| `lockedColumns` | `Set<String>?` | — | Column keys excluded from visibility menu (always visible) |
| `initialColumnVisibility` | `Map<String, bool>?` | — | Initial visibility state; used by Reset button |
| `onColumnVisibilityChanged` | `Function(Map<String, bool>)?` | — | Called when column visibility changes via menu |
| `columnVisibilityIcon` | `IconData?` | `Icons.view_column` | Icon for column visibility menu button |
| `columnVisibilityTooltip` | `String?` | `'Columns'` | Tooltip for column visibility menu button |
| `exportColumns` | `Set<String>?` | — | Override: export only these column keys |
| `exportExceptColumns` | `Set<String>?` | — | Override: export all columns except these keys |
| `enableColumnResizing` | `bool` | `true` | Allow drag-resizing column widths |
| `enableColumnReordering` | `bool` | `false` | Allow drag-reordering columns |
| `frozenColumnsCount` | `int?` | — | Number of leading data columns to freeze |
| `frozenColumnsFromEnd` | `int?` | — | Number of trailing data columns to freeze |
| `enableRuntimeFreeze` | `bool` | `false` | Let user freeze/unfreeze columns at runtime |
| `stickyHeader` | `bool` | `true` | Pin the column header while the body scrolls |
| `expandedRowBuilder` | `Widget Function?` | — | Builder for expandable row detail panel |
| `maxHeight` | `double?` | `400` | Maximum table height in pixels |
| `showSumTotals` | `bool` | `false` | Auto-calculate and show column sum totals |
| `totalRow` | `List<dynamic>?` | — | Manually supplied totals row values (legacy positional list) |
| `totalRowByColumnKey` | `Map<String, String>?` | — | Footer labels keyed by [TableColumn.key]; aligns under data columns when actions/checkbox columns are present |
| `rowFormattingRules` | `List<RowFormattingRule>?` | — | Conditional row background/text color rules |
| `enableInlineEditing` | `bool` | `false` | Click a cell to edit it inline |
| `editableColumns` | `Set<String>?` | — | Restrict inline editing to these column keys |
| `onCellValueChanged` | `Function?` | — | `(context, rowIndex, key, oldValue, newValue)` |
| `validateCellValue` | `Function?` | — | Return an error string or `null` to accept |
| `showBulkActionsToolbar` | `bool` | `false` | Show the bulk-action toolbar when rows are selected |
| `bulkActions` | `List<TableAction>?` | — | Actions shown in the bulk toolbar |
| `onBulkActionTap` | `Function?` | — | `(context, action, selectedIndices, selectedData)` |
| `saveColumnPreferences` | `bool` | `false` | Persist column widths/order/freeze to `SharedPreferences` |
| `preferencesKey` | `String?` | — | Storage key for `saveColumnPreferences` |
| `enableVirtualScrolling` | `bool` | `false` | Use virtual scrolling for very large datasets |
| `stylePresets` | `List<TableStylePreset>` | built-in | Available presets in the style picker |
| `defaultStylePreset` | `TableStylePreset?` | `orbit` | Initial style preset |
| `enableStylePicker` | `bool` | `true` | Show the style-picker button in the toolbar |
| `onStylePresetChanged` | `ValueChanged?` | — | Called when the user picks a new preset |
| `rowColorBuilder` | `RowColorBuilder?` | — | Per-row background color override |
| `defaultColumnWidth` | `double` | `160` | Fallback width for columns without an explicit width |
| `cellPadding` | `EdgeInsets` | 8 all | Padding applied to each cell |
| `responsive` | `bool` | `true` | Scale column widths for mobile/tablet |
| `enableHorizontalScroll` | `bool` | `true` | Enable horizontal scrolling |

---

## CustomDataTableLight Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `columns` | `List<String>` | required | Column header labels |
| `rows` | `List<List<Widget>>` | required | Widget cells |
| `title` | `String?` | — | Optional title above the table |
| `emptyMessage` | `String?` | — | Centred message when rows is empty |
| `wrapInCard` | `bool` | `true` | Wrap in a `Card` |
| `zebraStripes` | `bool` | `true` | Alternate row background |
| `wrapHeaderLabels` | `bool` | `true` | Allow header text to wrap |
| `columnWidths` | `List<double>?` | — | Explicit widths per column |
| `defaultColumnWidth` | `double` | `120` | Fallback column width |
| `headingRowHeight` | `double` | `44` | Header row height |
| `dataRowMinHeight` | `double` | `48` | Minimum data row height |
| `dataRowMaxHeight` | `double` | `∞` | Maximum data row height |
| `columnSpacing` | `double` | `20` | Space between columns |
| `horizontalMargin` | `double` | `12` | Horizontal padding |
| `headerColor` | `Color?` | — | Header background color |

Use `CustomDataTableLight.text(...)` when every cell is plain text.

---

## Theming

### Style Presets

```dart
CustomDataTable(
  // ...
  defaultStylePreset: TableStylePresets.pro,
  enableStylePicker: false,   // hide the in-table picker
)
```

Built-in presets: `orbit`, `modern`, `classic`, `pro`, `minimal`, `vivid`, `carbon`, `frost`, `atlas`, `prism`.

### Custom Preset

```dart
const myPreset = TableStylePreset(
  id: 'my_preset',
  label: 'My Style',
  icon: Icons.table_chart,
  headerHeight: 48,
  rowHeight: 44,
  cellHorizontalPadding: 12,
  cellVerticalPadding: 8,
  showRowSeparators: true,
  rowSeparatorWidth: 0.5,
  showHeaderBottomBorder: true,
  headerBottomBorderWidth: 1.0,
  outerBorderRadius: BorderRadius.all(Radius.circular(8)),
  stripedRows: true,
  headerFontWeight: FontWeight.w600,
  headerLetterSpacing: 0.2,
  headerUppercase: false,
  headerSurface: TableSurfaceTone.surfaceHigh,
  hoverSurface: TableSurfaceTone.primaryFaint,
  selectionSurface: TableSurfaceTone.primaryContainer,
  stripeSurface: TableSurfaceTone.surfaceFaint,
);

CustomDataTable(
  defaultStylePreset: myPreset,
  stylePresets: const [myPreset],
  // ...
)
```

---

## Row Actions

```dart
CustomDataTable(
  showActions: true,
  actions: const [
    TableActionView(),
    TableActionEdit(),
    TableActionDelete(),
  ],
  onActionTap: (context, rowIndex, actionKey, rowData) {
    switch (actionKey) {
      case ActionKeys.view:   _viewItem(rowData);   break;
      case ActionKeys.edit:   _editItem(rowData);   break;
      case ActionKeys.delete: _deleteItem(rowData); break;
    }
  },
)
```

---

## Pagination

When `onNext` / `onPrev` are set, **`CustomDataTable`** renders an embedded
**`CustomPaginationControlWidget`** below the table (no separate pagination widget required).

```dart
CustomDataTable(
  perPage: 25,
  currentPage: page,
  lastPage: lastPage,
  perPageOptions: PaginationPerPageOption.defaults,
  showPerPageDropdown: true,
  paginationLabels: const PaginationControlLabels(
    showPrefix: 'Show',
    perPageHint: 'Limit',
    page: 'Page',
    pageOf: 'of',
  ),
  onNext: (p) => setState(() => page = p),
  onPrev: (p) => setState(() => page = p),
  onPerPageChanged: (size) => setState(() {
    perPage = size;
    page = 1;
  }),
  hidePagination: false,
  // ...
)
```

Use **`totalRowByColumnKey`** when footer totals must sit under specific columns (e.g. amount under `total`, label under `name`) while an actions column is pinned on the right:

```dart
CustomDataTable(
  totalRowByColumnKey: const {
    'name': 'Total',
    'total': '1,234.56',
    'status': 'Paid: 18 · Due: 7',
  },
  // ...
)
```

---

## Export

```dart
CustomDataTable(
  onExportCsv: (rows, headers) async {
    final csv = [headers, ...rows].map((r) => r.join(',')).join('\n');
    // share or save csv string
  },
  onExportPdf: (rows, headers, title) async {
    // build pdf using any pdf package
  },
)
```

---

## Column Visibility Control

Enable the column visibility menu to let users show/hide columns at runtime:

```dart
CustomDataTable(
  showColumnVisibilityMenu: true,
  preferencesKey: 'my_table_columns',  // persist visibility state
  initialColumnVisibility: const {
    'id': true,
    'email': true,
    'status': false,  // hidden by default
  },
  lockedColumns: const {'id'},  // always visible, excluded from menu
  onColumnVisibilityChanged: (visibility) {
    debugPrint('Visibility changed: $visibility');
  },
  // ...
)
```

### Menu Features

- **Show All / Hide All / Reset** — quick actions for bulk visibility changes
- **Real-time updates** — table refreshes immediately when checkboxes are toggled
- **Persistent state** — saves to `SharedPreferences` when `preferencesKey` is set
- **Locked columns** — exclude critical columns from the menu via `lockedColumns`
- **Export control** — exported data respects visible columns by default

### Export Overrides

Control which columns are exported independently of visibility:

```dart
CustomDataTable(
  showColumnVisibilityMenu: true,
  exportColumns: const {'id', 'name', 'email'},  // export only these
  // OR
  exportExceptColumns: const {'internal_notes'},  // export all except these
  onExportCsv: (rows, headers) {
    // rows contain only the specified columns
  },
)
```

When neither `exportColumns` nor `exportExceptColumns` is set, export uses visible columns. Locked columns are always included in export.

---

## License

MIT License — see [LICENSE](LICENSE).
