#!/bin/bash
# PostToolUse hook: analyze file changes and auto-save important decisions
# Triggered on Write|Edit operations
# - Categorizes files by importance
# - Auto-saves definite infrastructure decisions
# - Skips test files, docs, and irrelevant changes

set -f  # disable globbing

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
SETTINGS_FILE=".claude/hindsight.json"
PAUSE_FILE=".claude/hindsight-paused"

# Check if initialized (settings file is the initialization marker)
if [ ! -f "$SETTINGS_FILE" ]; then
  exit 0
fi

# Check if paused
if [ -f "$PAUSE_FILE" ]; then
  exit 0
fi

# Check auto_save setting
if [ -f "$SETTINGS_FILE" ]; then
  AUTO_SAVE=$(grep -o '"auto_save"[[:space:]]*:[[:space:]]*"[^"]*"' "$SETTINGS_FILE" 2>/dev/null | sed 's/.*"\([^"]*\)"$/\1/')
  if [ "$AUTO_SAVE" = "off" ] || [ "$AUTO_SAVE" = "false" ]; then
    exit 0
  fi
fi

# Read tool input from stdin
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

# Exit if no file path
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Get just the filename/relative path for pattern matching
FILENAME=$(basename "$FILE_PATH")
REL_PATH="$FILE_PATH"

# === SKIP patterns (don't save) ===

# Test files
if [[ "$FILENAME" =~ \.(test|spec)\.(ts|tsx|js|jsx|py|go|rs)$ ]]; then
  exit 0
fi
if [[ "$REL_PATH" =~ __tests__/ ]] || [[ "$REL_PATH" =~ /tests?/ ]] || [[ "$REL_PATH" =~ /spec/ ]]; then
  exit 0
fi

# Documentation (except architectural)
if [[ "$FILENAME" =~ ^(README|CHANGELOG|LICENSE|CONTRIBUTING) ]]; then
  exit 0
fi

# Dependencies/generated
if [[ "$REL_PATH" =~ node_modules/ ]] || [[ "$REL_PATH" =~ vendor/ ]] || [[ "$REL_PATH" =~ dist/ ]] || [[ "$REL_PATH" =~ build/ ]]; then
  exit 0
fi

# Lock files
if [[ "$FILENAME" =~ \.(lock|sum)$ ]] || [[ "$FILENAME" == "package-lock.json" ]] || [[ "$FILENAME" == "yarn.lock" ]] || [[ "$FILENAME" == "pnpm-lock.yaml" ]]; then
  exit 0
fi

# Formatting/style only
if [[ "$FILENAME" =~ ^\.?(eslint|prettier|editorconfig|stylelint) ]]; then
  exit 0
fi

# === DEFINITE SAVE patterns (auto-save) ===

DEFINITE_SAVE=false
CATEGORY="decisions"
CONTENT=""

# Package managers (new dependencies = tech-stack decision)
if [[ "$FILENAME" == "package.json" ]] || [[ "$FILENAME" == "Cargo.toml" ]] || [[ "$FILENAME" == "go.mod" ]] || [[ "$FILENAME" == "requirements.txt" ]] || [[ "$FILENAME" == "pyproject.toml" ]] || [[ "$FILENAME" == "Gemfile" ]]; then
  DEFINITE_SAVE=true
  CATEGORY="tech-stack"
  CONTENT="Dependencies changed in $FILENAME"
fi

# Docker/containerization
if [[ "$FILENAME" =~ ^[Dd]ockerfile ]] || [[ "$FILENAME" == "docker-compose.yml" ]] || [[ "$FILENAME" == "docker-compose.yaml" ]] || [[ "$FILENAME" == "compose.yml" ]] || [[ "$FILENAME" == "compose.yaml" ]]; then
  DEFINITE_SAVE=true
  CATEGORY="architecture"
  CONTENT="Container configuration changed: $FILENAME"
fi

# CI/CD pipelines
if [[ "$REL_PATH" =~ \.github/workflows/ ]] || [[ "$FILENAME" == ".gitlab-ci.yml" ]] || [[ "$FILENAME" == "Jenkinsfile" ]] || [[ "$FILENAME" == ".circleci/config.yml" ]]; then
  DEFINITE_SAVE=true
  CATEGORY="conventions"
  CONTENT="CI/CD pipeline changed: $FILENAME"
fi

# Infrastructure as Code
if [[ "$FILENAME" =~ \.(tf|tfvars)$ ]] || [[ "$REL_PATH" =~ k8s/ ]] || [[ "$REL_PATH" =~ kubernetes/ ]] || [[ "$FILENAME" =~ ^(deployment|service|ingress|configmap).*\.ya?ml$ ]]; then
  DEFINITE_SAVE=true
  CATEGORY="architecture"
  CONTENT="Infrastructure configuration changed: $FILENAME"
fi

# Build/compile configuration
if [[ "$FILENAME" == "tsconfig.json" ]] || [[ "$FILENAME" =~ ^(webpack|vite|rollup|esbuild|babel)\.config\. ]] || [[ "$FILENAME" == "Makefile" ]] || [[ "$FILENAME" == "CMakeLists.txt" ]]; then
  DEFINITE_SAVE=true
  CATEGORY="tech-stack"
  CONTENT="Build configuration changed: $FILENAME"
fi

# Database migrations
if [[ "$REL_PATH" =~ migrations?/ ]] || [[ "$REL_PATH" =~ schema/ ]] || [[ "$FILENAME" =~ ^[0-9]+.*\.(sql|up|down)$ ]]; then
  DEFINITE_SAVE=true
  CATEGORY="architecture"
  CONTENT="Database schema changed: $FILENAME"
fi

# === Execute save if definite ===

if [ "$DEFINITE_SAVE" = true ]; then
  # Get bank ID
  BANK_ID=$(bash "$PLUGIN_ROOT/scripts/get-bank-id.sh" 2>/dev/null)
  if [ -z "$BANK_ID" ]; then
    exit 0
  fi

  # Check Hindsight availability
  if ! timeout 2 hindsight bank list &>/dev/null; then
    exit 0
  fi

  # Check for duplicates (quick recall)
  EXISTING=$(timeout 2 hindsight memory recall "$BANK_ID" "$CONTENT" --budget low --max-tokens 200 2>/dev/null)
  LOWER_EXISTING=$(echo "$EXISTING" | tr '[:upper:]' '[:lower:]')

  # Skip if very similar entry exists
  if [ -n "$EXISTING" ] && [[ "$LOWER_EXISTING" != *"no relevant"* ]] && [[ "$LOWER_EXISTING" != *"no memories"* ]]; then
    # Similar entry exists, skip to avoid noise
    exit 0
  fi

  # Save to memory
  if timeout 3 hindsight memory retain "$BANK_ID" "$CONTENT" --context "$CATEGORY" &>/dev/null; then
    echo "{\"systemMessage\": \"\ud83d\udcbe Auto-saved: $FILENAME change ($CATEGORY)\"}"
  fi
fi
