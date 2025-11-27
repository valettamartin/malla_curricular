import 'package:flutter/material.dart';
import '../data/materia.dart';
import '../data/db.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Materia> materias = [];

  @override
  void initState() {
    super.initState();
    _cargarMaterias();
  }

  // Cargar materias desde la base
  Future<void> _cargarMaterias() async {
    final lista = await DatabaseHelper.getMaterias();

    // Ordenamos por semestre y luego por nombre
    lista.sort((a, b) {
      if (a.semestre != b.semestre) {
        return a.semestre.compareTo(b.semestre);
      }
      return a.nombre.compareTo(b.nombre);
    });

    setState(() {
      materias = lista;
    });
  }

  // Agrupa todas las materias por semestre
  Map<int, List<Materia>> _agruparPorSemestre(List<Materia> materias) {
    final mapa = <int, List<Materia>>{};
    for (final m in materias) {
      mapa.putIfAbsent(m.semestre, () => []);
      mapa[m.semestre]!.add(m);
    }
    return mapa;
  }

  // Define color según estado
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
      appBar: AppBar(
        title: const Text("Malla Curricular"),
        centerTitle: true,
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
              children: materiasPorSemestre.entries.map((entrada) {
                final semestre = entrada.key;
                final lista = entrada.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
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
                              // ⛔ ANTES: arguments: m
                              // ✅ AHORA: enviamos solo el ID
                              await Navigator.pushNamed(
                                context,
                                '/materia',
                                arguments: m.id, 
                              );

                              _cargarMaterias();   // refrescar al volver
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
                                  const Icon(Icons.arrow_forward_ios,
                                      color: Colors.white, size: 18),
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
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add');
          _cargarMaterias(); // refrescar
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
