import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Read-only compact [DataTable] for dialogs and detail panels.
///
/// For large list screens with filters, export, and inline editing, use
/// [CustomDataTable] instead.
///
/// ```dart
/// CustomDataTableLight.text(
///   title: 'Opening Stock',
///   columns: ['SKU', 'Product', 'Qty', 'Value'],
///   rows: data.map((e) => [e.sku, e.name, '${e.qty}', e.value]).toList(),
/// )
/// ```
class CustomDataTableLight extends StatelessWidget {
  const CustomDataTableLight({
    super.key,
    this.title,
    required this.columns,
    required this.rows,
    this.emptyMessage,
    this.wrapInCard = true,
    this.zebraStripes = true,
    this.wrapHeaderLabels = true,
    this.columnWidths,
    this.defaultColumnWidth = 120,
    this.headingRowHeight = 44,
    this.dataRowMinHeight = 48,
    this.dataRowMaxHeight = double.infinity,
    this.columnSpacing = 20,
    this.horizontalMargin = 12,
    this.headerColor,
  }) : textRows = null;

  const CustomDataTableLight._text({
    super.key,
    this.title,
    required this.columns,
    required List<List<String>> this.textRows,
    this.emptyMessage,
    this.wrapInCard = true,
    this.zebraStripes = true,
    this.wrapHeaderLabels = true,
    this.columnWidths,
    this.defaultColumnWidth = 120,
    this.headingRowHeight = 44,
    this.dataRowMinHeight = 48,
    this.dataRowMaxHeight = double.infinity,
    this.columnSpacing = 20,
    this.horizontalMargin = 12,
    this.headerColor,
  }) : rows = const [];

  /// Optional title displayed above the table.
  final String? title;

  /// Column header labels.
  final List<String> columns;

  /// Widget rows. Each inner list must have the same length as [columns].
  final List<List<Widget>> rows;

  /// Text-only rows, used by the [CustomDataTableLight.text] factory.
  final List<List<String>>? textRows;

  /// Message shown in the centre when there are no rows.
  final String? emptyMessage;

  /// Whether to wrap the content in a [Card]. Defaults to `true`.
  final bool wrapInCard;

  /// Alternate row background colors for readability.
  final bool zebraStripes;

  /// When true, header labels wrap within each column width.
  final bool wrapHeaderLabels;

  /// Optional fixed width per column.
  final List<double>? columnWidths;

  /// Fallback column width used when a column width cannot be inferred.
  final double defaultColumnWidth;

  /// Height of the heading row.
  final double headingRowHeight;

  /// Minimum height of a data row.
  final double dataRowMinHeight;

  /// Maximum height of a data row.
  final double dataRowMaxHeight;

  /// Spacing between columns.
  final double columnSpacing;

  /// Horizontal margin around the table content.
  final double horizontalMargin;

  /// Header row background color. Defaults to `theme.primaryColorDark`.
  final Color? headerColor;

