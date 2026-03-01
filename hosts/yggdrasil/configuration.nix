# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  constants,
  self,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    (self + /nixos/server.nix)
    (self + /nixos/services/glances.nix)
    (self + /nixos/services/kavita.nix)
    (self + /nixos/services/alexandria-nas-nfs.nix)
    (self + /nixos/services/blocky.nix)
    (self + /nixos/services/prometheus.nix)
    (self + /nixos/services/grafana.nix)
    (self + /nixos/services/jellyfin.nix)
    (self + /nixos/services/pocket-id.nix)
    (self + /nixos/services/homepage-dashboard.nix)
    (self + /nixos/services/bentopdf.nix)
    (self + /nixos/services/booklore.nix)
    (self + /nixos/services/kiwix.nix)
    (self + /nixos/services/miniflux.nix)
    (self + /nixos/services/navidrome.nix)
    (self + /nixos/services/cyberchef.nix)
    (self + /nixos/services/pinchflat.nix)
    (self + /nixos/services/gatus.nix)
    (self + /nixos/services/speedtest-tracker.nix)
    (self + /nixos/services/forgejo.nix)
    (self + /nixos/services/pairdrop.nix)
    (self + /nixos/services/tailscale-subnet-router.nix)
    (self + /nixos/services/caddy.nix)
  ];

  networking = {
    hostName = "yggdrasil";
    hostId = "6e9d6c6c";
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # WARNING: Read comment in lib/constants.nix file!
  system.stateVersion = constants.stateVersion;
}
