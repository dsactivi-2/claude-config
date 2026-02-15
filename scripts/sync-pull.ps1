# Sync GitHub repo -> local CLAUDE.md (Windows)
# Usage: .\scripts\sync-pull.ps1
# Task Scheduler: every 30 min

$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Target = "$env:USERPROFILE\.claude\CLAUDE.md"

Set-Location $RepoDir
git pull origin main --quiet 2>$null

if (!(Test-Path $Target)) {
  New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
}

$src = Get-FileHash "$RepoDir\CLAUDE.md" -Algorithm MD5
$dst = if (Test-Path $Target) { Get-FileHash $Target -Algorithm MD5 } else { $null }

if (!$dst -or ($src.Hash -ne $dst.Hash)) {
  Copy-Item "$RepoDir\CLAUDE.md" $Target -Force
  Write-Host "CLAUDE.md aktualisiert."
} else {
  Write-Host "Keine Aenderungen."
}
