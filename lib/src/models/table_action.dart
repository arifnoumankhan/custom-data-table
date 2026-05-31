import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'table_keys.dart';

/// Describes a row-level action shown in the actions column dropdown.
class TableAction {
  /// Unique string identifier for this action (passed to [ActionCallback]).
  final String key;

  /// Icon rendered in the action menu item.
  final IconData icon;

  /// Tooltip / label text shown beside the icon.
  final String tooltip;

  /// Optional icon color. Defaults to [ColorScheme.primary] when `null`.
  final Color? color;

  /// Optional predicate; when provided, the action is hidden unless this
  /// returns `true` for the row's data map.
  final bool Function(dynamic rowData)? shouldShow;

  const TableAction({
    required this.key,
    required this.icon,
    required this.tooltip,
    this.color,
    this.shouldShow,
  });
}

// ---------------------------------------------------------------------------
// Convenience subclasses for common row actions.
// ---------------------------------------------------------------------------

class TableActionEdit extends TableAction {
  const TableActionEdit({
    super.tooltip = 'Edit',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.edit,
          icon: Icons.edit,
          color: color ?? Colors.blue,
        );
}

class TableActionDelete extends TableAction {
  const TableActionDelete({
    super.tooltip = 'Delete',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.delete,
          icon: Icons.delete,
          color: color ?? Colors.red,
        );
}

class TableActionView extends TableAction {
  const TableActionView({
    super.tooltip = 'View',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.view,
          icon: Icons.visibility,
          color: color ?? Colors.green,
        );
}

class TableActionPrint extends TableAction {
  const TableActionPrint({
    super.tooltip = 'Print',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.print,
          icon: Icons.print,
          color: color ?? Colors.orange,
        );
}

class TableActionShare extends TableAction {
  const TableActionShare({
    super.tooltip = 'Share',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.share,
          icon: Icons.share,
          color: color ?? Colors.purple,
        );
}

class TableActionDownload extends TableAction {
  const TableActionDownload({
    super.tooltip = 'Download PDF',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.download,
          icon: Icons.download,
          color: color ?? Colors.teal,
        );
}

class TableActionDuplicate extends TableAction {
  const TableActionDuplicate({
    super.tooltip = 'Duplicate',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.duplicate,
          icon: Icons.copy,
          color: color ?? Colors.blue,
        );
}

class TableActionArchive extends TableAction {
  const TableActionArchive({
    super.tooltip = 'Archive',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.archive,
          icon: Icons.archive,
          color: color ?? Colors.grey,
        );
}

class TableActionRestore extends TableAction {
  const TableActionRestore({
    super.tooltip = 'Restore',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.restore,
          icon: Icons.restore,
          color: color ?? Colors.green,
        );
}

class TableActionDeactivate extends TableAction {
  const TableActionDeactivate({
    super.tooltip = 'Deactivate',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.deactivate,
          icon: Icons.power_settings_new,
          color: color ?? Colors.red,
        );
}

class TableActionActivate extends TableAction {
  const TableActionActivate({
    super.tooltip = 'Activate',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.activate,
          icon: Icons.power_settings_new,
          color: color ?? Colors.green,
        );
}

class TableActionSettings extends TableAction {
  const TableActionSettings({
    super.tooltip = 'Settings',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.settings,
          icon: Icons.settings,
          color: color ?? Colors.grey,
        );
}

class TableActionPrintLabels extends TableAction {
  const TableActionPrintLabels({
    super.tooltip = 'Print Labels',
    Color? color,
    super.shouldShow,
  }) : super(
          key: ActionKeys.printLabels,
          icon: CupertinoIcons.barcode,
          color: color ?? Colors.blueGrey,
        );
}
