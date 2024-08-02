{ inputs, lib, config, pkgs, ... }: {
  users.extraGroups.docker.members = [ "zamlz" ];

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };
}
