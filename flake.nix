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
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        customPkgs = import ./nix/packages { inherit pkgs; };
        customContainers = import ./nix/containers { inherit pkgs; };
      in
      {
        packages = customPkgs // customContainers;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            customPkgs.twitterapiio
            delve
            docker-client
            go_1_24
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
    );
}
