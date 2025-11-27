import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Información de la App"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titulo(context, "📘 ¿Qué es esta aplicación?"),
            _texto(
                "Esta aplicación permite gestionar y visualizar la malla curricular de tu carrera. "
                "Podés registrar materias, ver su estado, modificar sus datos y controlar cómo avanzás."),

            const SizedBox(height: 24),
            _titulo(context, "📥 Agregar materias"),
            _texto(
                "En la pantalla principal, tocá el botón ➕ para agregar una nueva materia.\n\n"
                "Debés ingresar:\n"
                "• ID\n"
                "• Nombre\n"
                "• Semestre\n"
                "• Previas para cursar (opcional)\n"
                "• Previas para examen (opcional)\n"
                "• Estado inicial\n"
                "• Descripción"),

            const SizedBox(height: 16),
            _texto(
                "Las previas deben existir previamente.\n"
                "Si la materia tiene previas sin aprobar, su estado se ajustará automáticamente a *No habilitada*."),

            const SizedBox(height: 24),
            _titulo(context, "✏️ Modificar materias"),
            _texto(
                "Tocá cualquier materia en la pantalla principal para abrir su vista completa.\n\n"
                "Podés editar:\n"
                "• Nombre\n"
                "• Semestre\n"
                "• Previas (cursar y examen)\n"
                "• Estado\n"
                "• Descripción"),

            const SizedBox(height: 10),
            _texto(
                "El sistema recalcula automáticamente el estado de la materia y de todas las materias "
                "que dependan de ella."),

            const SizedBox(height: 24),
            _titulo(context, "🗑️ Eliminar materias"),
            _texto(
                "Desde la pantalla de una materia, podés eliminarla usando el ícono de basura.\n\n"
                "Al eliminarla, también se recalculan todas las materias que dependían de ella para mantener la coherencia."),

            const SizedBox(height: 24),
            _titulo(context, "🎨 Guía de colores"),
            _texto("Cada estado tiene su propio color:"),
            const SizedBox(height: 10),

            _colorItem("Aprobada", Colors.green.shade400),
            _colorItem("Examen pendiente", Colors.orange.shade400),
            _colorItem("Habilitada", Colors.blue.shade400),
            _colorItem("No habilitada", Colors.red.shade400),

            const SizedBox(height: 24),
            _titulo(context, "📏 Reglas de habilitación"),
            _texto(
                "El estado de una materia se controla automáticamente según las siguientes reglas:"),
            const SizedBox(height: 10),
            _bullet("Una materia sin previas nunca puede estar No habilitada."),
            _bullet("Si alguna previa no está aprobada o con examen pendiente, la materia debe estar No habilitada."),
            _bullet("Si todas las previas están aprobadas o con examen pendiente, la materia pasa a estar Habilitada."),
            _bullet("Modificar o eliminar materias recalcula todas las dependencias automáticamente."),

            const SizedBox(height: 40),
            Center(
              child: Text(
                "Malla Curricular v1.0",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titulo(BuildContext context, String texto) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _texto(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 16, height: 1.4),
    );
  }

  Widget _bullet(String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("•  ", style: TextStyle(fontSize: 18)),
        Expanded(child: Text(texto, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _colorItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
