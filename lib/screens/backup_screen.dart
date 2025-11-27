import 'package:flutter/material.dart';
import '../services/google_drive_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _cargando = false;
  String? ultimaAccion;

  // Subir a Google Drive
  Future<void> _subirBackup() async {
    setState(() => _cargando = true);

    final drive = GoogleDriveService();

    try {
      final ok = await drive.uploadBackup();

      if (!mounted) return;
      if (ok) {
        ultimaAccion = "Backup subido a Google Drive";
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Copia subida correctamente.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al subir la copia.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _cargando = false);
  }

  // Restaurar desde Google Drive
  Future<void> _restaurarBackup() async {
    setState(() => _cargando = true);

    final drive = GoogleDriveService();

    try {
      final ok = await drive.downloadBackup();

      if (!mounted) return;
      if (ok) {
        ultimaAccion = "Backup restaurado desde Google Drive";
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Copia restaurada correctamente.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No hay backup en Google Drive.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Copias de Seguridad"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Boton de subir
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Subir copia a Google Drive"),
                onPressed: _cargando ? null : _subirBackup,
              ),
            ),

            const SizedBox(height: 20),

            // Boton de restaurar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cloud_download),
                label: const Text("Restaurar desde Google Drive"),
                onPressed: _cargando ? null : _restaurarBackup,
              ),
            ),

            const SizedBox(height: 40),

            if (_cargando) const CircularProgressIndicator(),

            if (ultimaAccion != null) ...[
              const SizedBox(height: 30),
              Text(
                "Última acción: $ultimaAccion",
                style: const TextStyle(fontSize: 16),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
