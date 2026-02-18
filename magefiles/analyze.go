//go:build mage

package main

import (
	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Analyze groups static analysis targets.
type Analyze mg.Namespace

// Check runs all lefthook pre-push checks on all files.
func (Analyze) Check() error {
	return sh.RunV("lefthook", "run", "pre-push", "--all-files")
}

// Fix runs all auto-formatting fixes on all files.
func (Analyze) Fix() error {
	return sh.RunV("lefthook", "run", "fix", "--all-files")
}

// Lint runs ESLint.
func (Analyze) Lint() error {
	return sh.RunV("pnpm", "exec", "eslint", "--cache", ".")
}

// LintFix runs ESLint with auto-fix and Prettier.
func (Analyze) LintFix() error {
	if err := sh.RunV("pnpm", "exec", "eslint", "--cache", "--fix", "."); err != nil {
		return err
	}
	return sh.RunV("pnpm", "exec", "prettier", "--write", "--list-different", ".")
}

// Typecheck runs TypeScript type checking without emitting.
func (Analyze) Typecheck() error {
	return sh.RunV("pnpm", "exec", "tsc", "--noEmit")
}

// LintBackend runs golangci-lint on the Go codebase.
func (Analyze) LintBackend() error {
	return sh.RunV("golangci-lint", "run", "--build-tags", "mage", "./...")
}

// All runs all analysis checks.
func (Analyze) All() error { //nolint:unparam
	mg.Deps((Analyze).Lint, (Analyze).LintBackend, (Analyze).Typecheck)
	return nil
}
