//go:build mage

package main

import (
	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Test groups test targets.
type Test mg.Namespace

// Unit runs Jest unit tests in watch mode.
func (Test) Unit() error {
	return sh.RunV("pnpm", "exec", "jest", "--watch", "--onlyChanged")
}

// CI runs Jest with settings suitable for CI (no watch, passes with no tests).
func (Test) CI() error {
	return sh.RunV("pnpm", "exec", "jest", "--passWithNoTests", "--maxWorkers", "4")
}

// E2E runs Playwright end-to-end tests.
func (Test) E2E() error {
	return sh.RunV("pnpm", "exec", "playwright", "test")
}

// Backend runs Go unit tests.
func (Test) Backend() error {
	return sh.RunV("go", "test", "./...")
}

// All runs all test suites.
func (Test) All() error {
	mg.Deps((Test).CI, (Test).Backend, (Test).E2E)
	return nil
}
