# Implementierungsauftrag

## Ziel
Richte eine projektlokale Local-first-Pipeline ein, in der die lokale KI strukturierte Codeentwürfe liefert und Codex nur Planung, gezielten Review und Qualitätsprüfung übernimmt.

## Betroffene Dateien
- `scripts/invoke-local-draft.ps1` – ruft Ollama im Textentwurfs-Modus auf.
- `scripts/run-local-worker.ps1` – kompatibler Einstiegspunkt für lokale Entwürfe.
- `scripts/check-local-draft.ps1` – prüft Entwurfsformat und Git-Diff.
- `.codex/local-draft.md` – lokaler Entwurf, nicht automatisch anwenden.
- `README.md` und `AGENTS.md` – dokumentieren Rollen, Routing und Qualitäts-Gates.
- `docs/local-first-workflow.md` – ausführliche, versionierte GitHub-Anleitung.
- `.gitignore` – schließt generierte lokale Entwürfe aus.

## Architektur und Schritte
1. Die lokale KI darf keine Shell-, Git- oder Tool-Aufrufe erhalten; sie liefert ausschließlich einen strukturierten Entwurf.
2. Der Entwurf enthält Kurzplan, Patch, Tests und Risiken und wird nie automatisch angewendet.
3. Kontext beschränkt sich auf Handoff, AGENTS.md und explizit übergebene Projektdateien; `.env`-Dateien sind ausgeschlossen.
4. Codex entscheidet anhand von Handoff, Diff und Tests über die Übernahme.
5. Das Standardmodell bleibt `qwen2.5-coder:7b`; ein größeres Modell wird nur als optionaler Qualitätsmodus dokumentiert, nicht heruntergeladen.

## Akzeptanzkriterien
- `scripts/invoke-local-draft.ps1` läuft mit einem installierten Ollama-Modell und erzeugt einen Entwurf.
- Der Entwurf erfüllt das vierteilige Format.
- Die Scripts lesen keine `.env`-Dateien und führen keine Git-Schreiboperationen aus.
- Es gibt keine Commits, Pushes, Merges, Deployments oder globalen Codex-Konfigurationsänderungen.
- Die Dokumentation beschreibt das Aufgabenrouting und die Qualitäts-Gates.

## Testbefehle
- `powershell -NoProfile -Command "[scriptblock]::Create((Get-Content -Raw .\scripts\invoke-local-draft.ps1)) | Out-Null"`
- `powershell -NoProfile -File .\scripts\check-local-draft.ps1`
- `git diff --check`

## Nicht-Ziele
- Kein autonomes Schreiben von Produktcode durch die lokale KI.
- Kein Download des 30B-Modells ohne separaten Ressourcen-Benchmark und menschliche Freigabe.
- Keine Änderungen an Secrets, Deployment, CI oder globaler Git-/Codex-Konfiguration.
- Kein Commit, Push, Merge oder Branch-Wechsel.