  static const TextStyle _headerTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.25,
  );

  /// Convenience constructor when every cell is plain text.
  factory CustomDataTableLight.text({
    Key? key,
    String? title,
    required List<String> columns,
    required List<List<String>> rows,
    String? emptyMessage,
    bool wrapInCard = true,
    bool zebraStripes = true,
    bool wrapHeaderLabels = true,
    List<double>? columnWidths,
    double defaultColumnWidth = 120,
    double headingRowHeight = 44,
    double dataRowMinHeight = 48,
    double dataRowMaxHeight = double.infinity,
    double columnSpacing = 20,
    double horizontalMargin = 12,
    Color? headerColor,
  }) {
    return CustomDataTableLight._text(
      key: key,
      title: title,
      columns: columns,
      textRows: rows,
      emptyMessage: emptyMessage,
      wrapInCard: wrapInCard,
      zebraStripes: zebraStripes,
      wrapHeaderLabels: wrapHeaderLabels,
      columnWidths: columnWidths,
      defaultColumnWidth: defaultColumnWidth,
      headingRowHeight: headingRowHeight,
      dataRowMinHeight: dataRowMinHeight,
      dataRowMaxHeight: dataRowMaxHeight,
      columnSpacing: columnSpacing,
      horizontalMargin: horizontalMargin,
      headerColor: headerColor,
    );
  }

  /// Builds a styled header label widget for use in [DataColumn].
  static Widget headerLabel(
    String label, {
    double? maxWidth,
    bool wrap = true,
    TextAlign textAlign = TextAlign.left,
  }) {
    Widget text = Text(
      label,
      style: _headerTextStyle,
      softWrap: wrap,
      maxLines: wrap ? null : 1,
      overflow: wrap ? TextOverflow.visible : TextOverflow.ellipsis,
      textAlign: textAlign,
    );
    if (maxWidth != null && maxWidth > 0) {
      text = SizedBox(width: maxWidth, child: text);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Align(alignment: Alignment.centerLeft, child: text),
    );
  }

  /// Builds a styled body cell widget for use in [DataCell].
  static Widget bodyCell(
    BuildContext context,
    String value, {
    int? maxLines,
    TextAlign? textAlign,
    double? width,
  }) {
    Widget child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
        textAlign: textAlign,
        softWrap: true,
      ),
    );
    if (width != null && width > 0) {
      child = SizedBox(width: width, child: child);
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedRows = _resolveRows(context);
    final widths = _resolveColumnWidths(resolvedRows);
    final effectiveHeadingHeight = _resolveHeadingRowHeight(widths);
    final theme = Theme.of(context);

    final table = resolvedRows.isEmpty && (emptyMessage?.isNotEmpty ?? false)
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                emptyMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
            ),
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: effectiveHeadingHeight,
              dataRowMinHeight: dataRowMinHeight,
              dataRowMaxHeight: dataRowMaxHeight,
              columnSpacing: columnSpacing,
              horizontalMargin: horizontalMargin,
              headingRowColor: WidgetStateProperty.all(
                headerColor ?? theme.primaryColorDark,
              ),
              columns: List<DataColumn>.generate(columns.length, (index) {
                final headerWidth = wrapHeaderLabels ? widths[index] : null;
                return DataColumn(
                  label: headerLabel(
                    columns[index],
                    maxWidth: headerWidth,
                    wrap: wrapHeaderLabels,
                    textAlign: TextAlign.left,
                  ),
                );
              }),
              rows: List<DataRow>.generate(resolvedRows.length, (index) {
                final cells = resolvedRows[index];
                final rowColor = zebraStripes && index.isOdd ? Colors.grey.shade100 : Colors.white;
                return DataRow(
                  color: WidgetStateProperty.all(rowColor),
                  cells: List<DataCell>.generate(columns.length, (colIndex) {
                    final cell =
                        colIndex < cells.length ? cells[colIndex] : const SizedBox.shrink();
                    return DataCell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _constrainCellToColumn(cell, widths[colIndex]),
                      ),
                    );
                  }),
                );
              }),
            ),
          );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null && title!.trim().isNotEmpty) ...[
          Text(
            title!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],
        table,
      ],
    );

    if (!wrapInCard) return content;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: content,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  List<double> _resolveColumnWidths(List<List<Widget>> resolvedRows) {
    final widths = List<double>.filled(columns.length, 0);
    for (var col = 0; col < columns.length; col++) {
      var maxW = 0.0;
      if (columnWidths != null && col < columnWidths!.length && columnWidths![col] > 0) {
        maxW = columnWidths![col];
      }
      for (final row in resolvedRows) {
        if (col < row.length) {
          final w = _tryExtractWidth(row[col]);
          if (w != null && w > maxW) maxW = w;
        }
      }
      widths[col] = maxW > 0 ? maxW : defaultColumnWidth;
    }
    return widths;
  }

  double _resolveHeadingRowHeight(List<double> colWidths) {
    if (!wrapHeaderLabels) return headingRowHeight;
    var maxLines = 1;
    for (var i = 0; i < columns.length; i++) {
      final lines = _measureHeaderLines(columns[i], colWidths[i]);
      if (lines > maxLines) maxLines = lines;
    }
    final lineHeight = (_headerTextStyle.height ?? 1.25) * _headerTextStyle.fontSize!;
    final computed = 12 + (lineHeight * maxLines) + 12;
    return math.max(headingRowHeight, computed);
  }

  int _measureHeaderLines(String text, double maxWidth) {
    if (text.isEmpty || maxWidth <= 0) return 1;
    final painter = TextPainter(
      text: TextSpan(text: text, style: _headerTextStyle),
      textDirection: TextDirection.ltr,
      maxLines: 12,
    )..layout(maxWidth: maxWidth);
    return math.max(1, painter.computeLineMetrics().length);
  }

  static double? _tryExtractWidth(Widget widget) {
    if (widget is SizedBox) {
      final w = widget.width;
      if (w != null && w.isFinite && w > 0) return w;
    }
    if (widget is Padding) {
      final child = widget.child;
      if (child != null) return _tryExtractWidth(child);
    }
    if (widget is Align) {
      final child = widget.child;
      if (child != null) return _tryExtractWidth(child);
    }
    if (widget is ConstrainedBox) {
      final maxW = widget.constraints.maxWidth;
      if (maxW.isFinite && maxW > 0) return maxW;
    }
    return null;
  }

  static Widget _constrainCellToColumn(Widget cell, double colWidth) {
    final existing = _tryExtractWidth(cell);
    if (existing != null && existing > 0) return cell;
    return SizedBox(width: colWidth, child: cell);
  }

  List<List<Widget>> _resolveRows(BuildContext context) {
    if (rows.isNotEmpty) return rows;
    final text = textRows;
    if (text == null) return [];
    final widths = _resolveColumnWidthsForTextOnly();
    return text
        .map(
          (line) => List<Widget>.generate(
            columns.length,
            (colIndex) => bodyCell(
              context,
              colIndex < line.length ? line[colIndex] : '',
              width: widths[colIndex],
            ),
          ),
        )
        .toList();
  }

  List<double> _resolveColumnWidthsForTextOnly() {
    final widths = List<double>.filled(columns.length, defaultColumnWidth);
    if (columnWidths != null) {
      for (var i = 0; i < columns.length && i < columnWidths!.length; i++) {
        if (columnWidths![i] > 0) widths[i] = columnWidths![i];
      }
    }
    return widths;
  }
}
