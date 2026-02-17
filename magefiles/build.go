//go:build mage

package main

import (
	"os"
	"strings"

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

// Container builds the Nix container image and loads it into Docker.
// With no GRAFANA_VERSION set, builds the dev image (nix .#grafana-dev).
// With GRAFANA_VERSION=X.Y.Z set, builds a versioned CI image
// (nix .#grafana-X_Y_Z) that has the plugin dist/ baked in.
func (Build) Container() error {
	version := os.Getenv("GRAFANA_VERSION")
	nixAttr := ".#grafana-dev"
	imageTag := "dev"
	if version != "" {
		nixAttr = ".#grafana-" + strings.ReplaceAll(version, ".", "_")
		imageTag = version
	}
	if err := sh.RunV("nix", "build", nixAttr); err != nil {
		return err
	}
	if err := sh.RunV("sh", "-c", "docker load < result"); err != nil {
		return err
	}
	return sh.RunV("docker", "tag", "ajwelch-x-app:"+imageTag, "localhost:5000/ajwelch-x-app:dev")
}

// All builds both the backend and frontend.
func (Build) All() error {
	mg.Deps((Build).Backend, (Build).Frontend)
	return nil
}
