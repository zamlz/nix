{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  systemd.user = {
    enable = true;

    # Systemd task to clean out my tmp directory if a file gets over a week old
    tmpfiles.settings.tempDownloadDir.rules = {
      "/home/amlesh/tmp" = {
        "D" = {
          mode = "0700";
          user = "amlesh";
          group = "users";
        };
      };
    };
  };
}
