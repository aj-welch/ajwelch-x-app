//go:build mage

package main

import (
	"fmt"
	"os"

	"github.com/grafana/grafana-plugin-sdk-go/build"
	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Build groups build targets for backend, frontend, and container images.
type Build mg.Namespace

func init() {
	// The SDK defaults to ./pkg; override to use standard Go cmd/ layout.
	_ = build.SetBeforeBuildCallback(func(cfg build.Config) (build.Config, error) {
		cfg.RootPackagePath = "./cmd/plugin"
		return cfg, nil
	})
}

// Backend builds the plugin backend binary for linux/amd64 (for use in the container).
func (Build) Backend() error {
	return build.Build{}.Linux()
}

// Frontend installs dependencies and builds the frontend assets.
func (Build) Frontend() error {
	return sh.RunV("pnpm", "exec", "webpack", "-c", "./webpack.config.ts", "--env", "production")
}

// Sign signs the plugin using the Grafana sign-plugin tool.
func (Build) Sign() error {
	return sh.RunV("pnpm", "exec", "--yes", "@grafana/sign-plugin@latest")
}

// Container builds the Nix dev container image and loads it into Docker.
func (Build) Container() error {
	if err := sh.RunV("nix", "build", ".#grafana-dev"); err != nil {
		return err
	}
	if err := sh.RunV("sh", "-c", "docker load < result"); err != nil {
		return err
	}
	registry := os.Getenv("LOCAL_REGISTRY")
	if registry == "" {
		return fmt.Errorf("LOCAL_REGISTRY env var not set")
	}
	pluginID := os.Getenv("PLUGIN_ID")
	if pluginID == "" {
		return fmt.Errorf("PLUGIN_ID env var not set")
	}
	return sh.RunV("docker", "tag", pluginID+":dev", registry+"/"+pluginID+":dev")
}

// All builds both the backend and frontend.
func (Build) All() error {
	mg.Deps((Build).Backend, (Build).Frontend)
	return nil
}

// BuildAll builds the plugin backend for all target platforms.
// Called by grafana/plugin-actions/package-plugin (github.com/grafana/plugin-actions)
// via `mage buildAll` when Magefile.go is detected.
func BuildAll() error {
	mg.Deps((Build).Backend)
	return nil
}

// Coverage runs backend tests with coverage reporting.
// Called by grafana/plugin-actions/package-plugin (github.com/grafana/plugin-actions)
// via `mage coverage` when Magefile.go is detected.
func Coverage() error {
	return sh.RunV("go", "test", "-coverprofile=coverage.out", "./...")
}
