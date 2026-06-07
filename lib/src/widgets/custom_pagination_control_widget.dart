import 'package:flutter/material.dart';

import '../models/pagination_per_page_option.dart';

/// Pagination row with optional per-page dropdown and first/prev/next/last controls.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.hasBoundedWidth && constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : double.infinity,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showPerPageDropdown &&
                      widget.onPerPageChanged != null &&
                      widget.perPageOptions.isNotEmpty) ...[
                    Text(widget.labels.showPrefix, style: textStyle),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 72, maxWidth: 120),
                      child: SizedBox(
                        height: 36,
                        child: DropdownButtonFormField<PaginationPerPageOption>(
                          key: ValueKey(_resolveSelectedOption().value),
                          isExpanded: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(width: 12),
                  ],
                  IconButton(
                    tooltip: 'First page',
                    onPressed: _hasPrev ? () => widget.onPrev?.call(1) : null,
                    icon: const Icon(Icons.keyboard_double_arrow_left_outlined),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    tooltip: 'Previous page',
                    onPressed: _hasPrev
                        ? () => widget.onPrev?.call(widget.currentPage - 1)
                        : null,
                    icon: const Icon(Icons.keyboard_arrow_left_outlined),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '${widget.labels.page} ${widget.currentPage} '
                      '${widget.labels.pageOf} ${widget.lastPage}',
                      style: textStyle,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next page',
                    onPressed: _hasNext
                        ? () => widget.onNext?.call(widget.currentPage + 1)
                        : null,
                    icon: const Icon(Icons.keyboard_arrow_right_outlined),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    tooltip: 'Last page',
                    onPressed: _hasNext
                        ? () => widget.onNext?.call(widget.lastPage)
                        : null,
                    icon: const Icon(Icons.keyboard_double_arrow_right_outlined),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
