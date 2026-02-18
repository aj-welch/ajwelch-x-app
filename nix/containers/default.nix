{ pkgs }:
let
  ajwelch-x-app = pkgs.callPackage ../packages/ajwelch-x-app.nix { };
in
{
  grafana-dev = pkgs.callPackage ./grafana.nix { inherit ajwelch-x-app; };
}
