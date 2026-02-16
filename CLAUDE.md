# Claude Code Development Guide

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

### Tips for Claude Code

- Use `tmux capture-pane` to read delve output after each command
- Set breakpoints, then trigger them by interacting with Grafana
- Remember to `continue` after inspecting at a breakpoint
- The plugin process restarts when you edit Go files (thanks to mage-watcher)
