import 'package:flutter/material.dart';
import 'custom_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const double escudoScale = 0.5;
  static const double paragraphSpacing = 16.0;
  static const double footerSpacing = 32.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RedAppBar(title: 'Acerca de', context: context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: escudoScale,
                child: Image.asset('assets/escudo.png'),
              ),
              const SizedBox(height: 0),
              const Text(
                'Club Social y Deportivo Soler de Ing. Pablo Nogues A.C.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: paragraphSpacing),
              const Text(
                'En este pequeño club, que forman parte más de 140 chicos y chicas de entre 6 y 16 años que disfrutan del fútbol infantil y femenino, crecemos paso a paso, con el sueño de ofrecer un lugar donde cada uno aprenda, comparta y se sienta parte de una gran familia que late al ritmo del fútbol..',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: footerSpacing),
              const Text(
                'hector.h.orviz@gmail.com - 2025',
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
