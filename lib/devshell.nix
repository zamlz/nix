{ pkgs }:
{
  default = pkgs.mkShell {
    packages = with pkgs; [
      # nix rebuild wrapper
      nh
      # Nix formatting and linting
      nixfmt
      statix
      deadnix
    ];
  };
}
