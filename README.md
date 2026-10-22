# Hackathon1

Gemeinsames Hackathon-Projekt mit lokalem Coding-Workflow.

## Ablauf

```text
Idee / Issue → Codex plant → lokaler Coding-Agent implementiert
→ Tests → Codex-Review → Pull Request → menschliche Freigabe → Merge
```

## Rollen

- **Codex:** Architektur, klarer Implementierungsauftrag, Review und Debugging.
- **Lokaler Coding-Agent:** Implementierung und Tests innerhalb des Handoffs.
- **Team:** Produktumfang, Demo, Sicherheit und Merge-Freigabe.

## Start

1. Beschreibe die Aufgabe als GitHub Issue oder im Codex-Chat.
2. Lass Codex den Auftrag in `.codex/handoff.md` formulieren.
3. Starte den lokalen Agenten im Repository:

```powershell
codex exec --oss --local-provider ollama --model qwen2.5-coder:7b --sandbox workspace-write --ask-for-approval on-request "Lies .codex/handoff.md. Implementiere ausschließlich diesen Auftrag. Führe die genannten Tests aus. Ändere keine Secrets, CI-Konfiguration oder Deployment-Dateien."
```

4. Lass Codex die uncommitted Änderungen gegen den Handoff prüfen.
