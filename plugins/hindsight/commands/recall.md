---
description: Search for information in Hindsight memory bank
allowed-tools: ["Bash"]
argument-hint: "<query> [--budget <low|mid|high>]"
---

## Hindsight Memory Recall Results

Bank ID: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh 2>&1`

Search results:
!`BANK_ID=$(bash ${CLAUDE_PLUGIN_ROOT}/scripts/get-bank-id.sh 2>&1) && if [[ "$BANK_ID" == ERROR* ]]; then echo "$BANK_ID"; exit 1; fi && hindsight memory recall "$BANK_ID" $ARGUMENTS`

---

## Your Task

Analyze the search results above from the Hindsight memory bank and:

1. **Summarize findings**: Present the key information that matches the query
2. **Extract relevant details**: Highlight important decisions, reasoning, and context
3. **Identify patterns**: If multiple related memories exist, show connections
4. **Provide context**: Explain how this information relates to the current project

If no results were found, suggest:
- Refining the search query
- Using different keywords
- Checking if the information was stored with a different context

**Search parameters:**
- Query: $ARGUMENTS
- Budget: Automatically determined or specified by user
