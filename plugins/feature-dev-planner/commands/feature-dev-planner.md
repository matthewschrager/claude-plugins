---
description: Guided feature development with codebase understanding, architecture focus, and persistent file-based planning
argument-hint: Feature description (required)
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
            F=$(cat .feature-dev-context 2>/dev/null)
            if [ -n "$F" ] && [ -f "plans/$F/task_plan.md" ]; then
              echo "=== Current Plan (plans/$F/task_plan.md) ==="
              head -50 "plans/$F/task_plan.md"
              echo "=== End Plan Preview ==="
            fi
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: |
            F=$(cat .feature-dev-context 2>/dev/null)
            [ -n "$F" ] && echo "[feature-dev-planner] File updated. If this completes a phase, update plans/$F/task_plan.md status."
  Stop:
    - hooks:
        - type: command
          command: "bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-complete.sh"
---

# Feature Development with Planning

You are helping a developer implement a new feature using a systematic 7-phase approach with persistent file-based planning.

## Core Principles

- **Ask clarifying questions**: Identify all ambiguities, edge cases, and underspecified behaviors. Ask specific, concrete questions rather than making assumptions. Wait for user answers before proceeding with implementation.
- **Understand before acting**: Read and comprehend existing code patterns first
- **Read files identified by agents**: When launching agents, ask them to return lists of the most important files to read. After agents complete, read those files to build detailed context before proceeding.
- **Simple and elegant**: Prioritize readable, maintainable, architecturally sound code
- **Worktree awareness**: If working in a git worktree, create all planning files (`plans/`, `.feature-dev-context`) in the worktree directory, not the main repository. Always use the current working directory for planning files.
- **Use planning files**: All progress tracked in `plans/{feature}/` directory
- **Use TodoWrite**: Track immediate tasks alongside file-based planning

---

## FIRST: Initialize Feature Directory

**Feature request:** $ARGUMENTS

