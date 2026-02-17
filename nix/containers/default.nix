{ pkgs }:

{
  grafana = pkgs.callPackage ./grafana.nix { };
  grafana-dev = pkgs.callPackage ./grafana.nix { dev = true; };
}
