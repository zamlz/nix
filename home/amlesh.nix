{
  systemConfig,
  constants,
  ...
}:
{
  imports =
    if systemConfig.useGUI then
      [
        ./cli
        ./desktop
      ]
    else
      [ ./cli ];

  home = {
    username = "amlesh";
    homeDirectory = "/home/amlesh";
    # WARNING: Read comment in lib/constants.nix file!
    inherit (constants) stateVersion;
  };
}
