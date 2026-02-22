{ self, pkgs }:
pkgs.runCommand "statix" { buildInputs = [ pkgs.statix ]; } ''
  ${pkgs.statix}/bin/statix check ${self}
  touch $out
''