Before starting, run the initialization script with a **short feature name** (2-4 words max):

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-feature.sh "<short-feature-name>"
```

**Important**: Derive a succinct slug from the feature request—do NOT pass the full `$ARGUMENTS` verbatim. Long directory names cause filesystem errors. Examples:
- "Add user authentication with JWT tokens and refresh token rotation" → `"user-auth-jwt"`
- "Fix the bug where clicking submit twice creates duplicate entries" → `"duplicate-submit-fix"`

This creates:
- `plans/{feature-slug}/task_plan.md` — 7-phase workflow tracking
- `plans/{feature-slug}/findings.md` — Research and discoveries
- `plans/{feature-slug}/progress.md` — Session logging
- `.feature-dev-context` — Current feature context for hooks

**Then read all three planning files** to understand the structure.

---

## Phase 1: Discovery

**Goal**: Understand what needs to be built

**Actions**:
1. Create todo list with all 7 phases
2. If feature unclear, ask user for:
   - What problem are they solving?
   - What should the feature do?
   - Any constraints or requirements?
3. Summarize understanding and confirm with user
4. Update `task_plan.md` Goal section
5. Update `findings.md` Requirements section
6. Mark Phase 1 complete in `task_plan.md`

---

## Phase 2: Codebase Exploration

**Goal**: Understand relevant existing code and patterns at both high and low levels

**Actions**:
1. Launch 2-3 code-explorer agents in parallel. Each agent should:
   - Trace through the code comprehensively and focus on getting a comprehensive understanding of abstractions, architecture and flow of control
   - Target a different aspect of the codebase (eg. similar features, high level understanding, architectural understanding, user experience, etc)
   - Include a list of 5-10 key files to read

   **Example agent prompts**:
   - "Find features similar to [feature] and trace through their implementation comprehensively"
   - "Map the architecture and abstractions for [feature area], tracing through the code comprehensively"
   - "Analyze the current implementation of [existing feature/area], tracing through the code comprehensively"
   - "Identify UI patterns, testing approaches, or extension points relevant to [feature]"

2. Once the agents return, read all files identified by agents to build deep understanding
3. Update `findings.md` with:
   - Similar Features Found
   - Architecture Patterns
   - Key Files table
4. Update `progress.md` with agent outputs
5. Mark Phase 2 complete in `task_plan.md`

---

## Phase 3: Clarifying Questions

**Goal**: Fill in gaps and resolve all ambiguities before designing

**CRITICAL**: This is one of the most important phases. DO NOT SKIP.

**Actions**:
1. Review the codebase findings and original feature request
2. Identify underspecified aspects: edge cases, error handling, integration points, scope boundaries, design preferences, backward compatibility, performance needs
3. **Present all questions to the user in a clear, organized list**
4. **Wait for answers before proceeding to architecture design**
5. Document questions and answers in `findings.md`
6. Update `progress.md` with Q&A
7. Mark Phase 3 complete in `task_plan.md`

If the user says "whatever you think is best", provide your recommendation and get explicit confirmation.

---

## Phase 4: Architecture Design

**Goal**: Design multiple implementation approaches with different trade-offs

**Actions**:
1. Launch 2-3 code-architect agents in parallel with different focuses: minimal changes (smallest change, maximum reuse), clean architecture (maintainability, elegant abstractions), or pragmatic balance (speed + quality)
2. Review all approaches and form your opinion on which fits best for this specific task (consider: small fix vs large feature, urgency, complexity, team context)
3. Document all options in `findings.md` Architecture Options section
4. Present to user: brief summary of each approach, trade-offs comparison, **your recommendation with reasoning**, concrete implementation differences
5. **Ask user which approach they prefer**
6. Document chosen approach in `findings.md`
7. Update `progress.md` with decision
8. Mark Phase 4 complete in `task_plan.md`

---

## Phase 5: Implementation

**Goal**: Build the feature

**DO NOT START WITHOUT USER APPROVAL**

**Actions**:
1. Wait for explicit user approval
2. Read all relevant files identified in previous phases
3. Implement following chosen architecture
4. Follow codebase conventions strictly
5. Write clean, well-documented code
6. Update `progress.md` as you work:
   - Files created/modified
   - Key decisions made
7. Update todos as you progress
8. Mark Phase 5 complete in `task_plan.md`

---

## Phase 6: Quality Review

**Goal**: Ensure code is simple, DRY, elegant, easy to read, and functionally correct

**Actions**:
1. Launch 3 code-reviewer agents in parallel with different focuses: simplicity/DRY/elegance, bugs/functional correctness, project conventions/abstractions
2. Consolidate findings and identify highest severity issues that you recommend fixing
3. Document issues in `progress.md`
4. **Present findings to user and ask what they want to do** (fix now, fix later, or proceed as-is)
5. Address issues based on user decision
6. Update `progress.md` with resolutions
7. Mark Phase 6 complete in `task_plan.md`

---

## Phase 7: Summary

**Goal**: Document what was accomplished

**Actions**:
1. Mark all todos complete
2. Update `task_plan.md` final sections:
   - Decisions Made table
   - Any remaining notes
3. Update `progress.md` with final summary:
   - What was built
   - Key decisions made
   - Files modified
   - Suggested next steps
4. Present summary to user
5. Mark Phase 7 complete in `task_plan.md`

---

## Important Reminders

- **Re-read planning files before major decisions** — keeps goals in attention window
- **Update files after each phase** — mark phases complete, log findings
- **Log ALL errors** — they help avoid repetition
- **Never repeat failed actions** — mutate your approach

## The 2-Action Rule
After every 2 view/browser/search operations, IMMEDIATELY save key findings to `findings.md`. This prevents visual/multimodal information from being lost.

## 5-Question Reboot Test
If you can answer these, your context management is solid:
1. Where am I? → Current phase in task_plan.md
2. Where am I going? → Remaining phases
3. What's the goal? → Goal statement in task_plan.md
4. What have I learned? → findings.md
5. What have I done? → progress.md
