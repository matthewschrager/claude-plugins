#!/bin/bash
# Check if brainstorm is ready for Linear push or completed
# Used by Stop hook

FEATURE_SLUG=$(head -1 .brainstorm-context 2>/dev/null)

if [ -z "$FEATURE_SLUG" ]; then
    echo "No active brainstorm context found (.brainstorm-context missing)"
    exit 1
fi

BRAINSTORM_FILE="brainstorms/$FEATURE_SLUG/brainstorm.md"

if [ ! -f "$BRAINSTORM_FILE" ]; then
    echo "ERROR: $BRAINSTORM_FILE not found"
    exit 1
fi

echo "=== Feature Brainstorm Status Check ==="
echo "Feature: $FEATURE_SLUG"
echo ""

# Count phases
TOTAL=$(grep -c "### Phase" "$BRAINSTORM_FILE" 2>/dev/null | tr -d '[:space:]')
COMPLETE=$(grep -cF "**Status:** complete" "$BRAINSTORM_FILE" 2>/dev/null | tr -d '[:space:]')

: "${TOTAL:=0}"
: "${COMPLETE:=0}"

echo "Phases:     $COMPLETE / $TOTAL complete"
echo ""

# Check for Linear URLs
BREAKDOWN_FILE="brainstorms/$FEATURE_SLUG/task_breakdown.md"
TASK_COUNT=$(grep -c "^### Task" "$BREAKDOWN_FILE" 2>/dev/null | tr -d '[:space:]')
: "${TASK_COUNT:=0}"

echo "Tasks defined: $TASK_COUNT"

# Check if Linear issues created
LINEAR_FILE="brainstorms/$FEATURE_SLUG/linear_issues.md"
if grep -q "Linear URL:.*http" "$LINEAR_FILE" 2>/dev/null; then
    echo "Linear issues: Created"
else
    echo "Linear issues: Not yet created"
fi

echo ""

if [ "$COMPLETE" -eq "$TOTAL" ] && [ "$TOTAL" -eq 5 ]; then
    echo "ALL 5 PHASES COMPLETE"
    exit 0
else
    echo "BRAINSTORM NOT COMPLETE"
    echo ""
    echo "Complete all 5 phases:"
    echo "  1. Feature Capture"
    echo "  2. Codebase Exploration"
    echo "  3. Interactive Brainstorm"
    echo "  4. Task Breakdown"
    echo "  5. Linear Push"
    exit 1
fi
