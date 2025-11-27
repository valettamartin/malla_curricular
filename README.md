# malla_curricular

Aplicación móvil en Flutter para visualizar y gestionar mallas curriculares (planes de estudio). Este proyecto sirve como base para desarrollar funcionalidades de planificación académica: ver asignaturas por semestre, relaciones de prerequisitos, marcar progreso y planificar semestres.

## Objetivo
Proveer una interfaz clara y responsiva para estudiantes y administradores académicos, que permita explorar la malla curricular y realizar un seguimiento del avance académico.

## Características (ejemplos)
- Listado de asignaturas por semestre.
- Visualización de prerequisitos y relaciones entre materias.
- Marcar asignaturas como cursadas/pendientes.
- Planificador por semestre (contruir planes de estudio).
- Exportar/importar datos de la malla (JSON).
- Diseño responsivo para móviles y tablets.

## Estructura del repositorio
- android/ — código nativo para Android.
- ios/ — código nativo para iOS.
- lib/ — código principal de Flutter/Dart:
  - lib/main.dart — punto de entrada.
  - lib/models/ — modelos de datos (Asignatura, Semestre, Malla).
  - lib/screens/ — pantallas de la app.
  - lib/widgets/ — widgets reutilizables.
  - lib/services/ — lógica de negocio, persistencia e importación/exportación.
- assets/ — imágenes, fuentes y archivos JSON de ejemplo.
- test/ — pruebas unitarias y de widget.
- pubspec.yaml — dependencias y configuración del proyecto.

## Requisitos
- Flutter (SDK) instalado — versión estable recomendada.
- Dart SDK (incluido con Flutter).
- Android Studio o VS Code con extensiones Flutter/Dart.
- (Opcional) Xcode para compilación en iOS.

## Instalación y ejecución (Windows)
1. Clona el repositorio:
   - git clone <url-del-repositorio>
2. En la terminal (PowerShell o CMD), sitúate en el proyecto:
   - cd "c:\Users\marti\OneDrive\Desktop\Cuadernos\00 - Proyectos Personales\malla_curricular"
3. Instala dependencias:
   - flutter pub get
4. Ejecuta en un dispositivo/emulador:
   - flutter run
5. Compilar para Android:
   - flutter build apk
6. Compilar para iOS (requiere macOS/Xcode):
   - flutter build ios

## Pruebas
- Ejecuta pruebas unitarias y de widget:
  - flutter test
- Analiza el código para detectar problemas:
  - flutter analyze
- Formatea el código con:
  - dart format .

## Notas
- Ajusta la estructura de carpetas si adopta

## Uso
- Para instalar la version actual, instalar malla-curricular-v1.0.apk