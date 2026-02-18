{ pkgs }:
let
  inherit (pkgs) lib;

  pluginId = "ajwelch-x-app";
  version = "0.3.0";
  src = ../..;

  # Build Go backend binary for linux/amd64.
  # Grafana expects: plugins/<id>/gpx_<executable>_linux_amd64
  backend = pkgs.buildGoModule {
    pname = "${pluginId}-backend";
    inherit version src;

    subPackages = [ "cmd/plugin" ];

    env.CGO_ENABLED = "0";

    vendorHash = "sha256-fJ4rklmdDGSz2jeDrESbmdHEKmk2757hx6GP1by7mzI=";

    postInstall = ''
      mv $out/bin/plugin $out/bin/gpx_x_linux_amd64
    '';
  };

  # Fetch pnpm dependency store for offline webpack build.
  pnpmDeps = pkgs.fetchPnpmDeps {
    pname = "${pluginId}-frontend";
    inherit version src;
    pnpm = pkgs.pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-d6u+tXu6RQ2HmvQvUodo+ssA5HpB67f8zxS7RJ082Ho=";
  };

  # Build TypeScript frontend via pnpm + webpack → dist/.
  frontend = pkgs.stdenvNoCC.mkDerivation {
    pname = "${pluginId}-frontend";
    inherit version src;

    nativeBuildInputs = [
      pkgs.nodejs_22
      pkgs.pnpm_10
      pkgs.pnpmConfigHook
    ];

    inherit pnpmDeps;

    buildPhase = "pnpm run build";

    installPhase = "mv dist $out";
  };

in
# Combine frontend dist/ and backend binary into the Grafana plugin layout.
pkgs.runCommand pluginId { } ''
  mkdir -p $out
  cp -r ${frontend}/. $out/
  install -m 755 ${backend}/bin/gpx_x_linux_amd64 $out/gpx_x_linux_amd64
''
