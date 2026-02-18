# Rebuild backend and frontend on source changes.
local_resource(
    'backend',
    cmd='mage build:backend',
    deps=['internal/', 'cmd/', 'go.mod', 'go.sum'],
    labels=['build'],
)

local_resource(
    'frontend',
    serve_cmd='pnpm exec webpack -w -c ./webpack.config.ts --env development',
    deps=['src/', 'package.json', 'webpack.config.ts'],
    labels=['build'],
)

# Container image: built by Nix via mage build:container.
# live_update syncs dist/ into the running pod without a full rebuild.
custom_build(
    'localhost:5000/ajwelch-x-app',
    'mage build:container && docker tag ajwelch-x-app:dev $EXPECTED_REF && docker push $EXPECTED_REF',
    deps=['nix/containers/', 'dist/'],
    live_update=[
        sync('dist/', '/var/lib/grafana/plugins/ajwelch-x-app/'),
    ],
)

# Install Gateway API CRDs before applying the main overlay. The EnvoyProxy
# custom resource in envoy-gateway requires its CRD to be established first.
local_resource(
    'gateway-crds',
    cmd='kustomize build --enable-helm k8s/overlays/crds | kubectl apply --server-side -f - && kubectl wait --for=condition=established --timeout=60s crd --all',
    labels=['infrastructure'],
    deps=['k8s/components/crds/'],
)

# Apply k8s manifests via Kustomize (with Helm chart inflation)
k8s_yaml(kustomize('k8s/overlays/development', flags=['--enable-helm']))

k8s_resource(
    'grafana',
    resource_deps=['gateway-crds'],
    port_forwards=['3000:3000', '2345:2345', '35729:35729'],
    labels=['app'],
)
