---
name: memory-workflow
description: This skill should be used when the user asks to "store decision", "save to memory", "remember this", "recall past decisions", "what did we decide", "check memory", or mentions "hindsight", "memory bank", "retain", "recall", "reflect". Also use proactively when architectural decisions are made, technologies are chosen, bugs are solved, or tradeoffs are discussed.
model: sonnet
---

# Hindsight Memory Workflow

Guide for effectively using Hindsight memory bank during development sessions.

## CRITICAL: Automatic Behavior

As an AI assistant, you MUST use Hindsight memory proactively:

### Always Check Memory BEFORE:
- Making architectural recommendations
- Suggesting technology choices
- Proposing design patterns
- Answering "how should we..." questions

Use the **recall skill** to search memory.

### Always SAVE to Memory AFTER:
- User makes a decision with reasoning ("Let's use X because Y")
- Bug is solved ("Found it! The problem was...")
- Tradeoff is discussed ("We're sacrificing X for Y")
- Convention is established ("From now on...")
- User says "remember", "important"

Use the **retain skill** to store to memory.

### Trigger Phrases (SAVE immediately when you hear):
- "Let's use...", "We decided...", "The reason is..."
- "Remember that...", "From now on...", "Important:..."
- "The solution was...", "We chose X over Y..."

## When to Access Memory

### Recall Memory (Search)

Access memory bank when:

1. **Before making architectural decisions**
   - "Let me check if we've discussed this approach before..."
   - Query: architectural patterns, design decisions for [component]

2. **When choosing technologies or libraries**
   - "I should verify our previous technology choices..."
   - Query: tech stack, library choices, [technology name]

3. **When encountering similar problems**
   - "This looks familiar, checking memory..."
   - Query: bugs, issues, problems with [component/feature]

4. **When the user asks about past decisions**
   - Explicit: "What did we decide about X?"
   - Implicit: "Why is it done this way?"

5. **When context seems missing**
   - "There might be context I'm not aware of..."
   - Query: requirements, constraints, [feature area]

### Retain Memory (Store)

Store information when:

1. **Architectural decisions are made**
   ```
   Example: "We decided to use event-driven architecture for the notification system because it allows better scalability and decoupling"
   Context: architecture
   ```

2. **Technology choices are finalized**
   ```
   Example: "Chose Redis for caching over Memcached due to better data structure support and persistence options"
   Context: tech-stack
   ```

3. **Complex bugs are solved**
   ```
   Example: "Memory leak in WebSocket handler was caused by event listeners not being cleaned up on disconnect"
   Context: bugs
   ```

4. **Tradeoffs are explicitly discussed**
   ```
   Example: "Sacrificed some type safety by using 'any' in the legacy adapter to maintain backward compatibility"
   Context: tradeoffs
   ```

5. **Important lessons are learned**
   ```
   Example: "Integration tests caught the race condition that unit tests missed - always test concurrent scenarios"
   Context: lessons
   ```

6. **Requirements or constraints are established**
   ```
   Example: "API response time must stay under 200ms per product requirements"
   Context: requirements
   ```

### Reflect (Analysis)

Use reflection when:

1. **Evaluating new approaches against existing patterns**
   - "Given our past decisions, should we adopt microservices?"

2. **Looking for patterns in past decisions**
   - "What architectural patterns have worked well for us?"

3. **Making recommendations based on history**
   - "What approach would align with our established conventions?"

## Memory Categories

| Category | What to Store | Example |
|----------|--------------|---------|
| `architecture` | System design, component structure | "Using hexagonal architecture with ports and adapters" |
| `tech-stack` | Technology and library choices | "PostgreSQL chosen over MongoDB for ACID compliance" |
| `patterns` | Code patterns, design patterns | "Repository pattern for data access layer" |
| `decisions` | Key decisions with reasoning | "Monorepo structure to share code between services" |
| `tradeoffs` | Compromises and justification | "Denormalized data for read performance" |
| `bugs` | Complex bugs and solutions | "Race condition in payment processing fixed with optimistic locking" |
| `lessons` | Insights and learnings | "E2E tests are essential for auth flows" |
| `requirements` | Business constraints | "GDPR compliance requires data encryption at rest" |
| `conventions` | Code and process standards | "All API endpoints follow REST naming conventions" |

## Best Practices

### For Storing Memories

1. **Be specific and include reasoning**
   - Bad: "Use PostgreSQL"
   - Good: "Use PostgreSQL for the users service because we need ACID transactions for financial data"

2. **Include context about alternatives considered**
   - "Chose X over Y because of Z"

3. **Store at the moment of decision, not later**
   - Context is freshest immediately after discussion

4. **Use appropriate categories**
   - Helps with future recall accuracy

### For Retrieving Memories

1. **Be specific in queries**
   - Bad: "database"
   - Good: "database choice for user authentication"

2. **Use appropriate budget**
   - `low` for quick lookups of recent/obvious info
   - `mid` for general queries
   - `high` for comprehensive analysis

3. **Cross-reference with current context**
   - Memory might be outdated; verify relevance

## Action Skills

For execution details, the following action skills handle all CLI interactions:

- **retain skill** — saves content to memory bank (handles bank_id, CLI flags, heredoc)
- **recall skill** — searches memory bank (handles bank_id, budget, max-tokens)
- **reflect skill** — gets AI analysis from memory bank (handles bank_id, budget, max-tokens)
