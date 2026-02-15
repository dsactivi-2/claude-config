#!/bin/bash
# Sync GitHub repo -> local CLAUDE.md (Mac/Linux)
# Usage: ./scripts/sync-pull.sh

set -e
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.claude/CLAUDE.md"

cd "$REPO_DIR"
git pull origin main --quiet

if ! diff -q "$REPO_DIR/CLAUDE.md" "$TARGET" > /dev/null 2>&1; then
  cp "$REPO_DIR/CLAUDE.md" "$TARGET"
  echo "CLAUDE.md aktualisiert."
else
  echo "Keine Aenderungen."
fi
