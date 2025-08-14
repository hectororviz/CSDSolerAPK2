import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final BuildContext context;

  const RedAppBar({
    super.key,
    required this.title,
    required this.context,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFFA70000),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Club Social y Deportivo',
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF555555),
                letterSpacing: 3.0,
                height: 0.8,
              ),
            ),
            const SizedBox(height: 0),
            Text(
              'SOLER',
              style: GoogleFonts.roboto(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFA70000),
                height: 0.8,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        Image.asset(
          'assets/escudo.png',
          height: 80,
        ),
      ],
    );
  }
}