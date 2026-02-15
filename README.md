# Claude Code Config Sync

Synchronisiert CLAUDE.md, Skills und Setup zwischen Mac und Windows.

## Windows Setup (Erstmalig)

```powershell
irm https://raw.githubusercontent.com/dsactivi-2/claude-config/main/setup.ps1|iex
```

## Sync

### Mac -> GitHub (Push)
```bash
./scripts/sync-push.sh
```

### GitHub -> Windows (Pull)
```powershell
.\scripts\sync-pull.ps1
```

### Automatisch (Cron / Task Scheduler)

**Mac** — alle 30 Min:
```bash
crontab -e
# */30 * * * * /path/to/claude-config/scripts/sync-push.sh
```

**Windows** — alle 30 Min:
```powershell
schtasks /create /tn "ClaudeSync" /tr "powershell -File %USERPROFILE%\claude-config\scripts\sync-pull.ps1" /sc minute /mo 30
```
