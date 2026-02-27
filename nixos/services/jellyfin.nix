# Jellyfin media server — self-hosted Netflix for movies, shows, and more.
# Accessed via Caddy reverse proxy.
#
# Debugging:
#   systemctl status jellyfin
#   journalctl -u jellyfin
#   Access https://jellyfin.lab.zamlz.org in a browser
{ constants, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.jellyfin) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = false;
  };
}
