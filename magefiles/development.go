//go:build mage

package main

import (
	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Development groups targets for managing the local k3d development cluster.
type Development mg.Namespace

// ClusterCreate creates the k3d cluster using k3d.yaml, then patches the
// local-registry-hosting ConfigMap so Tilt uses localhost:5000 in k8s
// manifests. Without this, Tilt reads k3d's auto-generated ConfigMap which
// sets hostFromContainerRuntime to the Docker-network registry hostname,
// causing Tilt to mangle image names (e.g. localhost_5000_ajwelch-x-app).
// With localhost:5000 set here, Tilt skips rewriting because the image ref
// already starts with that registry. The k3d containerd mirror config then
// handles the actual redirect inside the cluster nodes.
func (Development) ClusterCreate() error {
	if err := sh.RunV("k3d", "cluster", "create", "--config", "k3d.yaml"); err != nil {
		return err
	}
	return sh.RunV("sh", "-c", `kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:5000"
    hostFromContainerRuntime: "localhost:5000"
EOF`)
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

// E2ECI runs tilt in CI mode: builds the versioned Grafana+plugin image,
// deploys to the k3d cluster, waits for all resources to be healthy, then
// exits. Set GRAFANA_VERSION to select the Grafana version. CI=true is passed
// automatically so the Tiltfile skips watch resources.
func (Development) E2ECI() error {
	return sh.RunWithV(map[string]string{"CI": "true"}, "tilt", "ci")
}

// PortForward starts a background kubectl port-forward for the Grafana service.
// Run after E2ECI exits so Playwright tests can reach localhost:3000.
func (Development) PortForward() error {
	return sh.RunV("sh", "-c", "kubectl port-forward -n ajwelch-x-app svc/grafana 3000:3000 &")
}
