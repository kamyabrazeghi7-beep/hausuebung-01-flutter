# Hausübungen – Entwicklung grafischer Benutzeroberflächen
**Name:** Kamyab Razeghizeidi
**E-Mail:** kamyab.razeghizeidi@stud.thm.de
**Matrikelnummer:** 5592717

## Projekte im Repository

- `calculator_app/` – Hausübung 1: Taschenrechner
- `todo_app/` – Hausübung 1 + Hausübung 2 (siehe Hinweis unten)

## Hinweis zu Hausübung 2 (Dashboard & Wetter-API)

Die Hausübung 2 wurde als **Erweiterung der bestehenden todo_app** umgesetzt
(gemäß Aufgabenstellung: "Es kann auch mit einem Hinweis in der Readme eine
Erweiterung der bestehenden Projekte sein"). Die App enthält eine
Dashboard-Startseite mit Wetter-API-Anbindung und Todo-Übersicht.

## Dashboard-Konzept

Nach dem Login öffnet sich die Dashboard-Startseite. Aufbau:

1. **Begrüßung** mit Namen des eingeloggten Benutzers
2. **Wetter-Kachel** (Frankfurt am Main) mit echten Daten der Open-Meteo API
3. **Todo-Statistiken** als drei Karten: Gesamt, Offen, Erledigt
4. **Fortschrittsbalken** mit Prozentanzeige der erledigten Aufgaben
5. **Navigation** zu den weiteren App-Bereichen (Todos, Chat)

### Verwendete Wetter-API

**Open-Meteo** – https://open-meteo.com/ (kostenlos, kein API-Key nötig)

Angezeigte Wetterwerte:
- Aktuelle Temperatur (`temperature_2m`)
- Windgeschwindigkeit (`wind_speed_10m`)
- Wetterbeschreibung + Icon (aus `weather_code` abgeleitet)

Die App zeigt während des Abrufs einen Ladeindikator und im Fehlerfall
eine Meldung ("Wetter nicht verfügbar") an.

### Zweites Dashboard-Thema: Todo-Übersicht

Als zweites Thema wurde die Todo-Übersicht gewählt, da die App bereits
eine Todo-Funktion besitzt. Das Dashboard zeigt die Anzahl aller,
offener und erledigter Aufgaben sowie den Fortschritt in Prozent.
Die Daten kommen aus der Appwrite-Datenbank des eingeloggten Benutzers.

## Technischer Aufbau (todo_app)

- `lib/appwrite_service.dart` – Anbindung an Appwrite (Auth, Datenbank)
- `lib/services/weather_service.dart` – Wetter-API-Anbindung (HTTP + JSON)
- `lib/screens/dashboard_screen.dart` – Dashboard-Startseite
- `lib/screens/login_screen.dart` – Login/Registrierung
- `lib/screens/chat_screen.dart` – Chat
- `lib/providers/todo_provider.dart` – Todo-Verwaltung (State Management)

## Starten der App
