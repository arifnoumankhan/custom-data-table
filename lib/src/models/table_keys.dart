/// Common column key constants for use with [TableColumn.key].
///
/// These are purely for convenience — you can use any string as a column key.
class TableKeys {
  TableKeys._();

  static const String id = 'id';
  static const String date = 'date';
  static const String invoiceNo = 'invoice_no';
  static const String referenceNo = 'reference_no';
  static const String amount = 'amount';
  static const String totalAmount = 'total_amount';
  static const String customer = 'customer';
  static const String customerName = 'customer_name';
  static const String paymentMethod = 'payment_method';
  static const String paymentStatus = 'payment_status';
  static const String status = 'status';
  static const String description = 'description';
  static const String quantity = 'quantity';
  static const String price = 'price';
  static const String total = 'total';
  static const String createdBy = 'created_by';
  static const String updatedAt = 'updated_at';
  static const String createdAt = 'created_at';
  static const String name = 'name';
  static const String email = 'email';
  static const String sku = 'sku';
  static const String productName = 'product_name';
  static const String note = 'note';
  static const String action = 'action';
}

/// Common action key constants for use with [TableAction.key].
class ActionKeys {
  ActionKeys._();

  static const String view = 'view';
  static const String edit = 'edit';
  static const String delete = 'delete';
  static const String print = 'print';
  static const String share = 'share';
  static const String download = 'download';
  static const String duplicate = 'duplicate';
  static const String archive = 'archive';
  static const String restore = 'restore';
  static const String approve = 'approve';
  static const String reject = 'reject';
  static const String cancel = 'cancel';
  static const String complete = 'complete';
  static const String export = 'export';
  static const String copy = 'copy';
  static const String deactivate = 'deactivate';
  static const String activate = 'activate';
  static const String settings = 'settings';
  static const String printLabels = 'print_labels';
}
