# Claude Code Config Sync

Synchronisiert CLAUDE.md, Skills und Setup zwischen Mac und Windows.

## Schutz

- `main` Branch ist geschuetzt (Branch Protection)
- Kein direktes Pushen auf main moeglich
- Aenderungen NUR ueber Pull Request
- Force-Push und Branch-Loeschen deaktiviert
- CI prueft PowerShell-Syntax + Token-Budget bei jedem PR

## Windows Setup (Erstmalig)

PowerShell als Admin oeffnen, eingeben:

```powershell
irm https://raw.githubusercontent.com/dsactivi-2/claude-config/main/setup.ps1|iex
```

Dann Repo klonen fuer Sync:

```powershell
cd $env:USERPROFILE
git clone https://github.com/dsactivi-2/claude-config.git
```

Taeglich automatisch pullen (Task Scheduler):

```powershell
schtasks /create /tn "ClaudeSync" /tr "powershell -ExecutionPolicy Bypass -File %USERPROFILE%\claude-config\scripts\sync-pull.ps1" /sc daily /st 07:00
```

## Mac Sync (laeuft automatisch)

Cron taeglich um 06:00 — erstellt PR bei Aenderungen:

```
0 6 * * * /Users/dsselmanovic/claude-config/scripts/sync-push.sh
```
