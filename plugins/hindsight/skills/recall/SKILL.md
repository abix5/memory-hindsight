---
name: recall
description: This skill should be used when the user asks "what did we decide", "check memory", "recall", "do we have info about", "was there a decision", or proactively before making architectural recommendations, technology choices, or design decisions. Also activate when context seems missing or a question about past decisions is asked.
model: sonnet
version: 0.1.0
---

# Search Memory Bank

Search memory with one command. Pick the budget, write query, execute:

```bash
bash !`echo ${CLAUDE_PLUGIN_ROOT}`/scripts/do-recall.sh <BUDGET> <<'EOF'
<QUERY>
EOF
```

## Budget Levels

| Budget | When to use |
|--------|-------------|
| `low` | Quick lookup, duplicate check, recent info |
| `mid` | Balanced search (default) |
| `high` | Comprehensive, thorough analysis |

## After Searching

1. Summarize findings — key information matching the query
2. Extract details — decisions, reasoning, context
3. Show connections — patterns across multiple memories
4. Relate to current work — how this applies now

If no results: suggest different keywords or use `/hindsight:reflect` for analysis-based answers.
