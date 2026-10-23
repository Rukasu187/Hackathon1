# Hackathon1

Gemeinsames Hackathon-Projekt mit lokalem Coding-Workflow.

## Ablauf

```text
Idee / Issue → Codex plant → lokaler Entwurf → Codex-Review + Tests
→ Pull Request → menschliche Freigabe → Merge
```

## Rollen

- **Codex:** Architektur, klarer Implementierungsauftrag, Review und Debugging.
- **Lokale KI:** Liefert begrenzte Entwürfe (Plan, Patch, Tests, Risiken) auf Basis des Handoffs; führt keine Tools oder Git-Befehle aus.
- **Team:** Produktumfang, Demo, Sicherheit und Merge-Freigabe.

## Start

1. Beschreibe die Aufgabe als GitHub Issue oder im Codex-Chat. Codex formuliert sie dann in `.codex/handoff.md`.
2. Erstelle einen sauberen Arbeitsbranch:

```powershell
.\scripts\start-task-branch.ps1 -Branch feature/kurze-beschreibung
```

3. Starte den lokalen Entwurfs-Worker. Ohne Parameter verwendet er den aktuellen Handoff:

```powershell
.\scripts\run-local-worker.ps1
```

4. Der Worker speichert den Entwurf in `.codex/local-draft.md`. Lass Codex anschließend den Entwurf, `git diff` und die Tests gegen den Handoff prüfen. Der Entwurf wird nie automatisch angewendet.
5. Erst nach dem Review erstellst du einen Pull Request. Merge und Deploy bleiben menschliche Entscheidungen.

## Was die Automatisierung prüft

- Der lokale Worker prüft, ob Ollama und das gewählte Modell verfügbar sind.
- Er übergibt nur Handoff, Agentenregeln und explizit angegebene Projektdateien. `.env`-Dateien sind ausgeschlossen.
- Er darf weder committen noch pushen, führt keine Tools aus und hinterlässt einen standardisierten Entwurf für das Codex-Review.

## Modell-Routing

- `qwen3.5:4b`: Zusammenfassungen, Tickets und Dokumentation.
- `qwen2.5-coder:7b`: kleine Komponenten, Tests und Patch-Entwürfe.
- `qwen3-coder:30b`: optionaler Qualitätsmodus für größere Aufgaben. Vor Installation ist ein separater Ressourcen-Benchmark erforderlich; das Modell wird nicht automatisch heruntergeladen.

Codex bleibt für Architektur, Security, Integration und den finalen Test-Review zuständig. Lokale Entwürfe werden erst nach erfolgreichem Qualitäts-Gate übernommen.

Die vollständige Anleitung mit Rollen, Sicherheitsregeln und Aufgabenrouting findest du in [docs/local-first-workflow.md](docs/local-first-workflow.md).
