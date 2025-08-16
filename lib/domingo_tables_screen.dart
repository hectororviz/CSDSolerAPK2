import 'package:flutter/material.dart';
import 'dart:math' as math;
//import 'package:google_fonts/google_fonts.dart';
import 'custom_header.dart';
import 'google_sheet_service.dart';

class DomingoTablesScreen extends StatefulWidget {
  const DomingoTablesScreen({super.key});

  @override
  State<DomingoTablesScreen> createState() => _DomingoTablesScreenState();
}

class _DomingoTablesScreenState extends State<DomingoTablesScreen> {
  final Map<String, String> tablesGid = {
    'General': '1374959447',
    '2010': '1995683667',
    '2011': '1112937965',
    '2012': '498160849',
    '2013': '1037222485',
    '2014': '1385282857',
    '2015': '1076055031',
    '2016': '2003934986',
    '2017': '885589143',
    '2018': '175024698',
    '2019': '226882980',
  };

  Map<String, List<List<dynamic>>> _tablesData = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadAllTables();
  }

  Future<void> _loadAllTables() async {
    setState(() {
      _loading = true;
    });

    try {
      for (var entry in tablesGid.entries) {
        final tableName = entry.key;
        final gid = entry.value;
        final data = await GoogleSheetService.fetchSheet(gid);
        setState(() {
          _tablesData[tableName] = data;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar tablas: ${e.toString()}')),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  Widget _buildTable(String tableName, List<List<dynamic>> data) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    // Cambiado a List<int> explícito
    final List<int> hiddenColumns = [];

    // Asegurando que centeredColumns sea List<int>
    final List<int> centeredColumns = List<int>.generate(data.first.length, (index) => index);

    final columnWidths = _calculateColumnWidths(data, hiddenColumns);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            tableName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA70000),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 4,
                headingRowColor: WidgetStateColor.resolveWith((_) => const Color(0xFFA70000)),
                dataRowMinHeight: 30,
                dataRowMaxHeight: 30,
                headingRowHeight: 40,
                columns: data.first
                    .asMap()
                    .entries
                    .where((entry) => !hiddenColumns.contains(entry.key))
                    .map((entry) {
                  final index = entry.key;
                  return DataColumn(
                    label: SizedBox(
                      width: columnWidths[index],
                      child: Center(
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                rows: _buildDynamicRows(data, hiddenColumns, centeredColumns, columnWidths),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Map<int, double> _calculateColumnWidths(List<List<dynamic>> data, List<int> hiddenColumns) {
    final Map<int, double> widths = {};
    final textStyle = const TextStyle(fontWeight: FontWeight.normal);
    final padding = 16.0;

    if (data.isEmpty) return widths;

    for (int col = 0; col < data.first.length; col++) {
      if (hiddenColumns.contains(col)) continue;

      double maxWidth = 0;
      final headerWidth = _textWidth(data.first[col].toString(), textStyle) + padding;
      maxWidth = math.max(maxWidth, headerWidth);

      for (int row = 1; row < data.length; row++) {
        if (col >= data[row].length) continue;
        final cellWidth = _textWidth(data[row][col].toString(), textStyle) + padding;
        maxWidth = math.max(maxWidth, cellWidth);
      }

      widths[col] = math.max(20, math.min(maxWidth, 200));
    }

    return widths;
  }

  double _textWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  List<DataRow> _buildDynamicRows(
      List<List<dynamic>> data,
      List<int> hiddenColumns,
      List<int> centeredColumns,
      Map<int, double> columnWidths) {
    return List.generate(data.length - 1, (rowIndex) {
      final row = data[rowIndex + 1];
      final isOdd = rowIndex.isOdd;

      return DataRow(
        color: WidgetStateColor.resolveWith(
              (_) => isOdd ? Colors.grey.shade200 : Colors.white,
        ),
        cells: row.asMap()
            .entries
            .where((entry) => !hiddenColumns.contains(entry.key))
            .map((entry) {
          final index = entry.key;
          final cellValue = entry.value.toString();
          final isCentered = centeredColumns.contains(index);
          final width = columnWidths[index] ?? 100;

          return DataCell(
            Container(
              color: _getCellColor(cellValue),
              padding: const EdgeInsets.all(4),
              width: width,
              child: SizedBox(
                width: width,
                child: isCentered
                    ? Center(child: _buildCellText(cellValue))
                    : _buildCellText(cellValue),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Color _getCellColor(String value) {
    if (value == 'P') return Colors.red.shade100;
    if (value == 'G') return Colors.green.shade100;
    if (value == 'E') return Colors.yellow.shade100;
    return Colors.transparent;
  }

  Widget _buildCellText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: ['P', 'G', 'E'].contains(text) ? FontWeight.bold : FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RedAppBar(
        title: 'Tablas F. Infantil - Domingos',
        context: context,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._tablesData.entries.map((entry) =>
                _buildTable(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }
}