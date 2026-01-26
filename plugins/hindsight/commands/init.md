---
description: Initialize Hindsight memory bank for the current project
allowed-tools: ["Bash", "Read", "Write", "Glob", "Grep", "AskUserQuestion"]
argument-hint: "[bank_id]"
---

## Hindsight Initialization

Detected options and existing banks:

!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/detect-bank-options.sh 2>&1`

---

## Your Task

Follow this process step by step:

### Phase 1: Choose Bank Name

If the user provided an argument ($ARGUMENTS is not empty), use it directly as bank_id and skip to Phase 2.

Otherwise, use AskUserQuestion to ask the user which bank name to use.

Build options from the detection output above:
- Include all unique suggested names (from_remote, from_repo, from_dir) as options
- If existing banks were found, add relevant ones as "Use existing: <name>" options
- The user can always provide a custom name via "Other"

Example question: "Which memory bank name should be used for this project?"
Options should be the detected names (deduplicated), plus any existing banks that look relevant.

**Important:** The bank name is how this project's memories are identified. It should be unique per project. In worktree setups, multiple worktrees of the same repo should share one bank.

### Phase 2: Initialize Bank

After the user chooses a bank name, run:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-bank.sh "<chosen_bank_id>"
```

If initialization **failed**, explain the error and suggest fixes. Stop here.

If initialization **succeeded**, proceed to Phase 3.

### Phase 3: Gather Project Context

Use AskUserQuestion to ask the user:

**Question 1: Project Description**
"What is this project? Briefly describe its purpose and main functionality."
Options:
- Let Claude figure it out from codebase (auto-detect)
- I'll describe it (manual input via Other)

**Question 2: What should be remembered?**
"What types of decisions are most important to remember for this project?"
Options (multiSelect: true):
- Architecture decisions (system design, patterns)
- Technology choices (libs, frameworks, tools)
- Business rules (domain logic, constraints)
- Performance considerations (optimization, scaling)

### Phase 4: Project Scan

After gathering answers, scan the project to seed initial context:

1. **Check for key infrastructure files** and store findings:
   - package.json / Cargo.toml / go.mod / pyproject.toml (tech stack)
   - Dockerfile / docker-compose (containerization)
   - CI/CD configs (.github/workflows, etc.)
   - tsconfig.json / vite.config / webpack.config (build setup)

2. **Identify project structure**:
   - Main entry points
   - Key directories and their purpose
   - Testing framework in use

3. **Store initial memories** using:
   ```bash
   BANK_ID=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh)
   hindsight memory retain "$BANK_ID" "<finding>" --context <category>
   ```

   Store 3-7 key facts about the project (don't overwhelm):
   - Primary language and framework
   - Key dependencies and their purpose
   - Project structure overview
   - Build/test setup
   - Container/deployment setup (if present)

### Phase 5: Update CLAUDE.md

Add Hindsight instructions to CLAUDE.md so the AI assistant knows to use memory bank automatically:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/update-claude-md.sh "<chosen_bank_id>"
```

This script is **idempotent**:
- If CLAUDE.md doesn't exist - creates it with Hindsight block
- If CLAUDE.md exists without Hindsight block - appends the block
- If Hindsight block exists with same bank_id - no changes
- If Hindsight block exists with different bank_id - updates it

The block contains **mandatory instructions** for the AI to:
- Check memory before making decisions
- Save architectural decisions automatically
- Save bug solutions and technology choices
- React to "remember" requests from user

Report to user what was done with CLAUDE.md.

### Phase 6: Confirmation

Report to the user:
1. Bank ID and connection status
2. What was scanned and stored (brief list)
3. CLAUDE.md status (created/updated/unchanged)
4. How auto-workflow works:
   - Session start: loads context automatically
   - During prompts: relevant memories surface as context
   - On infrastructure changes: auto-saves decisions
   - **AI follows instructions in CLAUDE.md to proactively use memory**
5. Control commands:
   - /hindsight:pause - pause auto-features
   - /hindsight:status - check current status
   - "!" prefix on prompt - skip recall for one prompt
6. How to store more decisions manually with /hindsight:retain

**Important:**
- Don't store obvious/trivial information
- Focus on decisions that have "why" behind them
- Keep initial seed concise (3-7 entries max)
- If auto-detect was chosen, infer project description from files
- CLAUDE.md instructions ensure AI uses memory proactively across sessions
