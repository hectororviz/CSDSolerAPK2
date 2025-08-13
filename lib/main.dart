import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

// 1. Añade este nuevo widget ANTES de MyApp
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200), // Duración total
      vsync: this,
    );

    // Configuración de la animación en tres fases
    _scaleAnimation = TweenSequence([
      // Fase 1: Aparece pequeño y crece rápidamente (0ms - 400ms)
      TweenSequenceItem(
        tween: Tween(begin: 0.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 0.33,
      ),
      // Fase 2: Pausa (400ms - 900ms)
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 0.42,
      ),
      // Fase 3: Explosión final (900ms - 1200ms)
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 15.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.25,
      ),
    ]).animate(_controller);

    _controller.forward();

    // Navegar al HomeScreen después de 1300ms (un poco después de la animación)
    Future.delayed(const Duration(milliseconds: 1300), () {
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
          // Cuando la escala sea muy grande, mostramos solo negro
          if (_scaleAnimation.value > 5.0) {
            return Container(color: Colors.black);
          }

          return Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Image.asset(
                'assets/escudo.png',
                width: 200,
                // Opcional: Efecto de desvanecimiento en la última fase
                opacity: AlwaysStoppedAnimation(
                    _controller.value < 0.8 ? 1.0 : 1.0 - (_controller.value - 0.8) * 5
                ),
              ),
            ),
          );
        },
      ),
    );
  }
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

