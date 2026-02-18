# Repository Setup

One-time manual settings required after creating this repository.

## GitHub Actions permissions

**Settings → Actions → General → Workflow permissions**

Enable "Allow GitHub Actions to create and approve pull requests". Required for
the `publish-report` job to comment on pull requests with Playwright test results.

## GitHub Pages

**Settings → Pages → Build and deployment**

Set Source to "Deploy from a branch" and choose `gh-pages`. Required for the
`publish-report` job to publish Playwright test reports.
