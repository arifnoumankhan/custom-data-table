import 'package:flutter/material.dart';

/// Logical surface tone resolved against a [ColorScheme].
///
/// Using tones (rather than raw colors) keeps presets theme-aware: a single
/// preset works in both light and dark mode without per-mode color tables.
enum TableSurfaceTone {
  /// Fully transparent.
  none,

  /// `colorScheme.surface`.
  surface,

  /// Light overlay on `onSurface` (~3% alpha).
  surfaceFaint,

  /// `colorScheme.surfaceContainerHighest`.
  surfaceHigh,

  /// `colorScheme.primaryContainer` at 30% opacity.
  primaryFaint,

  /// `colorScheme.primaryContainer`.
  primaryContainer,

  /// `colorScheme.secondary` at 12% opacity.
  secondaryFaint,

  /// `colorScheme.primary` — full-color branded headers.
  primary,

  /// `colorScheme.tertiaryContainer` — warm/neutral accent surface.
  tertiaryContainer,
}

/// Visual style preset for [CustomDataTable].
///
/// A preset is an immutable value type capturing every visual decision the
/// table needs to render: row metrics, borders, paddings, header treatment,
/// and the surface tones for header/hover/selection. Concrete colors are
/// resolved against the active [ColorScheme] at build time by
/// [TableStyleResolved.from].
///
/// Built-in presets live on [TableStylePresets]. Callers may construct their
/// own preset for full control.
@immutable
class TableStylePreset {
  /// Stable identifier used for persistence. Must be unique per preset.
  final String id;

  /// Short user-facing label shown in the style picker.
  final String label;

  /// Icon shown in the style picker.
  final IconData icon;

  // ---- Metrics ----

  final double headerHeight;
  final double rowHeight;
  final double cellHorizontalPadding;
  final double cellVerticalPadding;

  // ---- Borders & separators ----

  final bool showRowSeparators;
  final double rowSeparatorWidth;
  final bool showHeaderBottomBorder;
  final double headerBottomBorderWidth;
  final TableSurfaceTone headerBottomBorderTone;
  final BorderRadius outerBorderRadius;

  /// Width of the left accent border on the outer container (0 = disabled).
  final double containerLeftAccentWidth;

  /// Surface tone for the left container accent border.
  final TableSurfaceTone containerLeftAccentTone;

  /// When true, the first data row also shows a row separator (top edge).
  final bool separatorOnFirstRow;

  // ---- Row treatment ----

  final bool stripedRows;

  // ---- Header typography ----

  final FontWeight headerFontWeight;
  final double headerLetterSpacing;
  final bool headerUppercase;

  // ---- Surface tones (resolved by [TableStyleResolved]) ----

  final TableSurfaceTone headerSurface;
  final TableSurfaceTone hoverSurface;
  final TableSurfaceTone selectionSurface;
  final TableSurfaceTone stripeSurface;

  const TableStylePreset({
    required this.id,
    required this.label,
    required this.icon,
    required this.headerHeight,
    required this.rowHeight,
    required this.cellHorizontalPadding,
    required this.cellVerticalPadding,
    required this.showRowSeparators,
    required this.rowSeparatorWidth,
    required this.showHeaderBottomBorder,
    required this.headerBottomBorderWidth,
    this.headerBottomBorderTone = TableSurfaceTone.none,
    required this.outerBorderRadius,
    this.containerLeftAccentWidth = 0,
    this.containerLeftAccentTone = TableSurfaceTone.none,
    this.separatorOnFirstRow = false,
    required this.stripedRows,
    required this.headerFontWeight,
    required this.headerLetterSpacing,
    required this.headerUppercase,
    required this.headerSurface,
    required this.hoverSurface,
    required this.selectionSurface,
    required this.stripeSurface,
  });

