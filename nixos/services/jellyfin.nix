# Jellyfin media server — self-hosted Netflix for movies, shows, and more.
#
# Debugging:
#   systemctl status jellyfin
#   journalctl -u jellyfin
#   Access http://<host>:8096 in a browser
{ firewallUtils, ... }:
{
  imports = [
    # Wider subnet to include TV and other devices
    (firewallUtils.mkOpenPortForSubnetRule {
      port = 8096;
      subnet = "10.69.0.0/16";
    })
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = false;
  };
}
