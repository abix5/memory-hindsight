#!/bin/bash
# Pre-stop hook: remind to save important decisions before session ends
# Only triggers if Hindsight is initialized and not paused

set -f  # disable globbing

SETTINGS_FILE=".claude/hindsight.json"
PAUSE_FILE=".claude/hindsight-paused"

# Check if initialized
if [ ! -f "$SETTINGS_FILE" ]; then
  exit 0
fi

# Check if paused
if [ -f "$PAUSE_FILE" ]; then
  exit 0
fi

# Check Hindsight availability (quick)
if ! timeout 2 hindsight bank list &>/dev/null; then
  exit 0
fi

# Return prompt-like message to remind about saving
cat << 'EOF'
{"systemMessage": "🧠 Session ending. If any important decisions were made (architecture, tech choices, bug fixes, tradeoffs), consider saving them with /hindsight:retain before ending."}
EOF
