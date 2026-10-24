# Hackathon1 – Projektstatus und Testnachweis

Stand: 24. Oktober 2026 · Entwicklungsstand auf dem Branch `feature/local-first-workflow`

## Worum geht es?

Hackathon1 erprobt einen sicheren **Local-first-Coding-Workflow**: Eine lokale KI erstellt kleine, klar abgegrenzte Entwürfe. Codex übernimmt Planung, Sicherheitsgrenzen, Ausnahmebehandlung und Tests. Das erste sichtbare Beispiel ist die browserlokale App **Habit Flow**.

## Aktueller Funktionsstand: Habit Flow

| Bereich | Vorhanden |
| --- | --- |
| Gewohnheiten | Anlegen, bearbeiten und löschen |
| Planung | Kategorie und Wochenziel (3×, 5× oder 7×) pro Gewohnheit |
| Tagesansicht | Als erledigt/offen markieren, Fortschrittsbalken und Tageszähler |
| Motivation | Tagesstreak und Gesamtzahl der Erledigungen in den letzten sieben Tagen |
| Übersicht | Filter für alle, offene und erledigte Einträge |
| Daten | Speicherung nur im Browser (`localStorage`), JSON-Export und -Import |
| Oberfläche | Responsive Layout für Desktop und Mobilgeräte |

Es gibt absichtlich **kein Backend, keine Anmeldung und kein Deployment**. Die Daten bleiben auf dem jeweiligen Browsergerät. Ein Löschen von Browserdaten löscht daher auch die lokalen Einträge, sofern vorher kein Export erstellt wurde.

## Verifizierte Tests

| Test | Ergebnis |
| --- | --- |
| JavaScript-Syntax: `node --check experiments/habit-tracker/app.js` | bestanden |
| Whitespace-/Patch-Prüfung: `git diff --check` | bestanden |
| Gewohnheit mit Kategorie und Wochenziel anlegen | im Browser bestanden |
| Als erledigt markieren | im Browser bestanden; Zähler, Fortschritt und Streak aktualisieren sich |
| Filter „Offen“ | im Browser bestanden |
| Gewohnheit bearbeiten | im Browser bestanden |
| Browser neu laden | im Browser bestanden; Eintrag und Status bleiben erhalten |
| JSON-Export auslösen | im Browser bestanden |
| JSON-Import über Dateiauswahl | implementiert, aber noch nicht manuell End-to-End getestet |

## So lässt sich die Demo lokal starten

```powershell
cd experiments/habit-tracker
python -m http.server 4174 --bind 127.0.0.1
```

Anschließend im Browser `http://127.0.0.1:4174/` öffnen. Zum Beenden im Terminal `Ctrl+C` drücken.

## So arbeitet die lokale KI mit Codex zusammen

```text
Aufgabe → Handoff mit einer Ziel-Datei → lokaler Textentwurf
→ abgesichertes Ein-Datei-Patch-Gate → Tests → Pull Request → menschlicher Merge
```

Der lokale Worker erhält nur die Agentenregeln, den Handoff und höchstens eine ausdrücklich erlaubte Datei. Der Kontext ist auf 8.000 Zeichen begrenzt. Er führt keine Tools oder Git-Befehle aus und darf weder committen noch pushen.

Das Patch-Gate blockiert abweichende Dateipfade, `.env`- und `.git`-Dateien, Binärdaten, Umbenennungen und neue Dateien. Bei fehlerhaften Diff-Köpfen akzeptiert es nur eindeutig passenden alten Kontext in der vorher erlaubten Datei. Dadurch werden unpassende lokale Entwürfe verworfen, statt still in das Projekt zu gelangen.

Im aktuellen Beispiel wurden zwei unpassende JavaScript-Reparaturentwürfe abgewiesen. Die spätere größere UI-Erweiterung betraf HTML, CSS und JavaScript gleichzeitig; sie wurde deshalb als dokumentierte Codex-Ausnahme umgesetzt und getestet.

## Relevante Dokumente

- [Vollständiger Local-first-Workflow](local-first-workflow.md)
- [Erster Habit-Tracker-Pipeline-Test](habit-tracker-pipeline-test.md)
- [Agentenregeln](../AGENTS.md)

## Nächste sinnvolle Schritte

1. JSON-Import einmal manuell im Browser mit einer exportierten Datei testen.
2. Ein kleines Testset für Datenmigration und Importfehler ergänzen.
3. Bei Team-Bedarf entscheiden, ob ein gemeinsames Backend und Login wirklich nötig sind.
4. Erst nach Review den Pull Request bewusst mergen; ein Deployment ist nicht Teil dieses Stands.
