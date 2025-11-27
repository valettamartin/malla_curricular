import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_materia_screen.dart';
import 'screens/materia_screen.dart';
import 'screens/info_screen.dart';
import 'theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar el tema guardado antes de iniciar la app
  await ThemeController.loadTheme();

  runApp(const MallaCurricularApp());
}

class MallaCurricularApp extends StatelessWidget {
  const MallaCurricularApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, modo, _) {
        return MaterialApp(
          title: "Malla Curricular",
          debugShowCheckedModeBanner: false,

          themeMode: modo,

          // Tema Claro
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.light,
          ),

          // Tema Oscuro
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.dark,
          ),

          // Home
          home: const HomeScreen(),

          // Rutas
          routes: {
            '/add': (context) => const AddMateriaScreen(),
            '/materia': (context) => const MateriaScreen(),
            '/info': (context) => const InfoScreen(),
          },
        );
      },
    );
  }
}
