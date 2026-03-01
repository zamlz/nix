# Navidrome — self-hosted music streaming server (Subsonic-compatible).
# Runs as an OCI container on yggdrasil, music library on Alexandria NAS via NFS.
# Accessible at https://navidrome.lab.zamlz.org via Caddy.
#
# Mobile apps (Subsonic-compatible):
#   Android: Symfonium (paid, best), Ultrasonic (free)
#   iOS: Amperfy (free), Substreamer
#
# First-time setup:
#   Create /mnt/media/music on Alexandria: mkdir -p && chmod 755
#   Drop music files into /mnt/media/music — Navidrome will scan automatically.
#
# Debugging:
#   docker logs navidrome
#   curl http://localhost:4533
#   Access https://navidrome.lab.zamlz.org in a browser
{ constants, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.navidrome) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  virtualisation.oci-containers.containers.navidrome = {
    image = "ghcr.io/navidrome/navidrome:latest";
    environment = {
      ND_MUSICFOLDER = "/music";
      ND_PORT = toString constants.services.navidrome.port;
      ND_LOGLEVEL = "info";
      ND_ENABLEINSIGHTSCOLLECTOR = "false";
    };
    ports = [
      "${toString constants.services.navidrome.port}:${toString constants.services.navidrome.port}"
    ];
    volumes = [
      "navidrome-data:/data"
      "/mnt/media/music:/music:ro"
    ];
  };
}
