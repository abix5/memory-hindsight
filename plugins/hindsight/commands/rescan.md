---
description: Rescan project to update memory with new findings and refresh outdated entries
allowed-tools: ["Bash", "Read", "Glob", "Grep", "Task"]
argument-hint: "[--deep]"
---

## Hindsight Rescan

Bank ID: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh`

Current memory summary:
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/do-reflect.sh mid 4096 <<'EOF'
List all key facts known about this project in categories: architecture, tech-stack, patterns, conventions
EOF`

---

### Your Task: Compare & Update

You are performing a DIFFERENTIAL analysis - find what changed or is missing.

#### Phase 1: Understand Current Memory

Review the memory summary above. Note:
- What areas are already documented
- What seems outdated or incomplete
- What major aspects might be missing

#### Phase 2: Scan Codebase for Changes

Use Task tool with Explore agent to investigate the project. Focus on:

1. **New or changed architecture:**
   - New modules/packages since last scan
   - Changed component relationships
   - New integrations or services

2. **Technology updates:**
   - New dependencies in package.json/etc
   - Version upgrades of key tools
   - New build/deploy configurations

3. **Pattern evolution:**
   - New conventions established in recent code
   - Changed API patterns
   - New testing approaches

4. **Infrastructure changes:**
   - New CI/CD steps
   - Container/deployment changes
   - New environments

#### Phase 3: Update Memory

For each finding:

1. **Check if similar exists** in memory:
   ```bash
   bash !`echo ${CLAUDE_PLUGIN_ROOT}`/scripts/do-recall.sh low 200 <<'EOF'
   <brief topic>
   EOF
   ```

2. **Action based on result:**
   - **Not found** → Create new memory entry
   - **Found but outdated** → Create updated entry (old stays for history)
   - **Found and current** → Skip, no action needed

3. **Store new/updated findings:**
   ```bash
   bash !`echo ${CLAUDE_PLUGIN_ROOT}`/scripts/do-retain.sh <category> <<'EOF'
   <finding with WHAT + WHY + CONTEXT>
   EOF
   ```

#### Phase 4: Report

Summarize to user:
1. What was scanned
2. What NEW entries were added (list with categories)
3. What was UPDATED (old vs new)
4. What remained unchanged
5. Any areas that need manual review

### Deep Mode (--deep flag)

If $ARGUMENTS contains "--deep", perform extended analysis:
- Code quality patterns and technical debt
- Performance optimization opportunities
- Security measures and potential gaps
- Testing coverage and strategy
- Documentation completeness
- Dependency health and update opportunities

### Quality Standards

Each memory entry MUST include:
- **WHAT**: specific component, decision, or pattern
- **WHY**: reasoning, alternatives considered, tradeoffs
- **CONTEXT**: how it relates to other parts, when it applies

**Examples of GOOD memories:**

1. "Architecture Update: Added event-driven communication between OrderService and NotificationService via RabbitMQ. Previously direct HTTP calls caused timeout issues under load. Events in src/events/ follow CloudEvents spec."

2. "Tech-Stack Update: Migrated from Jest to Vitest for testing. Vitest config in vitest.config.ts. Chose for 10x faster test runs and native ESM support. Test files use same patterns (describe/it/expect)."

**Avoid trivial updates:**
- "Updated package.json" (no context)
- "Added new file" (too vague)
