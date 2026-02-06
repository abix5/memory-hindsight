#!/bin/bash
# Session start hook: load project context from Hindsight memory bank
# - Checks Hindsight availability
# - Loads project context if bank has data
# - Provides instructions for AI to use memory proactively

set -f  # disable globbing

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
SETTINGS_FILE=".claude/hindsight.json"
PAUSE_FILE=".claude/hindsight-paused"

# Check if initialized (settings file is the initialization marker)
if [ ! -f "$SETTINGS_FILE" ]; then
  # Not initialized - silently exit, don't bother user
  exit 0
fi

BANK_ID=$(bash "$PLUGIN_ROOT/scripts/get-bank-id.sh" 2>/dev/null)

# Check if paused
if [ -f "$PAUSE_FILE" ]; then
  echo '{"systemMessage": "\u23f8\ufe0f Hindsight auto-features paused. Use /hindsight:resume to re-enable."}'
  exit 0
fi

# Check if Hindsight is available (with timeout)
if ! timeout 3 hindsight bank list &>/dev/null; then
  echo '{"systemMessage": "\u26a0\ufe0f Hindsight unavailable. Memory features disabled for this session."}'
  exit 0
fi

# Check if bank exists and has data (fast: ~50ms)
STATS=$(timeout 2 hindsight bank stats "$BANK_ID" -o yaml 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$STATS" ]; then
  echo '{"systemMessage": "\ud83c\udd95 Memory bank not initialized. Run /hindsight:init to set up."}'
  exit 0
fi

# Try to extract node count from stats output
TOTAL_NODES=$(echo "$STATS" | grep -oE '[0-9]+' | head -1)

INSTRUCTIONS="MEMORY INSTRUCTIONS: You have access to Hindsight memory bank (bank: $BANK_ID). Use it throughout this session: 1) BEFORE making architectural or technology decisions, check memory with /hindsight:recall [query] to see if there are prior decisions on this topic. 2) AFTER making important decisions (architecture, tech-stack, patterns, tradeoffs, bug fixes), save them with /hindsight:retain [description with WHAT + WHY] --context [category]. Categories: architecture, tech-stack, patterns, decisions, tradeoffs, bugs, lessons. 3) Always include WHY in saved decisions, not just WHAT."

if [ -z "$TOTAL_NODES" ] || [ "$TOTAL_NODES" = "0" ]; then
  echo "{\"systemMessage\": \"Memory bank '$BANK_ID' is empty. $INSTRUCTIONS\"}"
else
  echo "{\"systemMessage\": \"Memory bank '$BANK_ID' active ($TOTAL_NODES entries). $INSTRUCTIONS\"}"
fi
