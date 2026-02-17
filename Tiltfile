# Detect CI mode: set CI=true in the environment to skip watch resources and
# enable versioned image builds. Used by `mage development:e2eCI`.
is_ci = os.environ.get("CI") == "true"
grafana_version = os.environ.get("GRAFANA_VERSION", "")
image_tag = grafana_version if grafana_version else "dev"
grafana_version_env = ("GRAFANA_VERSION=" + grafana_version + " ") if grafana_version else ""

# Dev-only: rebuild backend and frontend on source changes, run localias.
# Skipped in CI since mage build:all runs before tilt ci.
if not is_ci:
    local_resource(
        'backend',
        serve_cmd='mage build:watch',
        deps=['internal/', 'cmd/', 'go.mod', 'go.sum'],
        labels=['build'],
    )

    local_resource(
        'frontend',
        serve_cmd='pnpm exec webpack -w -c ./webpack.config.ts --env development',
        deps=['src/', 'package.json', 'webpack.config.ts'],
        labels=['build'],
    )

    local_resource(
        'localias',
        serve_cmd='localias run',
        deps=['.localias.yaml'],
        labels=['infrastructure'],
    )

# Container image: built by Nix via mage build:container.
# In dev mode: builds .#grafana-dev, live_update syncs dist/ without a rebuild.
# In CI mode: GRAFANA_VERSION is set, builds .#grafana-X_Y_Z with dist/ baked in.
custom_build(
    'localhost:5000/ajwelch-x-app',
    grafana_version_env + 'mage build:container && docker tag ajwelch-x-app:' + image_tag + ' $EXPECTED_REF && docker push $EXPECTED_REF',
    deps=['nix/containers/', 'dist/'],
    live_update=[] if is_ci else [
        sync('dist/', '/var/lib/grafana/plugins/ajwelch-x-app/'),
    ],
)

# Apply k8s manifests via Kustomize (with Helm chart inflation)
k8s_yaml(kustomize('k8s/overlays/development', flags=['--enable-helm']))

# Port forwards: all three in dev, only Grafana UI in CI.
port_forwards = ['3000:3000']
if not is_ci:
    port_forwards += ['2345:2345', '35729:35729']

k8s_resource(
    'grafana',
    port_forwards=port_forwards,
    labels=['app'],
)
