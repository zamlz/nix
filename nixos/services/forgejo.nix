# Forgejo — self-hosted Git service.
# Runs natively on yggdrasil with SQLite database.
# Accessible at https://forgejo.lab.zamlz.org via Caddy.
# SSH cloning available at ssh://forgejo.lab.zamlz.org:2222
#
# First-time setup:
#   Visit the URL — first registered user becomes admin.
#   To add Pocket ID OIDC: Site Administration → Authentication Sources
#     → Add OAuth2 source → OpenID Connect
#     Discovery URL: https://pocket-id.lab.zamlz.org/.well-known/openid-configuration
#
# Debugging:
#   systemctl status forgejo
#   journalctl -u forgejo
#   Access https://forgejo.lab.zamlz.org in a browser
{ constants, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.forgejo) port;
      hosts = [ constants.services.caddy.host ];
    })
    (firewallUtils.mkOpenPortForSubnetRule {
      port = constants.services.forgejo.sshPort;
      subnet = constants.parentSubnet;
    })
  ];

  services.forgejo = {
    enable = true;
    settings = {
      server = {
        HTTP_PORT = constants.services.forgejo.port;
        DOMAIN = "forgejo.${constants.domainSuffix}";
        ROOT_URL = "https://forgejo.${constants.domainSuffix}/";
        START_SSH_SERVER = true;
        SSH_PORT = constants.services.forgejo.sshPort;
        SSH_LISTEN_PORT = constants.services.forgejo.sshPort;
      };
    };
  };
}
