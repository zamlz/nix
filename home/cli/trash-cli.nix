{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [trash-cli];

  # Cleanup files that are older than 30 days from the trash can
  systemd.user = let
    unitInfo = {
      Description = "Empty old trash (> 30 days) for trash-cli";
      Documentation = ["man:trash-empty(1)"];
    };
  in {
    enable = true;
    services = {
      trash-cli-empty = {
        Unit = unitInfo;
        Service = {
          Type = "oneshot";
          ExecStart = "trash-empty 30";
          StandardOutput = "journal";
          StandardError = "journal";
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };
    };
    timers = {
      trash-cli-empty = {
        Unit = unitInfo;
        Timer = {
          OnCalendar = "daily";
          Persistent = "true";
        };
      };
    };
  };
}
