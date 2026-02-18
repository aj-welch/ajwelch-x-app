{
  description = "Grafana plugin development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/fa56d7d6";
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
            commitizen
            customPkgs.lefthook
            customPkgs.twitterapi-io
            deadnix
            delve
            docker-client
            editorconfig-checker
            go_1_25
            gofumpt
            golangci-lint
            k3d
            keep-sorted
            kubeconform
            kubectl
            kubernetes-helm
            kustomize
            localias.packages.${system}.default
            mage
            markdownlint-cli2
            nixfmt-rfc-style
            nodejs_22
            nodePackages.pnpm
            oapi-codegen
            semgrep
            shellcheck
            shfmt
            statix
            taplo
            tilt
            yamllint
          ];

          shellHook = ''
            if [ -d .git ]; then
              lefthook install
            fi
          '';
        };
      }
    );
}
