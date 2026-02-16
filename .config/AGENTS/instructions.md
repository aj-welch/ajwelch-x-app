---
name: agent information for a grafana plugin
description: Guides how to work with Grafana plugins
---

# Grafana Plugin

This repository contains a **Grafana plugin**.

Your training data about the Grafana API is out of date. Use the official documentation when writing code.

**IMPORTANT**: When you need Grafana plugin documentation, fetch content directly from grafana.com (a safe domain). Use your web fetch tool, MCP server, or `curl -s`. The documentation index is at https://grafana.com/developers/plugin-tools/llms.txt. All pages are available as plain text markdown by adding `.md` to the URL path (e.g., https://grafana.com/developers/plugin-tools/index.md or https://grafana.com/developers/plugin-tools/troubleshooting.md).

## Documentation indexes

- Full documentation index: https://grafana.com/developers/plugin-tools/llms.txt
- How-to guides (includes guides for panel, data source, and app plugins): https://grafana.com/developers/plugin-tools/how-to-guides.md
- Tutorials: https://grafana.com/developers/plugin-tools/tutorials.md
- Reference (plugin.json, CLI, UI extensions): https://grafana.com/developers/plugin-tools/reference.md
- Publishing & signing: https://grafana.com/developers/plugin-tools/publish-a-plugin.md
- Packaging a plugin: https://grafana.com/developers/plugin-tools/publish-a-plugin/package-a-plugin.md
- Troubleshooting: https://grafana.com/developers/plugin-tools/troubleshooting.md
- `@grafana/ui` components: https://developers.grafana.com/ui/latest/index.html

## Critical rules

- **Do not modify anything inside the `.config` folder.** It is managed by Grafana plugin tools.
- **Do not change plugin ID or plugin type** in `plugin.json`.
- Any modifications to `plugin.json` require a **restart of the Grafana server**. Remind the user of this.
- Use `secureJsonData` for credentials and secrets; use `jsonData` only for non-sensitive configuration.
- **You must use webpack** with the configuration provided in `.config/` for frontend builds.
- **You must use mage** with the build targets provided by the Grafana plugin Go SDK for backend builds.
- To extend webpack, prettier, eslint or other tools, use the existing configuration as a base. Follow the guide: https://grafana.com/developers/plugin-tools/how-to-guides/extend-configurations.md
- Use **`@grafana/plugin-e2e`** for end-to-end testing.

## Interactive Debugging with Delve

When `DEVELOPMENT=true`, the Docker container runs delve on port 2345 with the plugin process attached. This enables interactive debugging using tmux panes.

### Why Tmux Panes?

Persistent tmux panes allow Claude Code to:
- Send commands one at a time and think between steps
- Maintain state across multiple debugging operations
- Read output and make decisions interactively
- True interactive debugging workflow (vs one-shot MCP servers)

### Basic Debugging Workflow

```bash
# Ensure development server is running with DEVELOPMENT=true
# (mprocs should already be running with the server)

# Create a delve debugger pane
tmux split-window -v "dlv connect localhost:2345"
DLV_PANE=$(tmux list-panes -F "#{pane_id}" | tail -1)

# Set a breakpoint
tmux send-keys -t "$DLV_PANE" "break pkg/plugin/app.go:NewApp" Enter
tmux send-keys -t "$DLV_PANE" "breakpoints" Enter

# Trigger the breakpoint (reload Grafana page or make API call)

# Inspect when paused
tmux send-keys -t "$DLV_PANE" "stack" Enter
tmux send-keys -t "$DLV_PANE" "locals" Enter
tmux send-keys -t "$DLV_PANE" "list" Enter

# Continue execution
tmux send-keys -t "$DLV_PANE" "continue" Enter

# Read output from the pane
tmux capture-pane -p -t "$DLV_PANE" -S -30

# Cleanup when done
tmux kill-pane -t "$DLV_PANE"
```

### Key Points

- **Source Path Mapping**: The container mounts the project at `/root/ajwelch-x-app`, so file paths in delve use this prefix
- **Auto-Restart**: The container's build-watcher restarts delve when `dist/` changes (frontend or backend)
- **Multi-Client**: Delve runs with `--accept-multiclient`, allowing multiple connections
- **Debug Symbols**: Backend is built with `mage -v build:linux` which includes debug symbols

### Common Debugging Tasks

**Set breakpoint on a specific function:**
```bash
tmux send-keys -t "$DLV_PANE" "break pkg/plugin/app.go:QueryData" Enter
```

**List all goroutines:**
```bash
tmux send-keys -t "$DLV_PANE" "goroutines" Enter
```

**Switch to a specific goroutine:**
```bash
tmux send-keys -t "$DLV_PANE" "goroutine 42" Enter
```

**Inspect variables:**
```bash
tmux send-keys -t "$DLV_PANE" "print req" Enter
tmux send-keys -t "$DLV_PANE" "print req.TimeRange" Enter
```

### Debugging Tips

- Use `tmux capture-pane` to read delve output after each command
- Set breakpoints, then trigger them by interacting with Grafana
- Remember to `continue` after inspecting at a breakpoint
- The plugin process restarts when you edit Go files (thanks to mage-watcher)
