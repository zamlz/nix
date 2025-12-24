{
  constants,
  ...
}:
{
  imports = [ ../../home/cli ];

  home = {
    username = "amlesh";
    homeDirectory = "/home/amlesh";
    # WARNING: Read comment in lib/constants.nix file!
    inherit (constants) stateVersion;
  };

  # IMPORTANT: Allows home manager to properly integrate with the original OS's
  # directories and settings
  targets.genericLinux.enable = true;
}
