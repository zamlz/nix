# Jellyfin media server — self-hosted Netflix for movies, shows, and more.
#
# Debugging:
#   systemctl status jellyfin
#   journalctl -u jellyfin
#   Access http://<host>:8096 in a browser
_: {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}
