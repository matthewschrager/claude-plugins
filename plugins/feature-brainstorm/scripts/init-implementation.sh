#!/bin/bash
# Initialize implementation session from Linear issue
# Usage: init-implementation.sh <linear-issue-id>

set -e

LINEAR_ISSUE="${1:-}"

if [ -z "$LINEAR_ISSUE" ]; then
    echo "ERROR: Linear issue identifier required"
    echo "Usage: init-implementation.sh PROJ-123"
    exit 1
fi

# Create slug from issue ID (lowercase, sanitized)
ISSUE_SLUG=$(echo "$LINEAR_ISSUE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')

if [ -z "$ISSUE_SLUG" ]; then
    ISSUE_SLUG="unnamed-issue"
fi

IMPL_DIR="$(pwd)/implementations/$ISSUE_SLUG"
DATE=$(date +%Y-%m-%d)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Initializing implementation: $LINEAR_ISSUE"
echo "  Slug: $ISSUE_SLUG"
echo "  Directory: $IMPL_DIR"

mkdir -p "$IMPL_DIR"

# Escape special characters for safe sed replacement (handles \, /, &)
LINEAR_ISSUE_ESCAPED=$(printf '%s' "$LINEAR_ISSUE" | sed 's/[\\/&]/\\&/g')

# Copy and substitute templates
for template in implementation.md task_queue.md; do
    TEMPLATE_PATH="$PLUGIN_ROOT/templates/$template"
    OUTPUT_PATH="$IMPL_DIR/$template"

    if [ ! -f "$OUTPUT_PATH" ]; then
        if [ -f "$TEMPLATE_PATH" ]; then
            sed "s/{LINEAR_ISSUE}/$LINEAR_ISSUE_ESCAPED/g; s/{ISSUE_SLUG}/$ISSUE_SLUG/g; s/{DATE}/$DATE/g" \
                "$TEMPLATE_PATH" > "$OUTPUT_PATH"
            echo "  Created: $template"
        else
            echo "  Warning: Template not found: $TEMPLATE_PATH"
        fi
    else
        echo "  Skipped (exists): $template"
    fi
done

# Detect if we're in a git worktree
WORKTREE_PATH=""
if git rev-parse --git-dir >/dev/null 2>&1; then
    GIT_COMMON=$(git rev-parse --git-common-dir 2>/dev/null)
    GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
    if [ "$GIT_COMMON" != "$GIT_DIR" ] && [ -n "$GIT_COMMON" ]; then
        WORKTREE_PATH=$(pwd)
        echo "  Worktree detected: $WORKTREE_PATH"
    fi
fi

# Write context file for hooks (Line 1: slug, Line 2: worktree path if any)
if [ -n "$WORKTREE_PATH" ]; then
    printf "%s\n%s\n" "$ISSUE_SLUG" "$WORKTREE_PATH" > .implement-context
else
    echo "$ISSUE_SLUG" > .implement-context
fi
echo "  Created: .implement-context"

echo ""
echo "Implementation initialized: implementations/$ISSUE_SLUG/"
echo ""
echo "Planning files:"
echo "  - implementations/$ISSUE_SLUG/implementation.md  (session tracking)"
echo "  - implementations/$ISSUE_SLUG/task_queue.md      (task queue/DAG)"
echo ""
echo "Next: Use Linear MCP to fetch issue details and parse DAG"
