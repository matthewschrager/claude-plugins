---
description: Brainstorm features, break into tasks, and push to Linear with detailed specs
argument-hint: Feature idea (required)
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
            F=$(head -1 .brainstorm-context 2>/dev/null)
            W=$(sed -n '2p' .brainstorm-context 2>/dev/null)
            if [ -n "$W" ]; then
              echo "=== WORKTREE: $W ==="
            fi
            if [ -n "$F" ] && [ -f "brainstorms/$F/brainstorm.md" ]; then
              echo "=== Current Brainstorm (brainstorms/$F/brainstorm.md) ==="
              head -50 "brainstorms/$F/brainstorm.md"
              echo "=== End Preview ==="
            fi
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: |
            F=$(head -1 .brainstorm-context 2>/dev/null)
            [ -n "$F" ] && echo "[feature-brainstorm] Updated. If this completes a phase, update brainstorms/$F/brainstorm.md status."
  Stop:
    - hooks:
        - type: command
          command: "bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-linear-ready.sh"
---

# Feature Brainstorm

You are helping a user brainstorm a large feature, break it into implementable tasks, and push to Linear.

## Core Principles

- **Interactive ideation**: This is collaborative - ask questions, explore ideas, don't just execute
- **Right-sized tasks**: Each task should be completable by a coding agent in 1-2 sessions
- **Self-contained specs**: Task descriptions must include full context for standalone implementation
- **User approval at gates**: Get explicit approval before proceeding to Task Breakdown and Linear Push

---

## FIRST: Initialize Brainstorm Session

**Feature idea:** $ARGUMENTS

Run the initialization script with a **short feature name** (2-4 words max):

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-brainstorm.sh "<short-feature-name>"
```

**Important**: Derive a succinct slug. Examples:
- "Add real-time collaboration with presence indicators" → `"realtime-collab"`
- "Redesign the dashboard with analytics widgets" → `"dashboard-analytics"`

Then **read all three brainstorm files** to understand the structure.

---

## Phase 1: Feature Capture

**Goal**: Understand what the user wants to build

**Actions**:
1. Create todo list with all 5 phases
2. Ask clarifying questions:
   - What problem does this solve?
   - Who are the target users?
   - What does success look like?
   - Any constraints (timeline, tech, dependencies)?
   - MVP vs full vision?
3. Document in `brainstorm.md`:
   - Problem Statement
   - Target Users
   - Success Criteria
   - Known Constraints
4. Mark Phase 1 complete

---

## Phase 2: Codebase Exploration

**Goal**: Understand the existing codebase context

**Actions**:
1. Launch 2-3 `brainstorm-facilitator` agents to:
   - Find related existing features
   - Map architectural patterns
   - Identify integration points
   - Note testing patterns
2. Read files identified by agents
3. Document in `brainstorm.md`:
   - Related Features table
   - Patterns to Follow
   - Integration Points
   - Key Files table
4. Ask user: What should we reuse vs build new?
5. Mark Phase 2 complete

---

## Phase 3: Interactive Brainstorm

**Goal**: Explore the feature space collaboratively

**Actions**:
1. Discuss with user:
   - Key user journeys
   - Technical components needed
   - Risks and unknowns
   - What could be cut for MVP?
2. Launch `brainstorm-facilitator` agents for idea generation if helpful
3. Document in `brainstorm.md`:
   - User Journeys
   - Technical Components
   - Risks and Unknowns
   - MVP Scope (in vs out)
4. **Present scope summary and get user approval before breakdown**
5. Mark Phase 3 complete

---

## Phase 4: Task Breakdown

**Goal**: Decompose into right-sized, well-specified tasks

**DO NOT START WITHOUT USER APPROVAL OF SCOPE**

**Actions**:
1. Launch `task-breakdown-expert` agents with the approved scope
2. For each task, generate in `task_breakdown.md`:
   - Title and summary
   - Full context (standalone readable)
   - Acceptance criteria (specific, testable)
   - Suggested approach (concrete steps)
   - Relevant files (with purpose)
   - Dependencies (which tasks first)
   - Complexity (S/M/L)
3. Create dependency graph
4. **Review full breakdown with user**
5. Iterate based on feedback
6. Mark Phase 4 complete

### Task Sizing Guidelines

**Small (S)**: ~1 session
- Single file changes
- Adding a simple component
- Writing tests for existing code

**Medium (M)**: 1-2 sessions
- Multi-file changes
- New feature component
- API endpoint with tests

**Large (L)**: ~2 sessions
- Cross-cutting changes
- New subsystem
- Complex integration

If a task seems larger than L, break it down further.

---

## Phase 5: Linear Push

**Goal**: Create Linear issues from the task breakdown

**DO NOT START WITHOUT USER APPROVAL OF TASKS**

**Actions**:
1. Prepare `linear_issues.md` with formatted content for each issue
2. Ask user for Linear team (use Linear MCP tools to list teams if needed)
3. Create parent issue (Epic):
   - Title: Feature name
   - Description: Overview, problem, scope from brainstorm.md
   - Labels: epic, feature
4. Create sub-issues for each task:
   - Title: Task title
   - Description: Full spec (context, criteria, approach, files)
   - Parent: Link to parent issue
   - Labels: task, feature-slug
5. Update `linear_issues.md` with URLs
6. Present summary to user with all Linear URLs
7. Mark Phase 5 complete

---

## Important Reminders

- **This is collaborative** - Ask questions, don't assume
- **Right-size tasks** - Each should be 1-2 coding sessions
- **Full context** - Task specs must be standalone readable
- **User gates** - Get approval before Phase 4 and Phase 5
- **Update files** - Keep brainstorm.md current after each phase

## 5-Question Check

1. Where am I? → Current phase in brainstorm.md
2. What's the feature? → Problem statement
3. What's the scope? → MVP definition
4. How many tasks? → task_breakdown.md count
5. Linear status? → Issues created or pending
