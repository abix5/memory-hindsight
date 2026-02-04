---
name: reflect
description: This skill should be used when the user asks for analysis based on past decisions, "what patterns have worked", "should we adopt X given our history", "what aligns with our conventions", or needs recommendations grounded in accumulated project knowledge.
model: sonnet
version: 0.1.0
---

# Analyze from Memory Bank

Get AI-powered analysis with one command. Pick the budget, write question, execute:

```bash
bash !`echo ${CLAUDE_PLUGIN_ROOT}`/scripts/do-reflect.sh <BUDGET> <<'EOF'
<QUESTION>
EOF
```

## Budget Levels

| Budget | When to use |
|--------|-------------|
| `low` | Quick analysis, simple questions |
| `mid` | Balanced depth (default) |
| `high` | Deep comprehensive reasoning |

## Difference from Recall

- **Recall** retrieves specific stored facts
- **Reflect** generates AI analysis and recommendations based on ALL relevant memories

## After Reflecting

1. Present analysis clearly
2. Connect to current conversation/task
3. Explain which past decisions influenced the analysis
4. Suggest concrete next steps
5. If gaps found, suggest storing additional context
