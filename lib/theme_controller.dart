import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  // Valor inicial (será reemplazado por lo guardado en memoria)
  static final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

  // Key para guardar el tema
  static const String _keyTheme = "theme_mode";

  /// Inicializa el controlador cargando el tema guardado
  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_keyTheme) ?? false;

    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Cambia de tema y lo guarda en memoria
  static Future<void> toggleTheme(bool dark) async {
    final prefs = await SharedPreferences.getInstance();

    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;

    // Guardamos
    await prefs.setBool(_keyTheme, dark);
  }
}
