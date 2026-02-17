{ pkgs, dev ? false }:

let
  pluginsDir = "/var/lib/grafana/plugins/ajwelch-x-app";

  devTools = with pkgs; lib.optionals dev [
    delve
  ];

  entrypoint = pkgs.writeShellScript "grafana-entrypoint" ''
    set -e

    mkdir -p ${pluginsDir}

    exec ${pkgs.grafana}/bin/grafana server \
      --homepath=${pkgs.grafana}/share/grafana \
      cfg:default.paths.plugins=/var/lib/grafana/plugins \
      "$@"
  '';
in

pkgs.dockerTools.buildLayeredImage {
  name = "ajwelch-x-app";
  tag = if dev then "dev" else "latest";

  contents = with pkgs; [
    grafana
    coreutils
    bash
    cacert
  ] ++ devTools;

  config = {
    Entrypoint = [ "${entrypoint}" ];
    ExposedPorts = {
      "3000/tcp" = { };
      "2345/tcp" = { };
    };
    Env = [
      "GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS=ajwelch-x-app"
      "GF_PATHS_PLUGINS=/var/lib/grafana/plugins"
      "GF_SECURITY_ADMIN_PASSWORD=admin"
    ];
    WorkingDir = "/var/lib/grafana";
  };
}
