param(
  [Parameter(Mandatory = $false)]
  [string]$Task = "Erstelle einen Entwurf für den aktiven Handoff.",
  [string[]]$ContextFile = @(),
  [string]$Model = "qwen2.5-coder:7b",
  [string]$OutputFile = ".codex/local-draft.md"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
  throw "Ollama wurde nicht gefunden. Installiere Ollama und starte den lokalen Dienst."
}

if (-not (ollama list | Select-String -SimpleMatch $Model)) {
  throw "Das lokale Modell $Model fehlt. Installiere es bewusst mit: ollama pull $Model"
}

$blockedNames = @(".env", ".env.local", ".env.production", ".env.development")
$context = @()
foreach ($path in @("AGENTS.md", ".codex/handoff.md") + $ContextFile) {
  $fullPath = Join-Path $repoRoot $path
  if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
    throw "Kontextdatei fehlt: $path"
  }
  if ([IO.Path]::GetFileName($fullPath) -in $blockedNames) {
    throw "Kontextdatei ist aus Sicherheitsgründen ausgeschlossen: $path"
  }
  $relativePath = Resolve-Path -LiteralPath $fullPath -Relative
  $content = Get-Content -LiteralPath $fullPath -Raw
  $context += "`n--- DATEI: $relativePath ---`n$content"
}

$prompt = @"
Du bist ein lokaler Entwurfsassistent. Du darfst keine Werkzeuge, Shell-Befehle, Git-Befehle, Websuche oder Dateizugriffe ausführen. Arbeite ausschließlich mit dem folgenden Kontext.

Aufgabe: $Task

Liefere genau diese vier Abschnitte und sonst keinen Text:
## Kurzplan
- maximal fünf konkrete Punkte

## Patch
```diff
ein kleiner Unified Diff; nur Dateien aus dem Handoff
```

## Tests
- konkrete Befehle und erwartetes Ergebnis

## Risiken
- keine oder konkrete Risiken

KONTEXT:
$($context -join "`n")
"@

$body = @{ model = $Model; prompt = $prompt; stream = $false; options = @{ temperature = 0.2 } } | ConvertTo-Json -Depth 4
try {
  $response = Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/generate" -Method Post -ContentType "application/json" -Body $body
} catch {
  throw "Ollama ist nicht erreichbar. Starte den Dienst mit: ollama serve"
}

$outputPath = Join-Path $repoRoot $OutputFile
$outputDirectory = Split-Path -Parent $outputPath
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
Set-Content -LiteralPath $outputPath -Value $response.response -Encoding utf8
Write-Output "Lokaler Entwurf gespeichert: $outputPath"
