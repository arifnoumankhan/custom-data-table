import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

final List<Map<String, dynamic>> _sampleData = List.generate(30, (i) => {
  'id': i + 1,
  'name': 'Customer ${i + 1}',
  'email': 'customer${i + 1}@example.com',
  'status': i % 3 == 0 ? 'Active' : (i % 3 == 1 ? 'Inactive' : 'Pending'),
  'amount': ((i + 1) * 47.5).toStringAsFixed(2),
  'date': '${2024 + (i ~/ 12)}-${(i % 12 + 1).toString().padLeft(2, '0')}-01',
});

final List<TableColumn> _columns = [
  const TableColumn(key: 'id', header: '#', width: 60, sortable: true),
  const TableColumn(key: 'name', header: 'Name', width: 180),
  const TableColumn(key: 'email', header: 'Email', width: 220),
  TableColumn(
    key: 'status',
    header: 'Status',
    width: 120,
    customCellBuilder: (ctx, value, _, __, ___) {
      final color = value == 'Active'
          ? Colors.green
          : value == 'Inactive'
              ? Colors.red
              : Colors.orange;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value?.toString() ?? '',
          style:
              TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      );
    },
  ),
  const TableColumn(key: 'amount', header: 'Amount (USD)', width: 140),
  const TableColumn(key: 'date', header: 'Date', width: 120),
];

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomDataTable Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const DemoHome(),
    );
  }
}

class DemoHome extends StatefulWidget {
  const DemoHome({super.key});

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  int _tab = 0;
  ThemeMode _themeMode = ThemeMode.light;

