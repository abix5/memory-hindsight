# Hindsight Plugin for Claude Code

Integration with [Hindsight](https://github.com/vectorize-io/hindsight) memory bank for storing and retrieving development decisions across sessions.

## Features

- **Persistent Memory**: Store architectural decisions, technology choices, bug solutions, and lessons learned
- **Smart Recall**: Search past decisions with semantic understanding
- **AI Reflection**: Get analysis and recommendations based on stored context
- **Direct CLI Integration**: Commands execute `hindsight` CLI directly via bash
- **Auto-Suggestions**: Proactive prompts to save important decisions
- **Per-Project Banks**: Each project uses its own memory bank

## Prerequisites

- Hindsight server running locally (see README.md for setup)
- `hindsight` CLI installed

### Installing CLI

```bash
cargo install hindsight-cli
# or download from releases
```

## Quick Start

1. **Initialize** the memory bank for your project:
   ```
   /hindsight:init
   ```

2. **Store** important decisions:
   ```
   /hindsight:retain We chose PostgreSQL over MongoDB for ACID compliance --context tech-stack
   ```

3. **Search** past decisions:
   ```
   /hindsight:recall database decisions
   ```

4. **Get AI analysis**:
   ```
   /hindsight:reflect Should we add caching given our current architecture?
   ```

## Commands

| Command | Description |
|---------|-------------|
| `/hindsight:init [bank_id]` | Initialize Hindsight for the project |
| `/hindsight:retain <content> [--context <category>]` | Store information |
| `/hindsight:recall <query> [--budget low\|mid\|high]` | Search memory |
| `/hindsight:reflect <question> [--budget low\|mid\|high]` | Get AI analysis |

## Memory Categories

| Category | What to Store |
|----------|--------------|
| `architecture` | System design, component structure |
| `tech-stack` | Technology and library choices |
| `patterns` | Code patterns, design patterns |
| `decisions` | Key decisions with reasoning |
| `tradeoffs` | Compromises and justification |
| `bugs` | Complex bugs and solutions |
| `lessons` | Insights and learnings |
| `requirements` | Business constraints |
| `conventions` | Code and process standards |

## Configuration

Settings are stored per-project in `.claude/hindsight.json`:

```json
{
  "bank_id": "my-project",
  "api_url": "http://localhost:8888",
  "default_context": "decisions"
}
```

This file is automatically added to `.gitignore` during initialization.

## Workflow

The plugin encourages a memory-first development workflow:

1. **Before decisions**: Check if similar decisions were made before
2. **During discussions**: The agent may suggest storing important conclusions
3. **After sessions**: Review and store key takeaways (via Stop hook)

## MCP Integration

The plugin also configures MCP server connection for direct tool access:
- `retain` - Store memories
- `recall` - Search memories
- `reflect` - AI analysis
- `list_banks` - List memory banks
- `create_bank` - Create new bank

## How It Works

Commands in this plugin use **bash execution** to directly call the `hindsight` CLI:

1. **Settings loading**: Scripts read `.claude/hindsight.json` (simple JSON config) to get the bank_id
2. **CLI execution**: Commands execute `hindsight memory <operation>` with arguments
3. **Result interpretation**: Claude receives the output and interprets it for you

This approach provides:
- ✅ **Direct access** to Hindsight functionality
- ✅ **Real-time results** from the memory bank
- ✅ **Automatic configuration** via project settings file
- ✅ **Smart interpretation** of results by Claude

## Plugin Structure

```
hindsight/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   ├── init.md              # /hindsight:init command
│   ├── retain.md            # /hindsight:retain command
│   ├── recall.md            # /hindsight:recall command
│   └── reflect.md           # /hindsight:reflect command
├── scripts/
│   ├── get-bank-id.sh       # Extract bank_id from settings
│   └── init-bank.sh         # Initialize bank and settings
├── agents/
│   └── memory-keeper.md     # Decision storage agent
├── skills/
│   └── memory-workflow/
│       ├── SKILL.md         # Memory workflow guidance
│       └── references/
│           └── cli-commands.md  # Complete CLI reference
├── hooks/
│   └── hooks.json           # Stop hook for session end
├── .mcp.json                # MCP server configuration
└── README.md                # This file
```

## Testing the Plugin

```bash
# Run Claude Code with the plugin
claude --plugin-dir /path/to/hindsight
```
