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

local_registry = os.environ['LOCAL_REGISTRY']
plugin_id = os.environ['PLUGIN_ID']
image_ref = '{}/{}'.format(local_registry, plugin_id)

# Container image: built by Nix via mage build:container.
# live_update syncs dist/ into the running pod without a full rebuild.
custom_build(
    image_ref,
    'mage build:container && docker tag {}:dev $EXPECTED_REF && docker push $EXPECTED_REF'.format(plugin_id),
    deps=['nix/', 'dist/'],
    live_update=[
        sync('dist/', '/var/lib/grafana/plugins/{}/'.format(plugin_id)),
    ],
)

# Install Gateway API CRDs before applying the main overlay. The EnvoyProxy
# custom resource in envoy-gateway requires its CRD to be established first.
local_resource(
    'gateway-crds',
    cmd='kustomize build --enable-helm k8s/crds | kubectl apply --server-side -f - && kubectl wait --for=condition=established --timeout=60s crd --all',
    labels=['infrastructure'],
    deps=['k8s/crds/'],
)

# Apply k8s manifests via Kustomize (with Helm chart inflation)
k8s_yaml(kustomize('k8s/development', flags=['--enable-helm']))

k8s_resource(
    'grafana',
    resource_deps=['gateway-crds'],
    port_forwards=['3000:3000', '2345:2345', '35729:35729'],
    labels=['app'],
)
