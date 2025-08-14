import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

/// App principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSD Soler',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// SplashScreen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.1, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 0.9)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.05,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.05,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 20.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.2,
      ),
    ]).animate(_controller);

    _bounceAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -30.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -30.0, end: 15.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 0.15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 15.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.05,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.0),
        weight: 0.5,
      ),
    ]).animate(_controller);

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1600), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_scaleAnimation.value > 5.0) {
            return Container(color: Colors.black);
          }

          return Center(
            child: Transform.translate(
              offset: Offset(0, _bounceAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _controller.value < 0.8 ? 1.0 : 1.0 - (_controller.value - 0.8) * 5,
                  child: Image.asset(
                    'assets/escudo.png',
                    width: 200,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Pantalla principal
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, String> hojasGid = {
    'home': '970777381',
    'sabado': '1525215119',
    'domingo': '761656977',
    'femenino': '0',
    'datos': '1599606612',
  };

  List<List<dynamic>> _data = [];
  bool _loading = false;
  String hojaActual = 'home';

  @override
  void initState() {
    super.initState();
    fetchData(hojaActual);
  }

  Future<void> fetchData(String hoja) async {
    setState(() {
      _loading = true;
      hojaActual = hoja;
    });

    final gid = hojasGid[hoja] ?? hojasGid['home']!;
    final url = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTH5wcJur5ysIqKDdpaRP3M1YDAXVME5Ztuo0zffL27P9crNqlDlbNp3Kg-DSOE9XapLGl9qwUO1hrZ/pub?gid=$gid&output=csv';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final csvData = const CsvToListConverter().convert(response.body);
        setState(() {
          _data = csvData;
        });
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _data = [
          ['Error al cargar datos', e.toString()]
        ];
      });
    }

    setState(() {
      _loading = false;
    });
  }

  Widget buildTable() {
    if (_data.isEmpty) {
      return const Center(child: Text('No hay datos para mostrar'));
    }

    final hiddenColumns = [5];
    final centeredColumns = [0, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

    final columnWidths = _calculateColumnWidths(_data, hiddenColumns);

    return Scrollbar(
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
            columns: _data.first
                .asMap()
                .entries
                .where((entry) => !hiddenColumns.contains(entry.key))
                .map((entry) {
              final index = entry.key;
              //final isCentered = centeredColumns.contains(index);
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
            rows: _buildDynamicRows(_data, hiddenColumns, centeredColumns, columnWidths),
          ),
        ),
      ),
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
        cells: row.asMap().entries.where((entry) => !hiddenColumns.contains(entry.key)).map((entry) {
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
    return PopScope(
      canPop: hojaActual == 'home',
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return; // Ya se hizo pop, no hacer nada

        if (hojaActual != 'home') {
          fetchData("home");
          return; // No hacemos pop automático
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Salir de la aplicación'),
            content: const Text('¿Estás seguro que quieres salir?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Salir'),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Padding(
            padding: const EdgeInsets.fromLTRB(8, 30, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _getTituloPagina(hojaActual),  // Ahora devuelve un Widget en lugar de String
                Image.asset(
                  'assets/escudo.png',
                  height: 80,
                ),
              ],
            ),
          ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.all(8.0),
                child: hojaActual == 'home'
                    ? _buildHomeContent()
                    : Column(
                  children: [
                    Expanded(child: buildTable()),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () => fetchData('home'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA70000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Volver', style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Acción para ver más datos
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Fixture', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_data.isEmpty || _data.length < 2) {
      return const Center(child: Text('No hay datos de próximos partidos'));
    }

    final headers = _data.isNotEmpty
        ? _data[0].sublist(0, 4)
        : ['Dia', 'Fecha', 'Localia', 'Rival'];

    final femeninoData = _data.length > 1 ? _data[1] : [];
    final sabadosData = _data.length > 2 ? _data[2] : [];
    final domingosData = _data.length > 3 ? _data[3] : [];

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildMatchCard(
            title: 'Fútbol Femenino',
            headers: headers,
            data: femeninoData,
            backgroundColor: Colors.pink[50]!,
            onFixturePressed: () => fetchData('femenino'),
          ),
          const SizedBox(height: 16),
          _buildMatchCard(
            title: 'Fútbol Infantil - Sábados',
            headers: headers,
            data: sabadosData,
            backgroundColor: Colors.green[50]!,
            onFixturePressed: () => fetchData('sabado'),
          ),
          const SizedBox(height: 16),
          _buildMatchCard(
            title: 'Fútbol Infantil - Domingos',
            headers: headers,
            data: domingosData,
            backgroundColor: Colors.blue[50]!,
            onFixturePressed: () => fetchData('domingo'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMatchCard({
    required String title,
    required List<dynamic> headers,
    required List<dynamic> data,
    Color backgroundColor = Colors.white,
    required VoidCallback onFixturePressed,
  }) {
    return Card(
      elevation: 4,
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA70000),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Próximo partido',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderCell(headers[0].toString()),
              _buildHeaderCell(headers[1].toString()),
              _buildHeaderCell(headers[2].toString()),
              _buildHeaderCell(headers[3].toString()),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          if (data.isNotEmpty && data.length >= 4)
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDataCell(data[0].toString()),
        _buildDataCell(data[1].toString()),
        _buildDataCell(data[2].toString()),
        _buildDataCell(data[3].toString()),
      ],
    )
  else
    const Text('No hay datos disponibles',
      style: TextStyle(color: Colors.grey),
      textAlign: TextAlign.center,
    ),
  const SizedBox(height: 16),
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      ElevatedButton(
        onPressed: onFixturePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFa70000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 12),
        ),
        child: const Text('Fixture', style: TextStyle(color: Colors.white)),
      ),
      ElevatedButton(
        onPressed: () {
          // A implementar
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 12),
          ),
          child: const Text('Tabla', style: TextStyle(color: Colors.white)),
      ),
    ],
),
    ],
    ),
    ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: text.isEmpty ? Colors.grey : Colors.black,
          fontStyle: text.isEmpty ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  Widget _getTituloPagina(String hojaActual) {
    switch (hojaActual) {
      case 'home':
        return _buildTituloClub(
          separacion: 0.0, // Ajusta este valor a tu gusto (en píxeles)
          colorSuperior: Colors.grey[700]!,
          colorInferior: Colors.black,
          sombra: [ // Personalización de sombra
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        );
      case 'sabado':
        return const Text('Futbol Infantil - Sabados');
      case 'domingo':
        return const Text('Futbol Infantil - Domingos');
      case 'femenino':
        return const Text('Futbol Femenino');
      case 'datos':
        return const Text('Proximamente - Estadisticas');
      default:
        return const Text('Club Deportivo');
    }
  }
}
Widget _buildTituloClub({
  double separacion = 4.0, // Ahora puede ser negativo
  Color colorSuperior = const Color(0xFF555555),
  Color colorInferior = const Color(0xFFA70000),
  List<Shadow> sombra = const [],
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Club Social y Deportivo',
        style: TextStyle(
          fontSize: 15, // Reducido ligeramente
          fontWeight: FontWeight.w400,
          color: colorSuperior,
          letterSpacing: 3.0,
          height: 0.8, // Altura de línea compacta
        ),
      ),
      SizedBox(height: separacion), // Acepta valores como -2, -4, etc.
      Text(
        'SOLER',
        style: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          color: colorInferior,
          height: 0.8, // Compacta el espacio vertical del texto
          shadows: sombra,
          letterSpacing: 1.0
          ,
        ),
      ),
    ],
  );
}