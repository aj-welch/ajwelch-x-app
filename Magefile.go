//go:build ignore

// This file exists so grafana/plugin-actions/package-plugin detects that this
// plugin has a backend via `if [ -f "Magefile.go" ]` (github.com/grafana/plugin-actions).
// Actual build targets live in magefiles/.
package main
