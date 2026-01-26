#!/bin/bash
# Update CLAUDE.md with Hindsight memory bank instructions
# - Idempotent: checks for existing markers before adding
# - Updates bank_id if block exists but bank changed
# - Creates CLAUDE.md if it doesn't exist
#
# Usage: bash update-claude-md.sh <bank_id>
# Exit codes:
#   0 - Success (added or updated)
#   1 - Error (missing arguments, etc.)

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
TEMPLATE_FILE="$PLUGIN_ROOT/templates/claude-md-hindsight.md"
CLAUDE_MD="CLAUDE.md"

# Markers for idempotent updates
START_MARKER="<!-- HINDSIGHT-MEMORY-BANK-START -->"
END_MARKER="<!-- HINDSIGHT-MEMORY-BANK-END -->"

# Check arguments
if [ $# -lt 1 ]; then
  echo "Error: bank_id required" >&2
  echo "Usage: bash update-claude-md.sh <bank_id>" >&2
  exit 1
fi

BANK_ID="$1"

# Check template exists
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Error: Template not found: $TEMPLATE_FILE" >&2
  exit 1
fi

# Read template and substitute bank_id
BLOCK_CONTENT=$(sed "s/{{BANK_ID}}/$BANK_ID/g" "$TEMPLATE_FILE")

# Function to add block to CLAUDE.md
add_block() {
  local target="$1"
  local content="$2"

  if [ -f "$target" ]; then
    # File exists - append with newlines
    echo "" >> "$target"
    echo "$content" >> "$target"
  else
    # Create new file
    echo "$content" > "$target"
  fi
}

# Function to update existing block
update_block() {
  local target="$1"
  local content="$2"

  # Create temp file
  local temp_file=$(mktemp)

  # State machine to replace block
  local in_block=false
  local block_replaced=false

  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" == *"$START_MARKER"* ]]; then
      in_block=true
      # Write new block content
      echo "$content" >> "$temp_file"
      block_replaced=true
    elif [[ "$line" == *"$END_MARKER"* ]]; then
      in_block=false
      # Skip the end marker (already in new content)
    elif [ "$in_block" = false ]; then
      echo "$line" >> "$temp_file"
    fi
    # Skip lines inside old block
  done < "$target"

  # Replace original file
  mv "$temp_file" "$target"
}

# Check if CLAUDE.md exists and contains our block
if [ -f "$CLAUDE_MD" ]; then
  if grep -q "$START_MARKER" "$CLAUDE_MD"; then
    # Block exists - check if bank_id changed
    # Extract bank_id from line like: **Bank ID:** `test-bank-id`
    EXISTING_BANK=$(grep "Bank ID:" "$CLAUDE_MD" | sed -n 's/.*`\([^`]*\)`.*/\1/p' | head -1)

    if [ "$EXISTING_BANK" = "$BANK_ID" ]; then
      echo "Hindsight block already exists in CLAUDE.md with same bank_id ($BANK_ID)"
      echo "No changes needed"
      exit 0
    else
      # Update block with new bank_id
      echo "Updating Hindsight block in CLAUDE.md (bank_id: $EXISTING_BANK -> $BANK_ID)"
      update_block "$CLAUDE_MD" "$BLOCK_CONTENT"
      echo "Updated successfully"
      exit 0
    fi
  else
    # File exists but no block - append
    echo "Adding Hindsight block to existing CLAUDE.md"
    add_block "$CLAUDE_MD" "$BLOCK_CONTENT"
    echo "Added successfully"
    exit 0
  fi
else
  # No CLAUDE.md - create with block
  echo "Creating CLAUDE.md with Hindsight block"
  add_block "$CLAUDE_MD" "$BLOCK_CONTENT"
  echo "Created successfully"
  exit 0
fi
