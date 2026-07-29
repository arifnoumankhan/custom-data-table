## 0.1.4

* **Column visibility menu fixes** — resolved width overflow and checkbox reactivity issues. Menu now constrains to 250-300px width with proper wrapping. StatefulBuilder reads fresh `_effectiveColumnVisibility` on each rebuild, ensuring checkboxes and count update immediately when toggled. Action buttons replaced with compact `InkWell` widgets to prevent overflow on narrow screens.
* **Column visibility menu improvements** — reduced font sizes (11px), changed count format from "(X of Y)" to "(X/Y)", wrapped action bar in `Wrap` for responsive layout, added tooltip threshold (30 chars) for long column names.
* **Export column control** — respects column visibility state when exporting; exportable column count displayed in export menu tooltip.

## 0.1.3

* **`CustomDataTable.rowAccentBuilder`** — optional 4px left severity stripe per row (leftmost column section when frozen/special panes are present).
* **`CustomDataTable.forceStylePreset`** — when `true`, `defaultStylePreset` always applies and any style saved via the runtime style picker is ignored (for design-locked screens).
* **Style presets consolidated** — 10 built-in presets reduced to 3 polished ones: `barioo` (new default: uppercase muted header, airy rows), `classic` (dense grid with stripes), `compact` (minimal chrome for dialogs). Saved references to removed presets fall back to the default.
* **Pagination footer redesign** — "Items per page" dropdown, "Showing x–y of N" summary (new **`CustomDataTable.totalItems`** param), and numbered pill page buttons with ellipsis windowing replacing the arrow-only controls. Stacks vertically on narrow layouts.

## 0.1.2

* **`CustomPaginationControlWidget`** — embedded in **`CustomDataTable`** footer row (first/prev/next/last + optional per-page dropdown).
* **`CustomDataTable.perPageOptions`**, **`paginationLabels`**, **`showPerPageDropdown`** — configure page-size choices and localized pagination strings.
* **`CustomDataTable.totalRowByColumnKey`** — footer totals align under the correct data columns when synthetic columns (actions, checkbox, row number) are present.
* **Tests** — widget tests for footer alignment (`totalRowByColumnKey`) and pagination controls.

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
