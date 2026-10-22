param(
  [string]$Task = "Implementiere den aktiven Auftrag aus .codex/handoff.md."
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
  throw "Codex CLI wurde nicht gefunden. Installiere Codex und melde dich an."
}

if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
  throw "Ollama wurde nicht gefunden. Installiere Ollama und starte den Dienst."
}

$model = "qwen2.5-coder:7b"
if (-not (ollama list | Select-String -SimpleMatch $model)) {
  throw "Das lokale Modell $model fehlt. Starte zuerst: ollama pull $model"
}

$reportPath = Join-Path $repoRoot ".codex\local-worker-report.md"
$prompt = @"
Lies zuerst AGENTS.md und .codex/handoff.md.

Implementiere ausschließlich diesen Auftrag: $Task

Halte alle Regeln ein. Ändere keine Secrets, CI-Konfiguration oder Deployment-Dateien. Führe die im Handoff genannten Tests aus. Committe, pushe, merge oder deploye nichts.

Antworte zum Schluss in genau diesem Format:
## Ergebnis
- <was umgesetzt wurde>

## Geänderte Dateien
- <Datei: Zweck>

## Tests
- <Befehl: Ergebnis>

## Offene Punkte
- <keine oder Beschreibung>
"@

& codex exec --oss --local-provider ollama --model $model -c 'model_reasoning_effort="none"' --sandbox workspace-write --ask-for-approval on-request --output-last-message $reportPath $prompt
exit $LASTEXITCODE
