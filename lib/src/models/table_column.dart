import 'package:flutter/material.dart';

/// Controls how cell text is handled when it overflows the column width.
enum TableTextOverflow {
  /// Text wraps to the next line (default).
  wrap,

  /// Text is clipped at the column boundary.
  clip,

  /// Text is truncated with an ellipsis.
  ellipsis,
}

/// Defines a column in [CustomDataTable].
///
/// Each column maps to a key in the data row [Map<String, dynamic>].
class TableColumn {
  /// Unique key that maps to a field in each data row.
  final String key;

  /// Text shown in the column header.
  final String header;

  /// Fixed pixel width for this column. Defaults to `120`. Pass `null` to
  /// let the table calculate the width responsively.
  final double? width;

  /// Whether the column header tap triggers a sort. Defaults to `true`.
  final bool sortable;

  /// Whether tapping a cell fires [CustomDataTable.onCellTap].
  final bool clickable;

  /// Horizontal alignment of header and cell text.
  final TextAlign? alignment;

  /// How cell text overflows the available width.
  final TableTextOverflow textOverflow;

  /// Builder that replaces the default text cell with a custom widget.
  ///
  /// Receives `(context, value, rowData, rowIndex, colIndex)`.
  final Widget Function(
    BuildContext context,
    dynamic value,
    Map<String, dynamic> rowData,
    int rowIndex,
    int colIndex,
  )? customCellBuilder;

  /// Converts the raw cell value to a display string before rendering.
  ///
  /// Also applied during CSV/Excel/PDF export.
  final String Function(dynamic value)? valueFormatter;

  /// Lock column visible — excluded from visibility menu, always rendered.
  final bool alwaysVisible;

  const TableColumn({
    required this.key,
    required this.header,
    this.width = 120,
    this.sortable = true,
    this.clickable = false,
    this.alignment,
    this.textOverflow = TableTextOverflow.wrap,
    this.customCellBuilder,
    this.valueFormatter,
    this.alwaysVisible = false,
  });
}

/// Cell-level visual formatting applied over the base [TextStyle].
class CellFormatting {
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final TextDecoration? textDecoration;
  final Color? textColor;
  final Color? backgroundColor;
  final double? fontSize;
  final TextAlign? alignment;

  const CellFormatting({
    this.fontWeight,
    this.fontStyle,
    this.textDecoration,
    this.textColor,
    this.backgroundColor,
    this.fontSize,
    this.alignment,
  });

  /// Returns a new [CellFormatting] where non-null fields from [other]
  /// override corresponding fields from this instance.
  CellFormatting merge(CellFormatting? other) {
    if (other == null) return this;
    return CellFormatting(
      fontWeight: other.fontWeight ?? fontWeight,
      fontStyle: other.fontStyle ?? fontStyle,
      textDecoration: other.textDecoration ?? textDecoration,
      textColor: other.textColor ?? textColor,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      fontSize: other.fontSize ?? fontSize,
      alignment: other.alignment ?? alignment,
    );
  }
}

/// Applies conditional visual formatting to rows that satisfy [condition].
class RowFormattingRule {
  final bool Function(Map<String, dynamic> rowData, int rowIndex) condition;
  final Color? backgroundColor;
  final Color? textColor;
  final FontWeight? fontWeight;
  final TextStyle? textStyle;

  /// Optional cell-level formatting applied when the row rule matches.
  final CellFormatting? cellFormatting;

  const RowFormattingRule({
    required this.condition,
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.textStyle,
    this.cellFormatting,
  });
}

/// Multi-column sort configuration.
class SortConfig {
  final String columnKey;
  final bool ascending;
  final int priority;

  const SortConfig({
    required this.columnKey,
    required this.ascending,
    required this.priority,
  });
}

/// Convenience density presets that map to a [TableStylePreset].
enum TableDensity {
  /// Compact rows (~36 px high), tight cell padding.
  compact,

  /// Standard rows (~48–52 px high). Default.
  comfortable,

  /// Spacious rows (~62 px high), generous padding.
  spacious,
}
