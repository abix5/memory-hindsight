# Hindsight Memory Bank Guide

This project uses [Hindsight](https://hindsight.vectorize.io/) to store and retrieve development decisions across sessions.

## Quick Reference

| Command | Usage |
|---------|-------|
| Store decision | `/hindsight:retain "decision text" --context category` |
| Search memory | `/hindsight:recall "query"` |
| Get AI analysis | `/hindsight:reflect "question"` |

## Memory Categories

Use these categories when storing decisions with `/hindsight:retain`:

### 🏗️ **architecture**
Architectural decisions, system design, component structure

**Examples:**
- "Using hexagonal architecture with ports and adapters pattern"
- "Microservices architecture chosen over monolith for scalability"
- "Event-driven design for notification system"

### 🛠️ **tech-stack**
Technology and library choices, framework decisions

**Examples:**
- "Using PostgreSQL over MongoDB because we need ACID transactions"
- "Chose React over Vue for larger ecosystem and team experience"
- "Selected Redis for caching due to rich data structures"

### 📐 **patterns**
Code patterns, design patterns, implementation approaches

**Examples:**
- "Repository pattern for all data access to separate business logic"
- "Using Strategy pattern for payment processing methods"
- "Singleton for database connection pool"

### 🎯 **decisions**
Important decisions with reasoning (general category)

**Examples:**
- "Decided to use JWT tokens stored in httpOnly cookies for auth"
- "API versioning through URL path (/v1/, /v2/) not headers"
- "Monorepo structure to share code between frontend and backend"

### ⚖️ **tradeoffs**
Compromises made and their justification

**Examples:**
- "Sacrificed some type safety in legacy adapter for backward compatibility"
- "Chose eventual consistency over strong consistency for better performance"
- "Using polling instead of WebSockets to avoid infrastructure complexity"

### 🐛 **bugs**
Complex bug descriptions and their solutions

**Examples:**
- "Memory leak in WebSocket handler caused by event listeners not being cleaned up on disconnect"
- "Race condition in payment processing fixed with optimistic locking"
- "N+1 query problem solved by eager loading with joins"

### 💡 **lessons**
Insights, learnings, things to remember

**Examples:**
- "Integration tests caught race condition that unit tests missed - always test concurrent scenarios"
- "Code reviews revealed implicit assumptions - document all non-obvious decisions"
- "Performance issues appeared only under load - use realistic data in tests"

### 📋 **requirements**
Business constraints, performance requirements

**Examples:**
- "API response time must stay under 200ms per product requirements"
- "Must support 10k concurrent users per SLA"
- "GDPR compliance requires data encryption at rest and right to deletion"

### 📜 **conventions**
Coding standards, naming conventions, processes

**Examples:**
- "All API endpoints follow REST naming conventions"
- "Use BEM methodology for CSS class names"
- "Git commit messages follow Conventional Commits format"

## Best Practices

### When to store

✅ **DO store:**
- Technology choices with reasoning
- Architectural decisions
- Complex bug solutions
- Important tradeoffs
- Non-obvious design decisions
- Failed approaches (what NOT to do)

❌ **DON'T store:**
- Obvious implementation details
- Temporary experiments
- Personal preferences without team agreement
- Duplicate information already in code comments

### How to store

1. **Include the "why"**
   ```
   ❌ Bad:  "Use PostgreSQL"
   ✅ Good: "Use PostgreSQL because we need ACID transactions for payment processing"
   ```

2. **Mention alternatives considered**
   ```
   "Chose Redis over Memcached for caching due to richer data structures and persistence options"
   ```

3. **Be specific to project context**
   ```
   "Use repository pattern for data access in the orders service to isolate business logic from database implementation"
   ```

4. **Keep it concise but complete**
   - One decision per memory entry
   - Include enough context for future understanding
   - Don't write essays, but don't be cryptic

### Searching memory

Use natural language queries:

```bash
/hindsight:recall database decisions
/hindsight:recall what did we decide about authentication
/hindsight:recall why did we choose microservices
/hindsight:recall how did we solve the race condition
```

**Budget options:**
- `--budget low` - Quick search, fewer results
- `--budget mid` - Balanced search (default)
- `--budget high` - Thorough search, comprehensive results

### Getting AI analysis

Use `/hindsight:reflect` for recommendations based on stored context:

```bash
/hindsight:reflect Should we add GraphQL given our current API architecture?
/hindsight:reflect What patterns have worked well for us?
/hindsight:reflect How should we approach caching?
```

**When to use reflect vs recall:**
- **Recall**: Finding specific stored information ("What did we decide?")
- **Reflect**: Getting analysis or recommendations ("Should we do X?")

## Workflow Tips

### Before making decisions

Check if similar decisions were made before:
```bash
/hindsight:recall similar topic
```

This helps maintain consistency with past choices.

### During development

When you make an important decision, store it immediately:
```bash
/hindsight:retain "Decision with reasoning" --context appropriate-category
```

### End of session

Review the session and use `/hindsight:retain` to save any important decisions before ending.

### Team collaboration

- Everyone runs `/hindsight:init` to connect to the same bank
- All team members can search and add to the shared memory
- Settings file (`.claude/hindsight.json`) is git-ignored, so each developer can use different API URLs
- This guide (`.claude/hindsight-guide.md`) is git-committed and shared

## Configuration

Your project settings are in `.claude/hindsight.json`:

```json
{
  "bank_id": "project-name",
  "api_url": "http://localhost:8888",
  "default_context": "decisions"
}
```

**Note:** This file is git-ignored. Each team member may have different settings.

## Troubleshooting

### "Settings file not found"

Run `/hindsight:init` to initialize Hindsight for this project.

### "Hindsight server not accessible"

Make sure Hindsight is running:
```bash
docker-compose up -d
```

Or set the API URL:
```bash
export HINDSIGHT_API_URL=http://localhost:8888
```

### Can't find past decisions

Try:
- Different keywords in search
- Using `--budget high` for more thorough search
- Check if the decision was stored with a different category

## Further Reading

- [Hindsight Documentation](https://hindsight.vectorize.io/)
- [Plugin README](../../README.md)
- [Plugin Usage Guide](../../USAGE.md)

---

_This guide is generated by the Hindsight plugin initialization._
_For questions, see the plugin documentation or ask Claude!_
