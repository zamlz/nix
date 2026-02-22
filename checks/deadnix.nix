{ self, pkgs }:
pkgs.runCommand "deadnix" { buildInputs = [ pkgs.deadnix ]; } ''
  ${pkgs.deadnix}/bin/deadnix --fail ${self}
  touch $out
''
