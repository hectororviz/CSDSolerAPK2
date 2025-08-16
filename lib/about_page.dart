import 'package:flutter/material.dart';
import 'custom_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const double escudoScale = 1.0;
  static const double paragraphSpacing = 16.0;
  static const double footerSpacing = 24.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RedAppBar(title: 'Acerca de', context: context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: escudoScale,
                child: Image.asset('assets/escudo.png'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Club Social y Deportivo Soler de Ing. Pablo Nogues A.C.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: paragraphSpacing),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: footerSpacing),
              const Text(
                'Nombre del desarrollador\ncorreo@example.com\n2024',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
