# Kubernetes Configuration

This directory uses Kustomize with a component-based architecture.

## Structure

```text
k8s/
├── crds/                # CRDs — installed separately before main resources
├── components/          # Reusable component library
│   ├── grafana/         # Grafana deployment with plugin
│   └── envoy-gateway/   # Envoy Gateway ingress
└── development/         # Development environment
    ├── vars.yaml        # Environment-specific values (single source of truth)
    ├── namespace.yaml
    └── kustomization.yaml
```

## Design

Components are isolated, reusable units that declare their inputs via an
internal `vars.yaml` ConfigMap. Environments provide values through a
`global-vars` ConfigMap that components read via Kustomize replacements.

This is dependency injection for Kubernetes:

- **Components** declare what inputs they need (`vars.yaml` with `PLACEHOLDER`
  values)
- **Environments** provide the actual values (`global-vars` ConfigMap in
  `development/vars.yaml`)

### Replacement flow

```text
global-vars (development/vars.yaml)
    → component-vars (components/*/vars.yaml)
        → actual resource fields
```

The two-step indirection documents the component's interface explicitly — you
can read `components/grafana/vars.yaml` to see exactly what inputs grafana
accepts.

### local-config annotation

Both `global-vars` and component vars ConfigMaps carry:

```yaml
annotations:
  config.kubernetes.io/local-config: 'true'
```

This tells Kustomize to exclude them from the final output, so they are never
deployed to the cluster.

### Adding a new environment

Create a sibling directory to `development/`:

```text
k8s/
├── development/
└── staging/
    ├── kustomization.yaml
    ├── namespace.yaml
    └── vars.yaml        # staging-specific values
```

## Usage

```bash
# Install CRDs first (required before main resources)
kustomize build --enable-helm k8s/crds | kubectl apply --server-side -f -
kubectl wait --for=condition=established --timeout=60s crd --all

# Apply development environment
kustomize build --enable-helm k8s/development | kubectl apply -f -
```

In practice, `mage development:up` runs Tilt which handles both steps
automatically.
