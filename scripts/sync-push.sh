#!/bin/bash
# Sync local CLAUDE.md -> GitHub via Pull Request
# Cron: 0 6 * * * (taeglich um 06:00)
# Aenderungen gehen NUR ueber PR, nie direkt auf main

set -e
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$HOME/.claude/CLAUDE.md"
BRANCH="sync/claude-md-$(date +%Y%m%d)"

if [ ! -f "$SOURCE" ]; then
  echo "CLAUDE.md not found at $SOURCE"
  exit 1
fi

if diff -q "$SOURCE" "$REPO_DIR/CLAUDE.md" > /dev/null 2>&1; then
  echo "$(date): No changes."
  exit 0
fi

cd "$REPO_DIR"
git fetch origin main --quiet
git checkout -B "$BRANCH" origin/main --quiet
cp "$SOURCE" "$REPO_DIR/CLAUDE.md"
git add CLAUDE.md
git commit -m "sync: CLAUDE.md $(date +%Y-%m-%d)" --quiet

git push origin "$BRANCH" --force --quiet 2>/dev/null

# PR erstellen falls noch keine offen
EXISTING=$(gh pr list --head "$BRANCH" --json number --jq 'length' 2>/dev/null || echo "0")
if [ "$EXISTING" = "0" ]; then
  gh pr create \
    --title "Sync CLAUDE.md $(date +%Y-%m-%d)" \
    --body "Automatischer Sync der lokalen CLAUDE.md." \
    --head "$BRANCH" \
    --base main
  echo "$(date): PR erstellt."
else
  echo "$(date): PR existiert bereits."
fi

git checkout main --quiet
