# Habit-Tracker-Ausbau

## Ziel
Die browserlokale Habit-Tracker-App funktional und visuell zu einer kleinen, alltagstauglichen Fortschritts-App ausbauen.

## Dateien
- `experiments/habit-tracker/index.html`
- `experiments/habit-tracker/styles.css`
- `experiments/habit-tracker/app.js`

## Funktionsumfang
- Gewohnheiten mit Kategorie und Wochenziel anlegen, bearbeiten, abhaken und löschen.
- Übersicht mit Erledigt-Zähler, Fortschrittsbalken, Tagesstreak und Filter für alle/offene/erledigte Einträge.
- Browserlokale Speicherung sowie JSON-Export und -Import; kein Backend, Account oder externe Abhängigkeiten.
- Die lokale KI erstellt nur einen Stil-Entwurf für `styles.css`; Codex integriert die abhängigen HTML-/JavaScript-Funktionen.

## Tests
- `node --check experiments/habit-tracker/app.js`
- `git diff --check`
- Browser: anlegen, Filter, erledigen, bearbeiten, Reload, Export/Import und löschen.

## Ergebnis
- Statische Prüfung und `git diff --check` erfolgreich.
- Browserprüfung erfolgreich: Gewohnheit anlegen, Erledigt-Status mit Fortschritt/Streak, Offen-Filter, Bearbeiten, Reload-Persistenz und JSON-Export.
- Der lokale CSS-Entwurf wurde nicht übernommen, da der Worker keine neue, zum Auftrag passende Ausgabe erzeugte. Die abhängige Drei-Datei-Erweiterung wurde daher als erlaubte Ausnahme durch Codex umgesetzt.

## Öffentliche Dokumentation
- `docs/project-status.md` fasst Funktionsstand, Ablauf, Tests, Grenzen und die lokale Startanleitung für Außenstehende zusammen.
- `README.md` verlinkt auf diese Übersicht.
