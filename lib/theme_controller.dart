import 'package:flutter/material.dart';

class ThemeController {
  // Modo claro por defecto
  static final themeMode = ValueNotifier(ThemeMode.light);

  static void toggleTheme(bool dark) {
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }
}
