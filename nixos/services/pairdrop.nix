# Pairdrop — local network file sharing (AirDrop alternative).
# Runs as a stateless OCI container on yggdrasil behind Caddy.
# Accessible at https://pairdrop.lab.zamlz.org via Caddy.
#
# Usage: open the URL on two devices on the same network — they
# discover each other via WebRTC and exchange files peer-to-peer.
#
# Debugging:
#   docker logs pairdrop
#   curl http://localhost:3001
#   Access https://pairdrop.lab.zamlz.org in a browser
{ constants, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.pairdrop) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  virtualisation.oci-containers.containers.pairdrop = {
    image = "lscr.io/linuxserver/pairdrop:latest";
    ports = [ "${toString constants.services.pairdrop.port}:3000" ];
  };
}
