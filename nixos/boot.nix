{ inputs, lib, config, pkgs, ... }: {

  # Please refer to the main file in `hosts/` for LUKS specific configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # NixOS doesn't use a tmpfs for the tmp dir, so let's be sure to clean it on boot instead
  boot.tmp.cleanOnBoot = true;
}
