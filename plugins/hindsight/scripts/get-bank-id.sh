#!/bin/bash
# Get bank_id from .claude/hindsight.json settings

set -e

SETTINGS_FILE=".claude/hindsight.json"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "ERROR: Settings file not found: $SETTINGS_FILE"
  echo "Please run /hindsight:init first"
  exit 1
fi

# Extract bank_id from JSON using grep and sed (no jq dependency)
BANK_ID=$(grep -o '"bank_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$SETTINGS_FILE" | sed 's/.*"bank_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

if [ -z "$BANK_ID" ]; then
  echo "ERROR: bank_id not found in $SETTINGS_FILE"
  exit 1
fi

echo "$BANK_ID"
