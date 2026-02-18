{ pkgs }:

{
  grafana-dev = pkgs.callPackage ./grafana.nix { };
}
