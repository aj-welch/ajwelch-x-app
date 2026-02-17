//go:build mage

package main

import (
	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Analyze groups static analysis targets.
type Analyze mg.Namespace

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

// All runs all analysis checks.
func (Analyze) All() error {
	mg.Deps((Analyze).Lint, (Analyze).Typecheck)
	return nil
}
