import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_header.dart';
import 'dart:math' as math;
import 'google_sheet_service.dart';

class FixturePage extends StatefulWidget {
  final String hoja;

  const FixturePage({super.key, required this.hoja});

  @override
  State<FixturePage> createState() => _FixturePageState();
}

class _FixturePageState extends State<FixturePage> {
  List<List<dynamic>> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final gid = _getGidForHoja(widget.hoja);
      final data = await GoogleSheetService.fetchSheet(gid);
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  String _getGidForHoja(String hoja) {
    switch (hoja) {
      case 'sabado':
        return '1525215119';
      case 'domingo':
        return '761656977';
      case 'femenino':
        return '0';
      default:
        return '970777381';
    }
  }

  Map<int, double> _calculateColumnWidths() {
    final Map<int, double> widths = {};
    final textStyle = GoogleFonts.roboto(fontWeight: FontWeight.normal);
    final padding = 16.0;

    if (_data.isEmpty) return widths;

    for (int col = 0; col < _data.first.length; col++) {
      double maxWidth = 0;
      final headerWidth = _textWidth(_data.first[col].toString(), textStyle) + padding;
      maxWidth = math.max(maxWidth, headerWidth);

      for (int row = 1; row < _data.length; row++) {
        if (col >= _data[row].length) continue;
        final cellWidth = _textWidth(_data[row][col].toString(), textStyle) + padding;
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

  Color _getCellColor(String value) {
    if (value == 'P') return Colors.red.shade100;
    if (value == 'G') return Colors.green.shade100;
    if (value == 'E') return Colors.yellow.shade100;
    return Colors.transparent;
  }

  Widget _buildTable() {
    if (_data.isEmpty) return const Center(child: Text('No hay datos disponibles'));

    final columnWidths = _calculateColumnWidths();
    final centeredColumns = List<int>.generate(_data.first.length, (index) => index);

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 4,
            headingRowColor: MaterialStateColor.resolveWith((_) => const Color(0xFFA70000)),
            dataRowMinHeight: 30,
            dataRowMaxHeight: 30,
            headingRowHeight: 40,
              columns: _data.first.asMap().entries.where((entry) => entry.key != 5).map((entry) {
                final index = entry.key;
                return DataColumn(
                  label: SizedBox(
                    width: columnWidths[index],
                    child: Center(
                      child: Text(
                        entry.value.toString(),
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }).toList(),
            rows: List.generate(_data.length - 1, (rowIndex) {
              final row = _data[rowIndex + 1];
              final isOdd = rowIndex.isOdd;

              return DataRow(
                color: MaterialStateColor.resolveWith(
                      (_) => isOdd ? Colors.grey.shade200 : Colors.white,
                ),
                cells: row.asMap().entries.where((entry) => entry.key != 5).map((entry) {
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
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCellText(String text) {
    return Text(
      text,
      style: GoogleFonts.roboto(
        fontWeight: ['P', 'G', 'E'].contains(text) ? FontWeight.bold : FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RedAppBar(
        title: widget.hoja == 'sabado'
            ? 'Sábados'
            : widget.hoja == 'domingo'
            ? 'Domingos'
            : 'Femenino',
        context: context,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildTable(),
      ),
    );
  }
}