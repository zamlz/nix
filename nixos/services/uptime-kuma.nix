# Uptime Kuma — service uptime monitoring with status page.
# Runs natively on yggdrasil behind Caddy.
# Accessible at https://uptime-kuma.lab.zamlz.org via Caddy.
#
# First-time setup:
#   Visit the URL and create an admin account on first load.
#   Add monitors for each service (HTTP, TCP, DNS, etc.)
#
# Debugging:
#   systemctl status uptime-kuma
#   journalctl -u uptime-kuma
#   Access https://uptime-kuma.lab.zamlz.org in a browser
{ constants, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.uptime-kuma) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = toString constants.services.uptime-kuma.port;
    };
  };
}
