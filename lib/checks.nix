{ self, pkgs }:
{
  nixfmt = pkgs.runCommand "nixfmt" { buildInputs = [ pkgs.nixfmt ]; } ''
    ${pkgs.nixfmt}/bin/nixfmt --check ${self}
    touch $out
  '';

  statix = pkgs.runCommand "statix" { buildInputs = [ pkgs.statix ]; } ''
    ${pkgs.statix}/bin/statix check ${self}
    touch $out
  '';

  deadnix = pkgs.runCommand "deadnix" { buildInputs = [ pkgs.deadnix ]; } ''
    ${pkgs.deadnix}/bin/deadnix --fail ${self}
    touch $out
  '';
}
