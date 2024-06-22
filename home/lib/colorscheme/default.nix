let
  gruvboxBlack = (import ./gruvbox-black.nix);
  modusVivendi = (import ./modus-vivendi.nix);
in {
  defaultColorScheme = gruvboxBlack;
}
