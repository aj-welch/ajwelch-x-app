# Changelog

## [0.5.0](https://github.com/aj-welch/ajwelch-x-app/compare/ajwelch-x-app-v0.4.0...ajwelch-x-app-v0.5.0) (2026-02-18)


### Features

* add frontend linting to pre-push hook and analyze GH action ([648a771](https://github.com/aj-welch/ajwelch-x-app/commit/648a771c61f8274264d31cf94e428bdd9ef2c4d0))


### Bug Fixes

* normalize CHANGELOG.md list style for markdownlint ([f45d6e4](https://github.com/aj-welch/ajwelch-x-app/commit/f45d6e4b5c1e09f1c23a9d0ee0dfd6bb87ea0718))
* update golangci-lint config for v2.10.1 schema changes ([c9c4191](https://github.com/aj-welch/ajwelch-x-app/commit/c9c4191538d983ae35cd11b41f6c0b2e2482d224))
* use Cachix (aj-welch) to cache Nix store for analyze workflow ([f1cc7dd](https://github.com/aj-welch/ajwelch-x-app/commit/f1cc7dde8a93679cda3c9e26c46c05f3c58244f2))

## [0.4.0](https://github.com/aj-welch/ajwelch-x-app/compare/ajwelch-x-app-v0.3.0...ajwelch-x-app-v0.4.0) (2026-02-18)

### Features

- Nix-based CI with version matrix and unified Tiltfile
  ([1d5d645](https://github.com/aj-welch/ajwelch-x-app/commit/1d5d6455ce824f3ad20e458810ce6cc15dbebb70))
- restore conformance files and reorganize docs
  ([b3871ac](https://github.com/aj-welch/ajwelch-x-app/commit/b3871acfb2e9dd9c49657439e1d9328ccfd9eeed))

### Bug Fixes

- install Gateway API CRDs before applying development overlay
  ([b5d1b50](https://github.com/aj-welch/ajwelch-x-app/commit/b5d1b503570915c004be684ce73c56c4c85b0303))
- mg.Deps return value in BuildAll
  ([17025fa](https://github.com/aj-welch/ajwelch-x-app/commit/17025fa13bbd97ed11ec992c463408a168866cd9))
- rename Test namespace to Tests, add top-level Test() for ci.yml
  ([0eceb85](https://github.com/aj-welch/ajwelch-x-app/commit/0eceb856f5ecd3a84228ae6dfb6d5fc41313fc29))
- resolve Tilt registry mangling for k3d local dev
  ([51c974d](https://github.com/aj-welch/ajwelch-x-app/commit/51c974d871fbd86456d181a4ce300da263a866db))
- update k3s to v1.32.2-k3s1
  ([511a5a4](https://github.com/aj-welch/ajwelch-x-app/commit/511a5a40ef7c12a0cdb10b458e89fc1af92cd1e0))

## [0.3.0](https://github.com/aj-welch/ajwelch-x-app/compare/ajwelch-x-app-v0.2.0...ajwelch-x-app-v0.3.0) (2026-02-17)

### Features

- replace Docker Compose with k3d + Tilt + Kustomize dev environment
  ([2482a0c](https://github.com/aj-welch/ajwelch-x-app/commit/2482a0cc71a60a9ba8d803df50d69ffdc1b047ef))

## [0.2.0](https://github.com/aj-welch/ajwelch-x-app/compare/x-v0.1.0...x-v0.2.0) (2026-02-17)

### Features

- replace Docker Compose with k3d + Tilt + Kustomize dev environment
  ([2482a0c](https://github.com/aj-welch/ajwelch-x-app/commit/2482a0cc71a60a9ba8d803df50d69ffdc1b047ef))
