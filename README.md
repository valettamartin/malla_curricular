# 📘 Malla Curricular

Mobile application developed in Flutter that allows you to manage a university curriculum map.
It includes creating, editing, viewing, and automatically updating each subject’s status based on its prerequisites.

This tool helps organize and visualize your academic progress, applying real-world rules about course correlatives and enrollment eligibility.

---

## 📱 Key Features

### ✔️ Full subject management
- Name
- Semester
- Prerequisites for attending
- Prerequisites for taking the exam
- Status (Not enabled / Enabled / Exam pending / Approved)
- Description

### ✔️ Automatic status verification
The app automatically adjusts each subject’s status according to real academic rules:
- If it has no prerequisites, it can never be Not enabled
- If any prerequisite is not approved or exam-pending, the subject must be Not enabled
- If all prerequisites are approved or exam-pending, the subject automatically becomes Enabled
- When a subject is edited, the app also recalculates all subjects that depend on it

### ✔️ Semester-organized view
The Home Screen displays the subjects grouped by semester, with colors based on their status:

- 🟩 **Approved**  
- 🟧 **Exam pending**  
- 🟦 **Enabled**  
- 🟥 **Not enabled**

### ✔️ Intuitive interface
- Floating button to add subjects
- Prerequisite selector showing name + ID
- Clean editing screen 
- Auto-refresh when returning to the home menu 

---

## Quick Installation (APK included)

To test the app without compiling anything, simply install the file:

### 👉 **`malla-curricular-v1.0.apk`**

This file is located in the project’s root directory.

Just transfer it to your Android phone and install it (you may need to enable installation from unknown sources).

---

## 🔧 Development Requirements

- Flutter SDK 3.10+  
- Dart SDK  
- Android SDK / Xcode  
- VS Code o Android Studio  

---

## 🛠️ Run the project in development mode

```sh
flutter pub get
flutter run
```

---

## 🏗️ Build APK

### Debug APK:
```sh
flutter build apk --debug
```

### Release APK:
```sh
flutter build apk --release
```

The final file will be located at:
```sh
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Project Structure
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

## 🎓 System Logic for Subject Eligibility
To maintain a valid curriculum structure:
- A subject with no prerequisites is always enabled
- A subject with prerequisites is enabled only if all are approved or exam-pending
- When a subject is modified, all subjects depending on it are recalculated
- When a subject is deleted, all related correlatives are automatically recalculated
This prevents inconsistencies and ensures an academically valid structure.

---

## 🧪 How to test the application

### ✔ Option 1 — Install the APK (recommended)

1. Open the file malla-curricular-v1.0.apk

2. Install it

3. Test the app by adding, editing, or deleting subjects

### ✔ Option 2 — Run from Flutter
```sh
flutter run
```

---

## 📄 MIT License