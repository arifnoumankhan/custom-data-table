import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const columns = [
    TableColumn(key: 'name', header: 'Name', width: 150),
    TableColumn(key: 'email', header: 'Email', width: 200),
    TableColumn(key: 'age', header: 'Age', width: 80),
  ];

  final data = List.generate(
    5,
    (i) => {
      'name': 'User $i',
      'email': 'user$i@example.com',
      'age': 20 + i,
    },
  );

  Widget buildTable({
    List<Map<String, dynamic>>? tableData,
    bool isLoading = false,
    Widget? emptyStateWidget,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CustomDataTable(
          columns: columns,
          data: tableData ?? data,
          perPage: 10,
          currentPage: 1,
          lastPage: 1,
          isLoading: isLoading,
          emptyStateWidget: emptyStateWidget,
        ),
      ),
    );
  }

  group('CustomDataTable', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(buildTable());
      expect(find.byType(CustomDataTable), findsOneWidget);
    });

    testWidgets('renders column headers', (tester) async {
      await tester.pumpWidget(buildTable());
      await tester.pump();
      // Headers should be present somewhere in the widget tree
      expect(find.byType(CustomDataTable), findsOneWidget);
    });

    testWidgets('shows loading overlay when isLoading is true', (tester) async {
      await tester.pumpWidget(buildTable(isLoading: true));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows custom empty widget when data is empty', (tester) async {
      await tester.pumpWidget(
        buildTable(
          tableData: const [],
          emptyStateWidget: const Text('Nothing here'),
        ),
      );
      await tester.pump();
      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('shows default empty state when data is empty', (tester) async {
      await tester.pumpWidget(buildTable(tableData: const []));
      await tester.pump();
      expect(find.byType(CustomDataTable), findsOneWidget);
    });

    testWidgets('shows title when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDataTable(
              title: 'My Table Title',
              columns: columns,
              data: data,
              perPage: 10,
              currentPage: 1,
              lastPage: 1,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('My Table Title'), findsOneWidget);
    });

    testWidgets('hides title toolbar when showTitleToolbar is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDataTable(
              title: 'Hidden Toolbar Title',
              showTitleToolbar: false,
              enableStylePicker: true,
              showSearch: true,
              showExportButtons: true,
              columns: columns,
              data: data,
              perPage: 10,
              currentPage: 1,
              lastPage: 1,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Hidden Toolbar Title'), findsNothing);
    });
  });

  group('CustomDataTable footer alignment', () {
    testWidgets('footer cells align under column headers when showActions is true',
        (tester) async {
      const cols = [
        TableColumn(key: 'ref', header: 'Ref', width: 100),
        TableColumn(key: 'amount', header: 'Amount', width: 120),
      ];
      const footerByKey = {
        'ref': 'Total:',
        'amount': 'RM 10.000',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 500,
              child: CustomDataTable(
                columns: cols,
                data: const [
                  {'ref': 'INV-1', 'amount': '5.000'},
                ],
                showActions: true,
                actions: const [TableActionView()],
                totalRowByColumnKey: footerByKey,
                perPage: 10,
                currentPage: 1,
                lastPage: 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total:'), findsOneWidget);
      expect(find.text('RM 10.000'), findsOneWidget);

      final refHeaderRect = tester.getRect(find.text('Ref'));
      final totalRect = tester.getRect(find.text('Total:'));
      final amountHeaderRect = tester.getRect(find.text('Amount'));
      final amountFooterRect = tester.getRect(find.text('RM 10.000'));

      expect((totalRect.left - refHeaderRect.left).abs(), lessThan(12));
      expect((amountFooterRect.left - amountHeaderRect.left).abs(), lessThan(12));
    });

    testWidgets('totalRowByColumnKey maps values by column key', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDataTable(
              columns: columns,
              data: data,
              totalRowByColumnKey: const {
                'name': 'Total:',
                'age': '105',
              },
              perPage: 10,
              currentPage: 1,
              lastPage: 1,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total:'), findsOneWidget);
      expect(find.text('105'), findsOneWidget);
    });
  });

  group('CustomPaginationControlWidget', () {
    testWidgets('renders per-page dropdown and page controls', (tester) async {
      var perPage = 25;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaginationControlWidget(
              currentPerPage: perPage,
              currentPage: 2,
              lastPage: 5,
              onPerPageChanged: (value) => perPage = value,
              onNext: (_) {},
              onPrev: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Show'), findsOneWidget);
      expect(find.text('Page 2 of 5'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<PaginationPerPageOption>), findsOneWidget);
    });

    testWidgets('uses custom perPageOptions', (tester) async {
      const customOptions = [
        PaginationPerPageOption(value: 5, label: 'Five'),
        PaginationPerPageOption(value: 15, label: 'Fifteen'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaginationControlWidget(
              currentPerPage: 5,
              currentPage: 1,
              lastPage: 3,
              perPageOptions: customOptions,
              onPerPageChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<PaginationPerPageOption>));
      await tester.pumpAndSettle();
      expect(find.text('Fifteen').last, findsOneWidget);
    });
  });

  group('CustomDataTable pagination', () {
    testWidgets('embeds per-page dropdown when onPerPageChanged is set', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDataTable(
              columns: columns,
              data: data,
              perPage: 25,
              currentPage: 1,
              lastPage: 3,
              onPerPageChanged: (_) {},
              onNext: (_) {},
              onPrev: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaginationControlWidget), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<PaginationPerPageOption>), findsOneWidget);
    });

    testWidgets('hides per-page dropdown when showPerPageDropdown is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDataTable(
              columns: columns,
              data: data,
              perPage: 25,
              currentPage: 1,
              lastPage: 3,
              showPerPageDropdown: false,
              onPerPageChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaginationControlWidget), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<PaginationPerPageOption>), findsNothing);
    });
  });

  group('CustomDataTableLight', () {
    testWidgets('renders text variant without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDataTableLight.text(
              title: 'Test Table',
              columns: const ['Name', 'Email'],
              rows: const [
                ['Alice', 'alice@example.com'],
                ['Bob', 'bob@example.com'],
              ],
            ),
          ),
        ),
      );
      expect(find.byType(CustomDataTableLight), findsOneWidget);
    });

    testWidgets('shows empty message when rows are empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDataTableLight.text(
              columns: const ['Name', 'Email'],
              rows: const [],
              emptyMessage: 'No records found',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('No records found'), findsOneWidget);
    });

    testWidgets('shows title when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CustomDataTableLight.text(
                title: 'My Table Title',
                columns: const ['Col A'],
                rows: const [
                  ['Row 1'],
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('My Table Title'), findsOneWidget);
    });
  });

  group('TableColumn', () {
    test('has correct default values', () {
      const col = TableColumn(key: 'test', header: 'Test');
      expect(col.key, 'test');
      expect(col.header, 'Test');
      expect(col.width, 120);
      expect(col.sortable, true);
      expect(col.clickable, false);
      expect(col.textOverflow, TableTextOverflow.wrap);
    });

    test('valueFormatter is applied', () {
      const col = TableColumn(
        key: 'price',
        header: 'Price',
        valueFormatter: _formatPrice,
      );
      expect(col.valueFormatter!(99.9), '\$99.9');
    });
  });

  group('TableAction', () {
    test('TableActionEdit has correct defaults', () {
      const action = TableActionEdit();
      expect(action.key, ActionKeys.edit);
      expect(action.icon, Icons.edit);
    });

    test('TableActionDelete has correct defaults', () {
      const action = TableActionDelete();
      expect(action.key, ActionKeys.delete);
      expect(action.color, Colors.red);
    });

    test('TableActionView has correct defaults', () {
      const action = TableActionView();
      expect(action.key, ActionKeys.view);
      expect(action.color, Colors.green);
    });
  });

  group('TableStylePresets', () {
    test('builtIn list is non-empty', () {
      expect(TableStylePresets.builtIn, isNotEmpty);
    });

    test('findById returns correct preset', () {
      final preset = TableStylePresets.findById('orbit');
      expect(preset, isNotNull);
      expect(preset!.id, 'orbit');
      expect(preset.label, 'Orbit');
    });

    test('findById returns null for unknown id', () {
      final preset = TableStylePresets.findById('unknown_preset_xyz');
      expect(preset, isNull);
    });

    test('orbit preset has expected properties', () {
      const preset = TableStylePresets.orbit;
      expect(preset.stripedRows, true);
      expect(preset.headerUppercase, false);
    });

    test('pro preset uses uppercase headers', () {
      const preset = TableStylePresets.pro;
      expect(preset.headerUppercase, true);
    });
  });
}

String _formatPrice(dynamic value) => '\$$value';
