param(
  [Parameter(Mandatory = $true)]
  [ValidatePattern('^[a-z0-9][a-z0-9/-]*$')]
  [string]$Branch
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

if (git status --porcelain) {
  throw "Der Arbeitsbaum ist nicht sauber. Prüfe oder committe die vorhandenen Änderungen zuerst."
}

git fetch origin
git switch main
git pull --ff-only origin main
git switch --create $Branch

Write-Host "Arbeitsbranch bereit: $Branch"
