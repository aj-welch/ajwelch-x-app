{
  description = "Grafana plugin development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    localias.url = "github:peterldowns/localias";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      localias,
      ...
    }:
    let
      # Grafana versions for the CI E2E matrix. Each entry maps a version
      # string to the sha256 of its linux-amd64 tarball from dl.grafana.com.
      # To add a version: nix-prefetch-url https://dl.grafana.com/oss/release/grafana-X.Y.Z.linux-amd64.tar.gz
      grafanaVersionsWithHashes = {
        "12.3.2" = "16wxiwkajsq48xq6jfprar4lysm22i0byclipdl85ws3gz05yrzq";
        "11.5.0" = "0nd0sb84g49pxnidq5nggzhng7mp4rzhv3sdjx5g79bgl2j60psk";
      };

      # Sorted list of version strings, exposed for CI matrix generation via:
      # nix eval .#grafanaVersions --json
      grafanaVersions = builtins.attrNames grafanaVersionsWithHashes;
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        customPkgs = import ./nix/packages { inherit pkgs; };
        customContainers = import ./nix/containers { inherit pkgs; };

        # Versioned CI images built from CDN tarballs. Linux-only since the
        # tarballs are linux/amd64 and autoPatchelf only runs on Linux.
        # Attribute names use underscores: grafana-12_3_2 = Grafana 12.3.2
        versionedContainers = pkgs.lib.optionalAttrs pkgs.stdenv.isLinux (
          builtins.listToAttrs (
            builtins.map (version: {
              name = "grafana-" + builtins.replaceStrings [ "." ] [ "_" ] version;
              value = pkgs.callPackage ./nix/containers/grafana.nix {
                inherit version;
                hash = grafanaVersionsWithHashes.${version};
              };
            }) grafanaVersions
          )
        );
      in
      {
        packages = customPkgs // customContainers // versionedContainers;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            customPkgs.twitterapiio
            delve
            docker-client
            go_1_24
            golangci-lint
            k3d
            kubectl
            kubernetes-helm
            kustomize
            localias.packages.${system}.default
            mage
            nodejs_22
            nodePackages.pnpm
            oapi-codegen
            tilt
          ];
        };
      }
    )
    // {
      inherit grafanaVersions;
    };
}
