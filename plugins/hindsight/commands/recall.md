---
description: Search for information in Hindsight memory bank
allowed-tools: ["Bash"]
argument-hint: "<query> [--budget <low|mid|high>]"
---

## Search Memory

Bank ID: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh`

Results:
!`set -f && BANK_ID=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh) && hindsight memory recall "$BANK_ID" "$ARGUMENTS" 2>&1`

---

## Instructions

Analyze the search results and present them clearly:

1. **Summarize findings**: Key information matching the query
2. **Extract details**: Important decisions, reasoning, context
3. **Show connections**: If multiple related memories, highlight patterns
4. **Provide context**: How this relates to current work

**Budget levels:**
- `low` - Quick lookup, recent/obvious info
- `mid` - Balanced search (default)
- `high` - Comprehensive, thorough analysis

If no results found, suggest:
- Try different keywords
- Use broader or narrower query
- Check if information was stored with different context
- Consider using `/hindsight:reflect` for analysis-based answers
