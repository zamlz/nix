# Pocket ID — passkey-based OIDC provider for SSO across homelab services.
# Accessed via Caddy reverse proxy.
#
# Debugging:
#   systemctl status pocket-id
#   Access https://pocket-id.lab.zamlz.org in a browser
#
# After first deploy, visit the URL to register the initial admin user + passkey.
{
  config,
  constants,
  firewallUtils,
  ...
}:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.pocket-id) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  sops.secrets.pocket-id-encryption-key = {
    owner = "pocket-id";
  };

  services.pocket-id = {
    enable = true;
    settings = {
      PORT = toString constants.services.pocket-id.port;
      APP_URL = "https://pocket-id.${constants.domainSuffix}";
      TRUST_PROXY = true;
    };
    credentials = {
      ENCRYPTION_KEY = config.sops.secrets.pocket-id-encryption-key.path;
    };
  };
}
