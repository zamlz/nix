{
  constants,
  pkgs,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    # Base ISO image configuration from nixpkgs
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares.nix"

    # Import all relevant system modules (including users.nix for amlesh user)
    ../../nixos/core.nix
    ../../nixos/gui.nix
    ../../nixos/audio.nix
    ../../nixos/networking.nix
    ../../nixos/nix.nix
    ../../nixos/users.nix
    ../../nixos/security.nix
    # Skip: docker.nix (optional), printing.nix (not needed for portable USB)
  ];

  # Disable auto-login - we want normal login like on actual systems
  services.displayManager.autoLogin.enable = lib.mkForce false;

  # ISO-specific settings
  networking.hostName = "nixos-live";
  networking.hostId = "12345678";

  # Set the system platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Boot configuration
  boot = {
    # Disable boot loader settings (ISO uses its own)
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = lib.mkForce false;
    };

    # Comprehensive kernel modules for various hardware
    initrd.availableKernelModules = [
      # NVMe/SATA
      "nvme"
      "ahci"
      "xhci_pci"
      "sd_mod"
      "sdhci_pci"
      # USB
      "usb_storage"
      "usbhid"
      "uas"
    ];

    # KVM support for Intel and AMD
    kernelModules = [
      "kvm-intel"
      "kvm-amd"
    ];
  };

  # Enable broad hardware support
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    # NVIDIA configuration for live ISO
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      nvidiaSettings = true;
    };
  };

  # Multiple video drivers for universal hardware support
  services.xserver.videoDrivers = lib.mkForce [
    "modesetting"
    "nvidia"
    "amdgpu"
    "radeon"
    "intel"
  ];

  # Installation tools
  environment.systemPackages = with pkgs; [
    gparted
    ddrescue
    testdisk
    inxi
    lshw
    dmidecode
  ];

  # ISO image customization
  isoImage = {
    volumeID = "NIXOS_CUSTOM";
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  image.fileName = "nixos-custom-${constants.stateVersion}-${pkgs.stdenv.hostPlatform.system}.iso";

  system.stateVersion = constants.stateVersion;
}
