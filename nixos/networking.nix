{ inputs, lib, config, pkgs, ... }: {

  # NOTE: hostname will be defined in the `/host` specific file!

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      #allowedUDPPorts = [ ... ];
    };
  };
  
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
