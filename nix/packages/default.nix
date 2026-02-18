{ pkgs }:
{
  twitterapi-io = pkgs.callPackage ./twitterapi-io.nix { };
  ajwelch-x-app = pkgs.callPackage ./ajwelch-x-app.nix { };
}
