param(
  [Parameter(Mandatory = $true)]
  [string]$Task
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

codex exec --oss --local-provider ollama --model qwen2.5-coder:7b -c 'model_reasoning_effort="none"' --sandbox workspace-write --ask-for-approval on-request "Lies AGENTS.md und .codex/handoff.md. Implementiere ausschließlich diesen Auftrag: $Task. Führe die genannten Tests aus. Ändere keine Secrets, CI-Konfiguration oder Deployment-Dateien."
