#!/bin/bash
# Initialize brainstorm session directory with templates
# Usage: init-brainstorm.sh <feature-name>

set -e

FEATURE_NAME="${1:-unnamed-feature}"

# Create slug (lowercase, hyphens, alphanumeric only)
FEATURE_SLUG=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')

if [ -z "$FEATURE_SLUG" ]; then
    FEATURE_SLUG="unnamed-feature"
fi

# Escape special characters for safe sed replacement (handles \, /, &)
FEATURE_NAME_ESCAPED=$(printf '%s' "$FEATURE_NAME" | sed 's/[\\/&]/\\&/g')

BRAINSTORM_DIR="$(pwd)/brainstorms/$FEATURE_SLUG"
DATE=$(date +%Y-%m-%d)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Initializing brainstorm: $FEATURE_NAME"
echo "  Slug: $FEATURE_SLUG"
echo "  Directory: $BRAINSTORM_DIR"

mkdir -p "$BRAINSTORM_DIR"

# Copy and substitute templates
for template in brainstorm.md task_breakdown.md linear_issues.md; do
    TEMPLATE_PATH="$PLUGIN_ROOT/templates/$template"
    OUTPUT_PATH="$BRAINSTORM_DIR/$template"

    if [ ! -f "$OUTPUT_PATH" ]; then
        if [ -f "$TEMPLATE_PATH" ]; then
            sed "s/{FEATURE_NAME}/$FEATURE_NAME_ESCAPED/g; s/{FEATURE_SLUG}/$FEATURE_SLUG/g; s/{DATE}/$DATE/g" \
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
    printf "%s\n%s\n" "$FEATURE_SLUG" "$WORKTREE_PATH" > .brainstorm-context
else
    echo "$FEATURE_SLUG" > .brainstorm-context
fi
echo "  Created: .brainstorm-context"

echo ""
echo "Brainstorm initialized: brainstorms/$FEATURE_SLUG/"
echo ""
echo "Planning files:"
echo "  - brainstorms/$FEATURE_SLUG/brainstorm.md        (session tracking)"
echo "  - brainstorms/$FEATURE_SLUG/task_breakdown.md    (task details)"
echo "  - brainstorms/$FEATURE_SLUG/linear_issues.md     (Linear issue content)"
