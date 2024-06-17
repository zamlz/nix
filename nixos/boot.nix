{ inputs, lib, config, pkgs, ... }: {

  # Please refer to the main file in `hosts/` for LUKS specific configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

}