/// Pantalla principal
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mapeo de nombres de hojas a su GID
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

    // 1. Configuraciones personalizables
    final hiddenColumns = [5]; // Índices de columnas a ocultar
    final centeredColumns = [0, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]; // Índices de columnas a centrar

    // 2. Calcular anchos dinámicos
    final columnWidths = _calculateColumnWidths(_data, hiddenColumns);

    // 3. Widget principal con doble scroll
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 4, // Reducido para mejor ajuste
            headingRowColor: WidgetStateColor.resolveWith((_) => Color(0xFFA70000)),
            dataRowMinHeight: 30, // Altura personalizada (en píxeles)
            dataRowMaxHeight: 30, // Altura personalizada (en píxeles)
            headingRowHeight: 40, // Altura del encabezado
            columns: _data.first
                .asMap()
                .entries
                .where((entry) => !hiddenColumns.contains(entry.key))
                .map((entry) {
              final index = entry.key;
              final isCentered = centeredColumns.contains(index);
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
            })
                .toList(),
            rows: _buildDynamicRows(_data, hiddenColumns, centeredColumns, columnWidths),
          ),
        ),
      ),
    );
  }

  Map<int, double> _calculateColumnWidths(List<List<dynamic>> data, List<int> hiddenColumns) {
    final Map<int, double> widths = {};
    final textStyle = const TextStyle(fontWeight: FontWeight.normal);
    final padding = 16.0; // Padding horizontal adicional

    if (data.isEmpty) return widths;

    // Calcular el ancho máximo para cada columna
    for (int col = 0; col < data.first.length; col++) {
      if (hiddenColumns.contains(col)) continue;

      double maxWidth = 0;

      // Considerar el encabezado
      final headerWidth = _textWidth(data.first[col].toString(), textStyle) + padding;
      maxWidth = math.max(maxWidth, headerWidth);

      // Considerar todas las celdas de la columna
      for (int row = 1; row < data.length; row++) {
        if (col >= data[row].length) continue;
        final cellWidth = _textWidth(data[row][col].toString(), textStyle) + padding;
        maxWidth = math.max(maxWidth, cellWidth);
      }

      // Establecer un mínimo y máximo razonable
      widths[col] = math.max(20, math.min(maxWidth, 200)); // Entre 40 y 200 pixeles
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
      Map<int, double> columnWidths
      ) {
    return List.generate(data.length - 1, (rowIndex) {
      final row = data[rowIndex + 1];
      final isOdd = rowIndex.isOdd;

      return DataRow(
        color: WidgetStateColor.resolveWith(
              (_) => isOdd ? Colors.grey.shade200 : Colors.white,
        ),
        cells: row
            .asMap()
            .entries
            .where((entry) => !hiddenColumns.contains(entry.key))
            .map((entry) {
          final index = entry.key;
          final cellValue = entry.value.toString();
          final isCentered = centeredColumns.contains(index);
          final width = columnWidths[index] ?? 100; // Default 100 si hay algún error

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
        })
            .toList(),
      );
    });
  }

// Helper para colores de celda
  Color _getCellColor(String value) {
    if (value == 'P') return Colors.red.shade100;
    if (value == 'G') return Colors.green.shade100;
    if (value == 'E') return Colors.yellow.shade100;
    return Colors.transparent;
  }

// Helper para texto de celda
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 30, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getTituloPagina(hojaActual),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
                  ? _buildHomeContent()  // Nuevo método para contenido home
                  : buildTable(),         // Tabla para las otras hojas
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: ['home', 'sabado', 'domingo', 'femenino', 'datos']
            .indexOf(hojaActual),
        onTap: (index) {
          final hoja = ['home', 'sabado', 'domingo', 'femenino', 'datos'][index];
          fetchData(hoja);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Sábado'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Domingo'),
          BottomNavigationBarItem(icon: Icon(Icons.female), label: 'Femenino'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Datos'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    // Verificar si hay datos disponibles
    if (_data.isEmpty || _data.length < 2) {
      return const Center(child: Text('No hay datos de próximos partidos'));
    }

    // Obtener los encabezados de las primeras 4 columnas
    final headers = _data.isNotEmpty
        ? _data[0].sublist(0, 4)
        : ['Dia', 'Fecha', 'Localia', 'Rival'];

    // Obtener las filas de datos (asumiendo que cada categoría tiene su fila)
    final femeninoData = _data.length > 1 ? _data[1] : [];
    final sabadosData = _data.length > 2 ? _data[2] : [];
    final domingosData = _data.length > 3 ? _data[3] : [];

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Próximos Partidos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Tarjeta Fútbol Femenino - Color rosa claro
          _buildMatchCard(
            title: 'Fútbol Femenino',
            headers: headers,
            data: femeninoData,
            backgroundColor: Colors.pink[50]!,
          ),

          const SizedBox(height: 16),

          // Tarjeta Fútbol Infantil - Sábados - Color azul claro
          _buildMatchCard(
            title: 'Fútbol Infantil - Sábados',
            headers: headers,
            data: sabadosData,
            backgroundColor: Colors.green[50]!,
          ),

          const SizedBox(height: 16),

          // Tarjeta Fútbol Infantil - Domingos - Color verde claro
          _buildMatchCard(
            title: 'Fútbol Infantil - Domingos',
            headers: headers,
            data: domingosData,
            backgroundColor: Colors.blue[50]!,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
// Widget auxiliar para construir las tarjetas de partido
  Widget _buildMatchCard({required String title, required List<dynamic> headers, required List<dynamic> data, Color backgroundColor = Colors.white, }) {
    return Card(
      elevation: 4,
      color: backgroundColor, // Aquí aplicamos el color de fondo
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
                color: Color(0xFFA70000), // Color rojo similar al del header
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Encabezados
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

            // Datos
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
          ],
        ),
      ),
    );
  }

// Widget auxiliar para celdas de encabezado
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

// Widget auxiliar para celdas de datos
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

  String _getTituloPagina(String hojaActual) {
    switch (hojaActual) {
      case 'home':
        return 'Club Social y Deportivo Soler';
      case 'sabado':
        return 'Futbol Infantil - Sabados';
      case 'domingo':
        return 'Futbol Infantil - Domingos';
      case 'femenino':
        return 'Futbol Femenino';
      case 'datos':
        return 'Proximamente - Estadisticas';
      default:
        return 'Club Deportivo';
    }
  }
}