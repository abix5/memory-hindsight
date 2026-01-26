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

# Check if bank exists and has data
STATS=$(timeout 3 hindsight bank stats "$BANK_ID" -o yaml 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$STATS" ]; then
  echo '{"systemMessage": "\ud83c\udd95 Memory bank not initialized. Run /hindsight:init to set up."}'
  exit 0
fi

# Try to extract node count from stats output
TOTAL_NODES=$(echo "$STATS" | grep -oE '[0-9]+' | head -1)

if [ -z "$TOTAL_NODES" ] || [ "$TOTAL_NODES" = "0" ]; then
  echo '{"systemMessage": "\ud83c\udd95 Memory bank empty. INSTRUCTION: Save important decisions during this session using /hindsight:retain."}'
else
  # Load key context with reflect (budget: low for speed)
  CONTEXT=$(timeout 5 hindsight memory reflect "$BANK_ID" "Summarize key architectural decisions, technology choices, and important context for this project in 2-3 sentences" --budget low -o yaml 2>/dev/null | head -c 1500)

  if [ -n "$CONTEXT" ]; then
    # Escape for JSON
    ESCAPED=$(echo "$CONTEXT" | tr '\n' ' ' | sed 's/"/\\"/g' | head -c 1000)
    echo "{\"systemMessage\": \"\ud83d\udcda Memory bank active ($TOTAL_NODES entries). Context: $ESCAPED. INSTRUCTION: Use this context when answering. Check memory before making decisions (/hindsight:recall). Save new decisions with /hindsight:retain.\"}"
  else
    echo "{\"systemMessage\": \"\ud83d\udcda Memory bank active ($TOTAL_NODES entries). INSTRUCTION: Check memory before making decisions (/hindsight:recall). Save important decisions with /hindsight:retain.\"}"
  fi
fi
