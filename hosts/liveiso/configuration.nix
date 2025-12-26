{
  constants,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../nixos/core.nix
    ../../nixos/gui.nix
    ../../nixos/audio.nix
    ../../nixos/networking.nix
    ../../nixos/nix.nix
    ../../nixos/users.nix
    ../../nixos/security.nix
  ];

  networking.hostName = "nixos-live";
  networking.hostId = "12345678";

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.initrd.availableKernelModules = [
    "nvme"
    "ahci"
    "xhci_pci"
    "sd_mod"
    "sdhci_pci"
    "usb_storage"
    "usbhid"
    "uas"
  ];

  boot.kernelModules = [
    "kvm-intel"
    "kvm-amd"
  ];

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      nvidiaSettings = true;
    };
  };

  services.xserver.videoDrivers = lib.mkForce [
    "modesetting"
    "nvidia"
    "amdgpu"
    "radeon"
    "intel"
  ];

  services.displayManager.autoLogin = {
    enable = true;
    user = "amlesh";
  };

  environment.systemPackages = with pkgs; [
    inxi
    lshw
    dmidecode
  ];

  system.stateVersion = constants.stateVersion;
}
