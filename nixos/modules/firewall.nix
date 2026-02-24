_: {
  # Per-service LAN rules are defined in each service file
  # using firewallUtils.mkOpenPortForSubnetRule.
  # SSH is opened globally via services.openssh.openFirewall in networking.nix.
  networking.firewall.enable = true;
}
