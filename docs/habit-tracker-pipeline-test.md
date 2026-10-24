# Habit-Tracker: Local-first-Test

Dieses kleine, browserlokale Beispiel prüft die Zusammenarbeit zwischen Codex und der lokalen KI, ohne Backend, Account, externe Abhängigkeiten oder Deployment.

## Ergebnis

- Die lokale KI (`qwen2.5-coder:7b`) lieferte getrennte Ein-Datei-Entwürfe für HTML, CSS und JavaScript.
- Das Patch-Gate übernahm nur Patches für die jeweils vorher erlaubte Datei. Fehlen oder Fehler in Diff-Köpfen werden ausschließlich über einen alten Kontext akzeptiert, der genau einmal vorkommt.
- Zwei fehlerhafte JavaScript-Reparaturentwürfe wurden abgewiesen; dadurch gelangte kein Halluzinations-Code in das Projekt.
- Der anschließende, minimale Codex-Ausnahmefix war erlaubt, weil der lokale Lauf fehlgeschlagen war: ein globaler Formularauslöser und ein Index am Listenelement.

## Nachvollziehbarer Ablauf

1. Handoff auf genau eine Ziel-Datei begrenzen.
2. Den lokalen Worker mit nur Handoff, Agentenregeln und dieser Datei starten.
3. Den Entwurf mit `scripts/apply-local-patch.ps1 -AllowedFile <Datei> -Apply` prüfen und übernehmen.
4. Für die nächste Datei wiederholen.
5. Statische und Browser-Tests ausführen; nur bei einem abgewiesenen Patch oder Testfehler greift Codex punktuell ein.

## Ausführen

```powershell
cd experiments/habit-tracker
python -m http.server 4174 --bind 127.0.0.1
```

Danach `http://127.0.0.1:4174/` öffnen. Die Einträge liegen ausschließlich im `localStorage` des Browsers unter `habit-tracker-items`.

## Verifizierte Tests

| Test | Ergebnis |
| --- | --- |
| `node --check experiments/habit-tracker/app.js` | erfolgreich |
| `git diff --check` | erfolgreich |
| Habit anlegen | erfolgreich |
| Erledigt markieren | erfolgreich, Zähler steigt auf 1 |
| Browser neu laden | Eintrag und Status bleiben erhalten |
| Habit löschen | erfolgreich, Zähler fällt auf 0 |

Das Beispiel zeigt den gewünschten Umgang: Lokale Modelle erledigen kleine, eng eingegrenzte Routineentwürfe; das Gate schützt das Repository, und Codex übernimmt nur die Ausnahmebehandlung und den abschließenden Test.

## Ausbau zur Habit-Flow-App

Die Demo wurde anschließend ohne Backend zu einer vollständig browserlokalen Mini-App erweitert. Sie unterstützt Kategorien und Wochenziele, Fortschrittsanzeige, Tagesstreak, Wochenstatistik, Filter, Bearbeiten sowie JSON-Export und -Import. Alle Daten verbleiben im Browser-`localStorage`.

Beim Style-Entwurf lieferte der lokale Worker keine neue, auf die erlaubte CSS-Datei passende Ausgabe. Die Erweiterung betraf ohnehin HTML, CSS und JavaScript gleichzeitig; sie wurde deshalb als dokumentierte Ausnahme direkt umgesetzt und im Browser geprüft.
