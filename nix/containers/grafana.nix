# Grafana + plugin container image for local development.
# Uses the nixpkgs-pinned Grafana build. The Tiltfile syncs dist/ via live_update.
{ pkgs, ajwelch-x-app }:
let
  pluginId = "ajwelch-x-app";

  entrypoint = pkgs.writeShellScript "grafana-entrypoint" ''
    set -e
    exec ${pkgs.grafana}/bin/grafana server \
      --homepath=${pkgs.grafana}/share/grafana "$@"
  '';
in

pkgs.dockerTools.buildLayeredImage {
  name = pluginId;
  tag = "dev";

  contents = with pkgs; [
    grafana
    coreutils
    bash
    cacert
    delve
  ];

  # Bake the plugin into the image so the pod starts with a functional plugin.
  # live_update then syncs dist/ changes without a full rebuild.
  extraCommands = ''
    mkdir -p tmp && chmod 1777 tmp
    mkdir -p var/lib/grafana/plugins/${pluginId}
    cp -r ${ajwelch-x-app}/. var/lib/grafana/plugins/${pluginId}/
    chmod +x var/lib/grafana/plugins/${pluginId}/gpx_x_linux_amd64
  '';

  config = {
    Entrypoint = [ "${entrypoint}" ];
    ExposedPorts = {
      "3000/tcp" = { };
      "2345/tcp" = { };
    };
    Env = [
      "GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS=${pluginId}"
      "GF_PATHS_PLUGINS=/var/lib/grafana/plugins"
      "GF_SECURITY_ADMIN_PASSWORD=admin"
    ];
    WorkingDir = "/var/lib/grafana";
  };
}
