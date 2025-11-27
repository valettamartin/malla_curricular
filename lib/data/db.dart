import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/materia.dart';

class DatabaseHelper {
  static const _databaseName = "malla.db";
  static const _databaseVersion = 2;

  static Database? _database;

  // Acceso a la base de datos
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Crear tabla
  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE materias (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        semestre INTEGER NOT NULL,
        previasCursar TEXT,
        previasExamen TEXT,
        estado TEXT NOT NULL,
        descripcion TEXT,
        minAprobadas INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Agregamos columna al actualizar BD
  static Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE materias ADD COLUMN minAprobadas INTEGER NOT NULL DEFAULT 0"
      );
    }
  }

  // Contador de materias aprobadas, global
  static Future<int> contadorAprobadas() async {
    final db = await database;

    final res = await db.rawQuery(
      "SELECT COUNT(*) AS total FROM materias WHERE estado = 'Aprobada'"
    );

    return Sqflite.firstIntValue(res) ?? 0;
  }

  // Validar si una materia cumple requisitos
  static Future<bool> cumpleRequisitos(Materia m) async {
    final db = await database;

    // Previas para cursar?
    if (m.previasCursar.isNotEmpty) {
      final result = await db.query(
        'materias',
        where: 'id IN (${m.previasCursar.join(',')}) AND (estado = ? OR estado = ?)',
        whereArgs: ['Aprobada', 'Examen pendiente'],
      );

      if (result.length != m.previasCursar.length) {
        return false;
      }
    }

    // Minimo de aprovadas?
    final aprobadas = await contadorAprobadas();
    if (aprobadas < m.minAprobadas) return false;

    return true;
  }

  // Insertar nueva materia
  static Future<void> insertMateria(Materia materia) async {
    final db = await database;

    // Existen las previas?
    Future<bool> existenPrevias(List<int> ids) async {
      if (ids.isEmpty) return true;
      final r = await db.query("materias",
          where: "id IN (${ids.join(',')})");
      return r.length == ids.length;
    }

    if (!await existenPrevias(materia.previasCursar)) {
      throw Exception("Error: previas para cursar inexistentes.");
    }
    if (!await existenPrevias(materia.previasExamen)) {
      throw Exception("Error: previas para examen inexistentes.");
    }

    // Validación completa
    final cumple = await cumpleRequisitos(materia);

    if (!cumple) {
      materia.estado = "No habilitada";
    } else {
      if (materia.estado == "No habilitada") {
        materia.estado = "Habilitada";
      }
    }

    await db.insert(
      'materias',
      materia.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await recalcularEstadosDependientes(materia.id!);
  }

  // Actualizar materia
  static Future<void> updateMateria(Materia materia) async {
    final db = await database;

    // Existen las previas?
    Future<bool> existenPrevias(List<int> ids) async {
      if (ids.isEmpty) return true;
      final r = await db.query("materias",
          where: "id IN (${ids.join(',')})");
      return r.length == ids.length;
    }

    if (!await existenPrevias(materia.previasCursar)) {
      throw Exception("Error: previas para cursar inexistentes.");
    }
    if (!await existenPrevias(materia.previasExamen)) {
      throw Exception("Error: previas para examen inexistentes.");
    }

    // Validación completa
    final cumple = await cumpleRequisitos(materia);

    if (!cumple) {
      materia.estado = "No habilitada";
    } else {
      if (materia.estado == "No habilitada") {
        materia.estado = "Habilitada";
      }
    }

    await db.update(
      'materias',
      materia.toMap(),
      where: "id = ?",
      whereArgs: [materia.id],
    );

    await recalcularEstadosDependientes(materia.id!);
  }

  // Recalcular estados de materias dependientes
  static Future<void> recalcularEstadosDependientes(int materiaId) async {
    final db = await database;

    final lista = (await db.query("materias"))
        .map((e) => Materia.fromMap(e)).toList();

    final mapa = {for (var m in lista) m.id!: m};

    bool cambios = true;

    while (cambios) {
      cambios = false;

      for (final m in lista) {
        final cumple = await cumpleRequisitos(m);

        if (!cumple && m.estado != "No habilitada") {
          m.estado = "No habilitada";
          await db.update("materias", m.toMap(),
              where: "id = ?", whereArgs: [m.id]);
          cambios = true;
        }

        if (cumple && m.estado == "No habilitada") {
          m.estado = "Habilitada";
          await db.update("materias", m.toMap(),
              where: "id = ?", whereArgs: [m.id]);
          cambios = true;
        }
      }
    }
  }

  // Consultar todas las materias
  static Future<List<Materia>> getMaterias() async {
    final db = await database;
    final res = await db.query("materias");
    return res.map((e) => Materia.fromMap(e)).toList();
  }

  static Future<Materia?> getMateriaById(int id) async {
    final db = await database;
    final res = await db.query("materias",
        where: "id = ?", whereArgs: [id], limit: 1);
    if (res.isEmpty) return null;
    return Materia.fromMap(res.first);
  }

  static Future<void> deleteMateria(int id) async {
    final db = await database;

    await db.delete("materias", where: "id = ?", whereArgs: [id]);

    await recalcularEstadosDependientes(id);
  }
}
