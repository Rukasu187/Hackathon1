param(
  [string]$Task = "Erstelle einen Entwurf für den aktiven Auftrag aus .codex/handoff.md.",
  [string[]]$ContextFile = @(),
  [string]$Model = "qwen2.5-coder:7b"
)

$script = Join-Path $PSScriptRoot "invoke-local-draft.ps1"
& $script -Task $Task -ContextFile $ContextFile -Model $Model
exit $LASTEXITCODE
