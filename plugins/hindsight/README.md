# Hindsight Plugin for Claude Code

Integration with [Hindsight](https://github.com/vectorize-io/hindsight) memory bank for storing and retrieving development decisions across sessions.

## Features

- **Persistent Memory**: Store architectural decisions, technology choices, bug solutions, and lessons learned
- **Smart Recall**: Search past decisions with semantic understanding
- **AI Reflection**: Get analysis and recommendations based on stored context
- **Auto Bank ID**: Automatically determines bank from git remote or project name
- **Auto-Workflow**: Automatic context loading, recall, and decision saving via hooks
- **Per-Project Banks**: Each project uses its own memory bank

## Prerequisites

- Hindsight server running locally
- `hindsight` CLI installed
- `jq` installed (for hook scripts)

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
   /hindsight:retain "We chose PostgreSQL over MongoDB for ACID compliance" --context tech-stack
   ```

3. **Search** past decisions:
   ```
   /hindsight:recall "database decisions"
   ```

4. **Get AI analysis**:
   ```
   /hindsight:reflect "Should we add caching given our current architecture?"
   ```

## Auto-Workflow

After initialization, the plugin automatically:

### Session Start
- Loads project context from memory bank
- Shows summary of stored decisions
- Gracefully skips if Hindsight is unavailable

### Smart Recall (on each prompt)
- Searches memory for context relevant to your current question
- Injects relevant past decisions as context
- Skips for short prompts, commands, and confirmations

### Auto-Save (on file changes)
Automatically saves infrastructure decisions when you modify:
- **tech-stack**: package.json, Cargo.toml, go.mod, tsconfig, webpack/vite configs
- **architecture**: Dockerfile, docker-compose, Terraform, Kubernetes, database migrations
- **conventions**: CI/CD pipelines (.github/workflows, .gitlab-ci.yml)

Skips: test files, docs, lock files, node_modules, formatting configs.

### Opt-Out Controls

| Method | Effect |
|--------|--------|
| `!` prefix on prompt | Skip recall for this prompt |
| `/hindsight:pause` | Pause all auto-features |
| `/hindsight:resume` | Resume auto-features |
| `"auto_recall": false` in settings | Disable auto-recall |
| `"auto_save": "off"` in settings | Disable auto-save |

## Commands

| Command | Description |
|---------|-------------|
| `/hindsight:init [bank_id]` | Initialize Hindsight for the project |
| `/hindsight:retain <content> [--context <category>]` | Store information |
| `/hindsight:recall <query> [--budget low\|mid\|high]` | Search memory |
| `/hindsight:reflect <question> [--budget low\|mid\|high]` | Get AI analysis |
| `/hindsight:pause` | Pause auto-recall and auto-save |
| `/hindsight:resume` | Resume auto-features |
| `/hindsight:status` | Show current auto-workflow status |

## Bank ID Resolution

The plugin automatically determines bank_id (no manual input needed):

1. **From settings**: `.claude/hindsight.json` if exists
2. **From git**: Remote origin URL (user/repo -> user-repo)
3. **Fallback**: Current directory name

This ensures you never accidentally store memories in the wrong bank.

## Memory Categories

| Category | What to Store |
|----------|--------------|
| `architecture` | Architectural decisions, system design |
| `tech-stack` | Technology and library choices |
| `patterns` | Code patterns and approaches |
| `decisions` | Important decisions with reasoning |
| `tradeoffs` | Compromises and their justification |
| `bugs` | Complex bugs and their solutions |
| `lessons` | Insights and learnings |
| `requirements` | Business requirements and constraints |
| `conventions` | Coding standards and processes |

## Configuration

Settings are stored per-project in `.claude/hindsight.json`:

```json
{
  "bank_id": "my-project",
  "api_url": "http://localhost:8888",
  "default_context": "decisions",
  "auto_recall": true,
  "auto_save": "hybrid"
}
```

This file is automatically created by `/hindsight:init` and added to `.gitignore`.

### Auto-Save Modes

| Mode | Behavior |
|------|----------|
| `"hybrid"` (default) | Auto-save definite decisions, ask for ambiguous |
| `"all"` | Auto-save all detected decisions |
| `"off"` | Disable auto-save entirely |

## Workflow

The plugin encourages a memory-first development workflow:

1. **Session start**: Context from past decisions is loaded automatically
2. **During work**: Relevant memories surface when you ask questions
3. **Infrastructure changes**: Key config changes are auto-saved
4. **Discussions**: The memory-keeper agent suggests storing important conclusions
5. **Manual save**: Use `/hindsight:retain` for nuanced decisions

## Graceful Degradation

The plugin handles failures gracefully:
- **Hindsight unavailable**: Shows warning, disables auto-features, manual commands show clear errors
- **Slow responses**: Timeouts prevent blocking (2-5s depending on operation)
- **Network errors**: Silent skip with no disruption to main workflow

## Plugin Structure

```
hindsight/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   ├── init.md              # /hindsight:init
│   ├── retain.md            # /hindsight:retain
│   ├── recall.md            # /hindsight:recall
│   ├── reflect.md           # /hindsight:reflect
│   ├── pause.md             # /hindsight:pause
│   ├── resume.md            # /hindsight:resume
│   └── status.md            # /hindsight:status
├── hooks/
│   └── hooks.json           # Auto-workflow hooks
├── scripts/
│   ├── get-bank-id.sh       # Smart bank_id resolution
│   ├── init-bank.sh         # Initialize bank and settings
│   ├── session-start.sh     # Session context loading
│   ├── smart-recall.sh      # Prompt-based auto-recall
│   ├── analyze-decision.sh  # File change auto-save
│   └── status-check.sh      # Status information
├── agents/
│   └── memory-keeper.md     # Proactive decision storage agent
├── skills/
│   └── memory-workflow/
│       └── SKILL.md         # Memory workflow guidance
├── templates/
│   └── hindsight-guide.md   # Project guide template
└── README.md                # This file
```

## Installation

```bash
# Add marketplace
/plugin marketplace add abix5/memory-hindsight

# Install plugin
/plugin install hindsight@memory-hindsight
```

For local development:

```bash
claude --plugin-dir /path/to/hindsight
```

## CLI Reference

For direct CLI usage (outside of plugin commands):

```bash
# Store memory
hindsight memory retain <bank_id> "<content>" --context <category>

# Search memory
hindsight memory recall <bank_id> "<query>" --budget <low|mid|high>

# Get analysis
hindsight memory reflect <bank_id> "<question>" --budget <low|mid|high>

# Bank management
hindsight bank list
hindsight bank stats <bank_id>
hindsight bank disposition <bank_id>
```
