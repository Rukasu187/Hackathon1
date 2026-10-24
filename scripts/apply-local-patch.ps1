param(
  [Parameter(Mandatory = $true)]
  [string]$AllowedFile,
  [string]$DraftFile = (Join-Path $env:USERPROFILE ".codex\local-sessions\Hackathon\local-draft.md"),
  [switch]$Apply
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

if ($AllowedFile -match '(^|[\\/])\.git([\\/]|$)|(^|[\\/])\.env') {
  throw "Die erlaubte Datei darf weder .git noch eine .env-Datei sein."
}

if ([IO.Path]::IsPathRooted($DraftFile)) {
  $draftPath = $DraftFile
} else {
  $draftPath = Join-Path $repoRoot $DraftFile
}
if (-not (Test-Path -LiteralPath $draftPath -PathType Leaf)) {
  throw "Kein lokaler Entwurf gefunden: $DraftFile"
}

$draft = Get-Content -LiteralPath $draftPath -Raw
$match = [regex]::Match($draft, '(?ms)^## Patch\s*\r?\n```[A-Za-z0-9_-]*\s*\r?\n(.*?)^```\s*\r?\n(?=## Tests)')
if (-not $match.Success) {
  throw "Der Entwurf enthält keinen gültigen, abgegrenzten Diff-Block."
}

$patch = $match.Groups[1].Value.Trim()
if ([string]::IsNullOrWhiteSpace($patch)) {
  throw "Der lokale Entwurf enthält absichtlich keinen Patch."
}
if ($patch -match '(?m)^(?:new file mode|deleted file mode|rename (?:from|to)|Binary files|GIT binary patch)') {
  throw "Dateioperationen, Umbenennungen und Binär-Patches sind nicht erlaubt."
}

$headers = [regex]::Matches($patch, '(?m)^diff --git a/(.+) b/(.+)$')
if ($headers.Count -gt 1) {
  throw "Es ist genau ein Datei-Patch erlaubt."
}
if ($headers.Count -eq 1) {
  foreach ($header in $headers) {
    if ($header.Groups[1].Value -ne $AllowedFile -or $header.Groups[2].Value -ne $AllowedFile) {
      throw "Der Patch darf nur $AllowedFile ändern."
    }
  }
  $allowedHeader = '(?m)^(?:---|\+\+\+) [ab]/' + [regex]::Escape($AllowedFile) + '(?:\t|$)'
  if ([regex]::Matches($patch, $allowedHeader).Count -ne 2) {
    throw "Die Diff-Dateiköpfe passen nicht zur erlaubten Datei."
  }
}

function Get-ContextFallbackContent {
  param([string]$PatchText, [string]$TargetFile)

  $hunks = [regex]::Matches($PatchText, '(?ms)^@@.*?\r?\n(.*?)(?=^@@|\z)')
  $hunkTexts = if ($hunks.Count -gt 0) {
    @($hunks | ForEach-Object { $_.Groups[1].Value })
  } else {
    @($PatchText)
  }

  $targetPath = Join-Path $repoRoot $TargetFile
  $current = Get-Content -LiteralPath $targetPath -Raw
  $newline = if ($current.Contains("`r`n")) { "`r`n" } else { "`n" }

  foreach ($hunkText in $hunkTexts) {
    $oldLines = [System.Collections.Generic.List[string]]::new()
    $newLines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in ($hunkText -split "`r?`n")) {
      if ($line.StartsWith(' ')) {
        $oldLines.Add($line.Substring(1))
        $newLines.Add($line.Substring(1))
      } elseif ($line.StartsWith('-')) {
        $oldLines.Add($line.Substring(1))
      } elseif ($line.StartsWith('+')) {
        $newLines.Add($line.Substring(1))
      } elseif ($line -and $line -ne '\ No newline at end of file') {
        throw "Der Diff-Hunk enthält eine ungültige Zeile."
      }
    }
    if ($oldLines.Count -eq 0) {
      throw "Der Kontext-Fallback benötigt alten Dateiinhalt."
    }

    $oldBlock = [string]::Join($newline, $oldLines)
    $newBlock = [string]::Join($newline, $newLines)
    $first = $current.IndexOf($oldBlock, [System.StringComparison]::Ordinal)
    if ($first -lt 0 -or $current.IndexOf($oldBlock, $first + 1, [System.StringComparison]::Ordinal) -ge 0) {
      throw "Der alte Patch-Kontext wurde nicht genau einmal in $TargetFile gefunden."
    }
    $current = $current.Substring(0, $first) + $newBlock + $current.Substring($first + $oldBlock.Length)
  }

  return $current
}

$tempPatch = [IO.Path]::GetTempFileName()
try {
  Set-Content -LiteralPath $tempPatch -Value $patch -Encoding utf8
  & git apply --check --recount --whitespace=error $tempPatch 2>$null
  $gitPatchIsValid = $LASTEXITCODE -eq 0
  $fallbackContent = $null
  if (-not $gitPatchIsValid) {
    $fallbackContent = Get-ContextFallbackContent -PatchText $patch -TargetFile $AllowedFile
  }

  if ($Apply) {
    if ($gitPatchIsValid) {
      & git apply --recount --whitespace=error $tempPatch
      if ($LASTEXITCODE -ne 0) {
        throw "git apply konnte den geprüften Patch nicht übernehmen."
      }
    } else {
      Set-Content -LiteralPath (Join-Path $repoRoot $AllowedFile) -Value $fallbackContent -NoNewline -Encoding utf8
      $global:LASTEXITCODE = 0
    }
    Write-Output "Lokaler Patch wurde ausschließlich auf $AllowedFile angewendet."
  } else {
    Write-Output "Lokaler Patch ist für $AllowedFile gültig. Trockenlauf beendet; für Übernahme mit -Apply erneut ausführen."
  }
} finally {
  Remove-Item -LiteralPath $tempPatch -Force -ErrorAction SilentlyContinue
}
