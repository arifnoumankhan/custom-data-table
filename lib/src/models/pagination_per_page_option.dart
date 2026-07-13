/// One entry in the per-page size dropdown (server-driven pagination).
class PaginationPerPageOption {
  const PaginationPerPageOption({
    required this.value,
    required this.label,
  });

  /// Rows per page sent to the caller. Use `0` for "show all rows" if your API supports it.
  final int value;

  /// Display label in the dropdown (e.g. `"25"`, `"All"`).
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationPerPageOption &&
          value == other.value &&
          label == other.label;

  @override
  int get hashCode => Object.hash(value, label);

  /// Default options when [CustomDataTable.perPageOptions] is omitted.
  static const List<PaginationPerPageOption> defaults = [
    PaginationPerPageOption(value: 10, label: '10'),
    PaginationPerPageOption(value: 25, label: '25'),
    PaginationPerPageOption(value: 50, label: '50'),
    PaginationPerPageOption(value: 100, label: '100'),
    PaginationPerPageOption(value: 500, label: '500'),
    PaginationPerPageOption(value: 1000, label: '1000'),
    PaginationPerPageOption(value: 0, label: 'All'),
  ];
}

/// Localizable strings for [CustomPaginationControlWidget].
class PaginationControlLabels {
  const PaginationControlLabels({
    this.showPrefix = 'Items per page',
    this.perPageHint = 'Limit',
    this.page = 'Page',
    this.pageOf = 'of',
  });

  final String showPrefix;
  final String perPageHint;
  final String page;
  final String pageOf;

  static const PaginationControlLabels defaults = PaginationControlLabels();
}
