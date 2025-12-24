{
  ...
}:
{
  systemd.user = {
    enable = true;
    startServices = "sd-switch";

    # Systemd task to clean out my tmp directory if a file gets over a week old
    tmpfiles.rules = [
      "D /home/amlesh/tmp 0700 amlesh users"
    ];
  };
}
