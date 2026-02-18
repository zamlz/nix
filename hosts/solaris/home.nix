{
  constants,
  self,
  ...
}:
{
  imports = [
    (self + /home/cli)
    (self + /home/desktop)
  ];

  my.fontScale = 2.0;
  # FIXME: ultrawide monitor is too large so let's make this a bit more sane.
  programs.niri.settings.layout.default-column-width.proportion = 0.5;

  home = {
    username = "amlesh";
    homeDirectory = "/home/amlesh";
    # WARNING: Read comment in lib/constants.nix file!
    inherit (constants) stateVersion;
  };
}
