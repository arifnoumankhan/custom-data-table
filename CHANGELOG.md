## 0.1.1

* `CustomDataTable.showTitleToolbar` — when `false`, hides the entire title toolbar (title, style picker, search, export) without changing other toolbar flags.
* `CustomDataTableLight.text` — optional `headingRowHeight`, `dataRowMinHeight`, `dataRowMaxHeight`, `columnSpacing`, and `horizontalMargin`.
* Column reorder drag handler cleanup; removed unused state in the main table widget.

## 0.1.0

* Initial release.
* `CustomDataTable` — feature-rich table with pagination, sorting, row selection, frozen columns, inline editing, column resizing/reordering, bulk actions, virtual scrolling, export hooks, and 10 built-in style presets.
* `CustomDataTableLight` — lean read-only variant for dialogs and detail panels.
* `TableStylePreset` and `TableStyleResolved` — full theming system, light/dark compatible.
* `TableColumn`, `TableAction`, `TableKeys`, `ActionKeys` model classes.
* `TableDensity` enum (compact/comfortable/spacious) convenience presets.
