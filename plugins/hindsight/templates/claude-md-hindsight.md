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

### Automatic Save Triggers (MANDATORY)

You MUST save to memory when you:

1. **Add a new dependency** → Save WHY it was chosen over alternatives
   ```
   /hindsight:retain "Added lodash for utility functions - chose over ramda for smaller bundle size and familiar API" --context tech-stack
   ```

2. **Change infrastructure** (Docker, CI/CD, K8s) → Save the reasoning
   ```
   /hindsight:retain "Added Redis service to docker-compose for session caching - chose Redis over Memcached for pub/sub support needed for real-time notifications" --context architecture
   ```

3. **Make architectural decision** → Save pattern and tradeoffs
   ```
   /hindsight:retain "Implemented event-driven communication between services via RabbitMQ - decouples services and handles load spikes better than direct HTTP calls" --context architecture
   ```

4. **Solve a complex bug** → Save problem and solution
   ```
   /hindsight:retain "Memory leak in WebSocket handler - fixed by ensuring connections are closed in finally block, not just on success path" --context bugs
   ```

5. **Establish a convention** → Save the rule and reasoning
   ```
   /hindsight:retain "API responses follow envelope pattern {data, error, meta} - consistent structure for frontend error handling and pagination" --context conventions
   ```

### Quality Format

Each saved memory MUST include:
- **WHAT**: specific component, decision, or pattern
- **WHY**: reasoning, alternatives considered, tradeoffs
- **CONTEXT**: how it relates to other parts

**BAD (avoid):** "Added Redis" / "Fixed bug" / "Updated config"
**GOOD:** Include the reasoning and context as shown in examples above

### Maintenance

- `/hindsight:rescan` - Re-analyze project, add new findings, update outdated entries
- `/hindsight:status` - Check memory bank connection and stats

<!-- HINDSIGHT-MEMORY-BANK-END -->
