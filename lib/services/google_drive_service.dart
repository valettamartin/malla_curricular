import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class GoogleDriveService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  GoogleSignInAccount? _currentUser;

  // Login con Google
  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser != null;
    } catch (e) {
      debugPrint("Error al iniciar sesión: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  Future<GoogleSignInAccount?> get user async {
    return _googleSignIn.currentUser;
  }

  // Token para drive
  Future<String?> _getAuthHeader() async {
    final auth = await _currentUser?.authHeaders;
    return auth?["Authorization"];
  }

  // Copia de la base slite
  Future<String> _exportDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final originalPath = "$dbPath/malla.db";
      final originalFile = File(originalPath);

      if (!originalFile.existsSync()) {
        debugPrint("ERROR: La base original no existe en $originalPath");
        return "";
      }

      final dir = await getApplicationDocumentsDirectory();
      final backupPath = "${dir.path}/malla.db";
      final backupFile = File(backupPath);

      await originalFile.copy(backupFile.path);

      debugPrint("COPIA OK > $backupPath");
      return backupFile.path;
    } catch (e) {
      debugPrint("ERROR exportando base: $e");
      return "";
    }
  }

  // Crear carpeta en drive
  Future<String?> _getOrCreateFolder() async {
    const folderName = "MallaCurricularBackup";

    final auth = await _getAuthHeader();
    if (auth == null) return null;

    final url =
        "https://www.googleapis.com/drive/v3/files?q=name='$folderName' and mimeType='application/vnd.google-apps.folder'";

    final res = await http.get(
      Uri.parse(url),
      headers: {"Authorization": auth},
    );

    if (res.statusCode == 200 && res.body.contains("id")) {
      final id = _extractId(res.body);
      if (id != null) return id;
    }

    // Crear carpeta
    final createUrl = "https://www.googleapis.com/drive/v3/files";
    final createRes = await http.post(
      Uri.parse(createUrl),
      headers: {
        "Authorization": auth,
        "Content-Type": "application/json",
      },
      body: '''
      {
        "name": "$folderName",
        "mimeType": "application/vnd.google-apps.folder"
      }
      ''',
    );

    return _extractId(createRes.body);
  }

  // Realizar el backup de la base
  Future<bool> uploadBackup() async {
    try {
      debugPrint("=== INICIANDO SUBIDA ===");

      // --- LOGIN ---
      if (_googleSignIn.currentUser == null) {
        debugPrint("No hay usuario, intentando login...");
        if (!await signIn()) {
          debugPrint("ERROR: No se pudo iniciar sesión");
          return false;
        }
      }
      debugPrint("Login OK");

      // --- TOKEN DE AUTORIZACIÓN ---
      final auth = await _getAuthHeader();
      if (auth == null) {
        debugPrint("ERROR: auth null");
        return false;
      }

      // --- PREFS ---
      final prefs = await SharedPreferences.getInstance();

      // --- CREAR / OBTENER CARPETA ---
      final folderId = await _getOrCreateFolder();
      debugPrint("Folder ID: $folderId");

      if (folderId == null) {
        debugPrint("ERROR: folderId null");
        return false;
      }

      // --- COPIAR BASE DE DATOS ---
      final dbPath = await _exportDatabase();
      if (dbPath.isEmpty) {
        debugPrint("ERROR: dbPath vacío");
        return false;
      }

      debugPrint("DB PATH PARA SUBIR: $dbPath");

      final file = File(dbPath);

      // --- FILE ID PREVIO (para PATCH) ---
      String? fileId = prefs.getString("drive_file_id");
      final isNew = fileId == null;

      // --- URL DE SUBIDA ---
      final url = isNew
          ? "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"
          : "https://www.googleapis.com/upload/drive/v3/files/$fileId?uploadType=multipart";

      debugPrint("USANDO MÉTODO: ${isNew ? 'POST (nuevo)' : 'PATCH (actualizar)'}");
      debugPrint("URL: $url");

      // --- MULTIPART REAL ---
      final request = http.MultipartRequest(
        isNew ? "POST" : "PATCH",
        Uri.parse(url),
      );

      request.headers["Authorization"] = auth;

      // Parte 1: Metadata JSON
      request.files.add(
        http.MultipartFile.fromString(
          "metadata",
          '''
          {
            "name": "malla.db",
            "parents": ["$folderId"]
          }
          ''',
          contentType: http.MediaType("application", "json"),
        ),
      );

      // Parte 2: Archivo sqlite
      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          await file.readAsBytes(),
          filename: "malla.db",
          contentType: http.MediaType("application", "octet-stream"),
        ),
      );

      // --- EJECUTAR PETICIÓN ---
      final response = await request.send();

      debugPrint("RESPUESTA SUBIDA: ${response.statusCode}");

      // LEER BODY COMPLETO
      final body = await response.stream.bytesToString();
      debugPrint("BODY SUBIDA COMPLETO >>> $body");

      // EXTRAER ID
      final newId = _extractId(body);
      debugPrint("ID EXTRAÍDO >>> $newId");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (newId == null) {
          debugPrint("ERROR: Body recibido NO contiene ID del archivo");
          return false;
        }

        // Guardar ID solo si es archivo nuevo
        if (isNew) {
          await prefs.setString("drive_file_id", newId);
        }

        debugPrint(
            "ID GUARDADO EN SharedPreferences >>> ${prefs.getString("drive_file_id")}");

        return true;
      }

      debugPrint("ERROR: código HTTP inesperado");
      return false;
    } catch (e) {
      debugPrint("Error subiendo backup: $e");
      return false;
    }
  }

  // Obtener el PATH donde Flutter guarda la base malla.db
  Future<String> _getLocalDbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/malla.db";
    debugPrint("PATH RESUELTO POR _getLocalDbPath(): $path");
    return path;
  }

  // Descargar y restaurar la base desde drive
  Future<bool> downloadBackup() async {
    try {
      debugPrint("=== INICIANDO RESTAURACIÓN ===");

      // Primero intentamos recuperar el usuario silenciosamente
      _currentUser = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();

      if (_currentUser == null) {
        debugPrint("No hay usuario activo, intentando login manual...");
        if (!await signIn()) {
          debugPrint("ERROR: No se pudo iniciar sesión.");
          return false;
        }
      }

      final auth = await _getAuthHeader();
      debugPrint("TOKEN: $auth");

      if (auth == null) {
        debugPrint("ERROR: auth header null");
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final fileId = prefs.getString("drive_file_id");

      if (fileId == null) {
        debugPrint("ERROR: No existe drive_file_id en SharedPreferences");
        return false;
      }

      debugPrint("ID del archivo en Drive: $fileId");

      final url = "https://www.googleapis.com/drive/v3/files/$fileId?alt=media";
      debugPrint("URL de descarga: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": auth},
      );

      debugPrint("HTTP STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final dbPath = await _getLocalDbPath();
        debugPrint("DB PATH LOCAL PARA GUARDAR: $dbPath");

        final file = File(dbPath);

        await file.writeAsBytes(response.bodyBytes, flush: true);
        debugPrint("RESTORE COMPLETADO > Archivo sobrescrito");

        return true;
      }

      debugPrint("ERROR: No se pudo descargar. Body:");
      debugPrint(response.body);

      return false;

    } catch (e) {
      debugPrint("Error restaurando backup: $e");
      return false;
    }
  }

  // Extraer ID del body
  String? _extractId(String body) {
    final match = RegExp(r'"id"\s*:\s*"([^"]+)"').firstMatch(body);
    return match?.group(1);
  }
}