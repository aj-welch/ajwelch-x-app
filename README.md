<!-- markdownlint-disable MD041 -->
<div align="center">
  <img src="src/img/logo.svg" alt="X Logo" width="200" height="200">
  <h1>X App</h1>
  <p>Grafana frontend for <a href="https://twitterapi.io">twitterapi.io</a></p>
</div>
<!-- markdownlint-enable MD041 -->

## Table of Contents

- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Frontend](#frontend)
- [Backend](#backend)

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

```bash
mprocs
```

This starts:
- pnpm install (dependencies)
- pnpm run dev (frontend watch mode)
- pnpm run server (Grafana on http://localhost:3000)

With `DEVELOPMENT=true`, the server container automatically:
- Rebuilds backend on Go file changes (`mage watch`)
- Reloads frontend changes via livereload
- Attaches delve debugger on port 2345

## Frontend

```bash
# Lint
pnpm run lint
pnpm run lint:fix

# Type check
pnpm run typecheck

# Unit tests
pnpm run test      # Watch mode
pnpm run test:ci   # CI mode

# E2E tests (requires server running)
pnpm run e2e
```

## Backend

```bash
# Build for current platform
mage build:linux   # Linux
mage build:darwin  # macOS
mage build:windows # Windows

# Build all platforms
mage
```
