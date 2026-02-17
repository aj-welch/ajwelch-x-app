//go:build mage

package main

import (
	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Development groups targets for managing the local k3d development cluster.
type Development mg.Namespace

// ClusterCreate creates the k3d cluster using k3d.yaml.
func (Development) ClusterCreate() error {
	return sh.RunV("k3d", "cluster", "create", "--config", "k3d.yaml")
}

// ClusterDelete deletes the k3d cluster.
func (Development) ClusterDelete() error {
	return sh.RunV("k3d", "cluster", "delete", "ajwelch-x-app")
}

// Up creates the cluster (if needed) and starts Tilt.
func (Development) Up() error {
	mg.Deps((Development).ClusterCreate)
	return sh.RunV("tilt", "up")
}

// Down tears down the Tilt session.
func (Development) Down() error {
	return sh.RunV("tilt", "down")
}
