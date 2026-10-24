param(
  [string]$DraftFile = (Join-Path $env:USERPROFILE ".codex\local-sessions\Hackathon\local-draft.md")
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot
if ([IO.Path]::IsPathRooted($DraftFile)) {
  $draftPath = $DraftFile
} else {
  $draftPath = Join-Path $repoRoot $DraftFile
}

if (-not (Test-Path -LiteralPath $draftPath -PathType Leaf)) {
  throw "Kein lokaler Entwurf gefunden: $DraftFile"
}

$draft = Get-Content -LiteralPath $draftPath -Raw
foreach ($heading in @("## Kurzplan", "## Patch", "## Tests", "## Risiken")) {
  if (-not $draft.Contains($heading)) {
    throw "Entwurf enthält den erforderlichen Abschnitt nicht: $heading"
  }
}

git diff --check
if ($LASTEXITCODE -ne 0) {
  throw "git diff --check ist fehlgeschlagen."
}

Write-Output "Entwurfsformat und Git-Diff sind gültig. Ein Ein-Datei-Patch kann nun über scripts/apply-local-patch.ps1 geprüft werden."