  TableStylePreset copyWith({
    String? id,
    String? label,
    IconData? icon,
    double? headerHeight,
    double? rowHeight,
    double? cellHorizontalPadding,
    double? cellVerticalPadding,
    bool? showRowSeparators,
    double? rowSeparatorWidth,
    bool? showHeaderBottomBorder,
    double? headerBottomBorderWidth,
    TableSurfaceTone? headerBottomBorderTone,
    BorderRadius? outerBorderRadius,
    double? containerLeftAccentWidth,
    TableSurfaceTone? containerLeftAccentTone,
    bool? separatorOnFirstRow,
    bool? stripedRows,
    FontWeight? headerFontWeight,
    double? headerLetterSpacing,
    bool? headerUppercase,
    TableSurfaceTone? headerSurface,
    TableSurfaceTone? hoverSurface,
    TableSurfaceTone? selectionSurface,
    TableSurfaceTone? stripeSurface,
  }) {
    return TableStylePreset(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      headerHeight: headerHeight ?? this.headerHeight,
      rowHeight: rowHeight ?? this.rowHeight,
      cellHorizontalPadding: cellHorizontalPadding ?? this.cellHorizontalPadding,
      cellVerticalPadding: cellVerticalPadding ?? this.cellVerticalPadding,
      showRowSeparators: showRowSeparators ?? this.showRowSeparators,
      rowSeparatorWidth: rowSeparatorWidth ?? this.rowSeparatorWidth,
      showHeaderBottomBorder: showHeaderBottomBorder ?? this.showHeaderBottomBorder,
      headerBottomBorderWidth: headerBottomBorderWidth ?? this.headerBottomBorderWidth,
      headerBottomBorderTone: headerBottomBorderTone ?? this.headerBottomBorderTone,
      outerBorderRadius: outerBorderRadius ?? this.outerBorderRadius,
      containerLeftAccentWidth: containerLeftAccentWidth ?? this.containerLeftAccentWidth,
      containerLeftAccentTone: containerLeftAccentTone ?? this.containerLeftAccentTone,
      separatorOnFirstRow: separatorOnFirstRow ?? this.separatorOnFirstRow,
      stripedRows: stripedRows ?? this.stripedRows,
      headerFontWeight: headerFontWeight ?? this.headerFontWeight,
      headerLetterSpacing: headerLetterSpacing ?? this.headerLetterSpacing,
      headerUppercase: headerUppercase ?? this.headerUppercase,
      headerSurface: headerSurface ?? this.headerSurface,
      hoverSurface: hoverSurface ?? this.hoverSurface,
      selectionSurface: selectionSurface ?? this.selectionSurface,
      stripeSurface: stripeSurface ?? this.stripeSurface,
    );
  }
}

/// Built-in style presets for [CustomDataTable].
class TableStylePresets {
  TableStylePresets._();

  /// Editorial / dashboard look. Default when no preset is specified.
  /// Barioo composite look — DEFAULT. Muted uppercase header, airy rows,
  /// striped hover; matches docs/redesign/all_products_redesign/composite_final.html.
  static const TableStylePreset barioo = TableStylePreset(
    id: 'barioo',
    label: 'Barioo',
    icon: Icons.auto_awesome_mosaic_outlined,
    headerHeight: 44,
    rowHeight: 56,
    cellHorizontalPadding: 14,
    cellVerticalPadding: 12,
    showRowSeparators: true,
    rowSeparatorWidth: 0.75,
    showHeaderBottomBorder: true,
    headerBottomBorderWidth: 1,
    outerBorderRadius: BorderRadius.all(Radius.circular(14)),
    stripedRows: false,
    headerFontWeight: FontWeight.w700,
    headerLetterSpacing: 0.8,
    headerUppercase: true,
    headerSurface: TableSurfaceTone.surfaceFaint,
    hoverSurface: TableSurfaceTone.primaryFaint,
    selectionSurface: TableSurfaceTone.primaryContainer,
    stripeSurface: TableSurfaceTone.none,
  );

  /// Dense rows-and-dividers grid for data-heavy admin/report screens.
  static const TableStylePreset classic = TableStylePreset(
    id: 'classic',
    label: 'Classic',
    icon: Icons.table_rows_outlined,
    headerHeight: 42,
    rowHeight: 44,
    cellHorizontalPadding: 10,
    cellVerticalPadding: 8,
    showRowSeparators: true,
    rowSeparatorWidth: 0.5,
    showHeaderBottomBorder: true,
    headerBottomBorderWidth: 1,
    outerBorderRadius: BorderRadius.all(Radius.circular(10)),
    stripedRows: true,
    headerFontWeight: FontWeight.w700,
    headerLetterSpacing: 0.3,
    headerUppercase: false,
    headerSurface: TableSurfaceTone.surfaceHigh,
    hoverSurface: TableSurfaceTone.primaryFaint,
    selectionSurface: TableSurfaceTone.primaryContainer,
    stripeSurface: TableSurfaceTone.surfaceFaint,
  );

