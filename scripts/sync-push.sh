#!/bin/bash
# Sync local CLAUDE.md -> GitHub repo
# Usage: ./scripts/sync-push.sh
# Cron:  */30 * * * * /path/to/sync-push.sh

set -e
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$HOME/.claude/CLAUDE.md"

if [ ! -f "$SOURCE" ]; then
  echo "CLAUDE.md not found at $SOURCE"
  exit 1
fi

# Check for changes
if diff -q "$SOURCE" "$REPO_DIR/CLAUDE.md" > /dev/null 2>&1; then
  echo "No changes."
  exit 0
fi

cp "$SOURCE" "$REPO_DIR/CLAUDE.md"
cd "$REPO_DIR"
git add CLAUDE.md
git commit -m "sync: CLAUDE.md $(date +%Y-%m-%d_%H:%M)"
git push origin main
echo "Pushed CLAUDE.md update."
