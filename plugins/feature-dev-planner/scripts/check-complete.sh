#!/bin/bash
# Check if all 7 phases in task_plan.md are complete
# Exit 0 if complete, exit 1 if incomplete
# Used by Stop hook to verify task completion

# Get current feature from context file
FEATURE_SLUG=$(cat .feature-dev-context 2>/dev/null)

if [ -z "$FEATURE_SLUG" ]; then
    echo "No active feature context found (.feature-dev-context missing)"
    echo "Cannot verify completion."
    exit 1
fi

PLAN_FILE="plans/$FEATURE_SLUG/task_plan.md"

if [ ! -f "$PLAN_FILE" ]; then
    echo "ERROR: $PLAN_FILE not found"
    echo "Cannot verify completion without a task plan."
    exit 1
fi

echo "=== Feature Development Completion Check ==="
echo "Feature: $FEATURE_SLUG"
echo ""

# Count phases by status (using -F for fixed string matching)
# Use tr to strip any whitespace/newlines from output
TOTAL=$(grep -c "### Phase" "$PLAN_FILE" 2>/dev/null | tr -d '[:space:]')
COMPLETE=$(grep -cF "**Status:** complete" "$PLAN_FILE" 2>/dev/null | tr -d '[:space:]')
IN_PROGRESS=$(grep -cF "**Status:** in_progress" "$PLAN_FILE" 2>/dev/null | tr -d '[:space:]')
PENDING=$(grep -cF "**Status:** pending" "$PLAN_FILE" 2>/dev/null | tr -d '[:space:]')

# Default to 0 if empty
: "${TOTAL:=0}"
: "${COMPLETE:=0}"
: "${IN_PROGRESS:=0}"
: "${PENDING:=0}"

echo "Total phases:   $TOTAL (expected: 7)"
echo "Complete:       $COMPLETE"
echo "In progress:    $IN_PROGRESS"
echo "Pending:        $PENDING"
echo ""

# List phase status for visibility
echo "Phase Status:"
# Use awk to extract phase names and their status
awk '/^### Phase/{phase=$0} /\*\*Status:\*\*/{gsub(/.*\*\*Status:\*\* /,""); print "  " phase ": " $0}' "$PLAN_FILE"
echo ""

# Check completion
if [ "$COMPLETE" -eq "$TOTAL" ] && [ "$TOTAL" -eq 7 ]; then
    echo "ALL 7 PHASES COMPLETE"
    exit 0
else
    echo "FEATURE NOT COMPLETE"
    echo ""
    echo "Complete all 7 phases before finishing:"
    echo "  1. Discovery"
    echo "  2. Codebase Exploration"
    echo "  3. Clarifying Questions"
    echo "  4. Architecture Design"
    echo "  5. Implementation"
    echo "  6. Quality Review"
    echo "  7. Summary"
    exit 1
fi
