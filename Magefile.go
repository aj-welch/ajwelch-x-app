//go:build mage
// +build mage

package main

import (
	// mage:import
	build "github.com/grafana/grafana-plugin-sdk-go/build"
)

// Default configures the default target.
var Default = build.BuildAll

func init() {
	// The SDK defaults to ./pkg; override to use standard Go cmd/ layout.
	_ = build.SetBeforeBuildCallback(func(cfg build.Config) (build.Config, error) {
		cfg.RootPackagePath = "./cmd/plugin"
		return cfg, nil
	})
}
