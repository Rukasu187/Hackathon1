# Agent-Regeln

## Arbeitsablauf
1. Lies zuerst `.codex/handoff.md`.
2. Erstelle vor einer Implementierung einen kurzen Plan mit höchstens acht Punkten.
3. Begrenze Änderungen auf den beschriebenen Auftrag.
4. Führe die im Handoff genannten Tests aus und dokumentiere ihr Ergebnis.

## Sicherheit und Git
- Keine Secrets, Tokens oder `.env`-Dateien ausgeben, committen oder verändern.
- Keine Deployments, Releases, Merges oder Pushes ohne menschliche Freigabe.
- Der lokale Coding-Agent erstellt keine Commits und wechselt keinen Branch.
- Jede Funktion kommt in einen eigenen Branch; Änderungen werden per Pull Request integriert.
- Pull Requests prüfen auf funktionale Fehler, Sicherheitsrisiken und fehlende Tests.

## Übergabe zwischen Agenten
- Codex erstellt oder aktualisiert `.codex/handoff.md`.
- Die lokale KI arbeitet im Local-first-Modus: Sie erhält nur den Handoff und explizit freigegebene Dateien und liefert einen strukturierten Entwurf, keinen autonomen Tool-Lauf.
- Der Entwurf wird in `.codex/local-draft.md` gespeichert und enthält Kurzplan, Patch, Tests und Risiken.
- Codex prüft danach Entwurf, Diff und Tests gegen den Handoff, bevor Änderungen übernommen werden.
