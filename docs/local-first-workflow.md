# Local-first Coding-Workflow

Dieser Workflow minimiert Codex-Aufwand, ohne lokale Entwürfe ungeprüft zu übernehmen.

## Rollen

| Rolle | Verantwortlichkeit |
| --- | --- |
| Mensch | Ziel, Produktentscheidung sowie Freigaben für Pull Requests, Merge und Deployment |
| Codex | Handoff, Architektur, Sicherheitsreview, Integration und finale Tests |
| Lokale KI | Kleine, strukturierte Entwürfe für Code, Tests, Dokumentation oder Log-Zusammenfassungen |

## Ablauf

1. Codex schreibt Ziel, betroffene Dateien, Tests und Nicht-Ziele in `.codex/handoff.md`.
2. Starte einen lokalen Entwurf mit `./scripts/run-local-worker.ps1`.
3. Bei relevantem Quellcode: `./scripts/run-local-worker.ps1 -ContextFile src/datei.ts`.
4. Die lokale KI speichert ausschließlich einen Vorschlag in `.codex/local-draft.md`.
5. Prüfe ihn mit `./scripts/check-local-draft.ps1`.
6. Codex übernimmt nur die passenden Teile, prüft den Diff und führt die Handoff-Tests aus.
7. Erst nach menschlicher Freigabe folgen Commit, Pull Request, Merge oder Deployment.

## Entwurfsformat

Jeder lokale Entwurf besitzt diese vier Abschnitte:

1. `## Kurzplan`
2. `## Patch`
3. `## Tests`
4. `## Risiken`

Der Patch wird nicht automatisch ausgeführt. Das verhindert, dass ein schwächeres lokales Modell unerwartete Datei-, Git- oder Tool-Aktionen auslöst.

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
- Codex keine Sicherheits- oder Architekturprobleme findet.

## Sicherheit

- Der lokale Worker erhält nur `AGENTS.md`, den Handoff und ausdrücklich angegebene Dateien.
- `.env`-Dateien sind ausgeschlossen.
- Der lokale Entwurf ist in `.gitignore`, damit Projektkontext nicht versehentlich in GitHub landet.
- Es gibt keine automatische Übernahme, keinen Commit, keinen Push, keinen Merge und kein Deployment.
