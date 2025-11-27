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
  final TextEditingController _minAprobadasController = TextEditingController();

  int _semestreSeleccionado = 1;
  String _estadoSeleccionado = "Habilitada";

  List<Materia> todas = [];
  List<int> previasCursar = [];
  List<int> previasExamen = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_cargado) return;
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
      _minAprobadasController.text = m.minAprobadas.toString();

      _semestreSeleccionado = m.semestre;
      _estadoSeleccionado = m.estado;

      previasCursar = List.from(m.previasCursar);
      previasExamen = List.from(m.previasExamen);
    });
  }

  /// Reglas de estado
  Future<void> _recalcularEstado() async {
    if (materia == null) return;

    final minAprobadas = int.tryParse(_minAprobadasController.text) ?? 0;
    final totalAprobadas = await DatabaseHelper.contadorAprobadas();

    // Min aprobadas
    if (totalAprobadas < minAprobadas) {
      _estadoSeleccionado = "No habilitada";
      setState(() {});
      return;
    }

    // Previas
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
          id: 0,
          nombre: "INVALIDA",
          semestre: 0,
          previasCursar: [],
          previasExamen: [],
          estado: "No habilitada",
          descripcion: "",
          minAprobadas: 0,
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
      minAprobadas: int.tryParse(_minAprobadasController.text) ?? 0,
    );

    await DatabaseHelper.updateMateria(actualizado);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _selectorPrevias({
    required String titulo,
    required List<int> lista,
    required Function(List<int>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(
          titulo,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: todas.map((m) {
              final check = lista.contains(m.id);
              return CheckboxListTile(
                title: Text("${m.nombre} (ID ${m.id})"),
                value: check,
                onChanged: (v) {
                  final nueva = [...lista];
                  if (v == true) {
                    nueva.add(m.id!);
                  } else {
                    nueva.remove(m.id);
                  }
                  onChanged(nueva);
                  _recalcularEstado();
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
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
              initialValue: _semestreSeleccionado,
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
              onChanged: (v) => setState(() => _semestreSeleccionado = v!),
            ),
            const SizedBox(height: 20),

            // minAprobadas
            TextFormField(
              controller: _minAprobadasController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Mínimo de materias aprobadas requeridas",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _recalcularEstado(),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: _estadoSeleccionado,
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

            // Previas cursar
            _selectorPrevias(
              titulo: "Previas para cursar",
              lista: previasCursar,
              onChanged: (v) => setState(() => previasCursar = v),
            ),

            // Previas examen
            _selectorPrevias(
              titulo: "Previas para examen",
              lista: previasExamen,
              onChanged: (v) => setState(() => previasExamen = v),
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
