---
description: Implement tasks from a Linear parent feature ticket with DAG-based parallelization
argument-hint: Linear issue identifier (e.g., PROJ-123) (required)
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - WebFetch
  - WebSearch
  - Task
  - TodoWrite
hooks:
  PreToolUse:
    - matcher: "Write|Edit|Bash|Read|Glob|Grep"
      hooks:
        - type: command
          command: |
            F=$(head -1 .implement-context 2>/dev/null)
            W=$(sed -n '2p' .implement-context 2>/dev/null)
            if [ -n "$W" ]; then
              echo "=== WORKTREE: $W ==="
            fi
            if [ -n "$F" ] && [ -f "implementations/$F/implementation.md" ]; then
              echo "=== Current Implementation (implementations/$F/implementation.md) ==="
              head -60 "implementations/$F/implementation.md"
              echo "=== End Preview ==="
            fi
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: |
            F=$(head -1 .implement-context 2>/dev/null)
            [ -n "$F" ] && echo "[implement-tasks] Updated. If this completes a task/phase, update implementations/$F/implementation.md status."
  Stop:
    - hooks:
        - type: command
          command: "bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-implementation.sh"
---

# Implement Tasks from Linear

You are implementing tasks from a Linear parent feature ticket. Tasks have dependencies (DAG structure), and you will assess each task before implementation.

## Core Principles

- **Assess before implementing**: Use task-assessor agents to evaluate complexity
- **Small tasks = autonomous**: Implement without user approval
- **Complex tasks = user approval**: Present approach, wait for confirmation
- **Parallel execution**: Independent tasks (no blocking dependencies) run in parallel (max 3)
- **Track everything**: All progress tracked in `implementations/{issue-slug}/`

---

## FIRST: Initialize Implementation Session

**Linear Issue:** $ARGUMENTS

Run the initialization script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-implementation.sh "$ARGUMENTS"
```

Then **read both implementation files** to understand the structure.

---

## Phase 1: Issue Discovery

**Goal**: Parse parent Linear issue and build task graph

**Actions**:
1. Create todo list with all 5 phases
2. Use Linear MCP to fetch parent issue details:
   - `linear_getIssue` with the issue ID
3. Parse the Execution Plan / DAG from the description:
   - Look for "## Execution Plan" or "## Dependency Graph" section
   - Extract phases and task groupings
   - Determine which tasks can run in parallel
4. Fetch all child/sub-issues using Linear MCP
5. Build task list in `implementation.md`:
   - Task table with Linear IDs, dependencies, status
   - Copy DAG visualization
6. Update `task_queue.md` with full task details from each child issue
7. Mark Phase 1 complete

### DAG Parsing

The feature-brainstorm plugin creates Execution Plans like:

```
## Execution Plan

Phase 1 (parallel): Task 1, Task 2
         |
         v
Phase 2 (sequential): Task 3
         |
         v
Phase 3 (parallel): Task 4, Task 5
```

Parse this to determine:
- Which tasks have no dependencies (can start immediately)
- Which tasks depend on others (must wait)
- Which tasks can run in parallel within a phase

---

## Phase 2: Task Assessment

**Goal**: Assess each task to determine complexity and approach

**Actions**:
1. Identify tasks with no unfinished dependencies (ready to assess)
2. Launch 2-3 `task-assessor` agents in parallel for ready tasks
3. Each agent evaluates:
   - File count, pattern match, clarity, risk, estimation
   - Total score determines size (S/M/L)
   - Confidence level (High/Medium/Low)
4. Classify each task:
   - **Autonomous**: Small + High confidence
   - **Approval Required**: Medium/Large OR Lower confidence
5. Document all assessments in `implementation.md`
6. Update `task_queue.md` with classification for each task
7. Mark Phase 2 complete

### Assessment Criteria Summary

| Classification | Criteria |
|----------------|----------|
| **Autonomous** | Small (S), High confidence, 1-3 files, clear pattern, no ambiguity |
| **Approval Required** | Medium/Large, OR Lower confidence, OR 4+ files, OR unclear requirements |

---

## Phase 3: Parallel Implementation

**Goal**: Implement tasks respecting DAG dependencies

**Actions**:
1. Build execution queue from DAG (topological sort)
2. For tasks with no unfinished blockers:

   **If Autonomous (Small + High Confidence):**
   - Launch `task-implementor` agents in parallel (max 3 at once)
   - Each agent implements its task independently
   - Update task status in `task_queue.md` as they complete

   **If Approval Required:**
   - Present the task assessment summary to user
   - Show: task description, complexity rationale, suggested approach
   - **Wait for explicit user approval**
   - Then launch `task-implementor` agent

3. As tasks complete:
   - Mark complete in `task_queue.md` (status: done)
   - Log in `implementation.md` Implementation Log
   - Identify newly-unblocked tasks (dependencies now satisfied)
   - Launch newly-ready tasks (repeat step 2)
4. Continue until all tasks complete
5. Mark Phase 3 complete

### Parallel Execution Rules

- Maximum 3 implementation agents running simultaneously
- Each agent works in isolation on its task
- Check git status before committing to detect conflicts
- If conflict detected, pause and alert user

---

## Phase 4: Quality Review

**Goal**: Verify all implementations meet quality standards

**Actions**:
1. Launch `code-reviewer` agents (from feature-dev-planner) to review all changes
   - Focus areas: simplicity/DRY, bugs/correctness, conventions
2. Consolidate findings by severity:
   - Critical: Must fix before proceeding
   - Major: Should fix
   - Minor: Nice to fix
3. Present findings to user
4. Address issues based on user decision
5. Update Linear issues with review notes if needed
6. Mark Phase 4 complete

---

## Phase 5: Summary

**Goal**: Document what was accomplished

**Actions**:
1. Update all Linear issues to Done (via MCP)
2. Generate summary in `implementation.md`:
   - Tasks completed (with Linear URLs)
   - Files modified
   - Key decisions made
   - Any remaining work or follow-up items
3. Present summary to user
4. Mark Phase 5 complete

---

## Important Reminders

- **Never skip assessment** - Every task must be assessed first
- **Respect the DAG** - Never implement a task with unfinished blockers
- **User gates for complex tasks** - Get approval before implementing non-autonomous tasks
- **Update Linear continuously** - Keep issue states in sync
- **Log everything** - Helps with debugging and resume

## 5-Question Check

1. Where am I? → Current phase in implementation.md
2. What issue? → Linear parent ID
3. How many tasks? → Total in task_queue.md
4. What's next? → Tasks with no blockers
5. Any blocked? → Tasks waiting on dependencies
