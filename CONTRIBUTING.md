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

Tilt opens its UI at **http://localhost:10350** and Grafana is available at **http://localhost:3000** (username: admin, password: admin).

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

Grafana's plugin ecosystem expects certain files and commands (scaffolded by [create-plugin](https://github.com/grafana/create-plugin)). We keep these files working so GitHub Actions workflows from [plugin-actions](https://github.com/grafana/plugin-actions) (`release.yml`, `is-compatible.yml`, `bundle-stats.yml`) can verify the plugin remains compatible. This is our "conformance" layer. Local development uses a separate Nix + k3d environment.

### Nix + k3d (Local Development)

```bash
mage build:backend      # Build Go backend
mage build:frontend     # Build TypeScript frontend
mage build:container    # Build Grafana+plugin container via Nix
mage build:all          # Build backend + frontend
```

### Standard Grafana Plugin Tooling (Conformance)

```bash
pnpm run build          # Build frontend
mage buildAll           # Build backend (all platforms)
mage coverage           # Run backend tests with coverage
pnpm run server         # Start Grafana via docker-compose
```

## Test

```bash
mage analyze:typecheck      # TypeScript type check
mage analyze:lint           # ESLint
mage analyze:lintBackend    # Go lint (golangci-lint)
mage tests:ci               # Jest unit tests
mage tests:backend          # Go unit tests
mage tests:e2e              # Playwright E2E (requires stack running)
```

## Debug

Delve attaches to the plugin process on port 2345 in dev mode:

```bash
dlv connect localhost:2345
```

The backend rebuilds automatically when Go files change, and delve reattaches.
