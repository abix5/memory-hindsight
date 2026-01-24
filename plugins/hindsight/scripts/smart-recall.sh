#!/bin/bash
# Smart recall hook: automatically search memory for relevant context
# Triggered on UserPromptSubmit
# - Checks opt-out conditions (! prefix, short prompts, commands)
# - Performs quick recall with low budget
# - Injects relevant context if found

set -f  # disable globbing

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
SETTINGS_FILE=".claude/hindsight.json"
PAUSE_FILE=".claude/hindsight-paused"

# Check if initialized (settings file is the initialization marker)
if [ ! -f "$SETTINGS_FILE" ]; then
  exit 0
fi

# Check if paused
if [ -f "$PAUSE_FILE" ]; then
  exit 0
fi

# Check auto_recall setting
if [ -f "$SETTINGS_FILE" ]; then
  AUTO_RECALL=$(grep -o '"auto_recall"[[:space:]]*:[[:space:]]*\(true\|false\)' "$SETTINGS_FILE" 2>/dev/null | grep -o '\(true\|false\)$')
  if [ "$AUTO_RECALL" = "false" ]; then
    exit 0
  fi
fi

# Read user prompt from stdin
INPUT=$(cat)
USER_PROMPT=$(echo "$INPUT" | jq -r '.user_prompt // empty' 2>/dev/null)

# Exit silently if no prompt
if [ -z "$USER_PROMPT" ]; then
  exit 0
fi

# Opt-out: "!" prefix means skip recall
if [[ "$USER_PROMPT" == "!"* ]]; then
  exit 0
fi

# Opt-out: slash commands
if [[ "$USER_PROMPT" == "/"* ]]; then
  exit 0
fi

# Opt-out: too short (less than 10 chars)
if [ ${#USER_PROMPT} -lt 10 ]; then
  exit 0
fi

# Opt-out: simple confirmations
LOWER_PROMPT=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]' | xargs)
case "$LOWER_PROMPT" in
  "yes"|"no"|"ok"|"y"|"n"|"да"|"нет"|"ок"|"ага"|"угу"|"continue"|"proceed"|"go ahead"|"sure"|"done"|"next")
    exit 0
    ;;
esac

# Get bank ID
BANK_ID=$(bash "$PLUGIN_ROOT/scripts/get-bank-id.sh" 2>/dev/null)
if [ -z "$BANK_ID" ]; then
  exit 0
fi

# Check Hindsight availability (quick timeout)
if ! timeout 2 hindsight bank list &>/dev/null; then
  exit 0
fi

# Perform quick recall (budget: low, max-tokens: 500 for speed)
RESULT=$(timeout 3 hindsight memory recall "$BANK_ID" "$USER_PROMPT" --budget low --max-tokens 500 2>/dev/null)

# Check if we got meaningful results
if [ -z "$RESULT" ]; then
  exit 0
fi

# Filter out "no results" type responses
LOWER_RESULT=$(echo "$RESULT" | tr '[:upper:]' '[:lower:]')
if [[ "$LOWER_RESULT" == *"no relevant"* ]] || [[ "$LOWER_RESULT" == *"no memories"* ]] || [[ "$LOWER_RESULT" == *"nothing found"* ]]; then
  exit 0
fi

# Escape result for JSON and truncate
ESCAPED=$(echo "$RESULT" | tr '\n' ' ' | sed 's/"/\\"/g' | head -c 800)
echo "{\"systemMessage\": \"\ud83d\udcdd Context from memory: $ESCAPED\"}"
