# Kavita — book and manga reader.
# Accessed via Caddy reverse proxy.
#
# Debugging:
#   systemctl status kavita
#   journalctl -u kavita
#   Access https://kavita.lab.zamlz.org in a browser
#
# Tip: nix run nixpkgs#mangal mini -- --format cbz -d
{
  config,
  constants,
  firewallUtils,
  ...
}:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.kavita) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  sops.secrets.kavita-token-key = {
    owner = "kavita";
  };

  services.kavita = {
    enable = true;
    tokenKeyFile = config.sops.secrets.kavita-token-key.path;
    settings.Port = constants.services.kavita.port;
  };
}
