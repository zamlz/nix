{ inputs, lib, config, pkgs, ... }: {
  # NOTE: hostname will be defined in the `/host` specific file!

  users.extraGroups.networkmanager.members = [ "amlesh" ];

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
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
