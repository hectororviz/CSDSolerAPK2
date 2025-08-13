import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Deportes',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final partidos = [
      {'rival': 'Equipo A', 'fecha': '2025-08-20'},
      {'rival': 'Equipo B', 'fecha': '2025-08-27'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Image.network('https://tu-url-del-logo.png', height: 100),
          const SizedBox(height: 20),
          const Text('Bienvenidos al Club!'),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: partidos.length,
              itemBuilder: (context, index) {
                final partido = partidos[index];
                return Card(
                  child: ListTile(
                    title: Text('vs ${partido['rival']}'),
                    subtitle: Text('Fecha: ${partido['fecha']}'),
                    onTap: () {
                      // acá podés navegar a detalles si querés
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menú')),
            ListTile(
              title: const Text('Fútbol Femenino'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LigaPage('Fútbol Femenino')),
              ),
            ),
            ListTile(
              title: const Text('Fútbol Inf. Sábados'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LigaPage('Fútbol Inf. Sábados')),
              ),
            ),
            ListTile(
              title: const Text('Fútbol Inf. Domingos'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LigaPage('Fútbol Inf. Domingos')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LigaPage extends StatelessWidget {
  final String liga;
  const LigaPage(this.liga, {super.key});

  @override
  Widget build(BuildContext context) {
    // Ejemplo de datos estáticos, luego los podés cargar desde Google Sheets
    final resultados = [
      {'equipo1': 'Club', 'equipo2': 'Rival', 'resultado': '2-1', 'fecha': '2025-07-01'},
      {'equipo1': 'Club', 'equipo2': 'Rival', 'resultado': '1-3', 'fecha': '2025-07-08'},
    ];

    return Scaffold(
      appBar: AppBar(title: Text(liga)),
      body: ListView.builder(
        itemCount: resultados.length,
        itemBuilder: (context, index) {
          final partido = resultados[index];
          return ListTile(
            title: Text('${partido['equipo1']} vs ${partido['equipo2']}'),
            subtitle: Text('Resultado: ${partido['resultado']} - Fecha: ${partido['fecha']}'),
          );
        },
      ),
    );
  }
}
