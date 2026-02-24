# Jellyfin media server — self-hosted Netflix for movies, shows, and more.
#
# Debugging:
#   systemctl status jellyfin
#   journalctl -u jellyfin
#   Access http://<host>:8096 in a browser
{ constants, firewallUtils, ... }:
{
  imports = [
    # Wider subnet to include TV and other devices
    (firewallUtils.mkOpenPortForSubnetRule {
      port = constants.ports.jellyfin;
      subnet = constants.parentSubnet;
    })
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = false;
  };
}
