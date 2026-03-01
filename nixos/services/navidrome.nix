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
{
  config,
  constants,
  firewallUtils,
  ...
}:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.navidrome) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  sops.secrets.navidrome-oidc-client-secret = { };

  sops.templates.navidrome-env = {
    content = ''
      ND_OIDC_CLIENTSECRET=${config.sops.placeholder.navidrome-oidc-client-secret}
    '';
  };

  virtualisation.oci-containers.containers.navidrome = {
    image = "ghcr.io/navidrome/navidrome:latest";
    environmentFiles = [ config.sops.templates.navidrome-env.path ];
    environment = {
      ND_MUSICFOLDER = "/music";
      ND_PORT = toString constants.services.navidrome.port;
      ND_LOGLEVEL = "info";
      ND_OIDC_ENABLED = "true";
      ND_OIDC_CLIENTID = "a24f6c9c-d8af-4f36-948f-6d148fc2e9ac";
      ND_OIDC_DISCOVERYURL = "https://pocket-id.${constants.domainSuffix}/.well-known/openid-configuration";
    };
    ports = [ "${toString constants.services.navidrome.port}:${toString constants.services.navidrome.port}" ];
    volumes = [
      "navidrome-data:/data"
      "/mnt/media/music:/music:ro"
    ];
  };
}
