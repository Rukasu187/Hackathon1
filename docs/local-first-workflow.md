# Local-first Coding-Workflow

Dieser Workflow ist der verbindliche Standard in diesem Repository: Die lokale KI bearbeitet die Routinearbeit im robusten Text-/Patch-Modus, während Codex nur noch einen kleinen Auftrag formuliert und bei Ausnahmen eingreift.

## Wann Codex direkt arbeitet

Nur bei fehlgeschlagenem lokalen Lauf oder Test, mehreren voneinander abhängigen Dateien, Architektur, Authentifizierung, Datenmigration oder Sicherheit. Auch dann wird der Kontext auf die betroffenen Dateien und die konkrete Fehlermeldung begrenzt.

## Rollen

| Rolle | Verantwortlichkeit |
| --- | --- |
| Mensch | Ziel, Produktentscheidung sowie Freigaben für Pull Requests, Merge und Deployment |
| Codex | Kurzauftrag, Sicherheitsgrenzen, automatisches Prüfergebnis und nur bei Ausnahmen Architektur-/Sicherheitsreview |
| Lokale KI | Kleine, strukturierte Patches für Code, Tests, Dokumentation oder Log-Zusammenfassungen |

## Ablauf

1. Der Handoff nennt genau eine Ziel-Datei und die Tests.
2. Starte einen kleinen lokalen Entwurf, zum Beispiel `./scripts/run-local-worker.ps1 -Task "Ändere nur den Button-Zustand." -ContextFile app.js`.
3. Die lokale KI erhält maximal 8.000 Kontextzeichen insgesamt und speichert ihren Vorschlag als lokale Sitzungsdatei unter `~/.codex/local-sessions/Hackathon/` außerhalb des Projekts.
4. Prüfe und übernimm den Ein-Datei-Patch automatisch: `./scripts/apply-local-patch.ps1 -AllowedFile app.js -Apply`.
5. Führe die Handoff-Tests aus. Nur bei einem Fehler, mehreren Dateien oder Sicherheits-/Architekturthemen prüft Codex den vollständigen Entwurf.
6. Erst nach menschlicher Freigabe folgen Commit, Pull Request, Merge oder Deployment.

## Entwurfsformat

Jeder lokale Entwurf besitzt diese vier Abschnitte:

1. `## Kurzplan`
2. `## Patch`
3. `## Tests`
4. `## Risiken`

Die sichere Übernahme ist nur für einen Ein-Datei-Patch möglich. Das Skript blockiert `.env`, `.git`, Binärdaten, Umbenennungen, neue Dateien und jeden abweichenden Dateipfad. Bei fehlerhaften Diff-Köpfen akzeptiert es nur einen alten Kontext, der genau einmal in der erlaubten Datei vorkommt; erst dann wird die Änderung übernommen. Es erstellt keinen Commit und führt keinen Push, Merge oder Deploy aus.

## Aufgabenrouting

| Aufgabe | Standardzuständig |
| --- | --- |
| Ticket-Zusammenfassung, Mock-Daten, Dokumentation | `qwen3.5:4b` |
| Kleine Komponenten, CSS, Unit-Test-Entwürfe | `qwen2.5-coder:7b` |
| Architektur, Authentifizierung, Datenmigration, Sicherheit | Codex direkt |
| Größere, klar abgegrenzte Codeaufgaben | optional `qwen3-coder:30b` nach Benchmark |

## Qualitäts-Gate

Ein lokaler Vorschlag wird nur übernommen, wenn:

- der Patch zum Handoff passt,
- die definierten Tests erfolgreich sind,
- `git diff --check` fehlerfrei ist und
- für Routineaufgaben das automatisierte Patch-Gate erfolgreich ist; Codex prüft nur bei Fehlern oder erhöhtem Risiko zusätzlich.

## Sicherheit

- Der lokale Worker erhält nur `AGENTS.md`, den Handoff und ausdrücklich angegebene Dateien.
- Der gesamte Kontext ist auf 8.000 Zeichen begrenzt; pro Datei auf 3.500 Zeichen.
- `.env`-Dateien sind ausgeschlossen.
- Der lokale Entwurf ist in `.gitignore`, damit Projektkontext nicht versehentlich in GitHub landet.
- Es gibt keine automatische Übernahme, keinen Commit, keinen Push, keinen Merge und kein Deployment.
