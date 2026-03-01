# Pinchflat — YouTube content archiver backed by yt-dlp.
# Runs as an OCI container on yggdrasil behind Caddy.
# Downloads are stored on the Alexandria NAS via NFS at /mnt/media/youtube,
# making them available in Jellyfin automatically.
#
# First-time setup:
#   Add sources and media profiles at https://pinchflat.lab.zamlz.org
#   Point Jellyfin at /mnt/media/youtube as a new library
#
# Debugging:
#   docker logs pinchflat
#   curl http://localhost:8945
#   Access https://pinchflat.lab.zamlz.org in a browser
{
  config,
  constants,
  firewallUtils,
  ...
}:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.pinchflat) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  sops.secrets.pinchflat-secret-key-base = { };

  sops.templates.pinchflat-env = {
    content = ''
      SECRET_KEY_BASE=${config.sops.placeholder.pinchflat-secret-key-base}
      TZ=America/Los_Angeles
    '';
  };

  virtualisation.oci-containers.containers.pinchflat = {
    image = "ghcr.io/kieraneglin/pinchflat:latest";
    environmentFiles = [ config.sops.templates.pinchflat-env.path ];
    ports = [ "${toString constants.services.pinchflat.port}:8945" ];
    volumes = [
      "pinchflat-config:/config"
      "/mnt/media/youtube:/downloads"
    ];
  };
}
