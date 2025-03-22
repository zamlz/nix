{ inputs, lib, config, pkgs, ... }: {
  systemd.user = {
    enable = true;

    # Systemd task to clean out my tmp directory if a file gets over a week old
    tmpfiles.rules = [
        "D /home/amlesh/tmp 0700 amlesh users"
    ];
  };
}
