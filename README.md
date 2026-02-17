<!-- markdownlint-disable MD041 -->
<div align="center">
  <img src="src/img/logo.svg" alt="X Logo" width="150" height="150">
  <h1>Grafana frontend for <a href="https://twitterapi.io">twitterapi.io</a></h1>
</div>
<!-- markdownlint-enable MD041 -->

- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Testing](#testing)
- [Debugging](#debugging)

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

## Local Development

### Setup

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

`.localias.yaml` maps subdomains to local ports using [localias](https://github.com/peterldowns/localias), which is already available in the Nix dev shell. This is useful for running multiple services on different subdomains locally with HTTPS.

localias requires root to edit `/etc/hosts` and bind to ports 80/443. Start it once per machine boot:

```bash
sudo localias start
```

After that, **https://grafana.ajwelch-x-app.test** resolves to the k3d load balancer. To add a service, edit `.localias.yaml` and run `localias reload`. To stop:

```bash
localias stop
```

## Testing

```bash
mage analyze:typecheck      # TypeScript type check
mage analyze:lint           # ESLint
mage analyze:lintBackend    # Go lint (golangci-lint)
mage test:ci                # Jest unit tests
mage test:backend           # Go unit tests
mage test:e2e               # Playwright E2E (requires stack running)
```

## Debugging

Delve attaches to the plugin process on port 2345 in dev mode:

```bash
dlv connect localhost:2345
```

The backend rebuilds automatically when Go files change, and delve reattaches.
