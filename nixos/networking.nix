{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # NOTE: hostname will be defined in the `/host` specific file!

  users.extraGroups.networkmanager.members = ["amlesh"];

  networking = {
    extraHosts = ''
      10.69.8.0 solaris
      10.69.8.1 xynthar.enp
      10.69.8.2 xynthar.wlp xynthar
      10.69.8.3 yggdrasil
      10.69.8.4 alexandria
    '';
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # ssh
        2049 # nfs
      ];
    };
    networkmanager.enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
