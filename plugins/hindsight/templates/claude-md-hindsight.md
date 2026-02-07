<!-- HINDSIGHT-MEMORY-BANK-START -->
## Hindsight Memory Bank

**Bank ID:** `{{BANK_ID}}`

### How to Save (async, non-blocking)

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/do-retain.sh <category> <<'EOF'
WHAT was decided/discovered + WHY (reasoning, alternatives, tradeoffs)
EOF
```

Saving is **asynchronous** (`--async`) — returns instantly, processes in background. Never wait for confirmation; continue working immediately.

### Decision Framework: WHEN to Save

Save to memory **autonomously** whenever ANY of these criteria is met during the conversation:

1. **Decision with reasoning** — "chose X because Y", "we decided to", "let's use X"
2. **Solved non-trivial bug** — root cause + fix (not just "fixed typo")
3. **Pattern/convention established** — "from now on...", "all X should follow Y"
4. **Constraint or workaround** — "X doesn't work because Y, using Z instead"
5. **Negative decision** — "we do NOT use X because Y" (what was rejected and why)
6. **Repeated context** — user explains the same thing a second time (save it so they don't have to again)
7. **Explicit request** — "remember", "save this", "important", "запомни", "важно"
8. **Dependency added with reasoning** — why this library over alternatives
9. **Infrastructure change** — Docker, CI/CD, K8s, DB schema changes with reasoning
10. **Tradeoff made** — sacrificing X for Y, technical debt accepted consciously

**DO NOT save:**
- Trivial changes without reasoning (formatting, typos, renames)
- Temporary/experimental decisions marked as such
- Information obvious from the code itself
- Duplicates of what's already in memory (check first if unsure)

### Decision Framework: WHEN to Search Memory

**Search memory BEFORE answering** whenever the prompt involves:

1. **Architecture/design** — "how to implement", "what approach", "how to structure"
2. **Technology choice** — "which DB", "which framework", "which library"
3. **Pattern/convention** — "how do we usually", "is there a standard", "what's our approach"
4. **Past decision** — "why is it this way", "what did we decide", "was there a reason"
5. **Recurring context** — you're unsure about project-specific context
6. **Similar bug** — problem with a component that may have been solved before
7. **Infrastructure** — "how is it configured", Docker/CI/CD/DB questions

**DO NOT search for:** trivial edits, formatting, confirmations, new code with no dependency on past decisions.

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/do-recall.sh <budget> <<'EOF'
search query
EOF
```

Budgets: `low` (quick), `mid` (balanced, default), `high` (thorough).

### Categories

| Category | When to use |
|----------|------------|
| `architecture` | System design, components, infrastructure, DB schema |
| `tech-stack` | Technology/library choices with reasoning |
| `patterns` | Code patterns, design patterns, implementation approaches |
| `decisions` | Key decisions with explicit reasoning |
| `tradeoffs` | Compromises, technical debt, what was sacrificed |
| `bugs` | Non-trivial bugs: root cause + solution |
| `lessons` | Insights, gotchas, things that surprised us |
| `requirements` | Business constraints, performance requirements, SLAs |
| `conventions` | Standards, naming, processes, team agreements |

### Quality Format

**BAD:** "Added Redis" / "Fixed bug" / "Updated config"
**GOOD:** "Chose Redis over Memcached for session caching — need TTL for auto-expiry, pub/sub for cache invalidation across instances, and persistence for restart safety"

Each memory: **WHAT** (specific) + **WHY** (reasoning) + alternatives if discussed.

### Commands

| Command | Purpose |
|---------|---------|
| `/hindsight:recall "query"` | Search memory |
| `/hindsight:retain "text"` | Save to memory |
| `/hindsight:reflect "question"` | AI analysis from memory |
| `/hindsight:status` | Bank status and stats |
| `/hindsight:rescan` | Re-analyze project, find new knowledge |

<!-- HINDSIGHT-MEMORY-BANK-END -->
