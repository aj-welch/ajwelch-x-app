# Backend: rebuild plugin binary on source changes
local_resource(
    'backend',
    serve_cmd='mage build:watch',
    deps=['internal/', 'cmd/', 'go.mod', 'go.sum'],
    labels=['build'],
)

# Frontend: webpack in watch mode for hot reload
local_resource(
    'frontend',
    serve_cmd='pnpm exec webpack -w -c ./webpack.config.ts --env development',
    deps=['src/', 'package.json', 'webpack.config.ts'],
    labels=['build'],
)

# Localias: manages /etc/hosts and TLS for grafana.ajwelch-x-app.test
local_resource(
    'localias',
    serve_cmd='localias run',
    deps=['.localias.yaml'],
    labels=['infrastructure'],
)

# Container image: built by Nix, loaded into the local k3d registry
custom_build(
    'localhost:5000/ajwelch-x-app',
    'nix build .#grafana-dev && docker load < result && docker tag ajwelch-x-app:dev $EXPECTED_REF && docker push $EXPECTED_REF',
    deps=['nix/containers/', 'dist/'],
    live_update=[
        sync('dist/', '/var/lib/grafana/plugins/ajwelch-x-app/'),
    ],
)

# Apply k8s manifests via Kustomize (with Helm chart inflation)
k8s_yaml(kustomize('k8s/overlays/development', flags=['--enable-helm']))

# Port forwards to localhost
k8s_resource(
    'grafana',
    port_forwards=[
        '3000:3000',   # Grafana UI
        '2345:2345',   # Delve debugger
        '35729:35729', # Webpack livereload
    ],
    labels=['app'],
)
