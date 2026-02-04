#!/bin/bash
# Wrapper: reads question from stdin (heredoc), takes budget=$1, max-tokens=$2
# Usage: bash do-reflect.sh <budget> [max-tokens] <<'EOF'
# question here
# EOF
set -f
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
BANK_ID=$(bash "$PLUGIN_ROOT/scripts/get-bank-id.sh" 2>/dev/null)
[ -z "$BANK_ID" ] && echo "Error: No bank_id. Run /hindsight:init" >&2 && exit 1
BUDGET="${1:-mid}"
MAX_TOKENS="${2:-4096}"
QUESTION=$(cat)
[ -z "$QUESTION" ] && echo "Error: No question via stdin" >&2 && exit 1
hindsight memory reflect "$BANK_ID" "$QUESTION" --budget "$BUDGET" --max-tokens "$MAX_TOKENS" -o yaml 2>&1
