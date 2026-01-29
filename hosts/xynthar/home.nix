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

  home = {
    username = "amlesh";
    homeDirectory = "/home/amlesh";
    # WARNING: Read comment in lib/constants.nix file!
    inherit (constants) stateVersion;
  };
}
