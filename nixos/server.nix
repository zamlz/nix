{ self, ... }:
{
  imports = [
    ./modules/console.nix
    ./modules/docker.nix
    ./modules/fail2ban.nix
    ./modules/firewall.nix
    ./modules/fwupd.nix
    ./modules/documentation.nix
    ./modules/hardware.nix
    ./modules/locale.nix
    ./modules/networking.nix
    ./modules/nix.nix
    ./modules/nh.nix
    ./modules/security.nix
    ./modules/ssh.nix
    ./modules/sops.nix
    ./modules/tailscale.nix
    ./modules/shell.nix
    ./modules/time.nix
    ./modules/users.nix
    ./modules/vulnix.nix
    (self + /nixos/services/prometheus-node-exporter.nix)
  ];
}
