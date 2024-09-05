{ inputs, lib, config, pkgs, ... }: {
  services.printing.enable = true;

  # enable autodiscovery of network printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
