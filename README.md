# Hindsight Plugin for Claude Code

Memory bank integration for storing and retrieving development decisions across sessions.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Requirements

- Claude Code >= 1.0.33
- Hindsight server ([Docker setup](./examples/))
- `hindsight` CLI (plugin uses CLI, not MCP server):
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
# Initialize memory bank for project
/hindsight:init

# Save a decision
/hindsight:retain "Chose PostgreSQL for ACID transactions" --context tech-stack

# Search memories
/hindsight:recall database architecture

# AI analysis
/hindsight:reflect Should we add caching?
```

## Commands

| Command | Description |
|---------|-------------|
| `/hindsight:init` | Initialize memory bank |
| `/hindsight:retain` | Save decision to memory |
| `/hindsight:recall` | Search memories |
| `/hindsight:reflect` | AI analysis based on memory |
| `/hindsight:status` | Check memory bank status |
| `/hindsight:pause` | Pause auto-workflow |
| `/hindsight:resume` | Resume auto-workflow |

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
- [Plugin Development Guide](./CLAUDE.md)

## Links

- [Hindsight](https://github.com/vectorize-io/hindsight) - Memory bank system
- [Claude Code](https://claude.com/claude-code) - AI development environment

## License

MIT
