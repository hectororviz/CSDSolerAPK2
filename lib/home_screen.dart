import 'package:flutter/material.dart';
import 'custom_header.dart';
import 'fixture_page.dart';
import 'femenino_tables_screen.dart';
import 'domingo_tables_screen.dart';
import 'sabado_tables_screen.dart';
import 'about_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'google_sheet_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<List<dynamic>> _data = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _loading = true;
    });

    try {
      final data = await GoogleSheetService.fetchSheet('970777381');
      setState(() {
        _data = data;
      });
    } catch (e) {
      // Manejo de errores
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 30, 16, 8),
            child: HomeHeader(),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildHomeContent(),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.instagram),
                  color: Colors.pink,
                  onPressed: () => _launchExternalUrl(
                      'https://www.instagram.com/csd_soler/'),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.facebook),
                  color: Colors.blue[700],
                  onPressed: () => _launchExternalUrl(
                      'https://www.facebook.com/profile.php?id=100078080747592'),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
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
            onFixturePressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FixturePage(hoja: 'femenino'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMatchCard(
            title: 'Fútbol Infantil - Sábados',
            headers: headers,
            data: sabadosData,
            backgroundColor: Colors.green[50]!,
            onFixturePressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FixturePage(hoja: 'sabado'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMatchCard(
            title: 'Fútbol Infantil - Domingos',
            headers: headers,
            data: domingosData,
            backgroundColor: Colors.blue[50]!,
            onFixturePressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FixturePage(hoja: 'domingo'),
              ),
            ),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // Distribución equitativa
              children: [
                // Botón Fixture
                ElevatedButton(
                  onPressed: onFixturePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFa70000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10), // Ajustado para mejor espacio
                  ),
                  child: const Text(
                      'Fixture', style: TextStyle(color: Colors.white)),
                ),

                // Botón Mapa (solo si hay coordenadas)
                if (data.length >= 6 && data[4]
                    .toString()
                    .isNotEmpty && data[5]
                    .toString()
                    .isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.location_on, size: 36),
                    color: Colors.blue[700],
                    onPressed: () =>
                        _openGoogleMaps(data[4].toString(), data[5].toString()),
                  )
                else
                  const SizedBox(width: 48), // Espacio reservado si no hay mapa

                // Botón Tabla
                ElevatedButton(
                  onPressed: title.contains('Femenino')
                      ? () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const FemeninoTablesScreen()),
                          )
                      : title.contains('Sábados')
                          ? () =>
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SabadoTablesScreen()),
                              )
                          : title.contains('Domingos')
                              ? () =>
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DomingoTablesScreen()),
                                  )
                              : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10), // Ajustado para mejor espacio
                  ),
                  child: const Text(
                      'Tabla', style: TextStyle(color: Colors.white)),
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

  Future<void> _openGoogleMaps(String lat, String long) async {
    // Reemplazar comas por puntos para el formato correcto
    final formattedLat = lat.replaceAll(',', '.');
    final formattedLong = long.replaceAll(',', '.');

    final url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$formattedLat,$formattedLong");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir Google Maps")),
      );
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}