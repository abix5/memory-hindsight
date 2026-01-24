#!/bin/bash
# Get bank_id for Hindsight operations
# Priority:
#   1. .claude/hindsight.json (if exists and has bank_id)
#   2. Git remote origin (user/repo → user-repo)
#   3. Current directory name (fallback)
#
# Usage: get-bank-id.sh
# Output: bank_id on stdout, errors on stderr
# Exit codes: 0 = success, 1 = error

set -e

SETTINGS_FILE=".claude/hindsight.json"

# Try to read from settings file first
if [ -f "$SETTINGS_FILE" ]; then
  BANK_ID=$(grep -o '"bank_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$SETTINGS_FILE" 2>/dev/null | sed 's/.*"bank_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || true)
  if [ -n "$BANK_ID" ]; then
    echo "$BANK_ID"
    exit 0
  fi
fi

# Try git remote origin
if git rev-parse --git-dir >/dev/null 2>&1; then
  REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || true)
  if [ -n "$REMOTE_URL" ]; then
    # Extract user/repo from various URL formats:
    # https://github.com/user/repo.git
    # git@github.com:user/repo.git
    # https://github.com/user/repo
    BANK_ID=$(echo "$REMOTE_URL" | sed -E 's/.*[:/]([^/]+)\/([^/]+?)(\.git)?$/\1-\2/' | tr '[:upper:]' '[:lower:]')
    if [ -n "$BANK_ID" ] && [ "$BANK_ID" != "$REMOTE_URL" ]; then
      echo "$BANK_ID"
      exit 0
    fi
  fi
fi

# Fallback to directory name
BANK_ID=$(basename "$PWD" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
echo "$BANK_ID"
