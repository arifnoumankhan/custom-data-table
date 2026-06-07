import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb, mapEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pagination_per_page_option.dart';
import '../models/table_action.dart';
import '../models/table_column.dart';
import '../theme/table_theme.dart';
import 'custom_pagination_control_widget.dart';

export '../theme/table_theme.dart' show TableStylePreset, TableStylePresets, TableSurfaceTone;

typedef RowColorBuilder = Color Function(BuildContext context, int index);
typedef CellTapCallback = void Function(
    BuildContext context, int rowIndex, int colIndex, dynamic value);
typedef ActionCallback = void Function(
    BuildContext context, int rowIndex, String action, dynamic rowData);

/// A feature-rich, themeable data table widget.
///
/// Supports pagination, multi-column sorting, row selection, frozen columns,
/// inline cell editing, column resizing/reordering, bulk actions, virtual
/// scrolling, conditional row formatting, export hooks, and 10 built-in style
/// presets.
///
/// ## Minimal usage
/// ```dart
/// CustomDataTable(
///   columns: [
///     TableColumn(key: 'name', header: 'Name'),
///     TableColumn(key: 'email', header: 'Email'),
///   ],
///   data: [
///     {'name': 'Alice', 'email': 'alice@example.com'},
///     {'name': 'Bob',   'email': 'bob@example.com'},
///   ],
///   perPage: 10,
///   currentPage: 1,
///   lastPage: 1,
/// )
/// ```
class CustomDataTable extends StatefulWidget {
  // --- Legacy support (deprecated; use columns/data instead) ---
  final List<String>? headers;
  final List<List<dynamic>>? rows;

  // --- Primary API ---
  final List<TableColumn>? columns;
  final List<Map<String, dynamic>>? data;

  // --- Footer / totals ---
  final List<dynamic>? totalRow;
  /// Preferred footer API: values keyed by [TableColumn.key] (survives column hide/reorder).
  final Map<String, String>? totalRowByColumnKey;
  final bool showSumTotals;

  // --- Text styles ---
  final TextStyle? headerTextStyle;
  final TextStyle? cellTextStyle;
  final TextStyle? totalTextStyle;

  // --- Column widths ---
  final List<double>? columnWidths;
  final double defaultColumnWidth;

  // --- Row coloring ---
  final RowColorBuilder? rowColorBuilder;

  // --- Pagination ---
  final int perPage;
  final int currentPage;
  final int lastPage;
  final List<PaginationPerPageOption>? perPageOptions;
  final PaginationControlLabels? paginationLabels;
  final bool showPerPageDropdown;
  final void Function(int pageNo)? onNext;
  final void Function(int pageNo)? onPrev;
  final void Function(int perPage)? onPerPageChanged;
  final bool hidePagination;

  // --- Callbacks ---
  final Function(List<Map<String, dynamic>> sortedData)? onDataSorted;
  final CellTapCallback? onCellTap;
  final ActionCallback? onActionTap;

  // --- Actions ---
  final List<TableAction>? actions;
  final List<Widget>? actionWidgets;
  final bool showActions;
  final double actionsColumnWidth;

  // --- Layout ---
  final bool responsive;
  final bool enableHorizontalScroll;
  final EdgeInsets cellPadding;
  final double? maxHeight;
  final bool stickyHeader;

  // --- States ---
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? emptyStateWidget;

  // --- UX features ---
  final bool showTooltipOnTruncate;
  final bool enableCopyToClipboard;
  final bool showRowNumbers;
  final String rowNumberHeader;

  // --- Row selection ---
  final bool enableRowSelection;
  final bool showSelectAllCheckbox;
  final void Function(List<int> selectedIndices, List<Map<String, dynamic>> selectedData)?
      onRowsSelected;

  // --- Column visibility ---
  final Map<String, bool>? columnVisibility;

  // --- Sorting ---
  final bool enableSorting;
  final bool enableMultiSort;
  final int maxSortColumns;

  // --- Search ---
  final bool showSearch;
  final String? searchHint;
  final Function(String query)? onSearch;
  final Function(String query)? onSearchChanged;
  final Duration searchDebounceDuration;
  final bool isLocalSearch;
  final String searchQuery;

  // --- Filtering ---
  final List<String>? filterableColumns;
  @Deprecated('Use filterableColumns instead.')
  final Map<String, List<dynamic>>? columnFilterOptions;

  // --- Column manipulation ---
  final bool enableColumnResizing;
  final bool enableColumnReordering;
  final Function(List<TableColumn> reorderedColumns)? onColumnsReordered;

  // --- Export ---
  final bool showExportButtons;
  final String? exportFilename;
  final String? title;

  /// When `false`, hides the entire title toolbar (title, style picker, search,
  /// export buttons) regardless of those individual flags.
  final bool showTitleToolbar;

  final Function(List<List<dynamic>> data, List<String> headers)? onExportCsv;
  final Function(List<List<dynamic>> data, List<String> headers)? onExportExcel;
  final Function(List<List<dynamic>> data, List<String> headers, String title)? onExportPdf;
  final Function(List<List<dynamic>> data, List<String> headers, String title)? onPrintPdf;

  // --- Frozen columns ---
  final int? frozenColumnsCount;
  final int? frozenColumnsFromEnd;
  final Set<String>? runtimeFrozenColumns;
  final Function(Set<String> frozenColumnKeys)? onFrozenColumnsChanged;
  final bool enableRuntimeFreeze;

  // --- Row expansion ---
  final Widget Function(BuildContext, int, Map<String, dynamic>)? expandedRowBuilder;

  // --- Conditional formatting ---
  final List<RowFormattingRule>? rowFormattingRules;

  // --- Inline editing ---
  final bool enableInlineEditing;
  final Set<String>? editableColumns;
  final Function(
          BuildContext context, int rowIndex, String columnKey, dynamic oldValue, dynamic newValue)?
      onCellValueChanged;
  final String? Function(BuildContext context, int rowIndex, String columnKey, dynamic value)?
      validateCellValue;

  // --- Bulk actions ---
  final bool showBulkActionsToolbar;
  final List<TableAction>? bulkActions;
  final Function(BuildContext context, String action, List<int> selectedIndices,
      List<Map<String, dynamic>> selectedData)? onBulkActionTap;

  // --- Preferences ---
  final bool saveColumnPreferences;
  final String? preferencesKey;

  // --- Cell formatting ---
  final bool enableCellFormatting;
  final Map<String, CellFormatting>? cellFormatting;
  final Map<String, CellFormatting>? columnFormatting;
  final Function(BuildContext, int, String, dynamic)? onCellFormattingChanged;

  // --- Virtual scrolling ---
  final bool enableVirtualScrolling;
  final double estimatedRowHeight;

  // --- Style presets ---
  final List<TableStylePreset> stylePresets;
  final TableStylePreset? defaultStylePreset;
  final bool enableStylePicker;
  final ValueChanged<TableStylePreset>? onStylePresetChanged;

  const CustomDataTable({
    super.key,
    // Legacy
    this.headers,
    this.rows,
    // Primary
    this.columns,
    this.data,
    // Footer
    this.totalRow,
    this.totalRowByColumnKey,
    this.showSumTotals = false,
    // Styles
    this.headerTextStyle,
    this.cellTextStyle,
    this.totalTextStyle,
    // Widths
    this.columnWidths,
    this.defaultColumnWidth = 160,
    // Colors
    this.rowColorBuilder,
    // Pagination
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.perPageOptions,
    this.paginationLabels,
    this.showPerPageDropdown = true,
    this.onNext,
    this.onPrev,
    this.onPerPageChanged,
    this.hidePagination = false,
    // Callbacks
    this.onDataSorted,
    this.onCellTap,
    this.onActionTap,
    // Actions
    this.actions,
    this.actionWidgets,
    this.showActions = false,
    this.actionsColumnWidth = 60,
    // Layout
    this.responsive = true,
    this.enableHorizontalScroll = true,
    this.cellPadding = const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    this.maxHeight = 400,
    this.stickyHeader = true,
    // States
    this.isLoading = false,
    this.loadingWidget,
    this.emptyStateWidget,
    // UX
    this.showTooltipOnTruncate = false,
    this.enableCopyToClipboard = false,
    this.showRowNumbers = false,
    this.rowNumberHeader = '#',
    // Selection
    this.enableRowSelection = false,
    this.showSelectAllCheckbox = true,
    this.onRowsSelected,
    // Visibility
    this.columnVisibility,
    // Sorting
    this.enableSorting = true,
    this.enableMultiSort = false,
    this.maxSortColumns = 3,
    // Search
    this.showSearch = true,
    this.searchHint = 'Search...',
    this.onSearch,
    this.onSearchChanged,
    this.searchDebounceDuration = const Duration(milliseconds: 300),
    this.isLocalSearch = false,
    this.searchQuery = '',
    // Filtering
    this.filterableColumns,
    this.columnFilterOptions,
    // Column manipulation
    this.enableColumnResizing = true,
    this.enableColumnReordering = false,
    this.onColumnsReordered,
    // Export
    this.showExportButtons = true,
    this.exportFilename,
    this.title,
    this.showTitleToolbar = true,
    this.onExportCsv,
    this.onExportExcel,
    this.onExportPdf,
    this.onPrintPdf,
    // Frozen
    this.frozenColumnsCount,
    this.frozenColumnsFromEnd,
    this.runtimeFrozenColumns,
    this.onFrozenColumnsChanged,
    this.enableRuntimeFreeze = false,
    // Expansion
    this.expandedRowBuilder,
    // Formatting
    this.rowFormattingRules,
    // Inline editing
    this.enableInlineEditing = false,
    this.editableColumns,
    this.onCellValueChanged,
    this.validateCellValue,
    // Bulk actions
    this.showBulkActionsToolbar = false,
    this.bulkActions,
    this.onBulkActionTap,
    // Preferences
    this.saveColumnPreferences = false,
    this.preferencesKey,
    // Cell formatting
    this.enableCellFormatting = false,
    this.cellFormatting,
    this.columnFormatting,
    this.onCellFormattingChanged,
    // Virtual scrolling
    this.enableVirtualScrolling = false,
    this.estimatedRowHeight = 48.0,
    // Style presets
    this.stylePresets = TableStylePresets.builtIn,
    this.defaultStylePreset,
    this.enableStylePicker = true,
    this.onStylePresetChanged,
  })  : assert((headers != null && rows != null) || (columns != null && data != null),
            'Either provide headers/rows or columns/data'),
        assert(
            columnWidths == null ||
                (headers != null && columnWidths.length == headers.length) ||
                columns != null,
            'columnWidths length must match headers length when using legacy API');

  @override
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  late List<double> resolvedWidths;
  late double totalTableWidth;
  late List<TableColumn> _columns;
  late List<Map<String, dynamic>> _data;
  late List<Map<String, dynamic>> _displayData;
  late List<Map<String, dynamic>> _filteredData;

