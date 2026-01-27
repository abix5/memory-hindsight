#!/bin/bash
# PostToolUse hook: remind model to save important decisions
# Returns systemMessage reminder instead of auto-saving
# Model decides whether to save based on context and reasoning

set -f  # disable globbing

SETTINGS_FILE=".claude/hindsight.json"
PAUSE_FILE=".claude/hindsight-paused"

# Check if initialized
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

# Exit if no file path
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Get filename and relative path
FILENAME=$(basename "$FILE_PATH")
REL_PATH="$FILE_PATH"

# === SKIP patterns (no reminder needed) ===

# Test files
if [[ "$FILENAME" =~ \.(test|spec)\.(ts|tsx|js|jsx|py|go|rs)$ ]]; then
  exit 0
fi
if [[ "$REL_PATH" =~ __tests__/ ]] || [[ "$REL_PATH" =~ /tests?/ ]] || [[ "$REL_PATH" =~ /spec/ ]]; then
  exit 0
fi

# Documentation
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

# === Determine category and reminder ===

CATEGORY=""
HINT=""

# Package managers (new dependencies)
if [[ "$FILENAME" == "package.json" ]] || [[ "$FILENAME" == "Cargo.toml" ]] || [[ "$FILENAME" == "go.mod" ]] || [[ "$FILENAME" == "requirements.txt" ]] || [[ "$FILENAME" == "pyproject.toml" ]] || [[ "$FILENAME" == "Gemfile" ]]; then
  CATEGORY="tech-stack"
  HINT="If you added/changed dependencies, save WHY you chose them over alternatives"
fi

# Docker/containerization
if [[ "$FILENAME" =~ ^[Dd]ockerfile ]] || [[ "$FILENAME" == "docker-compose.yml" ]] || [[ "$FILENAME" == "docker-compose.yaml" ]] || [[ "$FILENAME" == "compose.yml" ]] || [[ "$FILENAME" == "compose.yaml" ]]; then
  CATEGORY="architecture"
  HINT="If this is a significant container change, save the reasoning"
fi

# CI/CD pipelines
if [[ "$REL_PATH" =~ \.github/workflows/ ]] || [[ "$FILENAME" == ".gitlab-ci.yml" ]] || [[ "$FILENAME" == "Jenkinsfile" ]] || [[ "$FILENAME" == ".circleci/config.yml" ]]; then
  CATEGORY="conventions"
  HINT="If this establishes new pipeline patterns, save the approach"
fi

# Infrastructure as Code
if [[ "$FILENAME" =~ \.(tf|tfvars)$ ]] || [[ "$REL_PATH" =~ k8s/ ]] || [[ "$REL_PATH" =~ kubernetes/ ]] || [[ "$FILENAME" =~ ^(deployment|service|ingress|configmap).*\.ya?ml$ ]]; then
  CATEGORY="architecture"
  HINT="If this is an infrastructure decision, save the strategy and reasoning"
fi

# Build/compile configuration
if [[ "$FILENAME" == "tsconfig.json" ]] || [[ "$FILENAME" =~ ^(webpack|vite|rollup|esbuild|babel)\.config\. ]] || [[ "$FILENAME" == "Makefile" ]] || [[ "$FILENAME" == "CMakeLists.txt" ]]; then
  CATEGORY="tech-stack"
  HINT="If you changed build configuration for a reason, save the decision"
fi

# Database migrations
if [[ "$REL_PATH" =~ migrations?/ ]] || [[ "$REL_PATH" =~ schema/ ]] || [[ "$FILENAME" =~ ^[0-9]+.*\.(sql|up|down)$ ]]; then
  CATEGORY="architecture"
  HINT="If this schema change has design reasoning, save it"
fi

# === Return reminder if important file ===

if [ -n "$CATEGORY" ]; then
  # Return systemMessage reminder - model decides whether to save
  cat << EOF
{
  "systemMessage": "📝 Modified important file: $FILENAME. $HINT. To save: /hindsight:retain \"description with WHAT + WHY\" --context $CATEGORY"
}
EOF
fi

exit 0
