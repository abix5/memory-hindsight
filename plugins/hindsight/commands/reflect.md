---
description: Get AI analysis based on project memory
allowed-tools: ["Bash"]
argument-hint: "<question> [--budget <low|mid|high>]"
---

## AI Reflection

Bank ID: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh`

Analysis:
!`set -f && BANK_ID=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh) && hindsight memory reflect "$BANK_ID" "$ARGUMENTS" -o yaml 2>&1`

---

## Instructions

Present Hindsight's AI analysis to the user:

1. **Share the analysis**: Present recommendations clearly
2. **Add context**: Connect to current conversation or task
3. **Explain reasoning**: Which past decisions influenced this
4. **Suggest actions**: Concrete next steps based on reflection

**Difference from Recall:**
- **Recall** retrieves specific stored facts
- **Reflect** generates AI analysis and recommendations based on all relevant memories

**Budget levels:**
- `low` - Quick analysis
- `mid` - Balanced depth (default)
- `high` - Comprehensive, thorough reasoning

If reflection reveals gaps or conflicts in stored knowledge, point that out and suggest storing additional context with `/hindsight:retain`.
