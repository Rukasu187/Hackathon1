param(
  [Parameter(Mandatory = $false)]
  [string]$Task = "Erstelle einen Entwurf für den aktiven Handoff.",
  [string[]]$ContextFile = @(),
  [string]$Model = "qwen2.5-coder:7b",
  [string]$OutputFile = (Join-Path $env:USERPROFILE ".codex\local-sessions\Hackathon\local-draft.md"),
  [ValidateRange(2000, 16000)]
  [int]$MaxContextChars = 8000,
  [ValidateRange(500, 6000)]
  [int]$MaxFileChars = 3500,
  [ValidateRange(200, 1600)]
  [int]$MaxOutputTokens = 900
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

try {
  Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/version" -Method Get | Out-Null
  ollama show $Model | Out-Null
} catch {
  throw "Ollama oder das Modell $Model ist nicht bereit. Starte Ollama und prüfe es mit: ollama show $Model"
}

$blockedNames = @(".env", ".env.local", ".env.production", ".env.development")
$context = @()
$remainingContextChars = $MaxContextChars
$truncationMarker = "`n[Kontext an dieser Stelle gekürzt]"
foreach ($path in @("AGENTS.md", ".codex/handoff.md") + $ContextFile) {
  if ($remainingContextChars -le 0) {
    break
  }
  $fullPath = Join-Path $repoRoot $path
  if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
    throw "Kontextdatei fehlt: $path"
  }
  if ([IO.Path]::GetFileName($fullPath) -in $blockedNames) {
    throw "Kontextdatei ist aus Sicherheitsgründen ausgeschlossen: $path"
  }
  $relativePath = Resolve-Path -LiteralPath $fullPath -Relative
  $content = Get-Content -LiteralPath $fullPath -Raw
  $fileLimit = [Math]::Min($MaxFileChars, $remainingContextChars)
  if ($content.Length -gt $fileLimit) {
    $sourceLimit = [Math]::Max(0, $fileLimit - $truncationMarker.Length)
    $content = $content.Substring(0, $sourceLimit) + $truncationMarker
  }
  $context += "`n--- DATEI: $relativePath ---`n$content"
  $remainingContextChars -= $content.Length
}

$prompt = @"
Du bist ein lokaler Entwurfsassistent im reinen Textmodus. Du hast keine Tools und darfst niemals Tool-Aufrufe, Funktionsaufrufe, XML-Tools, Shell-Befehle, Git-Befehle, Websuchen oder Dateizugriffe ausgeben. Arbeite ausschließlich mit dem folgenden Kontext. Ändere nur Dateien, die im Auftrag ausdrücklich genannt werden. Wenn die Aufgabe nicht mit dem Kontext lösbar ist, liefere einen leeren Patch und erkläre das Risiko.

Aufgabe: $Task

Liefere genau diese vier Abschnitte und sonst keinen Text:
## Kurzplan
- maximal fünf konkrete Punkte

## Patch
```diff
ein kleiner Unified Diff mit höchstens 80 Zeilen; nur ausdrücklich erlaubte Dateien
```

## Tests
- konkrete Befehle und erwartetes Ergebnis

## Risiken
- keine oder konkrete Risiken

KONTEXT:
$($context -join "`n")
"@

$body = @{ model = $Model; prompt = $prompt; stream = $false; options = @{ temperature = 0.2; num_predict = $MaxOutputTokens } } | ConvertTo-Json -Depth 4
try {
  $response = Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/generate" -Method Post -ContentType "application/json" -Body $body
} catch {
  throw "Ollama ist nicht erreichbar. Starte den Dienst mit: ollama serve"
}

$draft = [string]$response.response
$requiredHeadings = @("## Kurzplan", "## Patch", "## Tests", "## Risiken")
$missingHeadings = @($requiredHeadings | Where-Object { -not $draft.Contains($_) })
if ($missingHeadings.Count -gt 0) {
  $repairPrompt = @"
Formatiere den folgenden lokalen Entwurf neu. Gib ausschließlich diese vier Abschnitte aus: ## Kurzplan, ## Patch, ## Tests, ## Risiken. Falls kein Code nötig ist, verwende einen leeren ```diff```-Block. Erfinde keine Tools oder Befehle außerhalb des Abschnitts Tests.

ENTWURF:
$draft
"@
  $repairBody = @{ model = $Model; prompt = $repairPrompt; stream = $false; options = @{ temperature = 0.1; num_predict = $MaxOutputTokens } } | ConvertTo-Json -Depth 4
  try {
    $draft = [string](Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/generate" -Method Post -ContentType "application/json" -Body $repairBody).response
  } catch {
    throw "Die lokale KI lieferte ein unvollständiges Format und die Format-Reparatur ist fehlgeschlagen."
  }
  $missingHeadings = @($requiredHeadings | Where-Object { -not $draft.Contains($_) })
  if ($missingHeadings.Count -gt 0) {
    throw "Die lokale KI lieferte trotz Reparatur kein gültiges Format: $($missingHeadings -join ', ')"
  }
}

if ([IO.Path]::IsPathRooted($OutputFile)) {
  $outputPath = $OutputFile
} else {
  $outputPath = Join-Path $repoRoot $OutputFile
}
$outputDirectory = Split-Path -Parent $outputPath
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
Set-Content -LiteralPath $outputPath -Value $draft -Encoding utf8
Write-Output "Lokaler Entwurf gespeichert: $outputPath (Kontext: $($MaxContextChars - $remainingContextChars)/$MaxContextChars Zeichen, Ausgabegrenze: $MaxOutputTokens Tokens)"
