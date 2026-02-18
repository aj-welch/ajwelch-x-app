//go:build mage

package main

import (
	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Clean groups cleanup targets.
type Clean mg.Namespace

// Dist removes the dist/ build output directory.
func (Clean) Dist() error {
	return sh.Rm("dist")
}

// All removes all build artifacts.
func (Clean) All() error { //nolint:unparam
	mg.Deps((Clean).Dist)
	return nil
}
