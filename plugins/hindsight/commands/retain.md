---
description: Save information to Hindsight memory bank
allowed-tools: ["Bash"]
argument-hint: "<content> [--context <category>]"
---

## Store Memory

Bank ID: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh`

Result:
!`set -f && BANK_ID=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh) && hindsight memory retain "$BANK_ID" "$ARGUMENTS" -o yaml 2>&1`

---

## Instructions

Confirm to the user:

1. **What was stored**: Summarize the content briefly
2. **Category**: Which context/category was applied (default: general)
3. **Bank**: Mention which bank it was stored in
4. **Retrieval hint**: Suggest keywords for future recall

**Categories for --context flag:**
- `architecture` - System design, component structure
- `tech-stack` - Technology and library choices
- `patterns` - Code patterns and approaches
- `decisions` - Important decisions with reasoning
- `tradeoffs` - Compromises and justification
- `bugs` - Complex bugs and solutions
- `lessons` - Insights and learnings
- `requirements` - Business constraints
- `conventions` - Code and process standards

If the operation failed, explain the error and suggest:
- Check if Hindsight server is running
- Verify the content is not empty
- Try `/hindsight:init` if bank doesn't exist
