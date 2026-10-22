# Hackathon1

Gemeinsames Hackathon-Projekt mit lokalem Coding-Workflow.

## Ablauf

```text
Idee / Issue → Codex plant → Arbeitsbranch → lokaler Coding-Agent implementiert
→ Tests + Bericht → Codex-Review → Pull Request → menschliche Freigabe → Merge
```

## Rollen

- **Codex:** Architektur, klarer Implementierungsauftrag, Review und Debugging.
- **Lokaler Coding-Agent:** Implementierung und Tests innerhalb des Handoffs; schreibt einen Abschlussbericht.
- **Team:** Produktumfang, Demo, Sicherheit und Merge-Freigabe.

## Start

1. Beschreibe die Aufgabe als GitHub Issue oder im Codex-Chat. Codex formuliert sie dann in `.codex/handoff.md`.
2. Erstelle einen sauberen Arbeitsbranch:

```powershell
.\scripts\start-task-branch.ps1 -Branch feature/kurze-beschreibung
```

3. Starte den lokalen Agenten. Ohne Parameter arbeitet er den aktuellen Handoff ab:

```powershell
.\scripts\run-local-worker.ps1
```

4. Der Agent speichert seine Zusammenfassung in `.codex/local-worker-report.md`. Lass Codex anschließend den Bericht und `git diff` gegen den Handoff prüfen.
5. Erst nach dem Review erstellst du einen Pull Request. Merge und Deploy bleiben menschliche Entscheidungen.

## Was die Automatisierung prüft

- Der lokale Worker prüft, ob Codex CLI, Ollama und `qwen2.5-coder:7b` verfügbar sind.
- Er arbeitet in einer schreibbaren Sandbox und verlangt bei riskanteren Aktionen eine Bestätigung.
- Er darf weder committen noch pushen und hinterlässt einen standardisierten Bericht für das Codex-Review.
