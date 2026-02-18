# Contributing to ajwelch-x-app

- [Prerequisites](#prerequisites)
- [Quickstart](#quickstart)
- [Build](#build)
- [Test](#test)
- [Debug](#debug)

## Prerequisites

- [Nix][1]
- [Docker daemon][3]
  - You only need the daemon; Nix provides the Docker command-line tool
  - [Rootless mode][4] supported
- [direnv][2]
  - Run `direnv allow` to load the environment
- Copy and configure local environment:

  ```bash
  cp .envrc.local.example .envrc.local
  ```

[1]: https://nixos.org/download.html
[2]: https://direnv.net/docs/installation.html
[3]: https://docs.docker.com/engine/install/
[4]: https://docs.docker.com/engine/security/rootless/

## Quickstart

```bash
mage development:up
```

This creates a k3d cluster (if it doesn't exist) and starts [Tilt](https://tilt.dev), which:

- Watches `src/` and rebuilds the frontend on changes
- Watches `internal/` and `cmd/` and rebuilds the backend on changes
- Builds a Grafana + plugin container image via Nix
- Deploys everything to the local k3d cluster via Kustomize

Tilt opens its UI at **http://localhost:10350** and Grafana is available at **http://localhost:3000** (admin / admin).

### Tear down

```bash
mage development:down          # stop Tilt, keep the cluster
mage development:clusterDelete # destroy the cluster entirely
```

### Local domains (optional)

[localias](https://github.com/peterldowns/localias) maps subdomains to local ports and is already available in the Nix dev shell. This is useful for running multiple services on different subdomains locally with HTTPS.

localias requires root to edit `/etc/hosts` and bind to ports 80/443. Run once to configure the domain mapping:

```bash
localias upsert grafana.ajwelch-x-app.test 8080
sudo localias start
```

`sudo localias start` must be re-run after each reboot; use systemd or your init system of choice to persist it. After that, **https://grafana.ajwelch-x-app.test** resolves to the k3d load balancer. To stop:

```bash
sudo localias stop
```

## Build

This project maintains two parallel build systems:

| System | Entry Points | Used By |
|--------|--------------|---------|
| **Nix + k3d** | `mage build:frontend`, `mage development:up` | Local development |
| **Standard Grafana Plugin Tooling** | `pnpm run build`, `mage buildAll` | Conformance workflows |

### Nix + k3d Development Environment

Custom `magefiles/` targets with Nix-based reproducible builds and Kubernetes-native local development. This is the **primary development workflow**.

### Standard Grafana Plugin Tooling

npm scripts + root `Magefile.go` (detection sentinel) with top-level `buildAll` and `coverage` mage targets. Used by GitHub Actions conformance workflows (`release.yml`, `is-compatible.yml`, `bundle-stats.yml`) from [grafana/plugin-actions](https://github.com/grafana/plugin-actions) to ensure the plugin remains compatible with Grafana plugin ecosystem expectations.

**What is conformance?** The Grafana plugin ecosystem provides scaffolding, GitHub Actions, and tooling (`create-plugin`, `plugin-actions`) that expect specific file structures and commands. By keeping the standard tooling working alongside our custom setup, we can verify we haven't accidentally broken compatibility with the broader Grafana ecosystem. The conformance workflows act as integration tests against Grafana's expectations.

## Test

```bash
mage analyze:typecheck      # TypeScript type check
mage analyze:lint           # ESLint
mage analyze:lintBackend    # Go lint (golangci-lint)
mage test:ci                # Jest unit tests
mage test:backend           # Go unit tests
mage test:e2e               # Playwright E2E (requires stack running)
```

## Debug

Delve attaches to the plugin process on port 2345 in dev mode:

```bash
dlv connect localhost:2345
```

The backend rebuilds automatically when Go files change, and delve reattaches.
