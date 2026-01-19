---
description: Save information to Hindsight memory bank
allowed-tools: ["Bash"]
argument-hint: "<content> [--context <category>]"
---

## Hindsight Memory Retain

Bank ID: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh 2>&1`

Store operation:
!`BANK_ID=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh 2>&1) && if [[ "$BANK_ID" == ERROR* ]]; then echo "$BANK_ID"; exit 1; fi && hindsight memory retain "$BANK_ID" $ARGUMENTS`

---

## Your Task

The information has been stored in the Hindsight memory bank. Confirm to the user:

1. **What was stored**: Briefly summarize the content
2. **Category used**: Mention which context/category was applied
3. **Future retrieval**: Suggest how this can be recalled later (keywords to use)

**Available categories:**
- `architecture` - Architectural decisions, project structure
- `tech-stack` - Technology and library choices
- `patterns` - Code patterns and approaches
- `decisions` - Important decisions with reasoning
- `tradeoffs` - Compromises and their justification
- `bugs` - Complex bugs and their solutions
- `lessons` - Learned lessons, insights
- `requirements` - Business requirements and constraints
- `conventions` - Code and process conventions

If the operation failed, explain the error and suggest how to fix it.
