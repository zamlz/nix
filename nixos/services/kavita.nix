# Kavita — book and manga reader.
#
# Debugging:
#   systemctl status kavita
#   journalctl -u kavita
#   Access http://<host>:5000 in a browser
#
# Tip: nix run nixpkgs#mangal mini -- --format cbz -d
_: {
  services.kavita = {
    enable = true;
    settings.Port = 5000;
  };
  networking.firewall.allowedTCPPorts = [ 5000 ];
}
