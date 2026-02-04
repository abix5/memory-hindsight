---
name: retain
description: This skill should be used when the user asks to "save to memory", "remember this", "store decision", or proactively when an architectural decision is made, technology is chosen, bug is solved, tradeoff discussed, convention established. Trigger phrases: "Let's use...", "We decided...", "The reason is...", "Remember that...", "From now on...", "The solution was...", "We chose X over Y..."
model: sonnet
version: 0.1.0
---

# Save to Memory Bank

Save information with one command. Pick the category, format content, execute:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/do-retain.sh <CATEGORY> <<'EOF'
<CONTENT>
EOF
```

## Categories

| Category | When to use |
|----------|-------------|
| `architecture` | System design, components, infrastructure |
| `tech-stack` | Technology/library choices with reasoning |
| `patterns` | Code patterns, design patterns |
| `decisions` | Key decisions with explicit reasoning |
| `tradeoffs` | Compromises and justification |
| `bugs` | Complex bugs and their solutions |
| `lessons` | Insights, learnings |
| `requirements` | Business constraints, performance requirements |
| `conventions` | Standards, naming, processes |

## Content Quality

Each memory MUST include:
- **WHAT** was decided
- **WHY** it was decided (reasoning)
- Alternatives considered (if any)

Bad: "Use PostgreSQL"
Good: "Use PostgreSQL for user service. Need ACID transactions for payments. MongoDB rejected due to consistency requirements."

## After Saving

Report to user: what was stored, category, keywords for future recall.

## Check for Duplicates (optional)

Before storing, optionally check if similar exists:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/do-recall.sh low 200 <<'EOF'
<brief topic>
EOF
```
