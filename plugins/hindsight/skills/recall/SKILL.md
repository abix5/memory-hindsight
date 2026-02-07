---
name: recall
description: This skill should be used when the user asks "what did we decide", "check memory", "recall", "do we have info about", "was there a decision", or proactively before making architectural recommendations, technology choices, or design decisions. Also activate when context seems missing, a question about past decisions is asked, or the prompt involves patterns, conventions, infrastructure, or known bugs.
model: sonnet
version: 0.2.0
---

# Search Memory Bank

## Command

```bash
bash !`echo ${CLAUDE_PLUGIN_ROOT}`/scripts/do-recall.sh <BUDGET> <<'EOF'
<QUERY>
EOF
```

## When to Search (Recall Decision Framework)

Search memory **before answering** when the prompt involves:

| Trigger | Example prompts |
|---------|----------------|
| Architecture/design | "how to implement X", "what approach for Y", "how to structure" |
| Technology choice | "which DB", "which library", "what framework for" |
| Pattern/convention | "how do we usually", "is there a standard for", "what's our approach" |
| Past decision | "why is it this way", "what did we decide about", "was there a reason" |
| Uncertain context | You're unsure about project-specific details |
| Similar bug/issue | Problem with a component that may have been solved before |
| Infrastructure | "how is X configured", Docker/CI/CD/DB questions |

**Skip recall for:** trivial edits, formatting, confirmations, new code with no dependency on past decisions.

## Budget Levels

| Budget | When to use |
|--------|-------------|
| `low` | Quick lookup, duplicate check, recent info |
| `mid` | Balanced search (default) |
| `high` | Comprehensive, thorough analysis |

## After Searching

1. Summarize findings relevant to the current question
2. Extract key decisions, reasoning, constraints
3. Note connections and patterns across memories
4. Apply findings to the current task

If no results: try different keywords, broaden the query, or use `/hindsight:reflect` for analysis-based answers.
