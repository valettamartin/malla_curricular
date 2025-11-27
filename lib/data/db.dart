import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/materia.dart';

class DatabaseHelper {
  static const _databaseName = "malla.db";
  static const _databaseVersion = 1;

  static Database? _database;

  // Acceso único a la base de datos
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa la base
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Crea tabla materias
  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE materias (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        semestre INTEGER NOT NULL,
        previasCursar TEXT,
        previasExamen TEXT,
        estado TEXT NOT NULL,
        descripcion TEXT
      )
    ''');
  }

  // ---------------------------------------------------------
  // INSERTAR MATERIA
  // ---------------------------------------------------------
  static Future<void> insertMateria(Materia materia) async {
    final db = await database;

    // 1. Validar que las previas existan
    Future<bool> existenPrevias(List<int> ids) async {
      if (ids.isEmpty) return true;

      final result = await db.query(
        'materias',
        where: 'id IN (${ids.join(',')})',
      );

      return result.length == ids.length;
    }

    if (!await existenPrevias(materia.previasCursar)) {
      throw Exception("Error: Existen previas para cursar que no están registradas.");
    }

    if (!await existenPrevias(materia.previasExamen)) {
      throw Exception("Error: Existen previas para examen que no están registradas.");
    }

    // 2. Validar cumplimiento de previas
    Future<bool> previasCumplidas(List<int> ids) async {
      if (ids.isEmpty) return true;

      final result = await db.query(
        'materias',
        where: 'id IN (${ids.join(',')}) AND (estado = ? OR estado = ?)',
        whereArgs: ['Aprobada', 'Examen pendiente'],
      );

      return result.length == ids.length;
    }

    final cumplePrevias = await previasCumplidas(materia.previasCursar);

    // 3. Corregir estado automáticamente
    if (materia.previasCursar.isEmpty || cumplePrevias) {
      if (materia.estado == "No habilitada") {
        materia.estado = "Habilitada";
      }
    } else {
      materia.estado = "No habilitada";
    }

    // 4. Guardar
    await db.insert('materias', materia.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    // 5. Recalcular dependientes
    await recalcularEstadosDependientes(materia.id!);
  }

  // ---------------------------------------------------------
  // ACTUALIZAR MATERIA
  // ---------------------------------------------------------
  static Future<void> updateMateria(Materia materia) async {
    final db = await database;

    // 1. Validar existencia de previas
    Future<bool> existenPrevias(List<int> ids) async {
      if (ids.isEmpty) return true;
      final result = await db.query(
        'materias',
        where: 'id IN (${ids.join(',')})',
      );
      return result.length == ids.length;
    }

    if (!await existenPrevias(materia.previasCursar)) {
      throw Exception("Error: Existen previas para cursar que no están registradas.");
    }

    if (!await existenPrevias(materia.previasExamen)) {
      throw Exception("Error: Existen previas para examen que no están registradas.");
    }

    // 2. Validar cumplimiento de previas
    Future<bool> previasCumplidas(List<int> ids) async {
      if (ids.isEmpty) return true;

      final result = await db.query(
        'materias',
        where: 'id IN (${ids.join(',')}) AND (estado = ? OR estado = ?)',
        whereArgs: ['Aprobada', 'Examen pendiente'],
      );

      return result.length == ids.length;
    }

    final cumplePrevias = await previasCumplidas(materia.previasCursar);

    // 3. Corregir estado
    if (materia.previasCursar.isEmpty || cumplePrevias) {
      if (materia.estado == "No habilitada") {
        materia.estado = "Habilitada";
      }
    } else {
      materia.estado = "No habilitada";
    }

    // 4. Guardar cambios
    await db.update(
      'materias',
      materia.toMap(),
      where: 'id = ?',
      whereArgs: [materia.id],
    );

    // 🔥 5. Recargar la versión guardada ANTES de recalcular dependientes
    final actualizada = await getMateriaById(materia.id!);

    // 6. Recalcular dependientes
    await recalcularEstadosDependientes(materia.id!);
  }

  // ---------------------------------------------------------
  // RECALCULAR ESTADOS DEPENDIENTES
  // ---------------------------------------------------------
  static Future<void> recalcularEstadosDependientes(int materiaId) async {
    final db = await database;

    // Obtener todas las materias
    final resultado = await db.query('materias');
    final todas = resultado.map((e) => Materia.fromMap(e)).toList();

    final mapa = {for (var m in todas) m.id!: m};

    bool huboCambios = true;

    while (huboCambios) {
      huboCambios = false;

      for (final materia in todas) {
        final previas = materia.previasCursar;

        // A) Sin previas jamás puede estar No habilitada
        if (previas.isEmpty) {
          if (materia.estado == "No habilitada") {
            materia.estado = "Habilitada";

            await db.update(
              'materias',
              materia.toMap(),
              where: 'id = ?',
              whereArgs: [materia.id],
            );

            mapa[materia.id!] = materia;
            huboCambios = true;
          }
          continue;
        }

        // B) Verificar si cumple previas
        final cumplePrevias = previas.every((idPrev) {
          final previa = mapa[idPrev];
          return previa != null &&
              (previa.estado == "Aprobada" ||
                  previa.estado == "Examen pendiente");
        });

        // C) Si NO cumple previas -> debe quedar No habilitada
        if (!cumplePrevias && materia.estado != "No habilitada") {
          materia.estado = "No habilitada";

          await db.update(
            'materias',
            materia.toMap(),
            where: 'id = ?',
            whereArgs: [materia.id],
          );

          mapa[materia.id!] = materia;
          huboCambios = true;
          continue;
        }

        // D) Si cumple previas -> solo desbloquear si estaba No habilitada
        if (cumplePrevias && materia.estado == "No habilitada") {
          materia.estado = "Habilitada";

          await db.update(
            'materias',
            materia.toMap(),
            where: 'id = ?',
            whereArgs: [materia.id],
          );

          mapa[materia.id!] = materia;
          huboCambios = true;
        }
      }
    }
  }

  // ---------------------------------------------------------
  // CONSULTAS
  // ---------------------------------------------------------
  static Future<List<Materia>> getMaterias() async {
    final db = await database;
    final res = await db.query('materias');
    return res.map((e) => Materia.fromMap(e)).toList();
  }

  static Future<Materia?> getMateriaById(int id) async {
    final db = await database;
    final res = await db.query(
      'materias',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return Materia.fromMap(res.first);
  }

  static Future<void> deleteMateria(int id) async {
    final db = await database;

    await db.delete(
      'materias',
      where: 'id = ?',
      whereArgs: [id],
    );

    await recalcularEstadosDependientes(id);
  }
}
