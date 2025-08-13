import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

void main() {
  runApp(const MyApp());
}

/// App principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabla Google Sheets',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
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
  // 🔹 Mapeo de nombres de hojas a su GID
  final Map<String, String> hojasGid = {
    'home': '970777381',
    'sabado': '1525215119',
    'domingo': '761656977',
    'femenino': '0',
    'datos': '1599606612',
  };

  List<List<dynamic>> _data = []; // Aquí guardamos los datos de la hoja
  bool _loading = false; // Indicador de carga
  String hojaActual = 'home'; // Hoja que se está mostrando

  @override
  void initState() {
    super.initState();
    fetchData(hojaActual); // Cargar "home" al inicio
  }

  /// 🔹 Descarga y parsea la hoja de Google Sheets en formato CSV
  Future<void> fetchData(String hoja) async {
    setState(() {
      _loading = true;
      hojaActual = hoja;
    });

    final gid = hojasGid[hoja] ?? hojasGid['home']!;
    final url =
        'https://docs.google.com/spreadsheets/d/e/2PACX-1vTH5wcJur5ysIqKDdpaRP3M1YDAXVME5Ztuo0zffL27P9crNqlDlbNp3Kg-DSOE9XapLGl9qwUO1hrZ/pub?gid=$gid&output=csv';

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

  /// 🔹 Widget que muestra la tabla con estilo zebra
  Widget buildTable() {
    if (_data.isEmpty) {
      return const Center(child: Text('No hay datos para mostrar'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor:
        MaterialStateColor.resolveWith((_) => Colors.blue.shade100),
        columns: _data.first
            .map((header) => DataColumn(
          label: Text(
            header.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ))
            .toList(),
        rows: List.generate(
          _data.length - 1,
              (index) {
            final row = _data[index + 1];
            final isOdd = index.isOdd; // Zebra effect

            return DataRow(
              color: MaterialStateColor.resolveWith(
                    (_) => isOdd ? Colors.grey.shade200 : Colors.white,
              ),
              cells: row
                  .map((cell) => DataCell(Text(cell.toString())))
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hoja: $hojaActual'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 Escudo del club en la parte superior
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/escudo.png',
              height: 80,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildTable(),
            ),
          ),
        ],
      ),
      // 🔹 Barra de botones para cambiar de hoja
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: [
          'home',
          'sabado',
          'domingo',
          'femenino',
          'datos'
        ].indexOf(hojaActual),
        onTap: (index) {
          final hoja = ['home', 'sabado', 'domingo', 'femenino', 'datos'][index];
          fetchData(hoja);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Sábado'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Domingo'),
          BottomNavigationBarItem(icon: Icon(Icons.female), label: 'Femenino'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Datos'),
        ],
      ),
    );
  }
}
