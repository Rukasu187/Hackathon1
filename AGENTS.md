# Hackathon

- Lies/aktualisiere `.codex/handoff.md`, plane kurz (max. 8 Punkte), bleibe im Auftrag und teste.
- **Local-first:** Routinearbeit zuerst lokal; nur Handoff + eine Ziel-Datei, max. 8.000 Zeichen, Text/Patch ohne Tools.
- Gültige Ein-Datei-Patches: `scripts/apply-local-patch.ps1 -AllowedFile <datei> -Apply`. Codex codet nur bei Fehlern, mehreren Dateien, Architektur, Auth, Migration oder Sicherheit.
- Halte Kontext, Antworten, Diffs und Logs klein; externe Recherche/Tools nur wenn nötig.
- Keine Secrets/`.env`; keine Commits, Pushes, Merges oder Deployments. Lokale KI wechselt keinen Branch und committet nicht.
- Jede Funktion: Branch + PR mit Fehler-, Sicherheits- und Testreview. Sitzungsentwürfe nie in Git. Details: `docs/local-first-workflow.md`.
