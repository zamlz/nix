{
  constants,
  ...
}:
{
  imports = [
    ../../home/cli
    ../../home/desktop
  ];

  home = {
    username = "amlesh";
    homeDirectory = "/home/amlesh";
    inherit (constants) stateVersion;
  };
}
