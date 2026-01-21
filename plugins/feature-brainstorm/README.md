# Feature Brainstorm

A Claude Code plugin that helps brainstorm large features, break them into implementable tasks, and push to Linear.

## Installation

```bash
# Add the marketplace
/plugin marketplace add matthewschrager/claude-plugins

# Install the plugin
/plugin install feature-brainstorm
```

## Prerequisites

- Linear MCP server configured (`https://mcp.linear.app/mcp`)

## Features

- **5-Phase Workflow**: Feature Capture → Codebase Exploration → Interactive Brainstorm → Task Breakdown → Linear Push
- **Specialized Agents**: brainstorm-facilitator, task-breakdown-expert
- **Persistent Planning**: Files saved to `brainstorms/{feature_name}/`
- **Linear Integration**: Creates parent issue (epic) + sub-issues
- **Detailed Task Specs**: Full context for coding agent implementation

## Usage

```
/feature-brainstorm <feature description>
```

Example:
```
/feature-brainstorm Add real-time collaboration with presence indicators
```

This will:
1. Create `brainstorms/realtime-collab/` directory
2. Guide you through 5 phases of brainstorming
3. Break down into implementable tasks
4. Push to Linear as epic + sub-issues

## Planning Files

| File | Purpose |
|------|---------|
| `brainstorm.md` | 5-phase workflow tracking, findings, decisions |
| `task_breakdown.md` | Detailed task specs with acceptance criteria |
| `linear_issues.md` | Linear issue content and URLs |

## Task Spec Format

Each task includes:
- **Context** - Full standalone background
- **Acceptance Criteria** - Specific, testable items
- **Suggested Approach** - Concrete implementation steps
- **Relevant Files** - With purpose annotations
- **Dependencies** - What blocks/is blocked by
- **Complexity** - S (1 session), M (1-2), L (2)

## Workflow Phases

| Phase | Goal | User Approval |
|-------|------|---------------|
| 1. Feature Capture | Understand problem, users, success criteria | - |
| 2. Codebase Exploration | Map patterns, integration points | - |
| 3. Interactive Brainstorm | Explore journeys, components, MVP scope | **Yes** |
| 4. Task Breakdown | Decompose into 1-2 session tasks | **Yes** |
| 5. Linear Push | Create parent + sub-issues | - |

## Hooks

- **PreToolUse**: Shows current brainstorm before Write/Edit/Bash/Read/Glob/Grep
- **PostToolUse**: Reminds to update brainstorm after Write/Edit
- **Stop**: Verifies all 5 phases are complete
