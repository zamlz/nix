{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # ClamAV is an antivirus software
  services.clamav = {
    daemon.enable = true;
    fangfrisch.enable = true;
    updater.enable = true;
  };
}
