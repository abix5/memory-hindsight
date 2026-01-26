<!-- HINDSIGHT-MEMORY-BANK-START -->
## Hindsight Memory Bank

**Bank ID:** `{{BANK_ID}}`

### Automatic Behavior (MANDATORY)

When working on this project you MUST follow these rules:

1. **Session Start** - Context is loaded automatically via hook. USE this context when answering questions.

2. **Before Making Decisions** - ALWAYS check memory first:
   ```
   /hindsight:recall "relevant query"
   ```
   Check if similar decisions were made before. Maintain consistency.

3. **After Architectural Decisions** - SAVE with reasoning:
   ```
   /hindsight:retain "Decision with WHY explanation" --context architecture
   ```

4. **After Solving Complex Bugs** - SAVE the solution:
   ```
   /hindsight:retain "Bug description and solution" --context bugs
   ```

5. **After Technology Choices** - SAVE with justification:
   ```
   /hindsight:retain "Chose X over Y because Z" --context tech-stack
   ```

6. **When User Says "remember"** - IMMEDIATELY save to memory.

7. **Before Session Ends** - Review if important decisions should be saved.

### Commands Reference

| Command | Purpose |
|---------|---------|
| `/hindsight:recall "query"` | Search memory for relevant context |
| `/hindsight:retain "text" --context cat` | Save decision to memory |
| `/hindsight:reflect "question"` | Get AI analysis based on memory |
| `/hindsight:status` | Check memory bank status |

### Categories

Use appropriate category with `--context`:

- `architecture` - System design, component structure
- `tech-stack` - Technology and library choices
- `patterns` - Code patterns, design patterns
- `decisions` - Key decisions with reasoning
- `tradeoffs` - Compromises and justification
- `bugs` - Complex bugs and solutions
- `lessons` - Insights and learnings
- `requirements` - Business constraints
- `conventions` - Code and process standards

### Proactive Triggers

Save to memory when you hear:
- "Let's use X because..."
- "We decided to..."
- "The reason for this is..."
- "Remember that..."
- "Important: ..."
- "From now on..."
- "The solution was..."
- "We chose X over Y..."

<!-- HINDSIGHT-MEMORY-BANK-END -->
