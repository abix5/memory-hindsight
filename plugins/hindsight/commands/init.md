---
description: Initialize Hindsight memory bank for the current project
allowed-tools: ["Bash", "Read", "Write"]
argument-hint: "[bank_id]"
---

## Hindsight Initialization

Initialize Hindsight for this project:
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-bank.sh $ARGUMENTS 2>&1`

---

## Your Task

Review the initialization output above and:

1. **Confirm success**: If initialization succeeded, confirm to the user that:
   - The memory bank has been created or connected
   - Settings file (`.claude/hindsight.json`) is configured
   - The bank_id being used

2. **Explain next steps**: Tell the user they can now:
   - Store decisions with `/hindsight:retain`
   - Search memories with `/hindsight:recall`
   - Get AI analysis with `/hindsight:reflect`

3. **Handle errors**: If initialization failed:
   - Explain what went wrong based on the error message
   - Suggest solutions (e.g., start Hindsight server, check connection)
   - Mention they can run `/hindsight:init [custom-bank-id]` to specify a different bank ID

**Bank ID determination:**
- If user provides an argument, use it as bank_id
- Otherwise, auto-detect from git remote (e.g., `user/repo`)
- If no git remote, use current directory name

**What the init script does:**
1. Checks if settings already exist (prevents accidental overwrite)
2. Verifies Hindsight server is accessible
3. Creates or confirms the memory bank exists
4. Creates `.claude/hindsight.json` with configuration
5. Adds `.claude/hindsight.json` to `.gitignore`
