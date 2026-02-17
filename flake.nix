{
  description = "Grafana plugin development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        customPkgs = import ./nix/packages { inherit pkgs; };
      in
      {
        packages = customPkgs;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            customPkgs.twitterapiio
            docker-client
            go_1_24
            mage
            mprocs
            nodejs_22
            nodePackages.pnpm
            oapi-codegen
          ];
        };
      }
    );
}
