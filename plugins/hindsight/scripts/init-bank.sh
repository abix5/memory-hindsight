#!/bin/bash
# Initialize Hindsight memory bank for the current project

set -e

SETTINGS_FILE=".claude/hindsight.json"
BANK_ID="${1:-}"

# Function to extract from git remote or use directory name
get_default_bank_id() {
  # Try git remote first
  if git config --get remote.origin.url >/dev/null 2>&1; then
    git config --get remote.origin.url | sed 's/.*[:/]\([^/]*\/[^/]*\)\.git/\1/' | tr '/' '-' 2>/dev/null || basename "$PWD"
  else
    basename "$PWD"
  fi
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
if hindsight bank list 2>/dev/null | grep -q "^$BANK_ID"; then
  echo "✅ Bank '$BANK_ID' already exists"
else
  echo "📦 Creating bank '$BANK_ID'..."
  if ! hindsight bank name "$BANK_ID" "$(basename "$PWD")" 2>&1; then
    echo "❌ Failed to create bank"
    exit 1
  fi

  if ! hindsight bank background "$BANK_ID" "Memory bank for $(basename "$PWD") project development decisions and architecture choices" 2>&1; then
    echo "⚠️  Bank created but failed to set background"
  fi

  echo "✅ Bank '$BANK_ID' created successfully"
fi

# Create settings file
echo ""
echo "📄 Creating settings file: $SETTINGS_FILE"
mkdir -p .claude
cat > "$SETTINGS_FILE" <<EOF
{
  "bank_id": "$BANK_ID",
  "api_url": "http://localhost:8888",
  "default_context": "decisions"
}
EOF

echo "✅ Settings file created"

# Add to .gitignore
if [ -f .gitignore ]; then
  if ! grep -q '.claude/hindsight.json' .gitignore 2>/dev/null; then
    echo ""
    echo "📝 Adding to .gitignore..."
    echo '.claude/hindsight.json' >> .gitignore
    echo "✅ Added to .gitignore"
  fi
fi

echo ""
echo "🎉 Hindsight initialization complete!"
echo ""
echo "Bank ID: $BANK_ID"
echo "Settings: $SETTINGS_FILE"
echo ""
echo "Next steps:"
echo "  /hindsight:retain \"<decision>\" --context <category>"
echo "  /hindsight:recall \"<query>\""
echo "  /hindsight:reflect \"<question>\""
