# Hindsight CLI Commands Reference

**IMPORTANT**: Complete reference based on `hindsight --help` (API v0.4.7).

## Main Commands

```bash
hindsight <COMMAND>
```

Available commands:
- `bank` - Manage banks (list, create, update, disposition, stats, name, mission, graph, delete, consolidate, clear-observations)
- `memory` - Manage memories (list, get, recall, reflect, retain, retain-files, delete, clear)
- `document` - Manage documents (list, get, delete)
- `entity` - Manage entities (list, get, regenerate)
- `tag` - Manage tags (list)
- `chunk` - Manage chunks (get)
- `operation` - Manage async operations (list, get, cancel)
- `mental-model` - Manage mental models (list, get, create, update, delete, refresh)
- `directive` - Manage directives (list, get, create, update, delete)
- `health` - Check API health status
- `metrics` - Get Prometheus metrics
- `version` - Get API version information
- `explore` - Interactive TUI explorer (k9s-style)
- `ui` - Launch web-based control plane UI
- `configure` - Configure CLI (API URL, API key)

Global options:
- `-o, --output <format>` - Output format: pretty (default), json, yaml
- `-v, --verbose` - Show verbose output including full requests/responses
- `-h, --help` - Print help
- `-V, --version` - Print version

## Bank Commands

### List Banks
```bash
hindsight bank list [OPTIONS]
```

### Get Bank Disposition
```bash
hindsight bank disposition <BANK_ID> [OPTIONS]
# Shows bank's disposition (skepticism, literalism, empathy), background, and mission
```

### Get Bank Stats
```bash
hindsight bank stats <BANK_ID> [OPTIONS]
# Shows memory statistics: total nodes, links, documents, breakdowns
```

### Set Bank Name
```bash
hindsight bank name <BANK_ID> <NAME> [OPTIONS]
# Note: This auto-creates the bank if it doesn't exist
```

### Set Bank Mission
```bash
hindsight bank mission <BANK_ID> <MISSION> [OPTIONS]
# Set the bank's mission statement
```

### Consolidate
```bash
hindsight bank consolidate <BANK_ID> [OPTIONS]
# Trigger consolidation to create/update observations from raw memories
# Options:
#   --wait                Wait for consolidation to complete (polls for status)
#   --poll-interval <N>   Poll interval in seconds (default: 10, only with --wait)
```

### Clear Observations
```bash
hindsight bank clear-observations <BANK_ID> [OPTIONS]
# Clear all observations for a bank (keeps raw memories)
```

### Delete Bank
```bash
hindsight bank delete <BANK_ID> [OPTIONS]
# Permanently deletes bank and all its data
```

## Memory Commands

### Retain (Store) — supports async
```bash
hindsight memory retain <BANK_ID> <CONTENT> [OPTIONS]

Options:
  -d, --doc-id <DOC_ID>          Document ID (auto-generated if not provided)
  -c, --context <CONTEXT>        Context/category for the memory
  --async                        Queue for background processing (RECOMMENDED)
```

### Retain Files (Bulk Import) — supports async
```bash
hindsight memory retain-files <BANK_ID> <PATH> [OPTIONS]
# Bulk import memories from files

Options:
  -r, --recursive                Search directories recursively
  -c, --context <CONTEXT>        Context for all memories
  --async                        Queue for background processing
```

### Recall (Search)
```bash
hindsight memory recall <BANK_ID> <QUERY> [OPTIONS]

Options:
  -t, --fact-type <TYPE>         Fact types: world, experience, opinion
                                 Default: world experience opinion
  -b, --budget <BUDGET>          Thinking budget: low, mid, high
                                 Default: mid
  --max-tokens <NUM>             Maximum tokens for results
                                 Default: 4096
  --trace                        Show trace information
  --include-chunks               Include chunks in results
  --chunk-max-tokens <NUM>       Max tokens for chunks (with --include-chunks)
                                 Default: 8192
```

### Reflect (Analyze)
```bash
hindsight memory reflect <BANK_ID> <QUERY> [OPTIONS]

Options:
  -b, --budget <BUDGET>          Thinking budget: low, mid, high
                                 Default: mid
  -c, --context <CONTEXT>        Additional context (DEPRECATED - pass in query)
  -m, --max-tokens <NUM>         Maximum tokens for response
                                 Default: 4096
  -s, --schema <PATH>            Path to JSON schema file for structured output
```

### List Memories
```bash
hindsight memory list <BANK_ID> [OPTIONS]
```

### Delete Memory
```bash
hindsight memory delete <BANK_ID> <MEMORY_ID> [OPTIONS]
```

### Clear Memories
```bash
hindsight memory clear <BANK_ID> [OPTIONS]
# Clear all memories for a bank
```

## Mental Model Commands

Mental models are user-curated summaries auto-generated from a source query.

