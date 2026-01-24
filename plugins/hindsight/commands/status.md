---
description: Show current Hindsight auto-workflow status and settings
allowed-tools: Bash, Read
---

Show the current status of Hindsight auto-workflow features.

Gather status information:

!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/status-check.sh`

Present the results clearly to the user with:
- Current bank_id
- Hindsight server availability
- Auto-features status (paused/active)
- Settings from .claude/hindsight.json (if exists)
- Memory bank stats (if available)
- Quick tips for controlling auto-features
