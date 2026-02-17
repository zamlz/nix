{
  config,
  ...
}:
{
  systemd.user = {
    enable = true;
    startServices = "sd-switch";

    # Import home.sessionVariables into systemd user environment
    sessionVariables = config.home.sessionVariables;

    # Systemd task to clean out my tmp directory if a file gets over a week old
    tmpfiles.rules = [
      "D /home/amlesh/tmp 0700 amlesh users"
    ];
  };
}
