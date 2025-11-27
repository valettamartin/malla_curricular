import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_materia_screen.dart';
import 'screens/materia_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MallaCurricularApp());
}

class MallaCurricularApp extends StatelessWidget {
  const MallaCurricularApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Malla Curricular",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),

      // Pantalla inicial
      home: const HomeScreen(),

      // Rutas nombradas
      routes: {
        '/add': (context) => const AddMateriaScreen(),
        '/materia': (context) => const MateriaScreen(),
      },
    );
  }
}
