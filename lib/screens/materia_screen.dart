import 'package:flutter/material.dart';
import '../data/materia.dart';
import '../data/db.dart';

class MateriaScreen extends StatefulWidget {
  const MateriaScreen({super.key});

  @override
  State<MateriaScreen> createState() => _MateriaScreenState();
}

class _MateriaScreenState extends State<MateriaScreen> {
  bool _cargado = false;

  Materia? materia;

  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();

  int _semestreSeleccionado = 1;
  String _estadoSeleccionado = "Habilitada";

  List<Materia> todas = [];
  List<int> previasCursar = [];
  List<int> previasExamen = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_cargado) return;        // 👈 EVITA QUE SE EJECUTE 2 VECES
    _cargado = true;

    final int id = ModalRoute.of(context)!.settings.arguments as int;
    _cargarMateria(id);
  }

  Future<void> _cargarMateria(int id) async {
    final m = await DatabaseHelper.getMateriaById(id);
    final lista = await DatabaseHelper.getMaterias();

    setState(() {
      materia = m;
      todas = lista.where((e) => e.id != id).toList();

      _nombreController.text = m!.nombre;
      _descripcionController.text = m.descripcion;

      _semestreSeleccionado = m.semestre;
      _estadoSeleccionado = m.estado;

      previasCursar = List.from(m.previasCursar);
      previasExamen = List.from(m.previasExamen);
    });
  }

  /// Reglas de estado automático
  void _recalcularEstado() {
    if (previasCursar.isEmpty) {
      if (_estadoSeleccionado == "No habilitada") {
        _estadoSeleccionado = "Habilitada";
      }
      setState(() {});
      return;
    }

    bool todasCumplen = previasCursar.every((idPrev) {
      final previa = todas.firstWhere(
        (m) => m.id == idPrev,
        orElse: () => Materia(
          id: -1,
          nombre: "INVALIDA",
          semestre: 0,
          previasCursar: [],
          previasExamen: [],
          estado: "No habilitada",
          descripcion: "",
        ),
      );
      return previa.estado == "Aprobada" || previa.estado == "Examen pendiente";
    });

    if (!todasCumplen) {
      _estadoSeleccionado = "No habilitada";
    } else {
      if (_estadoSeleccionado == "No habilitada") {
        _estadoSeleccionado = "Habilitada";
      }
    }

    setState(() {});
  }

  Future<void> _guardarCambios() async {
    if (materia == null) return;

    final actualizado = Materia(
      id: materia!.id,
      nombre: _nombreController.text.trim(),
      semestre: _semestreSeleccionado,
      previasCursar: previasCursar,
      previasExamen: previasExamen,
      estado: _estadoSeleccionado,
      descripcion: _descripcionController.text.trim(),
    );

    await DatabaseHelper.updateMateria(actualizado);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (materia == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(materia!.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await DatabaseHelper.deleteMateria(materia!.id!);
              if (!mounted) return;
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("ID: ${materia!.id}", style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 15),

            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<int>(
              value: _semestreSeleccionado,
              decoration: const InputDecoration(
                labelText: "Semestre",
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                12,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text("Semestre ${i + 1}"),
                ),
              ),
              onChanged: (v) {
                setState(() => _semestreSeleccionado = v!);
              },
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _estadoSeleccionado,
              decoration: const InputDecoration(
                labelText: "Estado",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "No habilitada", child: Text("No habilitada")),
                DropdownMenuItem(value: "Habilitada", child: Text("Habilitada")),
                DropdownMenuItem(value: "Examen pendiente", child: Text("Examen pendiente")),
                DropdownMenuItem(value: "Aprobada", child: Text("Aprobada")),
              ],
              onChanged: (v) {
                _estadoSeleccionado = v!;
                _recalcularEstado();
              },
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarCambios,
                child: const Text("Guardar cambios"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
