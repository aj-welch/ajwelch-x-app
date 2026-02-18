# Repository Setup

One-time manual settings required after creating this repository.

## GitHub Actions permissions

### Settings → Actions → General → Workflow permissions

Enable "Allow GitHub Actions to create and approve pull requests". Required for
the `publish-report` job to comment on pull requests with Playwright test results.

## Cachix binary cache

### Settings → Secrets and variables → Actions → Secrets

Add `CACHIX_AUTH_TOKEN` — generate at <https://app.cachix.org/cache/aj-welch>.
Required for the `analyze` workflow to push derivations to the `aj-welch` Cachix
cache, enabling fast `nix develop` in CI after the first cold run.

## GitHub Pages

### Settings → Pages → Build and deployment

Set Source to "Deploy from a branch" and choose `gh-pages`. Required for the
`publish-report` job to publish Playwright test reports.
