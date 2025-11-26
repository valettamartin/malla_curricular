import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_materia_screen.dart';
import 'screens/materia_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Malla Curricular',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // Pantalla inicial
      home: const HomeScreen(),

      // Rutas
      routes: {
      },
    );
  }
}
