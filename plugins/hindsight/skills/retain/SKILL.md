---
name: retain
description: This skill should be used when the user asks to "save to memory", "remember this", "store decision", or proactively when an architectural decision is made, technology is chosen, bug is solved, tradeoff discussed, convention established, constraint discovered, negative decision made, or user repeats context. Trigger phrases: "Let's use...", "We decided...", "The reason is...", "Remember that...", "From now on...", "The solution was...", "We chose X over Y...", "X doesn't work because...", "We don't use X because..."
model: sonnet
version: 0.2.0
---

# Save to Memory Bank

Retain is **asynchronous** — returns instantly, processes in background. Use freely without worrying about blocking.

## Command

```bash
bash !`echo ${CLAUDE_PLUGIN_ROOT}`/scripts/do-retain.sh <CATEGORY> <<'EOF'
<CONTENT>
EOF
```

## Categories

| Category | When to use |
|----------|-------------|
| `architecture` | System design, components, infrastructure, DB schema changes |
| `tech-stack` | Technology/library choices with reasoning |
| `patterns` | Code patterns, design patterns, implementation approaches |
| `decisions` | Key decisions with explicit reasoning |
| `tradeoffs` | Compromises, technical debt, what was sacrificed for what |
| `bugs` | Non-trivial bugs: root cause + solution |
| `lessons` | Insights, gotchas, unexpected behaviors |
| `requirements` | Business constraints, performance requirements, SLAs |
| `conventions` | Standards, naming, processes, team agreements |

## Content Quality

Each memory MUST include:
- **WHAT** was decided/discovered (specific)
- **WHY** it was decided (reasoning, alternatives rejected)

Bad: "Use PostgreSQL"
Good: "Use PostgreSQL for user service — need ACID transactions for payments. MongoDB rejected due to consistency requirements in financial data."

## Decision: When to Save

Save when ANY criterion is met:
1. Decision with reasoning (chose X because Y)
2. Solved non-trivial bug (root cause + fix)
3. Pattern/convention established
4. Constraint/workaround discovered (X doesn't work because Y)
5. Negative decision (we do NOT use X because Y)
6. User repeats context (save so they don't have to again)
7. Explicit request ("remember", "save this", "запомни")
8. Dependency added with reasoning
9. Infrastructure change with reasoning
10. Tradeoff made consciously

Do NOT save: trivial changes, temporary experiments, duplicates, obvious-from-code info.

## Duplicate Check (when unsure)

```bash
bash !`echo ${CLAUDE_PLUGIN_ROOT}`/scripts/do-recall.sh low 200 <<'EOF'
<brief topic>
EOF
```

## After Saving

Report to user: what was stored, category used.
