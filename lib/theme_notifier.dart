import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString('themeMode');
    if (modeName != null) {
      value = ThemeMode.values.firstWhere(
        (m) => m.name == modeName,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }
}

final ThemeNotifier themeNotifier = ThemeNotifier();
