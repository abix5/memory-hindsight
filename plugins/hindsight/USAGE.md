# Hindsight Plugin Usage Guide

## Quick Start

### 1. Install the Plugin

The plugin should be installed via the Claude Code marketplace:

```bash
# Add the local marketplace
/plugin marketplace add /Users/dmitriynenashev/.claude/plugins/hindsight-marketplace

# Install the plugin
/plugin install hindsight
```

### 2. Initialize for Your Project

Navigate to your project directory and run:

```
/hindsight:init
```

This will:
- Auto-detect a bank_id from git remote or directory name
- Create or connect to the memory bank
- Generate `.claude/hindsight.json` settings file
- Add `.claude/*.local.md` to `.gitignore`

You can also specify a custom bank ID:

```
/hindsight:init my-custom-bank-id
```

### 3. Store Important Decisions

Use `/hindsight:retain` to save decisions, discoveries, or lessons:

```
/hindsight:retain "We chose PostgreSQL over MongoDB because we need ACID transactions for payment processing" --context tech-stack

/hindsight:retain "Repository pattern used for all data access to separate business logic" --context architecture

/hindsight:retain "Race condition in WebSocket handler fixed by adding mutex lock" --context bugs
```

**Available categories:**
- `architecture` - System design decisions
- `tech-stack` - Technology choices
- `patterns` - Code patterns
- `decisions` - General decisions
- `tradeoffs` - Compromises made
- `bugs` - Bug solutions
- `lessons` - Insights learned
- `requirements` - Business constraints
- `conventions` - Coding standards

### 4. Search Past Decisions

Use `/hindsight:recall` to search the memory bank:

```
/hindsight:recall database decisions

/hindsight:recall authentication approach --budget high

/hindsight:recall what did we decide about caching
```

**Budget levels:**
- `low` - Quick search
- `mid` - Balanced (default)
- `high` - Thorough, comprehensive

### 5. Get AI Analysis

Use `/hindsight:reflect` for recommendations based on stored context:

```
/hindsight:reflect Should we add GraphQL given our current architecture?

/hindsight:reflect What patterns have worked well for us? --budget high

/hindsight:reflect How should we approach real-time updates?
```

## How Commands Work

All commands use **bash execution** to directly call the `hindsight` CLI:

```markdown
# In the command file:
!`hindsight memory recall "$BANK_ID" "$QUERY"`
```

1. **Configuration loading**: Scripts read `.claude/hindsight.json` to extract `bank_id`
2. **CLI execution**: Commands run `hindsight` CLI with proper arguments
3. **Result interpretation**: Claude receives the output and formats it for you

This approach provides:
- Direct access to Hindsight without abstractions
- Real-time results from the memory bank
- Automatic configuration from project settings
- Smart interpretation by Claude

## Settings File

Created automatically by `/hindsight:init` at `.claude/hindsight.json`:

```json
{
  "bank_id": "my-project",
  "api_url": "http://localhost:8888",
  "default_context": "decisions"
}
```

**Important**: This file is git-ignored by default.

## Advanced Features

### Memory Keeper Agent

The plugin includes a specialized agent that proactively identifies important decisions:

- Triggers when architectural decisions are discussed
- Suggests storing technology choices
- Captures bug solutions automatically
- Formulates memories with proper context

Claude may suggest: "This seems like an important decision. Should I store it in memory?"

### Stop Hook

At the end of each session, the plugin reviews the conversation and suggests storing any important decisions that weren't already saved.

### MCP Integration

The plugin also configures direct MCP tool access for advanced use cases:
- `mcp__hindsight__retain` - Store memories
- `mcp__hindsight__recall` - Search memories
- `mcp__hindsight__reflect` - Get analysis
- `mcp__hindsight__list_banks` - List available banks
- `mcp__hindsight__create_bank` - Create new banks

## Troubleshooting

### "ERROR: Settings file not found"

Run `/hindsight:init` first to create the settings file.

### "ERROR: Hindsight server not accessible"

Make sure Hindsight is running:

```bash
# Start Hindsight with Docker
docker-compose up -d

# Or set custom URL
export HINDSIGHT_API_URL=http://localhost:8888
```

### "ERROR: bank_id not found in settings"

The `.claude/hindsight.json` file may be corrupted. Check that it's valid JSON with a "bank_id" field, or delete it and run `/hindsight:init` again.

### Commands not appearing

1. Restart Claude Code
2. Check plugin is enabled: `/plugin list`
3. Verify plugin is in the correct location

## Examples

### Complete Workflow

```bash
# 1. Initialize
/hindsight:init

# 2. During development, store decisions
/hindsight:retain "Using Redux Toolkit for state management because it simplifies boilerplate and includes best practices" --context tech-stack

# 3. Later, recall what you decided
/hindsight:recall state management approach

# 4. Get AI analysis for new decisions
/hindsight:reflect Should we add MobX given our Redux setup?

# 5. Store the conclusion
/hindsight:retain "Decided to stick with Redux Toolkit rather than adding MobX to avoid mixing paradigms" --context decisions
```

### Team Workflow

Each developer runs `/hindsight:init` in their local environment. They all connect to the same shared bank_id (e.g., from git remote), so decisions are shared across the team.

Settings file is git-ignored, so each developer can use different API URLs if needed.

## Tips

1. **Be specific**: Store not just "what" but "why"
   - ❌ "Use PostgreSQL"
   - ✅ "Use PostgreSQL for user data because we need ACID transactions"

2. **Use categories**: Proper categorization helps with retrieval
   - Technology choices → `tech-stack`
   - Design patterns → `architecture`
   - Bug fixes → `bugs`

3. **Search naturally**: Use natural language queries
   - "What did we decide about authentication?"
   - "How did we solve the race condition?"
   - "Why did we choose this approach?"

4. **Reflect before deciding**: Check existing context before making new decisions
   - `/hindsight:reflect` before implementing new features
   - Helps maintain consistency with past choices

5. **Review at session end**: The Stop hook will remind you to save important decisions

## Further Reading

- [Hindsight Documentation](https://hindsight.vectorize.io/)
- [Hindsight CLI Reference](./skills/memory-workflow/references/cli-commands.md)
- [Claude Code Plugins Guide](https://code.claude.com/docs/en/plugins)
