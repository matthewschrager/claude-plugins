#!/bin/bash
# Check if implementation is complete
# Used by Stop hook

ISSUE_SLUG=$(head -1 .implement-context 2>/dev/null)

if [ -z "$ISSUE_SLUG" ]; then
    echo "No active implementation context found (.implement-context missing)"
    exit 1
fi

IMPL_FILE="implementations/$ISSUE_SLUG/implementation.md"

if [ ! -f "$IMPL_FILE" ]; then
    echo "ERROR: $IMPL_FILE not found"
    exit 1
fi

echo "=== Implementation Status Check ==="
echo "Issue: $ISSUE_SLUG"
echo ""

# Count phases
TOTAL=$(grep -c "### Phase" "$IMPL_FILE" 2>/dev/null | tr -d '[:space:]')
COMPLETE=$(grep -cF "**Status:** complete" "$IMPL_FILE" 2>/dev/null | tr -d '[:space:]')

: "${TOTAL:=0}"
: "${COMPLETE:=0}"

echo "Phases:     $COMPLETE / $TOTAL complete"
echo ""

# Count tasks from task_queue.md
QUEUE_FILE="implementations/$ISSUE_SLUG/task_queue.md"
if [ -f "$QUEUE_FILE" ]; then
    TASK_TOTAL=$(grep -c "^### Task" "$QUEUE_FILE" 2>/dev/null | tr -d '[:space:]')
    TASK_DONE=$(grep -c "**Status:** done" "$QUEUE_FILE" 2>/dev/null | tr -d '[:space:]')
    : "${TASK_TOTAL:=0}"
    : "${TASK_DONE:=0}"
    echo "Tasks:      $TASK_DONE / $TASK_TOTAL complete"
fi

echo ""

if [ "$COMPLETE" -eq "$TOTAL" ] && [ "$TOTAL" -eq 5 ]; then
    echo "ALL 5 PHASES COMPLETE"
    exit 0
else
    echo "IMPLEMENTATION NOT COMPLETE"
    echo ""
    echo "Complete all 5 phases:"
    echo "  1. Issue Discovery"
    echo "  2. Task Assessment"
    echo "  3. Parallel Implementation"
    echo "  4. Quality Review"
    echo "  5. Summary"
    exit 1
fi