  String _searchQuery = '';
  final Map<String, dynamic> _columnFilters = {};
  final Map<String, List<dynamic>> _generatedFilterOptions = {};
  Map<String, double> _resizedWidths = {};
  final Set<int> _expandedRows = {};
  String? _resizingColumnKey;
  double? _resizeStartX;
  double? _resizeStartWidth;

  Timer? _searchDebounceTimer;
  List<int> _columnOrder = [];

  int? _sortColIndex;
  bool _sortAsc = true;
  String? _sortColumnKey;
  final List<SortConfig> _sortConfigs = [];
  Set<int> _selectedRows = {};
  Set<String> _runtimeFrozenColumns = {};
  // ignore: unused_field
  Map<String, dynamic>? _loadedPreferences;

  String? _editingCellKey;
  TextEditingController? _editingController;
  FocusNode? _editingFocusNode;

  late TableStylePreset _stylePreset;
  TableStyleResolved? _resolvedStyle;

  late ScrollController _horizontalScrollController;
  late ScrollController _verticalScrollController;
  ScrollController? _headerHorizontalScrollController;
  ScrollController? _footerHorizontalScrollController;
  bool _isSyncingScroll = false;
  late TextEditingController _searchController;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _stylePreset = widget.defaultStylePreset ?? TableStylePresets.orbit;
    _initializeData();
    _columnOrder = List.generate(_columns.length, (i) => i);
    resolvedWidths = _columns.map((col) => col.width ?? widget.defaultColumnWidth).toList();
    totalTableWidth = resolvedWidths.fold<double>(0.0, (s, w) => s + w);
    _runtimeFrozenColumns = Set<String>.from(widget.runtimeFrozenColumns ?? {});

