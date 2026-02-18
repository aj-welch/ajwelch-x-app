# Grafana + plugin container image for local development.
# Uses the nixpkgs-pinned Grafana build. The Tiltfile syncs dist/ via live_update.
{ pkgs }:
let
  pluginId = "ajwelch-x-app";
  pluginDist = ../../dist;

  pluginFiles = pkgs.runCommand "plugin-dist" { } ''
    mkdir -p $out/var/lib/grafana/plugins/${pluginId}
    cp -r ${pluginDist}/. $out/var/lib/grafana/plugins/${pluginId}/
  '';

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
    pluginFiles
  ];

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
