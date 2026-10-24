param(
  [string]$Task = "Erstelle einen Entwurf für den aktiven Auftrag aus .codex/handoff.md.",
  [string[]]$ContextFile = @(),
  [string]$Model = "qwen2.5-coder:7b",
  [int]$MaxContextChars = 8000,
  [int]$MaxFileChars = 3500,
  [int]$MaxOutputTokens = 900
)

$script = Join-Path $PSScriptRoot "invoke-local-draft.ps1"
& $script -Task $Task -ContextFile $ContextFile -Model $Model -MaxContextChars $MaxContextChars -MaxFileChars $MaxFileChars -MaxOutputTokens $MaxOutputTokens
exit $LASTEXITCODE
