# Hackathon1

Gemeinsames Hackathon-Projekt mit lokalem Coding-Workflow.

## Ablauf

```text
Idee / Issue → kurzer Handoff → lokaler Patch → automatisches Patch-Gate + Tests
→ Pull Request → menschliche Freigabe → Merge
```

## Rollen

- **Codex:** Kurzer Implementierungsauftrag, Sicherheitsgrenzen und Hilfe nur bei Fehlern, Architektur oder Sicherheit.
- **Lokale KI:** Liefert für eine explizite Datei einen begrenzten Entwurf (Plan, Patch, Tests, Risiken); sie läuft nur im Textmodus und führt keine Tools oder Git-Befehle aus.
- **Team:** Produktumfang, Demo, Sicherheit und Merge-Freigabe.

## Start

1. Beschreibe die Aufgabe als GitHub Issue oder im Codex-Chat. Codex formuliert sie dann in `.codex/handoff.md`.
2. Erstelle einen sauberen Arbeitsbranch:

```powershell
.\scripts\start-task-branch.ps1 -Branch feature/kurze-beschreibung
```

3. Starte den lokalen Worker mit einer kleinen Aufgabe und höchstens einer Kontextdatei:

```powershell
.\scripts\run-local-worker.ps1 -Task "Ändere nur die Validierung." -ContextFile scripts/check-local-draft.ps1
```

4. Der Worker speichert den Entwurf als lokale Sitzungsdatei unter `~/.codex/local-sessions/Hackathon/` außerhalb des Projekts. Bei einer Ein-Datei-Aufgabe prüfst und übernimmst du ihn über das abgesicherte Patch-Gate:

```powershell
.\scripts\apply-local-patch.ps1 -AllowedFile scripts/check-local-draft.ps1 -Apply
```

Das Patch-Gate lässt nur genau diese Datei zu. Danach führst du die Handoff-Tests aus. Codex ist erst bei einem Fehler, bei mehreren Dateien oder bei Architektur und Sicherheit nötig.
5. Erst nach dem Review erstellst du einen Pull Request. Merge und Deploy bleiben menschliche Entscheidungen.

## Was die Automatisierung prüft

- Der lokale Worker prüft, ob Ollama und das gewählte Modell verfügbar sind.
- Er übergibt nur Handoff, Agentenregeln und höchstens eine explizit angegebene Projektdatei. Der Kontext ist insgesamt auf 8.000 Zeichen begrenzt; `.env`-Dateien sind ausgeschlossen.
- Vor der Generierung prüft er, ob Ollama und das gewählte Modell bereit sind. Er darf weder committen noch pushen, führt keine Tools aus und hinterlässt einen standardisierten Entwurf. Das lokale Patch-Gate übernimmt nur einen technisch gültigen Patch für die vorher erlaubte Datei.

## Modell-Routing

- `qwen3.5:4b`: Zusammenfassungen, Tickets und Dokumentation.
- `qwen2.5-coder:7b`: kleine Komponenten, Tests und Patch-Entwürfe.
- `qwen3-coder:30b`: optionaler Qualitätsmodus für größere Aufgaben. Vor Installation ist ein separater Ressourcen-Benchmark erforderlich; das Modell wird nicht automatisch heruntergeladen.

Codex bleibt für Architektur, Security, Integration und den finalen Test-Review zuständig. Lokale Entwürfe werden erst nach erfolgreichem Qualitäts-Gate übernommen.

Die vollständige Anleitung mit Rollen, Sicherheitsregeln und Aufgabenrouting findest du in [docs/local-first-workflow.md](docs/local-first-workflow.md).

Der nachvollziehbare End-to-End-Test der Pipeline ist in [docs/habit-tracker-pipeline-test.md](docs/habit-tracker-pipeline-test.md) dokumentiert.

Für Außenstehende gibt es eine kompakte Übersicht mit Funktionsstand, Testnachweis, Startanleitung und Grenzen: [docs/project-status.md](docs/project-status.md).
