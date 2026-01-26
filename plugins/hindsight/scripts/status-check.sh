#!/bin/bash
# Status check: gather all Hindsight auto-workflow status information

set -f

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
SETTINGS_FILE=".claude/hindsight.json"
PAUSE_FILE=".claude/hindsight-paused"

echo "=== Hindsight Auto-Workflow Status ==="
echo ""

# 1. Bank ID
BANK_ID=$(bash "$PLUGIN_ROOT/scripts/get-bank-id.sh" 2>/dev/null)
echo "Bank ID: ${BANK_ID:-unknown}"
echo ""

# 2. Pause status
if [ -f "$PAUSE_FILE" ]; then
  echo "Auto-features: PAUSED"
else
  echo "Auto-features: ACTIVE"
fi
echo ""

# 3. Settings
echo "Settings ($SETTINGS_FILE):"
if [ -f "$SETTINGS_FILE" ]; then
  cat "$SETTINGS_FILE"
else
  echo "  (not configured - using defaults)"
  echo "  auto_recall: true (default)"
  echo "  auto_save: hybrid (default)"
fi
echo ""

# 4. Server availability
echo "Hindsight server:"
if timeout 2 hindsight bank list &>/dev/null; then
  echo "  Status: AVAILABLE"

  # 5. Bank stats
  if [ -n "$BANK_ID" ]; then
    STATS=$(timeout 3 hindsight bank stats "$BANK_ID" -o yaml 2>/dev/null)
    if [ -n "$STATS" ]; then
      echo "  Bank stats:"
      echo "$STATS" | sed 's/^/    /'
    else
      echo "  Bank stats: bank not found or empty"
    fi
  fi
else
  echo "  Status: UNAVAILABLE"
  echo "  (auto-features will be skipped)"
fi
echo ""

# 6. Feature summary
echo "Feature details:"
echo "  SessionStart context load: $([ -f "$PAUSE_FILE" ] && echo "paused" || echo "active")"
echo "  UserPromptSubmit recall:   $([ -f "$PAUSE_FILE" ] && echo "paused" || echo "active")"
echo "  PostToolUse auto-save:     $([ -f "$PAUSE_FILE" ] && echo "paused" || echo "active")"
echo ""
echo "Controls:"
echo "  Pause all:  /hindsight:pause"
echo "  Resume all: /hindsight:resume"
echo "  Skip once:  prefix prompt with \"!\""
