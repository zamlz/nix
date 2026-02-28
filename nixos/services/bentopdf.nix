# BentoPDF — privacy-first, client-side PDF toolkit.
# Runs as an OCI container on yggdrasil behind Caddy.
# Fully stateless — all processing happens in the browser.
#
# Debugging:
#   docker logs bentopdf
#   curl http://localhost:8085
#   Access https://bentopdf.lab.zamlz.org in a browser
{ constants, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.bentopdf) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  virtualisation.oci-containers.containers.bentopdf = {
    image = "ghcr.io/alam00000/bentopdf:latest";
    ports = [ "${toString constants.services.bentopdf.port}:8080" ];
  };
}
