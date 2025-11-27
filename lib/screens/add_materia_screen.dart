import 'package:flutter/material.dart';
import '../data/materia.dart';
import '../data/db.dart';

class AddMateriaScreen extends StatefulWidget {
  const AddMateriaScreen({super.key});

  @override
  State<AddMateriaScreen> createState() => _AddMateriaScreenState();
}

class _AddMateriaScreenState extends State<AddMateriaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  int _semestreSeleccionado = 1;

  String _estadoSeleccionado = "Habilitada";

  // Previas seleccionadas
  List<int> _previasCursar = [];
  List<int> _previasExamen = [];

  // Lista de materias ya creadas (para seleccionar previas)
  List<Materia> todasLasMaterias = [];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMateriasExistentes();
  }

  Future<void> _cargarMateriasExistentes() async {
    final lista = await DatabaseHelper.getMaterias();
    setState(() {
      todasLasMaterias = lista;
      cargando = false;
    });
  }

  // Ajusta el estado automáticamente según previas
  void _recalcularEstado() {
    // Sin previas: estado nunca puede ser No habilitada
    if (_previasCursar.isEmpty) {
      if (_estadoSeleccionado == "No habilitada") {
        _estadoSeleccionado = "Habilitada";
      }
      setState(() {});
      return;
    }

    bool todasCumplen = true;

    for (final id in _previasCursar) {
      final previa = todasLasMaterias.firstWhere(
        (m) => m.id == id,
        orElse: () => Materia(
          id: 0,
          nombre: "INVALIDA",
          semestre: 0,
          previasCursar: [],
          previasExamen: [],
          estado: "No habilitada",
          descripcion: "",
        ),
      );

      if (previa.estado != "Aprobada" && previa.estado != "Examen pendiente") {
        todasCumplen = false;
        break;
      }
    }

    if (!todasCumplen) {
      _estadoSeleccionado = "No habilitada";
      setState(() {});
      return;
    }

    if (_estadoSeleccionado == "No habilitada") {
      _estadoSeleccionado = "Habilitada";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar materia"),
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ID
                    TextFormField(
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "ID",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Ingrese un ID";
                        }
                        final n = int.tryParse(value);
                        if (n == null || n <= 0) {
                          return "El ID debe ser un número positivo";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: "Nombre de la materia",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Ingrese un nombre" : null,
                    ),
                    const SizedBox(height: 16),

                    // Semestre
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: "Semestre",
                        border: OutlineInputBorder(),
                      ),
                      value: _semestreSeleccionado,
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text("Semestre ${i + 1}"),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _semestreSeleccionado = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Estado
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Estado inicial",
                      ),
                      value: _estadoSeleccionado,
                      items: const [
                        DropdownMenuItem(value: "No habilitada", child: Text("No habilitada")),
                        DropdownMenuItem(value: "Habilitada", child: Text("Habilitada")),
                        DropdownMenuItem(value: "Examen pendiente", child: Text("Examen pendiente")),
                        DropdownMenuItem(value: "Aprobada", child: Text("Aprobada")),
                      ],
                      onChanged: (value) {
                        _estadoSeleccionado = value!;
                        _recalcularEstado();
                      },
                    ),

                    const SizedBox(height: 24),

                    // PREVIAS CURSAR
                    _selectorPrevias(
                      titulo: "Previas para cursar",
                      seleccionados: _previasCursar,
                      onChanged: (value) {
                        setState(() => _previasCursar = value);
                        _recalcularEstado();
                      },
                    ),

                    const SizedBox(height: 24),

                    // PREVIAS EXAMEN
                    _selectorPrevias(
                      titulo: "Previas para examen",
                      seleccionados: _previasExamen,
                      onChanged: (value) {
                        setState(() => _previasExamen = value);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Descripción
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Descripción",
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Botón guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardar,
                        child: const Text("Guardar materia"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _selectorPrevias({
    required String titulo,
    required List<int> seleccionados,
    required Function(List<int>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: todasLasMaterias.map((m) {
              final yaSeleccionada = seleccionados.contains(m.id);
              return CheckboxListTile(
                title: Text("${m.nombre} (ID ${m.id})"),
                value: yaSeleccionada,
                onChanged: (v) {
                  final nuevaLista = [...seleccionados];
                  if (v == true) {
                    nuevaLista.add(m.id!);
                  } else {
                    nuevaLista.remove(m.id);
                  }
                  onChanged(nuevaLista);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nuevaMateria = Materia(
      id: int.parse(_idController.text),
      nombre: _nombreController.text.trim(),
      semestre: _semestreSeleccionado,
      previasCursar: _previasCursar,
      previasExamen: _previasExamen,
      estado: _estadoSeleccionado,
      descripcion: _descripcionController.text.trim(),
    );

    try {
      await DatabaseHelper.insertMateria(nuevaMateria);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
