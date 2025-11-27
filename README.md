# 📘 Malla Curricular

Aplicación móvil desarrollada en **Flutter** que permite gestionar una malla curricular universitaria.  
Incluye creación, edición, visualización y actualización automática del estado de cada materia según sus previas.

Esta herramienta facilita organizar y visualizar el avance académico de una carrera, aplicando reglas reales sobre correlatividades y habilitaciones.

---

## 📱 Características principales

### ✔️ Gestión completa de materias
- Nombre  
- Semestre  
- Previas para cursar  
- Previas para examen  
- Estado (No habilitada / Habilitada / Examen pendiente / Aprobada)  
- Descripción

### ✔️ Verificación automática del estado
La app ajusta el estado de cada materia según reglas académicas reales:

- Si **no tiene previas**, nunca puede estar *No habilitada*  
- Si **alguna previa no está aprobada o pendiente de examen**, debe estar *No habilitada*  
- Si **todas sus previas están aprobadas o con examen pendiente**, pasa automáticamente a *Habilitada*  
- Cuando se edita una materia, la app también recalcula las materias que dependen de ella

### ✔️ Vista organizada por semestres
El Home Screen muestra las materias agrupadas por semestre con colores según su estado:

- 🟩 **Aprobada**  
- 🟧 **Examen pendiente**  
- 🟦 **Habilitada**  
- 🟥 **No habilitada**

### ✔️ Interfaz intuitiva
- Botón flotante para agregar materias  
- Selector de previas mostrando **nombre + ID**  
- Pantalla de edición clara  
- Actualización automática al volver al menú principal  

---

## 📦 Instalación rápida (APK incluido)

Para probar la app sin compilar nada, simplemente instalá el archivo:

### 👉 **`malla-curricular-v1.0.apk`**

Este archivo se encuentra en el **directorio raíz del proyecto**.

Solo transferilo a tu teléfono Android e instalalo (activá *instalación desde fuentes desconocidas* si es necesario).

---

## 🔧 Requisitos de desarrollo

- Flutter SDK 3.10+  
- Dart SDK  
- Android SDK / Xcode  
- VS Code o Android Studio  

---

## 🛠️ Ejecutar el proyecto en modo desarrollo

```sh
flutter pub get
flutter run
```

---

## 🏗️ Compilar APK

### APK de debug:
```sh
flutter build apk --debug
```

### APK de release:
```sh
flutter build apk --release
```

El archivo final se generará en:
```sh
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Estructura del proyecto
```sh
/lib
  /data
    materia.dart
    db.dart
  /screens
    home_screen.dart
    add_materia_screen.dart
    materia_screen.dart
  main.dart
/assets
malla-curricular-v1.0.apk
pubspec.yaml
README.md
```

---

## 🎓 Lógica del sistema de habilitación
Para mantener una malla curricular siempre válida:
- Una materia sin previas siempre está habilitada
- Una materia con previas solo se habilita si todas están aprobadas o con examen pendiente
- Al modificar una materia, se recalculan todas las que dependen de ella
- Al eliminar una materia, las correlativas se recalculan automáticamente
Esto evita inconsistencias y asegura una estructura académica correcta.

---

## 🧪 Cómo probar la aplicación

### ✔ Opción 1 — Instalar el APK (recomendado)

1. Abrir el archivo malla-curricular-v1.0.apk

2. Instalar

3. Probar la app agregando, modificando o eliminando materias

### ✔ Opción 2 — Ejecutar desde Flutter
```sh
flutter run
```

---

## 📄 Licencia MIT