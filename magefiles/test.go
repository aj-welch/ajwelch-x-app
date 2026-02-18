//go:build mage

package main

import (
	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Tests groups test targets. Named Tests (plural) to avoid conflicting with
// the top-level Test() function required by ci.yml via `mage test`.
type Tests mg.Namespace

// Unit runs Jest unit tests in watch mode.
func (Tests) Unit() error {
	return sh.RunV("pnpm", "exec", "jest", "--watch", "--onlyChanged")
}

// CI runs Jest with settings suitable for CI (no watch, passes with no tests).
func (Tests) CI() error {
	return sh.RunV("pnpm", "exec", "jest", "--passWithNoTests", "--maxWorkers", "4")
}

// E2E runs Playwright end-to-end tests.
func (Tests) E2E() error {
	return sh.RunV("pnpm", "exec", "playwright", "test")
}

// Backend runs Go unit tests.
func (Tests) Backend() error {
	return sh.RunV("go", "test", "./...")
}

// All runs all test suites.
func (Tests) All() error { //nolint:unparam
	mg.Deps((Tests).CI, (Tests).Backend, (Tests).E2E)
	return nil
}

// Test runs Go unit tests.
// Called by ci.yml Test backend step via `mage test`.
func Test() error {
	return sh.RunV("go", "test", "./...")
}
