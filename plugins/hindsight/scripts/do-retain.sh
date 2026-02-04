#!/bin/bash
# Wrapper: reads content from stdin (heredoc), takes category as $1
# Usage: bash do-retain.sh <category> <<'EOF'
# content here
# EOF
set -f
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
BANK_ID=$(bash "$PLUGIN_ROOT/scripts/get-bank-id.sh" 2>/dev/null)
[ -z "$BANK_ID" ] && echo "Error: No bank_id. Run /hindsight:init" >&2 && exit 1
CATEGORY="${1:-general}"
CONTENT=$(cat)
[ -z "$CONTENT" ] && echo "Error: No content via stdin" >&2 && exit 1
hindsight memory retain "$BANK_ID" "$CONTENT" --context "$CATEGORY" -o yaml 2>&1
