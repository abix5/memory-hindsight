---
description: Get AI analysis based on project memory
allowed-tools: ["Bash"]
argument-hint: "<question> [--budget <low|mid|high>]"
---

## Hindsight Memory Reflect

Bank ID: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh 2>&1`

AI Analysis:
!`BANK_ID=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh 2>&1) && if [[ "$BANK_ID" == ERROR* ]]; then echo "$BANK_ID"; exit 1; fi && hindsight memory reflect "$BANK_ID" $ARGUMENTS`

---

## Your Task

The analysis above is from Hindsight's AI reflection based on the project's stored memories. Your role is to:

1. **Present the analysis**: Share Hindsight's recommendations clearly
2. **Add context**: Connect the analysis to the current conversation or task
3. **Explain reasoning**: Highlight which past decisions influenced the recommendations
4. **Suggest next steps**: Based on the reflection, propose concrete actions

**Difference from Recall:**
- **Recall** retrieves specific stored facts
- **Reflect** provides AI-generated analysis and recommendations based on all relevant memories

If the reflection suggests conflicting information or reveals gaps in stored knowledge, point that out and suggest storing additional context.

**Question asked:** $ARGUMENTS
