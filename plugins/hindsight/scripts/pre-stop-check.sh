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

# Return instruction to review and save decisions before ending
cat << 'EOF'
{"systemMessage": "BEFORE ENDING: Review this session for important decisions that should be saved to memory. For each significant decision (architecture, tech-stack, patterns, tradeoffs, bug fixes, lessons learned), save it with /hindsight:retain [WHAT was decided + WHY] --context [category]. Skip if nothing significant was decided."}
EOF
