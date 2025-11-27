class Materia {
  int? id;
  String nombre;
  int semestre;
  List<int> previasCursar;
  List<int> previasExamen;
  String estado;
  String descripcion;

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
      'previasCursar': previasCursar.join(','), 
      'previasExamen': previasExamen.join(','),
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
