import 'package:flutter/material.dart';
import '../data/materia.dart';
import '../data/db.dart';
import '../theme_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Materia> materias = [];
  int totalAprobadas = 0;

  @override
  void initState() {
    super.initState();
    _cargarMaterias();
  }

  // Cargar materias y contador
  Future<void> _cargarMaterias() async {
    final lista = await DatabaseHelper.getMaterias();
    final aprobadas = await DatabaseHelper.contadorAprobadas();

    lista.sort((a, b) {
      if (a.semestre != b.semestre) {
        return a.semestre.compareTo(b.semestre);
      }
      return a.nombre.compareTo(b.nombre);
    });

    setState(() {
      materias = lista;
      totalAprobadas = aprobadas;
    });
  }

  // Agrupar por semestre
  Map<int, List<Materia>> _agruparPorSemestre(List<Materia> materias) {
    final mapa = <int, List<Materia>>{};
    for (final m in materias) {
      mapa.putIfAbsent(m.semestre, () => []);
      mapa[m.semestre]!.add(m);
    }
    return mapa;
  }

  // Color según estado
  Color _colorEstado(String estado) {
    switch (estado) {
      case "Aprobada":
        return Colors.green.shade400;
      case "Examen pendiente":
        return Colors.orange.shade400;
      case "Habilitada":
        return Colors.blue.shade400;
      case "No habilitada":
      default:
        return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final materiasPorSemestre = _agruparPorSemestre(materias);

    return Scaffold(
      drawer: _buildDrawer(context),

      appBar: AppBar(
        title: const Text("Malla Curricular"),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),

      body: materias.isEmpty
          ? const Center(
              child: Text(
                "No hay materias registradas.\nToca el botón + para agregar una.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Contador de aprobadas
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Text(
                    "Materias aprobadas: $totalAprobadas",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),

                // Materias agrupadas por semestre
                ...materiasPorSemestre.entries.map((entrada) {
                  final semestre = entrada.key;
                  final lista = entrada.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Semestre $semestre",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ...lista.map((m) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/materia',
                                  arguments: m.id,
                                );
                                _cargarMaterias();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _colorEstado(m.estado),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        m.nombre,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add');
          _cargarMaterias();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Contenedor lateral
  Widget _buildDrawer(BuildContext context) {
    final isDark = ThemeController.themeMode.value == ThemeMode.dark;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Opciones",
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Modo oscuro
          SwitchListTile(
            title: const Text("Modo oscuro"),
            value: isDark,
            secondary: const Icon(Icons.dark_mode),
            onChanged: (v) {
              ThemeController.toggleTheme(v);
            },
          ),

          // Información
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Información de la app"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/info');
            },
          ),

          const Spacer(),

          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              "Malla Curricular v1.0",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
