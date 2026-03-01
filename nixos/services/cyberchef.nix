# CyberChef — data encoding, conversion, and analysis toolkit.
# Runs as an OCI container on yggdrasil behind Caddy.
# Fully stateless — all processing happens in the browser.
#
# Debugging:
#   docker logs cyberchef
#   curl http://localhost:8087
#   Access https://cyberchef.lab.zamlz.org in a browser
{ constants, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.cyberchef) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  virtualisation.oci-containers.containers.cyberchef = {
    image = "ghcr.io/gchq/cyberchef:latest";
    ports = [ "${toString constants.services.cyberchef.port}:80" ];
  };
}
