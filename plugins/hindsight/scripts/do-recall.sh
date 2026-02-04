#!/bin/bash
# Wrapper: reads query from stdin (heredoc), takes budget=$1, max-tokens=$2
# Usage: bash do-recall.sh <budget> [max-tokens] <<'EOF'
# query here
# EOF
set -f
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
BANK_ID=$(bash "$PLUGIN_ROOT/scripts/get-bank-id.sh" 2>/dev/null)
[ -z "$BANK_ID" ] && echo "Error: No bank_id. Run /hindsight:init" >&2 && exit 1
BUDGET="${1:-mid}"
MAX_TOKENS="${2:-4096}"
QUERY=$(cat)
[ -z "$QUERY" ] && echo "Error: No query via stdin" >&2 && exit 1
hindsight memory recall "$BANK_ID" "$QUERY" --budget "$BUDGET" --max-tokens "$MAX_TOKENS" -o yaml 2>&1