  /// Minimal chrome, tight rows — small dialogs & embedded tables.
  static const TableStylePreset compact = TableStylePreset(
    id: 'compact',
    label: 'Compact',
    icon: Icons.density_small_rounded,
    headerHeight: 38,
    rowHeight: 40,
    cellHorizontalPadding: 8,
    cellVerticalPadding: 6,
    showRowSeparators: true,
    rowSeparatorWidth: 0.5,
    showHeaderBottomBorder: true,
    headerBottomBorderWidth: 0.75,
    outerBorderRadius: BorderRadius.all(Radius.circular(8)),
    stripedRows: false,
    headerFontWeight: FontWeight.w600,
    headerLetterSpacing: 0.2,
    headerUppercase: false,
    headerSurface: TableSurfaceTone.none,
    hoverSurface: TableSurfaceTone.primaryFaint,
    selectionSurface: TableSurfaceTone.primaryContainer,
    stripeSurface: TableSurfaceTone.none,
  );

  static const List<TableStylePreset> builtIn = [
    barioo,
    classic,
    compact,
  ];

  static TableStylePreset? findById(String id) {
    for (final preset in builtIn) {
      if (preset.id == id) return preset;
    }
    return null;
  }
}

/// Concrete colors and metrics derived from a [TableStylePreset] and a
/// [ColorScheme]. Resolved once per build, then consumed by all rendering
/// paths (header, row, cell).
@immutable
class TableStyleResolved {
  final TableStylePreset preset;
  final Color? headerBackgroundColor;
  final Color? hoverBackgroundColor;
  final Color? selectionBackgroundColor;
  final Color? stripeBackgroundColor;
  final Color separatorColor;
  final Color? containerAccentColor;
  final Color headerBottomBorderColor;

  const TableStyleResolved({
    required this.preset,
    required this.headerBackgroundColor,
    required this.hoverBackgroundColor,
    required this.selectionBackgroundColor,
    required this.stripeBackgroundColor,
    required this.separatorColor,
    required this.containerAccentColor,
    required this.headerBottomBorderColor,
  });

  factory TableStyleResolved.from(
    TableStylePreset preset,
    ColorScheme colorScheme,
  ) {
    final separatorColor = colorScheme.outlineVariant;
    return TableStyleResolved(
      preset: preset,
      headerBackgroundColor: _resolveTone(preset.headerSurface, colorScheme),
      hoverBackgroundColor: _resolveTone(preset.hoverSurface, colorScheme),
      selectionBackgroundColor: _resolveTone(preset.selectionSurface, colorScheme),
      stripeBackgroundColor: _resolveTone(preset.stripeSurface, colorScheme),
      separatorColor: separatorColor,
      containerAccentColor: preset.containerLeftAccentWidth > 0
          ? _resolveTone(preset.containerLeftAccentTone, colorScheme)
          : null,
      headerBottomBorderColor:
          _resolveTone(preset.headerBottomBorderTone, colorScheme) ?? separatorColor,
    );
  }

  static Color? _resolveTone(TableSurfaceTone tone, ColorScheme cs) {
    switch (tone) {
      case TableSurfaceTone.none:
        return null;
      case TableSurfaceTone.surface:
        return cs.surface;
      case TableSurfaceTone.surfaceFaint:
        return cs.onSurface.withValues(alpha: 0.04);
      case TableSurfaceTone.surfaceHigh:
        return cs.surfaceContainerHighest;
      case TableSurfaceTone.primaryFaint:
        return cs.primaryContainer.withValues(alpha: 0.30);
      case TableSurfaceTone.primaryContainer:
        return cs.primaryContainer;
      case TableSurfaceTone.secondaryFaint:
        return cs.secondary.withValues(alpha: 0.12);
      case TableSurfaceTone.primary:
        return cs.primary;
      case TableSurfaceTone.tertiaryContainer:
        return cs.tertiaryContainer;
    }
  }
}

/// Toolbar control for switching the active [TableStylePreset].
///
/// Stateless — the owner decides what is selected and persists the choice.
class TableStylePicker extends StatelessWidget {
  final TableStylePreset selected;
  final List<TableStylePreset> presets;
  final ValueChanged<TableStylePreset> onChanged;
  final String? tooltip;

  const TableStylePicker({
    super.key,
    required this.selected,
    required this.presets,
    required this.onChanged,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      tooltip: tooltip ?? 'Table style',
      icon: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(selected.icon, size: 20),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (id) {
        final picked = presets.firstWhere(
          (p) => p.id == id,
          orElse: () => selected,
        );
        if (picked.id != selected.id) onChanged(picked);
      },
      itemBuilder: (_) => presets.map((preset) {
        final isSelected = preset.id == selected.id;
        return PopupMenuItem<String>(
          value: preset.id,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                preset.icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Text(
                preset.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.check,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
