# Grafana + plugin container image.
#
# Two modes:
#   dev (no version/hash): uses the nixpkgs-pinned Grafana build, no plugin
#     dist baked in. The Tiltfile syncs dist/ via live_update.
#   versioned (version + hash): fetches the official Grafana OSS tarball from
#     the CDN and patches ELF RPATHs with autoPatchelfHook. The built plugin
#     dist/ is baked into the image. Used for CI E2E testing.
{ pkgs, version ? null, hash ? null, dev ? false }:
let
  pluginId = "ajwelch-x-app";
  pluginsDir = "/var/lib/grafana/plugins/${pluginId}";
  isVersioned = version != null;

  grafanaPkg =
    if isVersioned then
      # Unpack and patch the Grafana OSS binary tarball from the CDN.
      # autoPatchelfHook rewrites RPATH entries to use Nix-managed glibc
      # instead of the system FHS paths (e.g. /lib/x86_64-linux-gnu/libc.so.6).
      pkgs.stdenv.mkDerivation {
        pname = "grafana-oss";
        inherit version;
        src = pkgs.fetchurl {
          url = "https://dl.grafana.com/oss/release/grafana-${version}.linux-amd64.tar.gz";
          sha256 = hash;
        };
        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = with pkgs; [
          glibc
          gcc-unwrapped.lib # libstdc++.so.6, libgcc_s.so.1
        ];
        dontConfigure = true;
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r . $out/
          runHook postInstall
        '';
      }
    else
      pkgs.grafana;

  homepath = if isVersioned then grafanaPkg else "${grafanaPkg}/share/grafana";

  devTools = pkgs.lib.optionals dev [ pkgs.delve ];

  imageTag = if isVersioned then version else "dev";

  entrypoint = pkgs.writeShellScript "grafana-entrypoint" ''
    set -e
    exec ${grafanaPkg}/bin/grafana server --homepath=${homepath} "$@"
  '';

  # For versioned images, bake the built plugin into the image.
  # For dev images, dist/ is synced at runtime via the Tiltfile live_update.
  pluginDist = pkgs.lib.optionalAttrs isVersioned {
    pluginDist = builtins.path {
      path = ../../dist;
      name = "plugin-dist";
    };
  };
in

pkgs.dockerTools.buildLayeredImage {
  name = pluginId;
  tag = imageTag;

  contents = with pkgs; [
    grafanaPkg
    coreutils
    bash
    cacert
  ] ++ devTools;

  fakeRootCommands = pkgs.lib.optionalString isVersioned ''
    mkdir -p ${pluginsDir}
    cp -r ${pluginDist.pluginDist}/. ${pluginsDir}/
    chmod -R 755 ${pluginsDir}
  '';
  enableFakechroot = isVersioned;

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
    ] ++ pkgs.lib.optional isVersioned "GF_PATHS_HOME=${homepath}";
    WorkingDir = "/var/lib/grafana";
  };
}
