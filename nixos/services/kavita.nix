# Kavita — book and manga reader.
#
# Debugging:
#   systemctl status kavita
#   journalctl -u kavita
#   Access http://<host>:5000 in a browser
#
# Tip: nix run nixpkgs#mangal mini -- --format cbz -d
{ config, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule { port = 5000; }) # Kavita web UI
  ];

  sops.secrets.kavita-token-key = {
    owner = "kavita";
  };

  services.kavita = {
    enable = true;
    tokenKeyFile = config.sops.secrets.kavita-token-key.path;
    settings.Port = 5000;
  };
}
