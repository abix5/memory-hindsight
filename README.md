# Hindsight Plugin for Claude Code

Persistent memory for AI-assisted development. Store decisions, recall context, and get analysis grounded in your project's history — across sessions.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## What It Does

Hindsight gives Claude Code a long-term memory bank. It automatically:

- **Recalls** relevant past decisions before answering your questions
- **Saves** important decisions, bug fixes, and tradeoffs as you work
- **Preserves** context before conversation compaction (so nothing is lost)
- **Analyzes** your accumulated knowledge to inform new decisions

All of this works autonomously — no manual commands needed for day-to-day use.

## Requirements

- Claude Code >= 1.0.33
- Hindsight server ([Docker setup](./examples/))
- `hindsight` CLI:
  ```bash
  curl -fsSL https://hindsight.vectorize.io/get-cli | bash
  ```

## Installation

```bash
# Add marketplace
/plugin marketplace add abix5/memory-hindsight

# Install plugin
/plugin install hindsight
```

## Quick Start

```bash
# Initialize memory bank for your project
/hindsight:init

# That's it — the plugin works autonomously from here
```

Once initialized, the plugin will automatically recall relevant context before answering architecture/design questions and save important decisions as they happen. You can also use commands manually:

```bash
# Save a decision
/hindsight:retain Chose PostgreSQL for ACID transactions in payment service

# Search memories
/hindsight:recall database architecture

# AI analysis grounded in project history
/hindsight:reflect Should we add caching layer?

# Check what's configured
/hindsight:status
```

## Commands

| Command | Description |
|---------|-------------|
| `/hindsight:init` | Initialize memory bank for current project |
| `/hindsight:retain` | Save information to memory bank |
| `/hindsight:recall` | Search for information in memory bank |
| `/hindsight:reflect` | Get AI analysis based on project memory |
| `/hindsight:rescan` | Rescan project to update memory with new findings |
| `/hindsight:status` | Show auto-workflow status and settings |
| `/hindsight:pause` | Pause auto-recall and auto-save |
| `/hindsight:resume` | Resume auto-recall and auto-save |

## How It Works

### Autonomous Memory Workflow

The plugin uses hooks to manage memory without manual intervention:

| Event | What happens |
|-------|-------------|
| **Session start** | Loads bank configuration, checks connectivity |
| **Each prompt** | Evaluates if memory recall would help, searches automatically |
| **Conversation compaction** | Saves unsaved decisions/insights before context is trimmed |
| **Session stop** | Checks for unsaved important knowledge |

### Components

- **Commands** — 8 slash commands for manual interaction
- **Agent (memory-keeper)** — proactively identifies decisions worth saving during conversation
- **Skills** — contextual knowledge for retain, recall, reflect, and the overall workflow
- **Hooks** — SessionStart, UserPromptSubmit, PreCompact, Stop automation

### Memory Categories

| Category | When to use |
|----------|-------------|
| `architecture` | System design, components, DB schema |
| `tech-stack` | Technology/library choices with reasoning |
| `patterns` | Code patterns, implementation approaches |
| `decisions` | Key decisions with reasoning |
| `tradeoffs` | Compromises, what was sacrificed for what |
| `bugs` | Non-trivial bugs: root cause + solution |
| `lessons` | Insights, gotchas, unexpected behaviors |
| `requirements` | Business constraints, SLAs |
| `conventions` | Standards, naming, team agreements |

## Server Setup

See [examples/](./examples/) for Docker Compose configuration:

```bash
cd examples
cp .env.example .env
# Edit .env with your LLM API key
docker-compose up -d
```

## Documentation

- [Plugin Usage Guide](./plugins/hindsight/USAGE.md)
- [CLI Commands Reference](./plugins/hindsight/skills/memory-workflow/references/cli-commands.md)
- [Plugin Development Guide](./CLAUDE.md)

## Links

- [Hindsight](https://github.com/vectorize-io/hindsight) — Memory bank system
- [Hindsight Docs](https://hindsight.vectorize.io/) — Official documentation
- [Claude Code](https://claude.com/claude-code) — AI development environment

## License

MIT