  static const _tabs = [
    'Basic',
    'Actions',
    'Export',
    'Light',
    'Density',
    'Dark',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _themeMode,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      darkTheme: ThemeData(
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.dark,
          useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CustomDataTable Demo'),
          actions: [
            IconButton(
              icon: Icon(_themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode),
              tooltip: 'Toggle theme',
              onPressed: () => setState(() {
                _themeMode = _themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
              }),
            ),
          ],
        ),
        body: Column(
          children: [
            // Tab bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.asMap().entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: FilterChip(
                      label: Text(e.value),
                      selected: _tab == e.key,
                      onSelected: (_) => setState(() => _tab = e.key),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(child: _buildTab(_tab)),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int tab) {
    switch (tab) {
      case 0:
        return _BasicDemo();
      case 1:
        return _ActionsDemo();
      case 2:
        return _ExportDemo();
      case 3:
        return _LightDemo();
      case 4:
        return _DensityDemo();
      case 5:
        return _DarkThemeDemo();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Tab 0 – Basic table with pagination
// ---------------------------------------------------------------------------

class _BasicDemo extends StatefulWidget {
  @override
  State<_BasicDemo> createState() => _BasicDemoState();
}

class _BasicDemoState extends State<_BasicDemo> {
  int _page = 1;
  final int _perPage = 10;

  int get _lastPage => (_sampleData.length / _perPage).ceil();

  List<Map<String, dynamic>> get _pageData {
    final start = (_page - 1) * _perPage;
    final end = (start + _perPage).clamp(0, _sampleData.length);
    return _sampleData.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomDataTable(
        title: 'Customers',
        columns: _columns,
        data: _pageData,
        perPage: _perPage,
        currentPage: _page,
        lastPage: _lastPage,
        onNext: (p) => setState(() => _page = p),
        onPrev: (p) => setState(() => _page = p),
        enableRowSelection: true,
        onRowsSelected: (indices, data) =>
            debugPrint('Selected ${indices.length} rows'),
        filterableColumns: const ['status'],
        isLocalSearch: true,
        defaultStylePreset: TableStylePresets.orbit,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1 – Table with row actions
// ---------------------------------------------------------------------------

class _ActionsDemo extends StatefulWidget {
  @override
  State<_ActionsDemo> createState() => _ActionsDemoState();
}

class _ActionsDemoState extends State<_ActionsDemo> {
  String _lastAction = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_lastAction.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Last action: $_lastAction',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary)),
            ),
          Expanded(
            child: CustomDataTable(
              title: 'Orders',
              columns: _columns,
              data: _sampleData.take(10).toList(),
              perPage: 10,
              currentPage: 1,
              lastPage: 1,
              showActions: true,
              actions: const [
                TableActionView(),
                TableActionEdit(),
                TableActionDelete(),
              ],
              onActionTap: (ctx, rowIndex, action, rowData) {
                setState(() => _lastAction =
                    '$action on row ${rowData['name']}');
              },
              defaultStylePreset: TableStylePresets.classic,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2 – Export demo
// ---------------------------------------------------------------------------

class _ExportDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomDataTable(
        title: 'Sales Report',
        columns: _columns,
        data: _sampleData.take(15).toList(),
        perPage: 15,
        currentPage: 1,
        lastPage: 1,
        showExportButtons: true,
        exportFilename: 'sales_report',
        onExportCsv: (data, headers) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('CSV export triggered: ${data.length} rows')),
          );
        },
        onExportExcel: (data, headers) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Excel export triggered: ${data.length} rows')),
          );
        },
        onExportPdf: (data, headers, title) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('PDF export triggered: $title')),
          );
        },
        onPrintPdf: (data, headers, title) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Print triggered: $title')),
          );
        },
        defaultStylePreset: TableStylePresets.pro,
        showSumTotals: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 3 – Light table variant
// ---------------------------------------------------------------------------

class _LightDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Widget rows variant',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          CustomDataTableLight(
            title: 'Opening Stock',
            columns: const ['SKU', 'Product', 'Qty', 'Value'],
            rows: List.generate(
              5,
              (i) => [
                Text('SKU-${1000 + i}'),
                Text('Product ${i + 1}'),
                Text('${(i + 1) * 10}'),
                Text('\$${((i + 1) * 25.0).toStringAsFixed(2)}'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Text-only variant',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          CustomDataTableLight.text(
            title: 'Price List',
            columns: const ['Item', 'Unit Price', 'Min Qty', 'Discount'],
            rows: List.generate(
              6,
              (i) => [
                'Item ${i + 1}',
                '\$${(10.0 + i * 5).toStringAsFixed(2)}',
                '${(i + 1) * 5}',
                '${i * 2}%',
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 4 – All density modes
// ---------------------------------------------------------------------------

class _DensityDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final presets = [
      ('Compact (Pro)', TableStylePresets.pro),
      ('Comfortable (Orbit)', TableStylePresets.orbit),
      ('Spacious (Frost)', TableStylePresets.frost),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: presets.length,
      itemBuilder: (ctx, i) {
        final (label, preset) = presets[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: SizedBox(
            height: 260,
            child: CustomDataTable(
              title: label,
              columns: _columns.take(4).toList(),
              data: _sampleData.take(4).toList(),
              perPage: 4,
              currentPage: 1,
              lastPage: 1,
              hidePagination: true,
              showSearch: false,
              showExportButtons: false,
              enableStylePicker: false,
              defaultStylePreset: preset,
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 5 – Dark theme demo
// ---------------------------------------------------------------------------

class _DarkThemeDemo extends StatefulWidget {
  @override
  State<_DarkThemeDemo> createState() => _DarkThemeDemoState();
}

class _DarkThemeDemoState extends State<_DarkThemeDemo> {
  TableStylePreset _preset = TableStylePresets.prism;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          brightness: Brightness.dark,
          useMaterial3: true),
      child: Builder(
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(16),
          child: CustomDataTable(
            title: 'Dark Mode Demo',
            columns: _columns,
            data: _sampleData.take(10).toList(),
            perPage: 10,
            currentPage: 1,
            lastPage: 1,
            defaultStylePreset: _preset,
            enableStylePicker: true,
            onStylePresetChanged: (p) => setState(() => _preset = p),
            enableRowSelection: true,
            showActions: true,
            actions: const [TableActionView(), TableActionEdit()],
            rowFormattingRules: [
              RowFormattingRule(
                condition: (row, _) => row['status'] == 'Active',
                textColor: Colors.greenAccent,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
