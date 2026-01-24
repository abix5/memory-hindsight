---
description: Pause auto-recall and auto-save features
allowed-tools: Bash
---

Pause Hindsight auto-features (auto-recall on prompts, auto-save on file changes).

Creating pause flag:

!`mkdir -p .claude && touch .claude/hindsight-paused && echo "done"`

Report to the user:
- Confirm that auto-features are now paused
- Auto-recall on user prompts: disabled
- Auto-save on file changes: disabled
- Manual commands (/hindsight:retain, /hindsight:recall, /hindsight:reflect) still work
- To resume: use /hindsight:resume
