{ self, pkgs }:
pkgs.runCommand "nixfmt" { buildInputs = [ pkgs.nixfmt ]; } ''
  ${pkgs.nixfmt}/bin/nixfmt --check ${self}
  touch $out
''
