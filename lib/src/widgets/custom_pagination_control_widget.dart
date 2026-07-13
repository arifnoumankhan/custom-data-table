import 'package:flutter/material.dart';

import '../models/pagination_per_page_option.dart';

/// Pagination footer: per-page dropdown (left), "Showing x–y of N" (center),
/// pill-style page numbers with ellipsis + prev/next chevrons (right).
class CustomPaginationControlWidget extends StatefulWidget {
  const CustomPaginationControlWidget({
    super.key,
    required this.currentPerPage,
    required this.currentPage,
    required this.lastPage,
    this.perPageOptions = PaginationPerPageOption.defaults,
    this.showPerPageDropdown = true,
    this.labels = PaginationControlLabels.defaults,
    this.onPerPageChanged,
    this.onNext,
    this.onPrev,
    this.totalItems,
    this.rowsOnPage,
  });

  final int currentPerPage;
  final int currentPage;
  final int lastPage;
  final List<PaginationPerPageOption> perPageOptions;
  final bool showPerPageDropdown;
  final PaginationControlLabels labels;
  final ValueChanged<int>? onPerPageChanged;
  final ValueChanged<int>? onNext;
  final ValueChanged<int>? onPrev;

  /// Total row count across all pages — enables "Showing x–y of N".
  final int? totalItems;

  /// Rows on the current page (defaults to [currentPerPage]).
  final int? rowsOnPage;

  @override
  State<CustomPaginationControlWidget> createState() =>
      _CustomPaginationControlWidgetState();
}

class _CustomPaginationControlWidgetState
    extends State<CustomPaginationControlWidget> {
  PaginationPerPageOption? _selectedOption;

  @override
  void didUpdateWidget(CustomPaginationControlWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPerPage != widget.currentPerPage ||
        oldWidget.perPageOptions != widget.perPageOptions) {
      _selectedOption = null;
    }
  }

  PaginationPerPageOption _resolveSelectedOption() {
    if (_selectedOption != null &&
        _selectedOption!.value == widget.currentPerPage) {
      return _selectedOption!;
    }
    for (final option in widget.perPageOptions) {
      if (option.value == widget.currentPerPage) {
        return option;
      }
    }
    return PaginationPerPageOption(
      value: widget.currentPerPage,
      label: widget.currentPerPage == 0 ? 'All' : '${widget.currentPerPage}',
    );
  }

  List<PaginationPerPageOption> _dropdownOptions() {
    final selected = _resolveSelectedOption();
    if (widget.perPageOptions.any((o) => o.value == selected.value)) {
      return widget.perPageOptions;
    }
    return [selected, ...widget.perPageOptions];
  }

  bool get _hasPrev => widget.currentPage > 1;

  bool get _hasNext =>
      widget.lastPage > 0 && widget.currentPage < widget.lastPage;

  /// Page numbers to render: 1 … window around current … last.
  /// `null` entries mark ellipsis gaps.
  List<int?> _pageWindow() {
    final last = widget.lastPage;
    final current = widget.currentPage;
    if (last <= 7) {
      return [for (var i = 1; i <= last; i++) i];
    }
    final pages = <int?>[1];
    final start = (current - 1).clamp(2, last - 3);
    final end = (current + 1).clamp(4, last - 1);
    if (start > 2) pages.add(null);
    for (var i = start; i <= end; i++) {
      pages.add(i);
    }
    if (end < last - 1) pages.add(null);
    pages.add(last);
    return pages;
  }

  String? _showingText() {
    final rows = widget.rowsOnPage ?? widget.currentPerPage;
    if (rows <= 0) return null;
    final start = (widget.currentPage - 1) * widget.currentPerPage + 1;
    final end = start + rows - 1;
    final total = widget.totalItems;
    if (total != null && total > 0) {
      return 'Showing $start–${end > total ? total : end} of $total';
    }
    return 'Showing $start–$end';
  }

  void _goTo(int page) {
    if (page == widget.currentPage) return;
    if (page < widget.currentPage) {
      widget.onPrev?.call(page);
    } else {
      widget.onNext?.call(page);
    }
  }

  Widget _pill(
    BuildContext context, {
    Widget? child,
    String? text,
    bool active = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: active ? theme.colorScheme.primary : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: active
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: child ??
                Text(
                  text ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: active
                        ? theme.colorScheme.onPrimary
                        : (onTap == null
                            ? theme.disabledColor
                            : theme.textTheme.bodyMedium?.color),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall;
    final showing = _showingText();

    final perPageGroup = <Widget>[
      if (widget.showPerPageDropdown &&
          widget.onPerPageChanged != null &&
          widget.perPageOptions.isNotEmpty) ...[
        Text('${widget.labels.showPrefix}:', style: textStyle),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64, maxWidth: 96),
          child: SizedBox(
            height: 34,
            child: DropdownButtonFormField<PaginationPerPageOption>(
              key: ValueKey(_resolveSelectedOption().value),
              isExpanded: true,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
              ),
              hint: Text(widget.labels.perPageHint),
              initialValue: _resolveSelectedOption(),
              items: _dropdownOptions()
                  .map(
                    (option) => DropdownMenuItem(
                      value: option,
                      child: Text(
                        option.label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (option) {
                if (option == null) return;
                setState(() => _selectedOption = option);
                widget.onPerPageChanged!(option.value);
              },
            ),
          ),
        ),
      ],
      if (showing != null) ...[
        const SizedBox(width: 14),
        Text(
          showing,
          style: textStyle?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    ];

    final pager = <Widget>[
      _pill(
        context,
        child: Icon(
          Icons.chevron_left_rounded,
          size: 18,
          color: _hasPrev ? null : theme.disabledColor,
        ),
        onTap: _hasPrev ? () => _goTo(widget.currentPage - 1) : null,
      ),
      for (final page in _pageWindow())
        page == null
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('…'),
              )
            : _pill(
                context,
                text: '$page',
                active: page == widget.currentPage,
                onTap: () => _goTo(page),
              ),
      _pill(
        context,
        child: Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: _hasNext ? null : theme.disabledColor,
        ),
        onTap: _hasNext ? () => _goTo(widget.currentPage + 1) : null,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow =
              constraints.hasBoundedWidth && constraints.maxWidth < 560;
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: perPageGroup),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(mainAxisSize: MainAxisSize.min, children: pager),
                ),
              ],
            );
          }
          return Row(
            children: [
              ...perPageGroup,
              const Spacer(),
              ...pager,
            ],
          );
        },
      ),
    );
  }
}
