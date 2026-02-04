---
description: Initialize Hindsight memory bank for the current project
allowed-tools: ["Bash", "Read", "Write", "Glob", "Grep", "AskUserQuestion", "Task"]
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

### Phase 4: Deep Project Analysis

**IMPORTANT:** This is the most critical phase. You must thoroughly explore the codebase to create meaningful memories. Use Task tool with Explore agent for comprehensive analysis.

#### 4.1 Analysis Checklist

Launch Explore agent to investigate each area. For each finding, immediately store to memory with full context.

**Architecture (target: 3-5 memories):**
- Overall architecture pattern (MVC, Clean, Hexagonal, Microservices, Monolith)
- Core modules/packages and their responsibilities
- Entry points and main request/data flows
- Component communication patterns (events, direct calls, queues)
- Data flow: where data enters, transforms, persists

**Technology Stack (target: 3-5 memories):**
- Primary language version and why
- Framework choice and configuration specifics
- Key dependencies: purpose and integration approach
- Build toolchain: bundler, compiler, transpiler setup
- Database type, ORM/query approach, schema patterns

**Patterns & Conventions (target: 2-4 memories):**
- Code organization (feature folders, layer-based, etc.)
- Naming conventions for files, classes, functions
- Error handling strategy
- API design patterns (REST structure, versioning)
- Testing approach (unit/integration/e2e split)

**Infrastructure (target: 2-3 memories):**
- Deployment strategy (containers, serverless, VMs)
- CI/CD pipeline stages and triggers
- Environment configuration approach
- Monitoring/logging patterns

#### 4.2 Quality Standards for Memories

Each memory entry MUST include:
- **WHAT**: specific component, decision, or pattern
- **WHY**: reasoning, alternatives considered, tradeoffs
- **CONTEXT**: how it relates to other parts, when it applies

**Examples of GOOD memories:**

1. "Architecture: Hexagonal architecture with ports/adapters pattern. Domain logic in src/domain/ isolated from infrastructure. Adapters in src/adapters/{db,http,queue}. Chosen to enable testing without infrastructure and future flexibility to swap implementations."

2. "Database: PostgreSQL 15 with Prisma ORM. Schema in prisma/schema.prisma uses soft deletes (deletedAt) on all entities. JSONB for flexible metadata on User and Product. Chose Prisma over TypeORM for type-safety and migrations DX."

3. "API Pattern: REST with /api/v1 prefix. Request validation via Zod schemas in src/schemas/. Responses follow envelope pattern {data, error, meta}. Pagination uses cursor-based approach with ?cursor=id for infinite scroll support."

**Examples of BAD memories (avoid these):**
- "Uses TypeScript" (no context)
- "Has tests" (too vague)
- "PostgreSQL database" (no why or how)

#### 4.3 Adaptive Quantity

- **Full project:** aim for 10-20 memories (minimum 10)
- **Small/new project:** fewer is OK if genuinely nothing else to document
- **Empty/boilerplate project:** 1-3 foundational memories are acceptable

The goal is QUALITY over QUANTITY. Each memory should be valuable for future context. If you can only find 5 meaningful things, store 5. Don't pad with trivial facts.

#### 4.4 Store Memories

Use this command for each finding:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/do-retain.sh <category> <<'EOF'
<detailed finding with WHAT + WHY + CONTEXT>
EOF
```

Categories: `architecture`, `tech-stack`, `patterns`, `conventions`, `decisions`

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
- Each memory MUST include WHAT + WHY + CONTEXT
- Focus on decisions and patterns, not just facts
- Minimum 10 detailed memories for established projects
- Fewer is OK for new/small projects (quality over padding)
- If auto-detect was chosen, infer project description from files
- CLAUDE.md instructions ensure AI uses memory proactively across sessions
- Run `/hindsight:rescan` later to add more findings or update outdated ones
