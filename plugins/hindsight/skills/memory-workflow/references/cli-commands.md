# Hindsight CLI Commands Reference

**IMPORTANT**: This is the complete and accurate reference based on `hindsight --help` output.

## Main Commands

```bash
hindsight <COMMAND>
```

Available commands:
- `bank` - Manage banks (list, profile, stats)
- `memory` - Manage memories (recall, reflect, retain, delete)
- `document` - Manage documents (list, get, delete)
- `entity` - Manage entities (list, get, regenerate)
- `operation` - Manage async operations (list, cancel)
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
# Shows bank's disposition (skepticism, literalism, empathy) and background
```

### Get Bank Stats
```bash
hindsight bank stats <BANK_ID> [OPTIONS]
# Shows memory statistics for the bank
```

### Set Bank Name
```bash
hindsight bank name <BANK_ID> <NAME> [OPTIONS]
# Note: This auto-creates the bank if it doesn't exist
```

### Set Bank Background
```bash
hindsight bank background <BANK_ID> <CONTENT> [OPTIONS]
# Options:
#   --no-update-disposition  Skip automatic disposition inference
# Note: This auto-creates the bank if it doesn't exist
```

### Delete Bank
```bash
hindsight bank delete <BANK_ID> [OPTIONS]
# Permanently deletes bank and all its data
```

## Memory Commands

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
  -c, --context <CONTEXT>        Additional context
  -m, --max-tokens <NUM>         Maximum tokens for response
                                 Default: 4096
  -s, --schema <PATH>            Path to JSON schema file for structured output
```

### Retain (Store)
```bash
hindsight memory retain <BANK_ID> <CONTENT> [OPTIONS]

Options:
  -d, --doc-id <DOC_ID>          Document ID (auto-generated if not provided)
  -c, --context <CONTEXT>        Context/category for the memory
  --async                        Queue for background processing
```

### Retain Files (Bulk Import)
```bash
hindsight memory retain-files <BANK_ID> <PATH> [OPTIONS]
# Bulk import memories from files
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
# Get detailed information about an entity
```

### Regenerate Entity
```bash
hindsight entity regenerate <BANK_ID> <ENTITY_UUID> [OPTIONS]
# Regenerate observations for an entity
```

## Operation Commands

### List Operations
```bash
hindsight operation list <BANK_ID> [OPTIONS]
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

Current API URL shown at bottom of `hindsight --help`

## Common Workflows

### Initialize New Bank
```bash
# Banks auto-create when you set name or background
hindsight bank name "my-project" "My Project Name"
hindsight bank background "my-project" "Project description and context"
```

### Check Bank Status
```bash
hindsight bank stats my-project
hindsight bank disposition my-project
```

### Store and Search
```bash
# Store decision
hindsight memory retain my-project "We chose PostgreSQL for ACID compliance" -c tech-stack

# Search
hindsight memory recall my-project "database choice" -b high

# Get analysis
hindsight memory reflect my-project "Should we use MongoDB?" -b mid
```

### Bulk Import
```bash
hindsight memory retain-files my-project ./docs/ -c documentation
```

## Important Notes

1. **No `hindsight bank create`** - Banks auto-create when using `name` or `background`
2. **No `hindsight bank info`** - Use `disposition` or `stats` instead
3. **Case-sensitive bank IDs** - `my-bank` ≠ `My-Bank`
4. **JSON output** - All commands support `--output json` for scripting
5. **Verbose mode** - Use `-v` or `--verbose` for debugging
6. **Budget levels**:
   - `low` - Quick, basic results
   - `mid` - Balanced (default)
   - `high` - Thorough, comprehensive
