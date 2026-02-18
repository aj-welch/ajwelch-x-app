{ pkgs }:

let
  filterPattern = "/[0-9]+;[0-9]+c_?|/[0-9]+c_?|\\x1b\\[[?0-9;]*c";
in
pkgs.writeShellScriptBin "lefthook" ''
  ${pkgs.util-linux}/bin/script -qec "${pkgs.lefthook}/bin/lefthook $*" /dev/null | ${pkgs.gnused}/bin/sed -E 's#${filterPattern}##g'
  exit ''${PIPESTATUS[0]}
''
