# Matthew Schrager's Claude Plugins

A collection of plugins for [Claude Code](https://claude.ai/code).

## Installation

```bash
/plugin marketplace add matthewschrager/claude-plugins
```

Then install individual plugins:

```bash
/plugin install feature-dev-planner
```

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [feature-dev-planner](./plugins/feature-dev-planner) | 7-phase feature development workflow with persistent markdown planning |

## Plugin Details

### feature-dev-planner

A systematic approach to feature development that combines:
- **7-Phase Workflow**: Discovery → Codebase Exploration → Clarifying Questions → Architecture Design → Implementation → Quality Review → Summary
- **Specialized Agents**: code-explorer, code-architect, code-reviewer
- **Persistent Planning**: Files saved to `plans/{feature_name}/` for organized tracking

Usage:
```bash
/feature-dev-planner Add user authentication with JWT tokens
```

## Adding More Plugins

Future plugins will be added to the `plugins/` directory.

## License

MIT
