# Kiwix — offline Wikipedia (and other ZIM content) server.
# Runs as an OCI container on yggdrasil behind Caddy.
# ZIM files are stored on the Alexandria NAS via NFS (/mnt/media/kiwix).
#
# To add content, download .zim files from https://library.kiwix.org
# and place them in /mnt/media/kiwix/ on any NFS client, then restart
# the container: systemctl restart docker-kiwix
#
# Debugging:
#   docker logs kiwix
#   curl http://localhost:8086
#   Access https://kiwix.lab.zamlz.org in a browser
{ constants, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.kiwix) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  virtualisation.oci-containers.containers.kiwix = {
    image = "ghcr.io/kiwix/kiwix-serve:3.8.1";
    ports = [ "${toString constants.services.kiwix.port}:8080" ];
    volumes = [
      "/mnt/media/backups/zim:/data:ro"
    ];
    cmd = [ "*.zim" ];
  };
}
