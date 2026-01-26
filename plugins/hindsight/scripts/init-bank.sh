#!/bin/bash
# Initialize Hindsight memory bank for the current project

set -e

SETTINGS_FILE=".claude/hindsight.json"
GUIDE_FILE=".claude/hindsight-guide.md"
BANK_ID="${1:-}"

# Function to extract from git remote or use directory name
get_default_bank_id() {
  # Try git remote first
  if git rev-parse --git-dir >/dev/null 2>&1; then
    REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || true)
    if [ -n "$REMOTE_URL" ]; then
      # Extract user/repo from various URL formats:
      # https://github.com/user/repo.git
      # git@github.com:user/repo.git
      # https://github.com/user/repo
      BANK_ID=$(echo "$REMOTE_URL" | sed -E 's/.*[:/]([^/]+)\/([^/]+?)(\.git)?$/\1-\2/' | tr '[:upper:]' '[:lower:]')
      if [ -n "$BANK_ID" ] && [ "$BANK_ID" != "$REMOTE_URL" ]; then
        echo "$BANK_ID"
        return 0
      fi
    fi
  fi
  # Fallback to directory name
  basename "$PWD" | tr '[:upper:]' '[:lower:]' | tr ' ' '-'
}

# Check if settings file already exists
if [ -f "$SETTINGS_FILE" ]; then
  echo "⚠️  Settings file already exists: $SETTINGS_FILE"
  EXISTING_BANK_ID=$(grep -o '"bank_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$SETTINGS_FILE" | sed 's/.*"bank_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  echo "Current bank_id: $EXISTING_BANK_ID"
  echo ""
  echo "To reinitialize, delete the file first: rm $SETTINGS_FILE"
  exit 1
fi

# Determine bank_id
if [ -z "$BANK_ID" ]; then
  BANK_ID=$(get_default_bank_id)
  echo "📝 Using auto-detected bank_id: $BANK_ID"
else
  echo "📝 Using provided bank_id: $BANK_ID"
fi

# Verify Hindsight server is accessible
echo ""
echo "🔍 Checking Hindsight server..."
if ! hindsight bank list >/dev/null 2>&1; then
  echo "❌ ERROR: Hindsight server not accessible"
  echo ""
  echo "Make sure Hindsight is running:"
  echo "  docker-compose up -d"
  echo ""
  echo "Or set HINDSIGHT_API_URL:"
  echo "  export HINDSIGHT_API_URL=http://localhost:8888"
  exit 1
fi
echo "✅ Hindsight server is accessible"

# Check if bank exists
echo ""
echo "🔍 Checking if bank exists..."
if hindsight bank list -o yaml 2>/dev/null | grep -q "^$BANK_ID"; then
  echo "✅ Bank '$BANK_ID' already exists"
else
  echo "📦 Creating bank '$BANK_ID'..."
  if ! hindsight bank name "$BANK_ID" "$(basename "$PWD")" -o yaml 2>&1; then
    echo "❌ Failed to create bank"
    exit 1
  fi

  if ! hindsight bank background "$BANK_ID" "Memory bank for $(basename "$PWD") project development decisions and architecture choices" -o yaml 2>&1; then
    echo "⚠️  Bank created but failed to set background"
  fi

  echo "✅ Bank '$BANK_ID' created successfully"
fi

# Create .claude directory
mkdir -p .claude

# Create settings file (JSON)
echo ""
echo "📄 Creating settings file: $SETTINGS_FILE"
cat > "$SETTINGS_FILE" <<EOF
{
  "bank_id": "$BANK_ID",
  "api_url": "http://localhost:8888",
  "default_context": "decisions",
  "auto_recall": true,
  "auto_save": "hybrid"
}
EOF
echo "✅ Settings file created"

# Copy guide template
echo ""
echo "📚 Creating guide file: $GUIDE_FILE"
if [ -f "${CLAUDE_PLUGIN_ROOT}/templates/hindsight-guide.md" ]; then
  cp "${CLAUDE_PLUGIN_ROOT}/templates/hindsight-guide.md" "$GUIDE_FILE"
  echo "✅ Guide file created from template"
else
  # Fallback if template not found
  cat > "$GUIDE_FILE" <<'GUIDE_EOF'
# Hindsight Memory Bank Guide

This project uses Hindsight to store and retrieve development decisions.

## Quick Commands

- `/hindsight:retain "decision" --context category` - Store decision
- `/hindsight:recall "query"` - Search memory
- `/hindsight:reflect "question"` - Get AI analysis

## Memory Categories

- **architecture** - Architectural decisions, system design
- **tech-stack** - Technology and library choices
- **patterns** - Code patterns and approaches
- **decisions** - Important decisions with reasoning
- **tradeoffs** - Compromises and their justification
- **bugs** - Complex bugs and their solutions
- **lessons** - Insights and learnings
- **requirements** - Business requirements and constraints
- **conventions** - Coding standards and processes

## Best Practices

### When storing:
- Include the "why" not just "what"
- Mention alternatives considered
- Be specific to project context

### Example:
```
✅ Good: "Use PostgreSQL because we need ACID transactions for payment processing"
❌ Bad:  "Use PostgreSQL"
```

See plugin documentation for more details.
GUIDE_EOF
  echo "✅ Guide file created (template not found, using fallback)"
fi

# Add to .gitignore
if [ -f .gitignore ]; then
  # Add settings file to gitignore (personal config)
  if ! grep -q '.claude/hindsight.json' .gitignore 2>/dev/null; then
    echo ""
    echo "📝 Adding settings to .gitignore..."
    echo '.claude/hindsight.json' >> .gitignore
    echo "✅ Added to .gitignore"
  fi

  # Make sure guide is NOT in gitignore (should be committed)
  if grep -q '.claude/hindsight-guide.md' .gitignore 2>/dev/null; then
    echo "⚠️  Warning: .claude/hindsight-guide.md is in .gitignore"
    echo "   This file should be committed for team collaboration"
  fi
else
  echo ""
  echo "📝 Creating .gitignore..."
  echo '.claude/hindsight.json' > .gitignore
  echo "✅ Created .gitignore"
fi

echo ""
echo "🎉 Hindsight initialization complete!"
echo ""
echo "Created files:"
echo "  📄 $SETTINGS_FILE (git-ignored, personal config)"
echo "  📚 $GUIDE_FILE (git-committed, team guide)"
echo ""
echo "Bank ID: $BANK_ID"
echo ""
echo "Next steps:"
echo "  /hindsight:retain \"<decision>\" --context <category>"
echo "  /hindsight:recall \"<query>\""
echo "  /hindsight:reflect \"<question>\""
echo ""
echo "💡 Tip: Check $GUIDE_FILE for detailed usage instructions!"
