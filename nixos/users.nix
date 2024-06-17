{ inputs, lib, config, pkgs, ... }: {
  # (Don't forget to set a password with ‘passwd’!)
  users.users.zamlz = {
    isNormalUser = true;
    description = "Amlesh Sivanantham";
    initialPassword = "pleasechangeme";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  services.getty.autologinUser = "zamlz";
}
