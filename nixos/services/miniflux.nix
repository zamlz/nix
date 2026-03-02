# Miniflux — minimalist RSS reader.
# Runs natively on yggdrasil with PostgreSQL managed automatically.
# Accessible at https://miniflux.lab.zamlz.org via Caddy.
# Authentication via Pocket ID OIDC.
#
# Debugging:
#   systemctl status miniflux
#   journalctl -u miniflux
#   Access https://miniflux.lab.zamlz.org in a browser
{
  config,
  constants,
  firewallUtils,
  ...
}:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.miniflux) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  sops.secrets.miniflux-admin-password = { };
  sops.secrets.miniflux-oidc-client-secret = { };

  sops.templates.miniflux-env = {
    content = ''
      ADMIN_USERNAME=admin
      ADMIN_PASSWORD=${config.sops.placeholder.miniflux-admin-password}
      OAUTH2_CLIENT_SECRET=${config.sops.placeholder.miniflux-oidc-client-secret}
    '';
  };

  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.sops.templates.miniflux-env.path;
    config = {
      LISTEN_ADDR = "0.0.0.0:${toString constants.services.miniflux.port}";
      BASE_URL = "https://miniflux.${constants.domainSuffix}";
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_CLIENT_ID = "50c4a367-91d7-48a5-9c71-968b0f51e267";
      OAUTH2_REDIRECT_URL = "https://miniflux.${constants.domainSuffix}/oauth2/oidc/callback";
      # Base URL only — go-oidc appends /.well-known/openid-configuration automatically
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://pocket-id.${constants.domainSuffix}";
      OAUTH2_USER_CREATION = "1";
    };
  };
}
