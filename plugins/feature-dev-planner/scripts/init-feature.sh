#!/bin/bash
# Initialize feature planning directory with templates
# Usage: init-feature.sh <feature-name>

set -e

FEATURE_NAME="${1:-unnamed-feature}"

# Create slug from feature name (lowercase, hyphens, alphanumeric only)
FEATURE_SLUG=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')

# Ensure we have a valid slug
if [ -z "$FEATURE_SLUG" ]; then
    FEATURE_SLUG="unnamed-feature"
fi

PLAN_DIR="$(pwd)/plans/$FEATURE_SLUG"
DATE=$(date +%Y-%m-%d)

# Get the plugin root directory (parent of scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Initializing feature: $FEATURE_NAME"
echo "  Slug: $FEATURE_SLUG"
echo "  Directory: $PLAN_DIR"

# Create plans directory
mkdir -p "$PLAN_DIR"

# Copy and substitute templates
for template in task_plan.md findings.md progress.md; do
    TEMPLATE_PATH="$PLUGIN_ROOT/templates/$template"
    OUTPUT_PATH="$PLAN_DIR/$template"

    if [ ! -f "$OUTPUT_PATH" ]; then
        if [ -f "$TEMPLATE_PATH" ]; then
            sed "s/{FEATURE_NAME}/$FEATURE_NAME/g; s/{DATE}/$DATE/g" \
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

# Write context file for hooks to find the current feature
# Line 1: feature slug, Line 2: worktree path (if any)
if [ -n "$WORKTREE_PATH" ]; then
    printf "%s\n%s\n" "$FEATURE_SLUG" "$WORKTREE_PATH" > .feature-dev-context
else
    echo "$FEATURE_SLUG" > .feature-dev-context
fi
echo "  Created: .feature-dev-context"

echo ""
echo "Feature initialized: plans/$FEATURE_SLUG/"
echo ""
echo "Planning files:"
echo "  - plans/$FEATURE_SLUG/task_plan.md   (phase tracking)"
echo "  - plans/$FEATURE_SLUG/findings.md    (research storage)"
echo "  - plans/$FEATURE_SLUG/progress.md    (session logging)"
