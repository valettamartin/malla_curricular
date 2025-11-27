class Materia {
  int? id;                      // ID único (4 dígitos)
  String nombre;                // Nombre visible
  int semestre;                 // Semestre recomendado
  List<int> previasCursar;      // IDs de materias necesarias para cursar
  List<int> previasExamen;      // IDs necesarias para rendir examen
  String estado;                // "No habilitada", "Habilitada", "Examen pendiente", "Aprobada"
  String descripcion;           // Descripción opcional

  Materia({
    this.id,
    required this.nombre,
    required this.semestre,
    required this.previasCursar,
    required this.previasExamen,
    required this.estado,
    required this.descripcion,
  });

  // Convertimos de Objeto a SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'semestre': semestre,
      'previasCursar': previasCursar.join(','), // Guardar como cadena separada por comas
      'previasExamen': previasExamen.join(','), // Guardar como cadena separada por comas
      'estado': estado,
      'descripcion': descripcion,
    };
  }

  // Convertimos de SQLite a Objeto
  factory Materia.fromMap(Map<String, dynamic> map) {
    List<int> parseLista(String? valor) {
      if (valor == null || valor.trim().isEmpty) return [];
      return valor
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map(int.parse)
          .toList();
    }

    return Materia(
      id: map['id'],
      nombre: map['nombre'],
      semestre: map['semestre'],
      previasCursar: parseLista(map['previasCursar']),
      previasExamen: parseLista(map['previasExamen']),
      estado: map['estado'],
      descripcion: map['descripcion'],
    );
  }
}