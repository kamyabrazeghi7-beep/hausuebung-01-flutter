# 📋 Todo App — Flutter Projekt
**Entwicklung grafischer Bedienoberflächen · THM**

---

## Projektübersicht

Eine professionelle To-do-Listen-App, entwickelt mit Flutter und dem `provider`-Paket für das State-Management. Die App demonstriert die Kernkonzepte der Vorlesung: reaktive Oberflächen, Zustandsverwaltung und persistente Datenspeicherung.

---

## Features

| Feature | Beschreibung |
|--------|-------------|
| ✅ Aufgaben verwalten | Hinzufügen, Bearbeiten, Löschen per Swipe |
| 🎯 Prioritäten | Hoch / Mittel / Niedrig mit Farbkodierung |
| 📁 Kategorien | Eigene Kategorien erstellen & filtern |
| 📅 Fälligkeitsdatum | Aufgaben mit Datum versehen |
| 🔍 Suche & Filter | Nach Status, Kategorie und Name filtern |
| 📊 Fortschrittsanzeige | Visuelle Statistik & Fortschrittsbalken |
| 💾 Persistenz | Daten bleiben nach App-Neustart erhalten (SharedPreferences) |
| 🔄 Sortierung | Datum, Fälligkeit, Priorität, Alphabetisch |

---

## Projektstruktur

```
lib/
├── main.dart                    # App-Einstiegspunkt
├── app_theme.dart               # Globales Design-System
├── models/
│   └── todo.dart                # Datenmodell (Todo, Priority Enum)
├── providers/
│   └── todo_provider.dart       # State Management (ChangeNotifier)
├── screens/
│   └── home_screen.dart         # Hauptbildschirm
└── widgets/
    ├── todo_card.dart           # Einzelne Aufgabenkarte mit Swipe-Aktionen
    ├── stats_summary.dart       # Statistikbereich oben
    └── todo_form_sheet.dart     # Formular zum Hinzufügen/Bearbeiten
```

---

## Verwendete Pakete

| Paket | Verwendung |
|-------|-----------|
| `provider` | State Management (ChangeNotifier) |
| `shared_preferences` | Lokale Datenpersistenz |
| `uuid` | Eindeutige IDs für Aufgaben |
| `intl` | Datumsformatierung |
| `flutter_slidable` | Swipe-Aktionen auf Listenelementen |
| `google_fonts` | Poppins-Schriftart |

---

## Installation & Start

### Voraussetzungen
- Flutter SDK ≥ 3.0.0 ([flutter.dev](https://flutter.dev))
- VS Code mit Flutter-Extension **oder** Android Studio
- Emulator oder physisches Gerät

### Schritte

```bash
# 1. In den Projektordner wechseln
cd todo_app

# 2. Abhängigkeiten installieren
flutter pub get

# 3. App starten
flutter run
```

### In VS Code
1. Ordner `todo_app` öffnen
2. Emulator/Gerät auswählen (untere Statusleiste)
3. `F5` drücken oder **Run > Start Debugging**

---

## Architektur-Konzepte

### State Management mit Provider
```dart
// Provider stellt Daten bereit
ChangeNotifierProvider(
  create: (_) => TodoProvider()..loadTodos(),
  child: const TodoApp(),
)

// Widgets hören auf Änderungen
final provider = context.watch<TodoProvider>();

// Aktionen auslösen (ohne Rebuild)
context.read<TodoProvider>().toggleTodo(id);
```

### Datenmodell
```dart
class Todo {
  final String id;        // UUID
  String title;           // Aufgabenname
  Priority priority;      // low / medium / high
  bool isCompleted;       // Status
  DateTime? dueDate;      // Fälligkeitsdatum (optional)
  String category;        // Kategorie
}
```

### Datenpersistenz
Aufgaben werden als JSON in `SharedPreferences` gespeichert und beim App-Start automatisch geladen.

---

## Bedienung

| Aktion | Geste / Element |
|--------|----------------|
| Neue Aufgabe | FAB-Button unten rechts |
| Aufgabe erledigen | Kreis links antippen |
| Aufgabe bearbeiten | Karte antippen oder nach links wischen |
| Aufgabe löschen | Nach links wischen → Mülleimer |
| Filtern | Chips oben (All / Active / Done) |
| Sortieren | ⋮ Menü oben rechts |
| Suchen | 🔍 oben rechts |

---

## Lernziele (EGB-Bezug)

- **Deklarative UI** mit Flutter Widgets (StatelessWidget, StatefulWidget)
- **Reaktives State Management** mit `ChangeNotifier` und `provider`
- **Composable Widgets** – Aufbau komplexer UIs aus kleinen Bausteinen
- **Persistente Datenspeicherung** mit `SharedPreferences`
- **Material Design 3** – AppBar, FAB, BottomSheet, Dialoge, Chips
- **Animationen** – AnimatedContainer, TweenAnimationBuilder

---

*Erstellt für das Modul „Entwicklung grafischer Bedienoberflächen" · THM Gießen*
