import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';
import 'theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeNotifier.loadThemeMode();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'CSD Soler',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: GoogleFonts.robotoTextTheme(
              ThemeData.light().textTheme,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme: GoogleFonts.robotoTextTheme(
              ThemeData.dark().textTheme,
            ),
          ),
          themeMode: mode,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}