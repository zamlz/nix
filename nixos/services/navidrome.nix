# Navidrome — self-hosted music streaming server (Subsonic-compatible).
# Runs natively on yggdrasil, music library on Alexandria NAS via NFS.
# Accessible at https://navidrome.lab.zamlz.org via Caddy.
#
# Mobile apps (Subsonic-compatible):
#   Android: Symfonium (paid, best), Ultrasonic (free)
#   iOS: Amperfy (free), Substreamer
#
# First-time setup:
#   1. Create /mnt/media/music on Alexandria with chmod 755
#   2. Create an OIDC client in Pocket ID with callback:
#      https://navidrome.lab.zamlz.org/login/callback
#   3. Add sops secret: navidrome-oidc-client-secret
#
# Debugging:
#   systemctl status navidrome
#   journalctl -u navidrome
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

  services.navidrome = {
    enable = true;
    openFirewall = false;
    settings = {
      MusicFolder = "/mnt/media/music";
      Port = constants.services.navidrome.port;
      Address = "0.0.0.0";
      "OIDC.Enabled" = true;
      "OIDC.ClientID" = "a24f6c9c-d8af-4f36-948f-6d148fc2e9ac";
      "OIDC.DiscoveryURL" = "https://pocket-id.${constants.domainSuffix}/.well-known/openid-configuration";
    };
  };

  systemd.services.navidrome.serviceConfig.EnvironmentFile =
    config.sops.templates.navidrome-env.path;
}
