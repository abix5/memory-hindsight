#!/bin/bash
# Detect possible bank_id options for user selection
# Outputs: suggested names and existing banks

set -f

echo "=== Suggested Bank Names ==="

# Option 1: From git remote
if git rev-parse --git-dir >/dev/null 2>&1; then
  REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || true)
  if [ -n "$REMOTE_URL" ]; then
    FROM_REMOTE=$(echo "$REMOTE_URL" | sed -E 's/.*[:/]([^/]+)\/([^/]+?)(\.git)?$/\1-\2/' | tr '[:upper:]' '[:lower:]')
    if [ -n "$FROM_REMOTE" ] && [ "$FROM_REMOTE" != "$REMOTE_URL" ]; then
      echo "from_remote: $FROM_REMOTE"
    fi
  fi
fi

# Option 2: From git repo root directory name (handles worktrees correctly)
if git rev-parse --git-dir >/dev/null 2>&1; then
  # Get the actual repo root (not worktree root)
  GIT_COMMON=$(git rev-parse --git-common-dir 2>/dev/null)
  if [ -n "$GIT_COMMON" ] && [ "$GIT_COMMON" != ".git" ]; then
    # Worktree: get parent repo name
    REPO_ROOT=$(dirname "$GIT_COMMON")
    FROM_REPO=$(basename "$REPO_ROOT" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
  else
    # Regular repo
    TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null)
    FROM_REPO=$(basename "$TOPLEVEL" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
  fi
  if [ -n "$FROM_REPO" ]; then
    echo "from_repo: $FROM_REPO"
  fi
fi

# Option 3: Current directory name (may differ in worktrees)
FROM_DIR=$(basename "$PWD" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
echo "from_dir: $FROM_DIR"

echo ""
echo "=== Existing Banks ==="

# List existing banks if Hindsight is available
if timeout 3 hindsight bank list &>/dev/null; then
  BANKS=$(timeout 3 hindsight bank list 2>/dev/null)
  if [ -n "$BANKS" ]; then
    echo "$BANKS"
  else
    echo "(none)"
  fi
else
  echo "(hindsight unavailable)"
fi
