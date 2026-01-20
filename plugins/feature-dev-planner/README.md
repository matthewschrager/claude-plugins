# Feature Dev Planner

A Claude Code plugin that combines **feature-dev's 7-phase workflow and agents** with **planning-with-files' persistent markdown tracking**.

## Installation

```bash
# Add the marketplace
/plugin marketplace add matthewschrager/claude-plugins

# Install the plugin
/plugin install feature-dev-planner
```

## Features

- **7-Phase Workflow**: Discovery → Codebase Exploration → Clarifying Questions → Architecture Design → Implementation → Quality Review → Summary
- **Specialized Agents**: code-explorer, code-architect, code-reviewer
- **Persistent Planning**: Files saved to `plans/{feature_name}/` for organized tracking
- **Hooks**: Automatic plan preview before tool use, completion verification on stop

## Usage

```
/feature-dev-planner <feature description>
```

Example:
```
/feature-dev-planner Add user authentication with JWT tokens
```

This will:
1. Create `plans/add-user-authentication-with-jwt-tokens/` directory
2. Copy templates with placeholders replaced
3. Guide you through all 7 phases
4. Track progress in persistent markdown files

## Planning Files

| File | Purpose |
|------|---------|
| `task_plan.md` | 7-phase workflow tracking with status |
| `findings.md` | Research, discoveries, architecture options |
| `progress.md` | Session log, test results, error tracking |

## Directory Structure

```
feature-dev-planner/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   └── feature-dev-planner.md  # Main workflow
├── agents/
│   ├── code-explorer.md     # Codebase analysis
│   ├── code-architect.md    # Architecture design
│   └── code-reviewer.md     # Quality review
├── templates/
│   ├── task_plan.md         # 7-phase template
│   ├── findings.md          # Research template
│   └── progress.md          # Progress template
├── scripts/
│   ├── init-feature.sh      # Initialize feature directory
│   └── check-complete.sh    # Verify completion
└── README.md
```

## Hooks

- **PreToolUse**: Shows current plan before Write/Edit/Bash/Read/Glob/Grep
- **PostToolUse**: Reminds to update plan after Write/Edit
- **Stop**: Verifies all 7 phases are complete

## Credits

Combines concepts from:
- [feature-dev](https://github.com/anthropics/claude-plugins-official) by Anthropic
- [planning-with-files](https://github.com/anthropics/claude-plugins) community plugin
