# Kavita — book and manga reader.
#
# Debugging:
#   systemctl status kavita
#   journalctl -u kavita
#   Access http://<host>:5000 in a browser
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
    (firewallUtils.mkOpenPortForSubnetRule { port = constants.ports.kavita; }) # Kavita web UI
  ];

  sops.secrets.kavita-token-key = {
    owner = "kavita";
  };

  services.kavita = {
    enable = true;
    tokenKeyFile = config.sops.secrets.kavita-token-key.path;
    settings.Port = constants.ports.kavita;
  };
}