    if (widget.saveColumnPreferences && widget.preferencesKey != null) {
      _loadPreferencesFromStorage();
    }
    _generateFilterOptions();

    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
    _headerHorizontalScrollController = ScrollController();
    if (_hasFooterContent) {
      _footerHorizontalScrollController = ScrollController();
    }
    _setupScrollSync();
  }

  @override
  void didUpdateWidget(covariant CustomDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }

    // Footer controller management
    final hasFooter = _hasFooterContent;
    final hadFooter = _footerHorizontalScrollController != null;
    if (hasFooter && !hadFooter) {
      _footerHorizontalScrollController = ScrollController();
      _setupScrollSync();
    } else if (!hasFooter && hadFooter) {
      _horizontalScrollController.removeListener(_syncBodyToFooter);
      _footerHorizontalScrollController!.removeListener(_syncFooterToBody);
      _footerHorizontalScrollController!.dispose();
      _footerHorizontalScrollController = null;
    }

    bool dataChanged = false;
    if (widget.columns != oldWidget.columns ||
        !_sameDataPayload(widget.data, oldWidget.data) ||
        !_sameDataPayloadLegacy(widget.rows, oldWidget.rows) ||
        widget.headers != oldWidget.headers ||
        widget.showActions != oldWidget.showActions ||
        widget.actions != oldWidget.actions ||
        widget.actionWidgets != oldWidget.actionWidgets) {
      _initializeData();
      dataChanged = true;
      _columnOrder = List.generate(_columns.length, (i) => i);
      if (widget.enableRowSelection) {
        _selectedRows.clear();
        _notifySelectionChanged();
      }
      _expandedRows.clear();
    }

    if (widget.runtimeFrozenColumns != oldWidget.runtimeFrozenColumns) {
      _runtimeFrozenColumns = Set<String>.from(widget.runtimeFrozenColumns ?? {});
    }

    if (widget.saveColumnPreferences &&
        widget.preferencesKey != null &&
        widget.preferencesKey != oldWidget.preferencesKey) {
      _loadPreferencesFromStorage();
      resolvedWidths = _resolveColumnWidths(context);
      totalTableWidth = resolvedWidths.fold<double>(0.0, (s, w) => s + w);
    }

    if (dataChanged || oldWidget.columnWidths != widget.columnWidths) {
      resolvedWidths = _resolveColumnWidths(context);
      totalTableWidth = resolvedWidths.fold<double>(0.0, (s, w) => s + w);
    }

    if (dataChanged) {
      _generateFilterOptions();
      _applyFilters();
      if (_sortColumnKey != null || _sortConfigs.isNotEmpty) {
        _sortData();
      }
    }
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    if (_headerHorizontalScrollController != null) {
      _horizontalScrollController.removeListener(_syncBodyToHeader);
      _headerHorizontalScrollController!.removeListener(_syncHeaderToBody);
    }
    if (_footerHorizontalScrollController != null) {
      _horizontalScrollController.removeListener(_syncBodyToFooter);
      _footerHorizontalScrollController!.removeListener(_syncFooterToBody);
    }
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _headerHorizontalScrollController?.dispose();
    _footerHorizontalScrollController?.dispose();
    _editingController?.dispose();
    _editingFocusNode?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data init helpers
  // ---------------------------------------------------------------------------

  bool get _hasFooterContent =>
      widget.totalRow != null ||
      (widget.totalRowByColumnKey != null && widget.totalRowByColumnKey!.isNotEmpty) ||
      widget.showSumTotals;

  void _initializeData() {
    if (widget.columns != null && widget.data != null) {
      _columns = List.from(widget.columns!);
      _data = List.from(widget.data!);
    } else if (widget.headers != null && widget.rows != null) {
      _columns = widget.headers!.asMap().entries.map((entry) {
        final index = entry.key;
        return TableColumn(
          key: 'col_$index',
          header: entry.value,
          width: widget.columnWidths != null && index < widget.columnWidths!.length
              ? widget.columnWidths![index]
              : null,
        );
      }).toList();
      _data = widget.rows!.map((row) {
        final Map<String, dynamic> m = {};
        for (int i = 0; i < row.length && i < _columns.length; i++) {
          m[_columns[i].key] = row[i];
        }
        return m;
      }).toList();
    } else {
      _columns = [];
      _data = [];
    }

    _displayData = List.from(_data);
    _filteredData = List.from(_data);

    if (widget.expandedRowBuilder != null) {
      _columns.insert(0, const TableColumn(key: '_expand', header: '', width: 40, sortable: false));
    }
    if (widget.showRowNumbers) {
      _columns.insert(
          0,
          TableColumn(
              key: '_rowNumber',
              header: widget.rowNumberHeader,
              width: 60,
              sortable: false,
              alignment: TextAlign.center));
    }
    if (widget.enableRowSelection) {
      final insertIndex = widget.showRowNumbers ? 1 : 0;
      _columns.insert(
          insertIndex, const TableColumn(key: '_checkbox', header: '', width: 50, sortable: false));
    }
    if (widget.showActions &&
        ((widget.actions?.isNotEmpty ?? false) || (widget.actionWidgets?.isNotEmpty ?? false))) {
      _columns
          .add(const TableColumn(key: '_actions', header: 'Actions', width: null, sortable: false));
    }
  }

  bool _sameDataPayload(List<Map<String, dynamic>>? a, List<Map<String, dynamic>>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == null && b == null;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!mapEquals(a[i], b[i])) return false;
    }
    return true;
  }

  bool _sameDataPayloadLegacy(List<List<dynamic>>? a, List<List<dynamic>>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == null && b == null;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final ra = a[i];
      final rb = b[i];
      if (ra.length != rb.length) return false;
      for (var j = 0; j < ra.length; j++) {
        if (ra[j] != rb[j]) return false;
      }
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Scroll sync
  // ---------------------------------------------------------------------------

  void _setupScrollSync() {
    _horizontalScrollController.removeListener(_syncBodyToHeader);
    _headerHorizontalScrollController?.removeListener(_syncHeaderToBody);
    _horizontalScrollController.removeListener(_syncBodyToFooter);
    _footerHorizontalScrollController?.removeListener(_syncFooterToBody);

    if (_headerHorizontalScrollController != null) {
      _horizontalScrollController.addListener(_syncBodyToHeader);
      _headerHorizontalScrollController!.addListener(_syncHeaderToBody);
    }
    if (_footerHorizontalScrollController != null) {
      _horizontalScrollController.addListener(_syncBodyToFooter);
      _footerHorizontalScrollController!.addListener(_syncFooterToBody);
    }
  }

  void _syncBodyToHeader() {
    if (_isSyncingScroll) return;
    final hsc = _headerHorizontalScrollController;
    if (hsc == null || !hsc.hasClients || !_horizontalScrollController.hasClients) return;
    _isSyncingScroll = true;
    final bodyOff = _horizontalScrollController.offset;
    if ((bodyOff - hsc.offset).abs() > 0.5) hsc.jumpTo(bodyOff);
    _isSyncingScroll = false;
  }

  void _syncHeaderToBody() {
    if (_isSyncingScroll) return;
    final hsc = _headerHorizontalScrollController;
    if (hsc == null || !hsc.hasClients || !_horizontalScrollController.hasClients) return;
    _isSyncingScroll = true;
    final headerOff = hsc.offset;
    if ((headerOff - _horizontalScrollController.offset).abs() > 0.5) {
      _horizontalScrollController.jumpTo(headerOff);
    }
    _isSyncingScroll = false;
  }

  void _syncBodyToFooter() {
    if (_isSyncingScroll) return;
    final fsc = _footerHorizontalScrollController;
    if (fsc == null || !fsc.hasClients || !_horizontalScrollController.hasClients) return;
    _isSyncingScroll = true;
    final bodyOff = _horizontalScrollController.offset;
    if ((bodyOff - fsc.offset).abs() > 0.5) fsc.jumpTo(bodyOff);
    _isSyncingScroll = false;
  }

  void _syncFooterToBody() {
    if (_isSyncingScroll) return;
    final fsc = _footerHorizontalScrollController;
    if (fsc == null || !fsc.hasClients || !_horizontalScrollController.hasClients) return;
    _isSyncingScroll = true;
    final footerOff = fsc.offset;
    if ((footerOff - _horizontalScrollController.offset).abs() > 0.5) {
      _horizontalScrollController.jumpTo(footerOff);
    }
    _isSyncingScroll = false;
  }

  // ---------------------------------------------------------------------------
  // Preferences
  // ---------------------------------------------------------------------------

  Future<void> _loadPreferencesFromStorage() async {
    if (!widget.saveColumnPreferences || widget.preferencesKey == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(widget.preferencesKey!);
      if (json != null) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        _loadedPreferences = map;
        if (mounted) setState(() => _applyLoadedPreferences(map));
      }
    } catch (_) {}
  }

  void _applyLoadedPreferences(Map<String, dynamic> prefs) {
    if (prefs['widths'] is Map) {
      final w = prefs['widths'] as Map<String, dynamic>;
      _resizedWidths = w.map((k, v) => MapEntry(k, (v as num).toDouble().clamp(50.0, 500.0)));
    }
    if (prefs['order'] is List) {
      final order = (prefs['order'] as List).map((e) => (e as num).toInt()).toList();
      final saved = order.toSet();
      _columnOrder = List<int>.from(order);
      for (int i = 0; i < _columns.length; i++) {
        if (!saved.contains(i)) _columnOrder.add(i);
      }
      if (_columnOrder.length != _columns.length) {
        _columnOrder = List.generate(_columns.length, (i) => i);
      }
    }
    if (prefs['frozenColumns'] is List) {
      _runtimeFrozenColumns = (prefs['frozenColumns'] as List).map((e) => e.toString()).toSet();
    }
    if (prefs['style'] is String) {
      final found = TableStylePresets.findById(prefs['style'] as String);
      if (found != null) _stylePreset = found;
    }
  }

  Future<void> _savePreferences() async {
    if (!widget.saveColumnPreferences || widget.preferencesKey == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = {
        'widths': _resizedWidths,
        'order': _columnOrder,
        'frozenColumns': _runtimeFrozenColumns.toList(),
        'style': _stylePreset.id,
      };
      await prefs.setString(widget.preferencesKey!, jsonEncode(map));
      _loadedPreferences = map;
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Filter / sort
  // ---------------------------------------------------------------------------

  void _generateFilterOptions() {
    _generatedFilterOptions.clear();
    if (widget.filterableColumns == null) return;
    const special = ['_actions', '_checkbox', '_rowNumber', '_expand'];
    for (final key in widget.filterableColumns!) {
      if (special.contains(key)) continue;
      final vals = _data
          .map((r) => r[key])
          .where((v) => v != null && v.toString().isNotEmpty)
          .toSet()
          .toList();
      vals.sort((a, b) {
        if (a is num && b is num) return a.compareTo(b);
        return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
      });
      _generatedFilterOptions[key] = vals;
    }
  }

  List<dynamic> _filterOptionsForColumn(String key) {
    // ignore: deprecated_member_use_from_same_package
    if (widget.columnFilterOptions?.containsKey(key) ?? false) {
      // ignore: deprecated_member_use_from_same_package
      return widget.columnFilterOptions![key] ?? [];
    }
    return _generatedFilterOptions[key] ?? [];
  }

  void _applyFilters() {
    _filteredData = List.from(_data);
    if (widget.showSearch && _searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      _filteredData = _filteredData
          .where((row) => row.values.any((v) => v?.toString().toLowerCase().contains(q) ?? false))
          .toList();
    }
    if (_columnFilters.isNotEmpty) {
      _filteredData = _filteredData.where((row) {
        for (final e in _columnFilters.entries) {
          if (e.value != null && row[e.key]?.toString() != e.value.toString()) {
            return false;
          }
        }
        return true;
      }).toList();
    }
    _displayData = List.from(_filteredData);
  }

  void _onColumnFilterChanged(String key, dynamic value) {
    _searchDebounceTimer?.cancel();
    setState(() {
      if (value == null) {
        _columnFilters.remove(key);
      } else {
        _columnFilters[key] = value;
      }
    });
    _searchDebounceTimer = Timer(widget.searchDebounceDuration, () {
      if (!mounted) return;
      setState(() {
        _applyFilters();
        if (_sortColumnKey != null || _sortConfigs.isNotEmpty) _sortData();
      });
    });
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    setState(() {
      _searchQuery = query;
    });
    _searchDebounceTimer = Timer(widget.searchDebounceDuration, () {
      if (!mounted) return;
      if (widget.isLocalSearch) {
        setState(() {
          _applyFilters();
          if (_sortColumnKey != null || _sortConfigs.isNotEmpty) _sortData();
        });
      }
      widget.onSearch?.call(query);
      widget.onSearchChanged?.call(query);
    });
  }

  void _sortData() {
    if (widget.enableMultiSort && _sortConfigs.isNotEmpty) {
      _displayData.sort((a, b) {
        for (final cfg in _sortConfigs) {
          final cmp = _compareValues(a[cfg.columnKey] ?? '', b[cfg.columnKey] ?? '');
          final result = cfg.ascending ? cmp : -cmp;
          if (result != 0) return result;
        }
        return 0;
      });
    } else if (_sortColumnKey != null) {
      _displayData.sort((a, b) {
        final cmp = _compareValues(a[_sortColumnKey!] ?? '', b[_sortColumnKey!] ?? '');
        return _sortAsc ? cmp : -cmp;
      });
    }
  }

  int _compareValues(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a.runtimeType == b.runtimeType) {
      if (a is DateTime) return a.compareTo(b as DateTime);
      if (a is num) return a.compareTo(b as num);
      if (a is String) return a.toLowerCase().compareTo((b as String).toLowerCase());
    }
    final na = _tryParseNum(a.toString());
    final nb = _tryParseNum(b.toString());
    if (na != null && nb != null) return na.compareTo(nb);
    final da = _tryParseDate(a.toString());
    final db = _tryParseDate(b.toString());
    if (da != null && db != null) return da.compareTo(db);
    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }

  double? _tryParseNum(String s) {
    var t = s.trim().replaceAll(RegExp(r'[^\d\-,\.]'), '');
    if (t.contains(',') && t.contains('.'))
      t = t.replaceAll(',', '');
    else if (t.contains(',')) t = t.replaceAll(',', '');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  DateTime? _tryParseDate(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    final iso = DateTime.tryParse(t);
    if (iso != null) return iso;
    try {
      final parts = t.split(' ');
      final datePart = parts[0];
      if (datePart.contains('/')) {
        final dp = datePart.split('/');
        if (dp.length >= 3) {
          final day = int.tryParse(dp[0]);
          final month = int.tryParse(dp[1]);
          final year = int.tryParse(dp[2]);
          if (day != null && month != null && year != null) {
            return DateTime(year, month, day);
          }
        }
      }
    } catch (_) {}
    return null;
  }

  // ---------------------------------------------------------------------------
  // Header tap / sort
  // ---------------------------------------------------------------------------

  void _onHeaderTap(int colIndex) {
    if (!widget.enableSorting) return;
    final col = _columns[colIndex];
    if (!col.sortable) return;

    setState(() {
      if (widget.enableMultiSort) {
        final existing = _sortConfigs.indexWhere((c) => c.columnKey == col.key);
        if (existing >= 0) {
          final e = _sortConfigs[existing];
          if (e.ascending) {
            _sortConfigs[existing] =
                SortConfig(columnKey: col.key, ascending: false, priority: e.priority);
          } else {
            _sortConfigs.removeAt(existing);
            for (int i = 0; i < _sortConfigs.length; i++) {
              _sortConfigs[i] = SortConfig(
                  columnKey: _sortConfigs[i].columnKey,
                  ascending: _sortConfigs[i].ascending,
                  priority: i);
            }
          }
        } else {
          if (_sortConfigs.length >= widget.maxSortColumns) {
            _sortConfigs.removeAt(0);
            for (int i = 0; i < _sortConfigs.length; i++) {
              _sortConfigs[i] = SortConfig(
                  columnKey: _sortConfigs[i].columnKey,
                  ascending: _sortConfigs[i].ascending,
                  priority: i);
            }
          }
          _sortConfigs
              .add(SortConfig(columnKey: col.key, ascending: true, priority: _sortConfigs.length));
        }
        if (_sortConfigs.isNotEmpty) {
          final primary = _sortConfigs.last;
          _sortColIndex = _columns.indexWhere((c) => c.key == primary.columnKey);
          _sortColumnKey = primary.columnKey;
          _sortAsc = primary.ascending;
        } else {
          _sortColIndex = null;
          _sortColumnKey = null;
        }
      } else {
        if (_sortColIndex == colIndex) {
          _sortAsc = !_sortAsc;
        } else {
          _sortColIndex = colIndex;
          _sortColumnKey = col.key;
          _sortAsc = true;
        }
        _sortConfigs.clear();
      }
      _sortData();
      widget.onDataSorted?.call(List.from(_displayData));
    });
  }

  // ---------------------------------------------------------------------------
  // Row selection
  // ---------------------------------------------------------------------------

  void _onRowSelectionChanged(int index, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedRows.add(index);
      } else {
        _selectedRows.remove(index);
      }
      _notifySelectionChanged();
    });
  }

  void _onSelectAllChanged(bool? selected) {
    setState(() {
      if (selected == true || selected == null) {
        _selectedRows = Set.from(List.generate(_displayData.length, (i) => i));
      } else {
        _selectedRows.clear();
      }
      _notifySelectionChanged();
    });
  }

  void _notifySelectionChanged() {
    final data = _selectedRows.map((i) => _displayData[i]).toList();
    widget.onRowsSelected?.call(_selectedRows.toList(), data);
  }

  // ---------------------------------------------------------------------------
  // Column freeze
  // ---------------------------------------------------------------------------

  void _onColumnFreezeToggled(String key) {
    if (!widget.enableRuntimeFreeze) return;
    setState(() {
      if (_runtimeFrozenColumns.contains(key)) {
        _runtimeFrozenColumns.remove(key);
      } else {
        _runtimeFrozenColumns.add(key);
      }
      widget.onFrozenColumnsChanged?.call(Set.from(_runtimeFrozenColumns));
      _savePreferences();
    });
  }

  // ---------------------------------------------------------------------------
  // Inline editing
  // ---------------------------------------------------------------------------

  bool _isEditable(String key) {
    if (!widget.enableInlineEditing) return false;
    const special = ['_rowNumber', '_checkbox', '_actions', '_expand'];
    if (special.contains(key)) return false;
    return widget.editableColumns == null || widget.editableColumns!.contains(key);
  }

  void _startEditing(int rowIndex, String key, dynamic current) {
    if (!_isEditable(key)) return;
    setState(() {
      _editingCellKey = '${rowIndex}_$key';
      _editingController = TextEditingController(text: current?.toString() ?? '');
      _editingFocusNode = FocusNode()..requestFocus();
      _editingController!.selection =
          TextSelection(baseOffset: 0, extentOffset: _editingController!.text.length);
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingCellKey = null;
      _editingController?.dispose();
      _editingController = null;
      _editingFocusNode?.dispose();
      _editingFocusNode = null;
    });
  }

  void _saveEdit(int rowIndex, String key, dynamic oldValue) {
    if (_editingController == null) return;
    if (_editingCellKey != '${rowIndex}_$key') {
      _cancelEditing();
      return;
    }
    final newValue = _editingController!.text;
    if (widget.validateCellValue != null) {
      final err = widget.validateCellValue!(context, rowIndex, key, newValue);
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        return;
      }
    }
    if (rowIndex < _displayData.length) {
      _displayData[rowIndex][key] = newValue;
      final origIdx = _data.indexWhere((r) => r == _displayData[rowIndex]);
      if (origIdx >= 0) _data[origIdx][key] = newValue;
    }
    widget.onCellValueChanged?.call(context, rowIndex, key, oldValue, newValue);
    _cancelEditing();
  }

  // ---------------------------------------------------------------------------
  // Column reorder
  // ---------------------------------------------------------------------------

  void _onColumnReorder(String dragged, String target) {
    if (!widget.enableColumnReordering) return;
    const special = ['_rowNumber', '_checkbox', '_actions', '_expand'];
    if (special.contains(dragged) || special.contains(target)) return;
    setState(() {
      final draggedCol = _columns.firstWhere((c) => c.key == dragged);
      final targetCol = _columns.firstWhere((c) => c.key == target);
      final fromIdx = _columns.indexOf(draggedCol);
      final toIdx = _columns.indexOf(targetCol);
      if (fromIdx == -1 || toIdx == -1) return;
      _columnOrder.remove(fromIdx);
      _columnOrder.insert(toIdx, fromIdx);
      widget.onColumnsReordered?.call(_columnOrder.map((i) => _columns[i]).toList());
      _savePreferences();
    });
  }

  // ---------------------------------------------------------------------------
  // Bulk actions
  // ---------------------------------------------------------------------------

  void _handleBulkAction(BuildContext context, TableAction action) {
    final indices = _selectedRows.toList();
    final data = indices.map((i) => _displayData[i]).toList();
    const destructive = ['delete', 'remove', 'archive', 'deactivate'];
    if (destructive.contains(action.key.toLowerCase())) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(action.tooltip),
          content: Text(
              'Are you sure you want to ${action.tooltip.toLowerCase()} ${indices.length} row(s)?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onBulkActionTap?.call(context, action.key, indices, data);
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: Text(action.tooltip),
            ),
          ],
        ),
      );
    } else {
      widget.onBulkActionTap?.call(context, action.key, indices, data);
    }
  }

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  List<String> _exportHeaders() {
    const skip = ['_rowNumber', '_checkbox', '_actions', '_expand'];
    return _visibleColumns.where((c) => !skip.contains(c.key)).map((c) => c.header).toList();
  }

  List<List<dynamic>> _exportData() {
    final rows = _selectedRows.isNotEmpty
        ? _selectedRows.map((i) => _displayData[i]).toList()
        : _displayData;
    const skip = ['_rowNumber', '_checkbox', '_actions', '_expand'];
    return rows.map((row) {
      return _visibleColumns.where((c) => !skip.contains(c.key)).map((c) {
        final v = row[c.key];
        return c.valueFormatter != null ? c.valueFormatter!(v) : v?.toString() ?? '';
      }).toList();
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Visible columns
  // ---------------------------------------------------------------------------

  List<TableColumn> get _visibleColumns {
    List<TableColumn> cols;
    if (widget.enableColumnReordering && _columnOrder.isNotEmpty) {
      cols = _columnOrder.map((i) => _columns[i]).toList();
    } else {
      cols = List.from(_columns);
    }
    if (widget.columnVisibility == null) return cols;
    const alwaysVisible = ['_rowNumber', '_checkbox', '_actions', '_expand'];
    return cols.where((c) {
      if (alwaysVisible.contains(c.key)) return true;
      return widget.columnVisibility![c.key] ?? true;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Width resolution
  // ---------------------------------------------------------------------------

  double get _horizontalMargin =>
      math.max(12.0, math.max(widget.cellPadding.left, widget.cellPadding.right));

  double _layoutWidth(TableColumn col) {
    final idx = _columns.indexOf(col);
    final w = idx < resolvedWidths.length ? resolvedWidths[idx] : widget.defaultColumnWidth;
    return w.roundToDouble();
  }

  List<double> _resolveColumnWidths(BuildContext context) {
    if (widget.columnWidths != null && widget.headers != null) {
      return List.from(widget.columnWidths!);
    }
    if (widget.columns != null && widget.columnWidths != null && widget.columnWidths!.isNotEmpty) {
      const special = ['_checkbox', '_rowNumber', '_actions', '_expand'];
      int cursor = 0;
      return _columns.map((col) {
        if (special.contains(col.key)) return _specialWidth(col, context);
        if (cursor < widget.columnWidths!.length) {
          return widget.columnWidths![cursor++];
        }
        return col.width ?? widget.defaultColumnWidth;
      }).toList();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final widths = _columns.map((col) {
      if (col.key == '_actions') return _specialWidth(col, context);
      if (widget.enableColumnResizing && _resizedWidths.containsKey(col.key)) {
        return _resizedWidths[col.key]!.clamp(50.0, 500.0);
      }
      if (col.width != null) return col.width!;
      final base = widget.defaultColumnWidth;
      if (isMobile) return base * 0.75;
      if (isTablet) return base * 0.9;
      return base;
    }).toList();

    final totalWidth = widths.fold<double>(0.0, (s, w) => s + w);
    final available = screenWidth - 100;

    if (!widget.enableHorizontalScroll && totalWidth > available) {
      final scale = available / totalWidth;
      return widths.map((w) => w * scale).toList();
    }
    if (totalWidth < available) {
      const specialKeys = ['_checkbox', '_rowNumber', '_actions', '_expand'];
      final dataIndices = [
        for (int i = 0; i < _columns.length; i++)
          if (!specialKeys.contains(_columns[i].key)) i
      ];
      if (dataIndices.isNotEmpty) {
        final dataTotal = dataIndices.fold<double>(0.0, (s, i) => s + widths[i]);
        if (dataTotal > 0) {
          final extra = available - totalWidth;
          final expanded = List<double>.from(widths);
          for (final i in dataIndices) {
            expanded[i] = widths[i] + extra * (widths[i] / dataTotal);
          }
          return expanded;
        }
      }
    }
    return widths;
  }

  double _specialWidth(TableColumn col, BuildContext context) {
    if (col.key == '_actions') {
      if (widget.actionsColumnWidth > 0) return widget.actionsColumnWidth;
      final w = MediaQuery.of(context).size.width;
      if (w < 768) return 30.0;
      if (w < 1024) return 35.0;
      return 40.0;
    }
    return col.width ?? widget.defaultColumnWidth;
  }

  // ---------------------------------------------------------------------------
  // Frozen split helpers
  // ---------------------------------------------------------------------------

  ({List<TableColumn> special, List<TableColumn> frozen, List<TableColumn> scrollable})
      _splitColumns(List<TableColumn> visible) {
    const specialKeys = ['_checkbox', '_rowNumber', '_actions', '_expand'];
    final special = <TableColumn>[];
    final data = <TableColumn>[];
    for (final c in visible) {
      (specialKeys.contains(c.key) ? special : data).add(c);
    }

    List<TableColumn> frozen = [];
    List<TableColumn> scrollable = [];

    if (widget.enableRuntimeFreeze && _runtimeFrozenColumns.isNotEmpty) {
      for (final c in data) {
        (_runtimeFrozenColumns.contains(c.key) ? frozen : scrollable).add(c);
      }
      frozen.sort((a, b) => data.indexOf(a).compareTo(data.indexOf(b)));
    } else if (widget.frozenColumnsCount != null && widget.frozenColumnsCount! > 0) {
      final count = widget.frozenColumnsCount!.clamp(0, data.length);
      frozen = data.sublist(0, count);
      scrollable = data.sublist(count);
    } else if (widget.frozenColumnsFromEnd != null && widget.frozenColumnsFromEnd! > 0) {
      final count = widget.frozenColumnsFromEnd!.clamp(0, data.length);
      frozen = data.sublist(data.length - count);
      scrollable = data.sublist(0, data.length - count);
    } else {
      scrollable = data;
    }

    return (special: special, frozen: frozen, scrollable: scrollable);
  }

  double _sumWidths(Iterable<TableColumn> cols) =>
      cols.fold<double>(0.0, (s, c) => s + _layoutWidth(c));

  double _sectionOuterWidth(double innerSum) => innerSum + 2 * _horizontalMargin;

  double _totalScrollWidth(List<TableColumn> visible) {
    final split = _splitColumns(visible);
    if (split.special.isEmpty && split.frozen.isEmpty) {
      return _sumWidths(visible) + 2 * _horizontalMargin;
    }
    var total = 0.0;
    if (split.special.isNotEmpty) total += _sectionOuterWidth(_sumWidths(split.special));
    if (split.frozen.isNotEmpty) total += _sectionOuterWidth(_sumWidths(split.frozen));
    if (split.scrollable.isNotEmpty) total += _sectionOuterWidth(_sumWidths(split.scrollable));
    return total;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    resolvedWidths = _resolveColumnWidths(context);
    totalTableWidth = resolvedWidths.fold<double>(0.0, (s, w) => s + w);

    _resolvedStyle = TableStyleResolved.from(_stylePreset, Theme.of(context).colorScheme);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncBodyToHeader();
      _syncBodyToFooter();
    });

    final preset = _stylePreset;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final baseHeader = tt.titleSmall ?? const TextStyle();
    final baseCell = tt.bodyMedium ?? const TextStyle();

    final headerTextColor = preset.headerSurface == TableSurfaceTone.primary
        ? cs.onPrimary
        : (widget.headerTextStyle?.color ?? cs.onSurfaceVariant);

    final headerStyle = (widget.headerTextStyle ??
            baseHeader.copyWith(
              fontWeight: preset.headerFontWeight,
              letterSpacing: preset.headerLetterSpacing,
            ))
        .copyWith(color: headerTextColor);

    final cellStyle = (widget.cellTextStyle ??
            baseCell.copyWith(
              fontWeight: FontWeight.w400,
              height: 1.38,
              letterSpacing: 0.12,
            ))
        .copyWith(color: widget.cellTextStyle?.color ?? cs.onSurface);

    final totalStyle = widget.totalTextStyle ??
        (tt.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.bold);

    final isMobile = MediaQuery.sizeOf(context).width < 768;
    final outerBorderColor = cs.outlineVariant.withValues(alpha: 0.65);
    final resolved = _resolvedStyle!;

    final leftAccent = preset.containerLeftAccentWidth > 0 && resolved.containerAccentColor != null
        ? BorderSide(color: resolved.containerAccentColor!, width: preset.containerLeftAccentWidth)
        : BorderSide.none;

    return LayoutBuilder(builder: (context, constraints) {
      final parentMaxHeight = constraints.maxHeight.isFinite
          ? constraints.maxHeight
          : MediaQuery.of(context).size.height;
      final reserved = _hasFooterContent ? 140.0 : 80.0;
      final contentHeight = widget.maxHeight != null
          ? math.min(widget.maxHeight!, parentMaxHeight - reserved)
          : math.max(200.0, parentMaxHeight - reserved);

      return DecoratedBox(
        decoration: BoxDecoration(borderRadius: preset.outerBorderRadius),
        child: ClipRRect(
          borderRadius: preset.outerBorderRadius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                left: leftAccent,
                top: BorderSide(color: outerBorderColor),
                right: BorderSide(color: outerBorderColor),
                bottom: BorderSide(color: outerBorderColor),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---- Toolbar ----
                  _buildToolbar(context, isMobile),

                  // ---- Bulk actions toolbar ----
                  if (widget.showBulkActionsToolbar &&
                      _selectedRows.isNotEmpty &&
                      (widget.bulkActions?.isNotEmpty ?? false))
                    _buildBulkActionsToolbar(context),

                  // ---- Mobile search ----
                  if (isMobile && widget.showSearch)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildSearchField(context),
                    ),

                  // ---- Table body ----
                  Expanded(
                    child: ClipRect(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildScrollableTable(context, contentHeight, headerStyle, cellStyle),
                          if (widget.isLoading)
                            Positioned.fill(
                              child: _buildOverlay(
                                context,
                                dim: true,
                                child: widget.loadingWidget ?? const CircularProgressIndicator(),
                              ),
                            )
                          else if (_displayData.isEmpty)
                            Positioned.fill(
                              child: _buildOverlay(
                                context,
                                dim: false,
                                child: widget.emptyStateWidget ?? _buildDefaultEmpty(context),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ---- Footer row ----
                  if (widget.totalRow != null ||
                      (widget.totalRowByColumnKey != null &&
                          widget.totalRowByColumnKey!.isNotEmpty)) ...[
                    const SizedBox(height: 8),
                    _buildTotalRow(context, totalStyle),
                  ] else if (widget.showSumTotals) ...[
                    const SizedBox(height: 8),
                    _buildSumTotalsRow(context, totalStyle),
                  ],

                  const SizedBox(height: 8),

                  // ---- Pagination ----
                  if (widget.perPage > 0 && !widget.hidePagination) _buildPagination(context),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Toolbar
  // ---------------------------------------------------------------------------

  Widget _buildToolbar(BuildContext context, bool isMobile) {
    if (!widget.showTitleToolbar) return const SizedBox.shrink();

    final hasToolbar = widget.title != null ||
        widget.showExportButtons ||
        widget.enableStylePicker ||
        (!isMobile && widget.showSearch);
    if (!hasToolbar) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.title != null)
                Expanded(
                  child: Text(
                    widget.title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                  ),
                )
              else
                const SizedBox.shrink(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.enableStylePicker)
                    TableStylePicker(
                      selected: _stylePreset,
                      presets: widget.stylePresets,
                      onChanged: (p) {
                        setState(() => _stylePreset = p);
                        widget.onStylePresetChanged?.call(p);
                        _savePreferences();
                      },
                    ),
                  if (!isMobile && widget.showSearch) ...[
                    const SizedBox(width: 8),
                    SizedBox(width: 280, child: _buildSearchField(context)),
                  ],
                  if (widget.showExportButtons) ...[
                    const SizedBox(width: 8),
                    _buildExportMenu(context),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: widget.searchHint ?? 'Search...',
        prefixIcon: const Icon(Icons.search, size: 20),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildExportMenu(BuildContext context) {
    final items = <PopupMenuEntry<String>>[];
    if (widget.onExportCsv != null) {
      items.add(const PopupMenuItem(
          value: 'csv',
          child: Row(children: [
            Icon(Icons.file_download, color: Color(0xFF1565C0)),
            SizedBox(width: 8),
            Text('Export CSV')
          ])));
    }
    if (widget.onExportExcel != null) {
      items.add(const PopupMenuItem(
          value: 'excel',
          child: Row(children: [
            Icon(Icons.table_chart, color: Color(0xFF1D6F42)),
            SizedBox(width: 8),
            Text('Export Excel')
          ])));
    }
    if (widget.onExportPdf != null) {
      items.add(const PopupMenuItem(
          value: 'pdf',
          child: Row(children: [
            Icon(Icons.picture_as_pdf, color: Color(0xFFC62828)),
            SizedBox(width: 8),
            Text('Export PDF')
          ])));
    }
    if (widget.onPrintPdf != null) {
      items.add(const PopupMenuItem(
          value: 'print',
          child: Row(children: [
            Icon(Icons.print, color: Color(0xFF424242)),
            SizedBox(width: 8),
            Text('Print')
          ])));
    }
    if (items.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: 'Export',
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => items,
      onSelected: (val) {
        final headers = _exportHeaders();
        final data = _exportData();
        final title = widget.exportFilename ?? widget.title ?? 'Export';
        switch (val) {
          case 'csv':
            widget.onExportCsv!(data, headers);
          case 'excel':
            widget.onExportExcel!(data, headers);
          case 'pdf':
            widget.onExportPdf!(data, headers, title);
          case 'print':
            widget.onPrintPdf!(data, headers, title);
        }
      },
    );
  }

  Widget _buildBulkActionsToolbar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${_selectedRows.length} row(s) selected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          ...widget.bulkActions!.map((action) {
            final show = action.shouldShow == null ||
                _selectedRows.any((i) =>
                    i < _displayData.length && (action.shouldShow?.call(_displayData[i]) ?? true));
            if (!show) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(action.icon),
              tooltip: action.tooltip,
              color: action.color ?? Theme.of(context).colorScheme.primary,
              onPressed: () => _handleBulkAction(context, action),
            );
          }),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Clear Selection',
            onPressed: () {
              setState(() {
                _selectedRows.clear();
                _notifySelectionChanged();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, {required bool dim, required Widget child}) {
    return AbsorbPointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dim
              ? Theme.of(context).colorScheme.scrim.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildDefaultEmpty(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_outlined, size: 48, color: Theme.of(context).hintColor),
        const SizedBox(height: 8),
        Text('No data',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).hintColor)),
      ],
    );
  }

  Widget _buildPagination(BuildContext context) {
    return CustomPaginationControlWidget(
      currentPerPage: widget.perPage,
      currentPage: widget.currentPage,
      lastPage: widget.lastPage,
      perPageOptions: widget.perPageOptions ?? PaginationPerPageOption.defaults,
      labels: widget.paginationLabels ?? PaginationControlLabels.defaults,
      showPerPageDropdown: widget.showPerPageDropdown,
      onPerPageChanged: widget.onPerPageChanged,
      onNext: widget.onNext,
      onPrev: widget.onPrev,
    );
  }

  // ---------------------------------------------------------------------------
  // Scrollable table routing
  // ---------------------------------------------------------------------------

  Widget _buildScrollableTable(
      BuildContext context, double contentHeight, TextStyle headerStyle, TextStyle cellStyle) {
    final visible = _visibleColumns;
    final totalWidth = _totalScrollWidth(visible);
    final showScrollbars = _shouldShowScrollbars(context);
    final split = _splitColumns(visible);
    final hasFrozen = split.frozen.isNotEmpty;
    final hasSpecial = split.special.isNotEmpty;

    if (hasFrozen || hasSpecial) {
      return _buildFrozenTable(
          context, contentHeight, headerStyle, cellStyle, visible, showScrollbars, totalWidth);
    }
    if (widget.stickyHeader) {
      return _buildStickyTable(
          context, contentHeight, headerStyle, cellStyle, visible, showScrollbars, totalWidth);
    }
    final dt = _buildDataTable(context, headerStyle, cellStyle, visible, false);
    return _wrapWithScrollbars(dt, contentHeight, showScrollbars, totalWidth);
  }

  bool _shouldShowScrollbars(BuildContext context) {
    return kIsWeb ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux;
  }

  // ---------------------------------------------------------------------------
  // Sticky header table
  // ---------------------------------------------------------------------------

  Widget _buildStickyTable(
    BuildContext context,
    double contentHeight,
    TextStyle headerStyle,
    TextStyle cellStyle,
    List<TableColumn> visible,
    bool showScrollbars,
    double totalWidth,
  ) {
    final preset = _stylePreset;
    final resolved = _resolvedStyle!;
    final headerBg = resolved.headerBackgroundColor ?? Theme.of(context).colorScheme.surface;
    final headerHeight = preset.headerHeight;

    final headerTable = DataTable(
      headingRowHeight: headerHeight,
      dataRowMinHeight: preset.rowHeight,
      dataRowMaxHeight: double.infinity,
      headingRowColor: WidgetStateProperty.all(headerBg),
      border: TableBorder(
        bottom: preset.showHeaderBottomBorder
            ? BorderSide(
                color: resolved.headerBottomBorderColor, width: preset.headerBottomBorderWidth)
            : BorderSide.none,
      ),
      columnSpacing: 0,
      horizontalMargin: _horizontalMargin,
      columns: visible.map((c) => _buildDataColumn(context, c, headerStyle)).toList(),
      rows: const [],
    );

    final bodyTable = DataTable(
      headingRowHeight: 0,
      dataRowMinHeight: preset.rowHeight,
      dataRowMaxHeight: double.infinity,
      dataRowColor: WidgetStateProperty.resolveWith((_) => null),
      border: preset.showRowSeparators
          ? TableBorder(
              bottom: BorderSide(color: resolved.separatorColor, width: preset.rowSeparatorWidth))
          : const TableBorder(),
      columnSpacing: 0,
      horizontalMargin: _horizontalMargin,
      columns:
          visible.map((c) => _buildDataColumn(context, c, headerStyle, bodyOnly: true)).toList(),
      rows: _buildRows(context, visible, cellStyle, false),
    );

    return Column(children: [
      // Fixed header
      SizedBox(
        height: headerHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: headerBg,
            border: Border(
              bottom: preset.showHeaderBottomBorder
                  ? BorderSide(
                      color: resolved.headerBottomBorderColor,
                      width: preset.headerBottomBorderWidth)
                  : BorderSide.none,
            ),
          ),
          child: _suppressScrollbar(
            context,
            SingleChildScrollView(
              controller: _headerHorizontalScrollController ?? _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: totalWidth, child: headerTable),
            ),
          ),
        ),
      ),
      // Scrollable body
      Expanded(
        child: showScrollbars
            ? _themedScrollbar(
                context,
                controller: _horizontalScrollController,
                axis: Axis.horizontal,
                child: _suppressScrollbar(
                  context,
                  SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: totalWidth,
                      child: _themedScrollbar(
                        context,
                        controller: _verticalScrollController,
                        axis: Axis.vertical,
                        child: SizedBox(
                          height: contentHeight - headerHeight,
                          child: _suppressScrollbar(
                            context,
                            SingleChildScrollView(
                              controller: _verticalScrollController,
                              scrollDirection: Axis.vertical,
                              child: SizedBox(width: totalWidth, child: bodyTable),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : _suppressScrollbar(
                context,
                SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalWidth,
                    child: SizedBox(
                      height: contentHeight - headerHeight,
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        scrollDirection: Axis.vertical,
                        child: SizedBox(width: totalWidth, child: bodyTable),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Frozen columns table (special + frozen pinned left, scrollable body)
  // ---------------------------------------------------------------------------

  Widget _buildFrozenTable(
    BuildContext context,
    double contentHeight,
    TextStyle headerStyle,
    TextStyle cellStyle,
    List<TableColumn> visible,
    bool showScrollbars,
    double totalWidth,
  ) {
    final split = _splitColumns(visible);
    final specialW = _sumWidths(split.special);
    final frozenW = _sumWidths(split.frozen);
    final scrollableW = _sumWidths(split.scrollable);
    final hInset = _horizontalMargin;

    if (split.special.isEmpty && split.frozen.isEmpty) {
      final dt = _buildDataTable(context, headerStyle, cellStyle, visible, false);
      return _wrapWithScrollbars(dt, contentHeight, showScrollbars, totalWidth);
    }

    final preset = _stylePreset;
    final resolved = _resolvedStyle!;
    final headerBg = resolved.headerBackgroundColor ?? Theme.of(context).colorScheme.surface;
    final headerHeight = preset.headerHeight;

    final sectionCount = (split.special.isNotEmpty ? 1 : 0) +
        (split.frozen.isNotEmpty ? 1 : 0) +
        (split.scrollable.isNotEmpty ? 1 : 0);
    final innerTotalWidth = specialW + frozenW + scrollableW + sectionCount * 2 * hInset;

    Widget buildSectionHeader(List<TableColumn> cols, bool showRightBorder) {
      return SizedBox(
        width: _sectionOuterWidth(_sumWidths(cols)),
        height: headerHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: headerBg,
            border: Border(
              bottom: preset.showHeaderBottomBorder
                  ? BorderSide(
                      color: resolved.headerBottomBorderColor,
                      width: preset.headerBottomBorderWidth)
                  : BorderSide.none,
              right: showRightBorder
                  ? BorderSide(color: resolved.separatorColor, width: preset.rowSeparatorWidth)
                  : BorderSide.none,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hInset),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cols.map((col) {
                return SizedBox(
                  width: _layoutWidth(col),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildHeaderLabel(context, col, headerStyle),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }

    return Column(children: [
      // Pinned header
      _suppressScrollbar(
        context,
        SingleChildScrollView(
          controller: _headerHorizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: innerTotalWidth,
            child: Row(children: [
              if (split.special.isNotEmpty)
                buildSectionHeader(
                    split.special, split.frozen.isNotEmpty || split.scrollable.isNotEmpty),
              if (split.frozen.isNotEmpty)
                buildSectionHeader(split.frozen, split.scrollable.isNotEmpty),
              if (split.scrollable.isNotEmpty) buildSectionHeader(split.scrollable, false),
            ]),
          ),
        ),
      ),
      // Body
      Expanded(
        child: showScrollbars
            ? _themedScrollbar(
                context,
                controller: _horizontalScrollController,
                axis: Axis.horizontal,
                child: _suppressScrollbar(
                  context,
                  SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: innerTotalWidth,
                      child: _themedScrollbar(
                        context,
                        controller: _verticalScrollController,
                        axis: Axis.vertical,
                        child: SizedBox(
                          height: contentHeight - headerHeight,
                          child: _buildSyncedBody(
                            context,
                            cellStyle,
                            split.special,
                            split.frozen,
                            split.scrollable,
                            specialW,
                            frozenW,
                            scrollableW,
                            hInset,
                            innerTotalWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : _suppressScrollbar(
                context,
                SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: innerTotalWidth,
                    child: SizedBox(
                      height: contentHeight - headerHeight,
                      child: _buildSyncedBody(
                        context,
                        cellStyle,
                        split.special,
                        split.frozen,
                        split.scrollable,
                        specialW,
                        frozenW,
                        scrollableW,
                        hInset,
                        innerTotalWidth,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    ]);
  }

  Widget _buildSyncedBody(
    BuildContext context,
    TextStyle cellStyle,
    List<TableColumn> special,
    List<TableColumn> frozen,
    List<TableColumn> scrollable,
    double specialW,
    double frozenW,
    double scrollableW,
    double hInset,
    double totalRowWidth,
  ) {
    final preset = _stylePreset;
    final resolved = _resolvedStyle!;

    Border rowBorder(int index) {
      if (!preset.showRowSeparators) return const Border();
      final side = BorderSide(color: resolved.separatorColor, width: preset.rowSeparatorWidth);
      if (index > 0 || preset.separatorOnFirstRow) return Border(top: side);
      return const Border();
    }

    Widget sectionCells(List<TableColumn> cols, Map<String, dynamic> rowData, int index,
        TextStyle style, RowFormattingRule? rule) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hInset),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cols.map((col) {
            final w = _layoutWidth(col);
            final isControl =
                const ['_actions', '_checkbox', '_expand', '_rowNumber'].contains(col.key);
            final inner = _buildCellChild(context, col, rowData, index, style, rule: rule);
            return SizedBox(
              width: w,
              child: Align(
                alignment: isControl ? Alignment.center : Alignment.topLeft,
                child: inner,
              ),
            );
          }).toList(),
        ),
      );
    }

    return ListView.builder(
      controller: _verticalScrollController,
      itemCount: _displayData.length,
      itemBuilder: (context, index) {
        if (index >= _displayData.length) return const SizedBox.shrink();
        final rowData = _displayData[index];
        final rule = _matchFormattingRule(rowData, index);
        final bgColor = _rowBgColor(context, index, rule);
        final style = _effectiveCellStyle(cellStyle, rule);
        final border = rowBorder(index);

        Widget sectionStrip(List<TableColumn> cols, double innerW, {bool rightEdge = false}) {
          final outerW = innerW + 2 * hInset;
          return SizedBox(
            width: outerW,
            child: ClipRect(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: bgColor,
                  border: rightEdge
                      ? Border(
                          top: border.top,
                          right: BorderSide(
                              color: resolved.separatorColor, width: preset.rowSeparatorWidth))
                      : border,
                ),
                child: sectionCells(cols, rowData, index, style, rule),
              ),
            ),
          );
        }

        final mainRow = ConstrainedBox(
          constraints: BoxConstraints(minHeight: preset.rowHeight),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (special.isNotEmpty) sectionStrip(special, specialW),
                if (frozen.isNotEmpty)
                  sectionStrip(frozen, frozenW, rightEdge: scrollable.isNotEmpty),
                if (scrollable.isNotEmpty) sectionStrip(scrollable, scrollableW),
              ],
            ),
          ),
        );

        Widget? expandedPanel;
        if (widget.expandedRowBuilder != null && _expandedRows.contains(index)) {
          expandedPanel = Container(
            width: totalRowWidth,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.30),
            child: widget.expandedRowBuilder!(context, index, rowData),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mainRow,
            if (expandedPanel != null) expandedPanel,
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // DataTable helpers
  // ---------------------------------------------------------------------------

  Widget _wrapWithScrollbars(DataTable dt, double contentHeight, bool showScrollbars,
      [double? width]) {
    final w = width ?? totalTableWidth;
    if (!showScrollbars) {
      return SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: w, child: dt),
      );
    }
    return _themedScrollbar(
      context,
      controller: _horizontalScrollController,
      axis: Axis.horizontal,
      child: _suppressScrollbar(
        context,
        SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: w,
            child: _themedScrollbar(
              context,
              controller: _verticalScrollController,
              axis: Axis.vertical,
              child: SizedBox(
                height: contentHeight,
                child: _suppressScrollbar(
                  context,
                  SingleChildScrollView(
                    controller: _verticalScrollController,
                    scrollDirection: Axis.vertical,
                    child: SizedBox(width: w, child: dt),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataTable _buildDataTable(
    BuildContext context,
    TextStyle headerStyle,
    TextStyle cellStyle,
    List<TableColumn> cols,
    bool isFrozen,
  ) {
    final preset = _stylePreset;
    final resolved = _resolvedStyle!;
    final headerBg = resolved.headerBackgroundColor ?? Theme.of(context).colorScheme.surface;

    return DataTable(
      headingRowHeight: preset.headerHeight,
      dataRowMinHeight: preset.rowHeight,
      dataRowMaxHeight: double.infinity,
      headingRowColor: WidgetStateProperty.all(headerBg),
      dataRowColor: WidgetStateProperty.resolveWith((_) => null),
      border: TableBorder(
        bottom: preset.showHeaderBottomBorder
            ? BorderSide(
                color: resolved.headerBottomBorderColor, width: preset.headerBottomBorderWidth)
            : BorderSide.none,
        right: isFrozen
            ? BorderSide(color: resolved.separatorColor, width: preset.rowSeparatorWidth)
            : BorderSide.none,
      ),
      columnSpacing: 0,
      horizontalMargin: _horizontalMargin,
      columns: cols.map((c) => _buildDataColumn(context, c, headerStyle)).toList(),
      rows: _buildRows(context, cols, cellStyle, isFrozen),
    );
  }

  DataColumn _buildDataColumn(
    BuildContext context,
    TableColumn col,
    TextStyle headerStyle, {
    bool bodyOnly = false,
  }) {
    final width = _layoutWidth(col);
    if (bodyOnly) {
      final onSort = col.sortable &&
              !const ['_actions', '_checkbox', '_expand', '_rowNumber'].contains(col.key)
          ? (int _, bool __) => _onHeaderTap(_columns.indexOf(col))
          : null;
      return DataColumn(
        label: SizedBox(width: width, child: const SizedBox.shrink()),
        onSort: onSort,
      );
    }
    return DataColumn(
      label: SizedBox(width: width, child: _buildHeaderLabel(context, col, headerStyle)),
      onSort: col.sortable &&
              !const ['_actions', '_checkbox', '_expand', '_rowNumber'].contains(col.key)
          ? (int _, bool __) => _onHeaderTap(_columns.indexOf(col))
          : null,
    );
  }

  Widget _buildHeaderLabel(BuildContext context, TableColumn col, TextStyle headerStyle) {
    if (col.key == '_actions') {
      return Text(
        _formatHeader(col.header),
        style: headerStyle,
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.visible,
        textAlign: col.alignment ?? TextAlign.left,
      );
    }

    if (col.key == '_checkbox') {
      bool? val;
      if (_displayData.isEmpty) {
        val = false;
      } else if (_selectedRows.length == _displayData.length) {
        val = true;
      } else if (_selectedRows.isEmpty) {
        val = false;
      } else {
        val = null;
      }
      return widget.showSelectAllCheckbox
          ? Checkbox(value: val, tristate: true, onChanged: _onSelectAllChanged)
          : const SizedBox.shrink();
    }

    SortConfig? sortCfg;
    if (widget.enableMultiSort) {
      try {
        sortCfg = _sortConfigs.firstWhere((c) => c.columnKey == col.key);
      } catch (_) {}
    }
    final isSorted =
        widget.enableMultiSort ? sortCfg != null : _sortColIndex == _columns.indexOf(col);
    final ascending = widget.enableMultiSort ? (sortCfg?.ascending ?? true) : _sortAsc;

    final filterOptions = _filterOptionsForColumn(col.key);
    final hasFilter = filterOptions.isNotEmpty;
    final isFiltered = _columnFilters.containsKey(col.key) && _columnFilters[col.key] != null;
    final canFreeze = widget.enableRuntimeFreeze &&
        !const ['_actions', '_checkbox', '_expand', '_rowNumber'].contains(col.key);
    final canReorder = widget.enableColumnReordering &&
        !const ['_actions', '_checkbox', '_expand', '_rowNumber'].contains(col.key);
    final currentWidth = _layoutWidth(col);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        if (canReorder)
          Draggable<String>(
            data: col.key,
            feedback: Material(
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_formatHeader(col.header), style: headerStyle),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: Icon(Icons.drag_handle, size: 20, color: Colors.grey),
            ),
            child: Tooltip(
              message: 'Drag to reorder',
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Icon(Icons.drag_handle,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            ),
          ),
        if (canReorder) const SizedBox(width: 4),
        Flexible(
          child: DragTarget<String>(
            onAcceptWithDetails: (details) {
              if (details.data != col.key && canReorder) {
                _onColumnReorder(details.data, col.key);
              }
            },
            builder: (ctx, candidate, _) => Text(
              _formatHeader(col.header),
              style: headerStyle,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.visible,
              textAlign: col.alignment ?? TextAlign.left,
            ),
          ),
        ),
        if (col.sortable && isSorted) ...[
          const SizedBox(width: 4),
          Icon(
            ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ] else if (col.sortable && widget.enableSorting) ...[
          const SizedBox(width: 4),
          const Icon(Icons.swap_vert, size: 16, color: Colors.grey),
        ],
        if (hasFilter || canFreeze) ...[
          const SizedBox(width: 4),
          Builder(
            builder: (btnCtx) => PopupMenuButton<dynamic>(
              icon: Row(mainAxisSize: MainAxisSize.min, children: [
                if (hasFilter)
                  Icon(
                    isFiltered ? Icons.filter_alt : Icons.filter_alt_outlined,
                    size: 16,
                    color: isFiltered ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                if (canFreeze) ...[
                  if (hasFilter) const SizedBox(width: 2),
                  Icon(
                    _runtimeFrozenColumns.contains(col.key) ? Icons.lock : Icons.lock_open,
                    size: 16,
                    color: _runtimeFrozenColumns.contains(col.key)
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ],
              ]),
              tooltip: 'Column Options',
              padding: EdgeInsets.zero,
              iconSize: 16,
              itemBuilder: (_) => _buildColumnMenuItems(context, col),
              onSelected: (val) {
                if (val == 'toggle_freeze') {
                  _onColumnFreezeToggled(col.key);
                } else if (val == 'open_filter') {
                  _showFilterMenu(context, col, btnCtx);
                }
              },
            ),
          ),
        ],
      ],
    );

    if (!widget.enableColumnResizing) return content;

    return Stack(children: [
      content,
      Positioned(
        right: 0,
        top: 0,
        bottom: 0,
        width: 4,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: GestureDetector(
            onHorizontalDragStart: (d) {
              setState(() {
                _resizingColumnKey = col.key;
                _resizeStartX = d.globalPosition.dx;
                _resizeStartWidth = currentWidth;
              });
            },
            onHorizontalDragUpdate: (d) {
              if (_resizingColumnKey == col.key && _resizeStartX != null) {
                final delta = d.globalPosition.dx - _resizeStartX!;
                setState(() {
                  _resizedWidths[col.key] = (_resizeStartWidth! + delta).clamp(50.0, 500.0);
                  resolvedWidths = _resolveColumnWidths(context);
                  totalTableWidth = resolvedWidths.fold<double>(0.0, (s, w) => s + w);
                });
              }
            },
            onHorizontalDragEnd: (_) {
              setState(() {
                _resizingColumnKey = null;
                _resizeStartX = null;
                _resizeStartWidth = null;
                _savePreferences();
              });
            },
            child: Container(
              color: _resizingColumnKey == col.key
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    ]);
  }

  List<DataRow> _buildRows(
    BuildContext context,
    List<TableColumn> cols,
    TextStyle cellStyle,
    bool isFrozen,
  ) {
    final rows = <DataRow>[];

    for (int i = 0; i < _displayData.length; i++) {
      final rowData = _displayData[i];
      final rule = _matchFormattingRule(rowData, i);
      final bg = _rowBgColor(context, i, rule);
      final style = _effectiveCellStyle(cellStyle, rule);

      rows.add(DataRow(
        key: ValueKey('row_${_rowId(rowData)}'),
        color: WidgetStateProperty.all(bg),
        cells: cols
            .map((c) => DataCell(
                  _buildCellChild(context, c, rowData, i, style, rule: rule),
                  onTap: c.clickable
                      ? () =>
                          widget.onCellTap?.call(context, i, _columns.indexOf(c), rowData[c.key])
                      : null,
                ))
            .toList(),
      ));

      if (widget.expandedRowBuilder != null && _expandedRows.contains(i)) {
        final expanded = widget.expandedRowBuilder!(context, i, rowData);
        rows.add(DataRow(
          key: ValueKey('row_${_rowId(rowData)}_exp'),
          color: WidgetStateProperty.all(
              Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
          cells: [
            DataCell(SizedBox(
              width: _sumWidths(cols),
              child: Padding(padding: const EdgeInsets.all(16), child: expanded),
            )),
            ...cols.skip(1).map((_) => const DataCell(SizedBox.shrink())),
          ],
        ));
      }
    }
    return rows;
  }

  // ---------------------------------------------------------------------------
  // Cell building
  // ---------------------------------------------------------------------------

  Widget _buildCellChild(
    BuildContext context,
    TableColumn col,
    Map<String, dynamic> rowData,
    int index,
    TextStyle cellStyle, {
    RowFormattingRule? rule,
  }) {
    final rowId = _rowId(rowData);

    if (col.key == '_actions') {
      return KeyedSubtree(
        key: ValueKey('cell_${rowId}_actions'),
        child: _buildActionsCell(context, rowData, index),
      );
    }

    if (col.key == '_expand') {
      final expanded = _expandedRows.contains(index);
      return KeyedSubtree(
        key: ValueKey('cell_${rowId}_expand'),
        child: IconButton(
          icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
          onPressed: () => setState(() {
            if (expanded) {
              _expandedRows.remove(index);
            } else {
              _expandedRows.add(index);
            }
          }),
        ),
      );
    }

    if (col.key == '_rowNumber') {
      final num = (widget.currentPage - 1) * widget.perPage + index + 1;
      return KeyedSubtree(
        key: ValueKey('cell_${rowId}_rn'),
        child: Text('$num', style: cellStyle, textAlign: TextAlign.center),
      );
    }

    if (col.key == '_checkbox') {
      return KeyedSubtree(
        key: ValueKey('cell_${rowId}_cb'),
        child: Checkbox(
          value: _selectedRows.contains(index),
          onChanged: (v) => _onRowSelectionChanged(index, v),
        ),
      );
    }

    final value = rowData[col.key];
    final display =
        col.valueFormatter != null ? col.valueFormatter!(value) : value?.toString() ?? '';
    final cellKey = '${index}_${col.key}';
    final isEditing = _editingCellKey == cellKey;

    Widget content;

    if (isEditing && _editingController != null && _editingFocusNode != null) {
      content = Focus(
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              _cancelEditing();
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.enter &&
                !HardwareKeyboard.instance.isShiftPressed) {
              _saveEdit(index, col.key, value);
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: _editingController,
          focusNode: _editingFocusNode,
          style: cellStyle,
          textAlign: col.alignment ?? TextAlign.left,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          onSubmitted: (_) => _saveEdit(index, col.key, value),
        ),
      );
    } else {
      // Apply cell formatting
      CellFormatting? fmt;
      if (widget.enableCellFormatting) {
        final cellFmt = widget.cellFormatting?[cellKey];
        final colFmt = widget.columnFormatting?[col.key];
        final ruleFmt = rule?.cellFormatting;
        fmt = const CellFormatting().merge(ruleFmt).merge(colFmt).merge(cellFmt);
      }

      TextStyle finalStyle = cellStyle;
      if (fmt != null) {
        finalStyle = finalStyle.copyWith(
          fontWeight: fmt.fontWeight,
          fontStyle: fmt.fontStyle,
          decoration: fmt.textDecoration,
          color: fmt.textColor,
          fontSize: fmt.fontSize,
        );
      }
      final textAlign = fmt?.alignment ?? col.alignment ?? TextAlign.left;

      TextOverflow overflow;
      int? maxLines;
      bool? softWrap;
      switch (col.textOverflow) {
        case TableTextOverflow.wrap:
          overflow = TextOverflow.visible;
          softWrap = true;
          maxLines = null;
        case TableTextOverflow.clip:
          overflow = TextOverflow.clip;
          softWrap = false;
          maxLines = 1;
        case TableTextOverflow.ellipsis:
          overflow = TextOverflow.ellipsis;
          softWrap = false;
          maxLines = 1;
      }

      Widget cellText = Text(display,
          style: finalStyle,
          overflow: overflow,
          softWrap: softWrap,
          maxLines: maxLines,
          textAlign: textAlign);

      if (fmt?.backgroundColor != null) {
        cellText = Container(
          color: fmt!.backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: cellText,
        );
      }

      content = col.customCellBuilder != null
          ? col.customCellBuilder!(context, value, rowData, index, _columns.indexOf(col))
          : (widget.showTooltipOnTruncate && display.isNotEmpty
              ? Tooltip(message: display, child: cellText)
              : cellText);

      if (widget.enableCopyToClipboard && display.isNotEmpty) {
        content = GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: display));
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
          },
          child: content,
        );
      }

      if (_isEditable(col.key)) {
        content = GestureDetector(
          onTap: () {
            if (!isEditing) _startEditing(index, col.key, value);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: content,
            ),
          ),
        );
      }
    }

    return KeyedSubtree(
      key: ValueKey('cell_${rowId}_${col.key}'),
      child: SizedBox(width: _layoutWidth(col), child: content),
    );
  }

  Widget _buildActionsCell(BuildContext context, Map<String, dynamic> rowData, int rowIndex) {
    if (widget.actionWidgets != null && widget.actionWidgets!.isNotEmpty) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.actionWidgets!
              .map((w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: w))
              .toList(),
        ),
      );
    }

    if (widget.actions == null || widget.actions!.isEmpty) {
      return const SizedBox.shrink();
    }

    final visible = widget.actions!.where((a) => a.shouldShow?.call(rowData) ?? true).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Center(
      child: PopupMenuButton<String>(
        tooltip: 'Actions',
        icon: const Icon(Icons.more_vert, size: 20),
        itemBuilder: (_) => visible.map((action) {
          return PopupMenuItem<String>(
            value: action.key,
            child: Row(children: [
              Icon(action.icon,
                  color: action.color ?? Theme.of(context).colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(action.tooltip),
            ]),
          );
        }).toList(),
        onSelected: (val) => widget.onActionTap?.call(context, rowIndex, val, rowData),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Footer rows
  // ---------------------------------------------------------------------------

  static const _footerSkipKeys = ['_actions', '_checkbox', '_rowNumber', '_expand'];

  Map<String, String> _footerCellsByColumnKey() {
    if (widget.totalRowByColumnKey != null && widget.totalRowByColumnKey!.isNotEmpty) {
      return Map<String, String>.from(widget.totalRowByColumnKey!);
    }
    if (widget.totalRow == null) return {};
    final map = <String, String>{};
    final dataCols = _columns.where((c) => !_footerSkipKeys.contains(c.key)).toList();
    for (var i = 0; i < dataCols.length && i < widget.totalRow!.length; i++) {
      map[dataCols[i].key] = widget.totalRow![i].toString();
    }
    return map;
  }

  Widget _buildFooterSectionCells(
    BuildContext context,
    List<TableColumn> cols,
    TextStyle tStyle,
    Map<String, String> footerByKey,
    double hInset,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hInset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cols.map((col) {
          final text = footerByKey[col.key] ?? '';
          return SizedBox(
            width: _layoutWidth(col),
            child: Text(
              text,
              style: tStyle,
              textAlign: col.alignment,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Footer row uses the same special / frozen / scrollable sections as the body so
  /// cells line up under body columns (including the pinned actions column).
  Widget _buildAlignedFooterRow(BuildContext context, TextStyle tStyle, Map<String, String> footerByKey) {
    final visible = _visibleColumns;
    final split = _splitColumns(visible);
    final hInset = _horizontalMargin;
    final preset = _stylePreset;
    final resolved = _resolvedStyle!;
    final footerBg = Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08);

    Widget sectionStrip(List<TableColumn> cols, {bool rightEdge = false}) {
      if (cols.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        width: _sectionOuterWidth(_sumWidths(cols)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: footerBg,
            border: rightEdge
                ? Border(
                    right: BorderSide(
                      color: resolved.separatorColor,
                      width: preset.rowSeparatorWidth,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _buildFooterSectionCells(context, cols, tStyle, footerByKey, hInset),
          ),
        ),
      );
    }

    final hasSplit = split.special.isNotEmpty || split.frozen.isNotEmpty;
    if (!hasSplit) {
      return SizedBox(
        width: _totalScrollWidth(visible),
        child: DecoratedBox(
          decoration: BoxDecoration(color: footerBg),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _buildFooterSectionCells(context, visible, tStyle, footerByKey, hInset),
          ),
        ),
      );
    }

    final sectionCount = (split.special.isNotEmpty ? 1 : 0) +
        (split.frozen.isNotEmpty ? 1 : 0) +
        (split.scrollable.isNotEmpty ? 1 : 0);
    final innerTotalWidth = _sumWidths(split.special) +
        _sumWidths(split.frozen) +
        _sumWidths(split.scrollable) +
        sectionCount * 2 * hInset;

    return SizedBox(
      width: innerTotalWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (split.special.isNotEmpty)
            sectionStrip(
              split.special,
              rightEdge: split.frozen.isNotEmpty || split.scrollable.isNotEmpty,
            ),
          if (split.frozen.isNotEmpty)
            sectionStrip(split.frozen, rightEdge: split.scrollable.isNotEmpty),
          if (split.scrollable.isNotEmpty) sectionStrip(split.scrollable),
        ],
      ),
    );
  }

  Widget _buildFooterScrollable(BuildContext context, TextStyle tStyle, Map<String, String> footerByKey) {
    return SingleChildScrollView(
      controller: _footerHorizontalScrollController ?? _horizontalScrollController,
      scrollDirection: Axis.horizontal,
      child: _buildAlignedFooterRow(context, tStyle, footerByKey),
    );
  }

  Widget _buildTotalRow(BuildContext context, TextStyle tStyle) {
    if (widget.totalRow == null &&
        (widget.totalRowByColumnKey == null || widget.totalRowByColumnKey!.isEmpty)) {
      return const SizedBox.shrink();
    }
    return _buildFooterScrollable(context, tStyle, _footerCellsByColumnKey());
  }

  Widget _buildSumTotalsRow(BuildContext context, TextStyle tStyle) {
    if (!widget.showSumTotals || _displayData.isEmpty) return const SizedBox.shrink();

    final totals = <String, double>{};
    for (final col in _visibleColumns) {
      if (_footerSkipKeys.contains(col.key)) continue;
      final nums = _displayData
          .map((r) => _parseNum(r[col.key]))
          .where((v) => v != null)
          .map((v) => v!)
          .toList();
      if (nums.isNotEmpty) totals[col.key] = nums.fold(0.0, (a, b) => a + b);
    }
    if (totals.isEmpty) return const SizedBox.shrink();

    final footerByKey = <String, String>{
      for (final entry in totals.entries) entry.key: entry.value.toStringAsFixed(2),
    };
    return _buildFooterScrollable(context, tStyle, footerByKey);
  }

  double? _parseNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      final cleaned = v.trim().replaceAll(RegExp(r'[^\d\-\.]'), '');
      return double.tryParse(cleaned);
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Column filter menu
  // ---------------------------------------------------------------------------

  List<PopupMenuEntry<dynamic>> _buildColumnMenuItems(BuildContext context, TableColumn col) {
    final items = <PopupMenuEntry<dynamic>>[];
    final canFreeze = widget.enableRuntimeFreeze &&
        !const ['_actions', '_checkbox', '_expand', '_rowNumber'].contains(col.key);
    final hasFilter = _filterOptionsForColumn(col.key).isNotEmpty;

    if (canFreeze) {
      final frozen = _runtimeFrozenColumns.contains(col.key);
      items.add(PopupMenuItem<dynamic>(
        value: 'toggle_freeze',
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(frozen ? Icons.lock_open : Icons.lock,
              size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(frozen ? 'Unfreeze Column' : 'Freeze Column',
              style: Theme.of(context).textTheme.bodySmall),
        ]),
      ));
    }
    if (hasFilter) {
      if (canFreeze) items.add(const PopupMenuDivider());
      items.add(PopupMenuItem<dynamic>(
        value: 'open_filter',
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.filter_alt_outlined,
              size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Text('Filter', style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Icon(Icons.chevron_right,
              size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
        ]),
      ));
    }
    return items;
  }

  void _showFilterMenu(BuildContext context, TableColumn col, BuildContext btnCtx) {
    final options = _filterOptionsForColumn(col.key);
    if (options.isEmpty) return;
    final rb = btnCtx.findRenderObject() as RenderBox?;
    final offset = rb?.localToGlobal(Offset.zero);
    final size = rb?.size;
    final screenSize = MediaQuery.of(context).size;

    showMenu<dynamic>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset != null && size != null ? offset.dx + size.width : screenSize.width / 2,
        offset?.dy ?? screenSize.height / 2,
        screenSize.width,
        screenSize.height,
      ),
      items: [
        PopupMenuItem<dynamic>(
            value: null,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.clear, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('Clear Filter'),
            ])),
        const PopupMenuDivider(),
        ...options.map((opt) {
          final isSel = _columnFilters[col.key] == opt;
          return PopupMenuItem<dynamic>(
            value: opt,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  width: 16,
                  child: isSel
                      ? Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary)
                      : null),
              const SizedBox(width: 8),
              Expanded(child: Text(opt.toString())),
            ]),
          );
        }),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ).then((val) {
      if (val == null) {
        _onColumnFilterChanged(col.key, null);
      } else {
        _onColumnFilterChanged(col.key, val);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Formatting helpers
  // ---------------------------------------------------------------------------

  RowFormattingRule? _matchFormattingRule(Map<String, dynamic> rowData, int i) {
    if (widget.rowFormattingRules == null) return null;
    for (final rule in widget.rowFormattingRules!) {
      if (rule.condition(rowData, i)) return rule;
    }
    return null;
  }

  Color _rowBgColor(BuildContext context, int index, RowFormattingRule? rule) {
    if (rule?.backgroundColor != null) return rule!.backgroundColor!;
    if (widget.rowColorBuilder != null) {
      return widget.rowColorBuilder!(context, index);
    }
    final preset = _stylePreset;
    if (!preset.stripedRows) return Theme.of(context).colorScheme.surface;
    final resolved = _resolvedStyle!;
    final stripe = resolved.stripeBackgroundColor;
    if (index.isOdd && stripe != null) return stripe;
    return Theme.of(context).colorScheme.surface;
  }

  TextStyle _effectiveCellStyle(TextStyle base, RowFormattingRule? rule) {
    if (rule == null) return base;
    if (rule.textColor != null || rule.fontWeight != null || rule.textStyle != null) {
      return base
          .copyWith(color: rule.textColor, fontWeight: rule.fontWeight)
          .merge(rule.textStyle);
    }
    return base;
  }

  String _rowId(Map<String, dynamic> row) {
    final id = row['id'] ?? row['uuid'] ?? row['key'];
    if (id != null) return id.toString();
    return row.toString().hashCode.toString();
  }

  String _formatHeader(String h) => _stylePreset.headerUppercase ? h.toUpperCase() : h;

  // ---------------------------------------------------------------------------
  // Scrollbar helpers
  // ---------------------------------------------------------------------------

  Widget _suppressScrollbar(BuildContext context, Widget child) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: child,
    );
  }

  Widget _themedScrollbar(
    BuildContext context, {
    required ScrollController controller,
    required Axis axis,
    required Widget child,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isVertical = axis == Axis.vertical;
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(true),
        trackVisibility: const WidgetStatePropertyAll(true),
        interactive: true,
        radius: Radius.circular(isVertical ? 9 : 10),
        thickness: WidgetStateProperty.resolveWith<double?>((states) =>
            states.contains(WidgetState.hovered) ? (isVertical ? 12 : 11) : (isVertical ? 10 : 9)),
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.dragged)) {
            return cs.primary.withValues(alpha: 0.95);
          }
          if (states.contains(WidgetState.hovered)) {
            return cs.primary.withValues(alpha: 0.82);
          }
          return cs.primary.withValues(alpha: 0.48);
        }),
      ),
      child: Scrollbar(
        controller: controller,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        child: child,
      ),
    );
  }
}