### List Mental Models
```bash
hindsight mental-model list <BANK_ID> [OPTIONS]
```

### Create Mental Model
```bash
hindsight mental-model create <BANK_ID> <NAME> <SOURCE_QUERY> [OPTIONS]
# Creates a new mental model from a source query
# Example: hindsight mental-model create my-bank "arch-overview" "What are the main architectural decisions?"
```

### Get Mental Model
```bash
hindsight mental-model get <BANK_ID> <MENTAL_MODEL_ID> [OPTIONS]
```

### Refresh Mental Model
```bash
hindsight mental-model refresh <BANK_ID> <MENTAL_MODEL_ID> [OPTIONS]
# Re-run the source query to update the mental model
```

### Delete Mental Model
```bash
hindsight mental-model delete <BANK_ID> <MENTAL_MODEL_ID> [OPTIONS]
```

## Directive Commands

Directives are behavioral rules injected into reflect prompts.

### List Directives
```bash
hindsight directive list <BANK_ID> [OPTIONS]
```

### Create Directive
```bash
hindsight directive create <BANK_ID> <NAME> <CONTENT> [OPTIONS]
# Example: hindsight directive create my-bank "code-style" "Always suggest TypeScript strict mode"
```

### Get Directive
```bash
hindsight directive get <BANK_ID> <DIRECTIVE_ID> [OPTIONS]
```

### Update Directive
```bash
hindsight directive update <BANK_ID> <DIRECTIVE_ID> [OPTIONS]
```

### Delete Directive
```bash
hindsight directive delete <BANK_ID> <DIRECTIVE_ID> [OPTIONS]
```

## Tag Commands

### List Tags
```bash
hindsight tag list <BANK_ID> [OPTIONS]
# Options:
#   -q, --query <QUERY>    Wildcard search (e.g., 'user:*')
#   -l, --limit <LIMIT>    Max results (default: 100)
#   -s, --offset <OFFSET>  Pagination offset (default: 0)
```

Note: Tags are set via API (not CLI) during retain. They enable filtering during recall.

## Document Commands

### List Documents
```bash
hindsight document list <BANK_ID> [OPTIONS]
```

### Get Document
```bash
hindsight document get <BANK_ID> <DOC_ID> [OPTIONS]
```

### Delete Document
```bash
hindsight document delete <BANK_ID> <DOC_ID> [OPTIONS]
# Deletes document and all its memory units
```

## Entity Commands

### List Entities
```bash
hindsight entity list <BANK_ID> [OPTIONS]
```

### Get Entity
```bash
hindsight entity get <BANK_ID> <ENTITY_UUID> [OPTIONS]
```

### Regenerate Entity
```bash
hindsight entity regenerate <BANK_ID> <ENTITY_UUID> [OPTIONS]
```

## Operation Commands (Async)

### List Operations
```bash
hindsight operation list <BANK_ID> [OPTIONS]
```

### Get Operation Status
```bash
hindsight operation get <BANK_ID> <OPERATION_UUID> [OPTIONS]
# Shows: status (pending/completed/failed), created_at, completed_at
```

### Cancel Operation
```bash
hindsight operation cancel <BANK_ID> <OPERATION_UUID> [OPTIONS]
```

## Interactive Tools

### TUI Explorer
```bash
hindsight explore
# Interactive k9s-style terminal UI for navigating banks, memories, entities
```

### Web UI
```bash
hindsight ui
# Launch web-based control plane UI
```

## Configuration

```bash
hindsight configure --api-url <URL>
# Or use environment variable:
export HINDSIGHT_API_URL=http://localhost:8888
```

## Common Workflows

### Store and Search
```bash
# Store decision (async - returns instantly)
hindsight memory retain my-project "We chose PostgreSQL for ACID compliance" -c tech-stack --async

# Search
hindsight memory recall my-project "database choice" -b high

# Get analysis
hindsight memory reflect my-project "Should we use MongoDB?" -b mid
```

### Check Async Operation
```bash
# After async retain, check status
hindsight operation get my-project <operation-id>
# Status: pending → completed
```

### Bulk Import
```bash
hindsight memory retain-files my-project ./docs/ -c documentation --async
```

## Important Notes

1. **Async retain is recommended** — use `--async` to avoid blocking
2. **No `hindsight bank create`** — Banks auto-create when using `name` or `background`
3. **Case-sensitive bank IDs** — `my-bank` != `My-Bank`
4. **Budget levels**: `low` (quick), `mid` (balanced, default), `high` (thorough)
5. **Fact types in recall**: `world` (facts), `experience` (raw memories), `observation` (auto-summaries)
6. **Tags** — set via API during retain, filtered during recall/reflect (not available via CLI flags)
7. **Mental models** — auto-generated summaries from a query, can be refreshed
8. **Directives** — behavioral rules injected into reflect responses
