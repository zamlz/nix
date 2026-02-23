# Blocky DNS server for local name resolution and ad blocking.
# Deployed on yggdrasil (10.69.8.3), all NixOS hosts point here via
# networking.nameservers in modules/networking.nix.
#
# Debugging:
#   systemctl status blocky
#   journalctl -u blocky
#   dig @localhost solaris              # local DNS mapping
#   dig @localhost google.com           # upstream resolution
#   dig @localhost ads.google.com       # should be blocked (0.0.0.0)
#   dig @10.69.8.3 solaris              # query from another machine
_: {
  services.blocky = {
    enable = true;
    settings = {
      # Upstream DNS resolvers
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query" # Cloudflare DoH
        "https://dns.google/dns-query" # Google DoH
        "1.1.1.1" # Cloudflare plain DNS fallback
        "8.8.8.8" # Google plain DNS fallback
      ];

      # Local DNS mappings (replaces need for /etc/hosts)
      customDNS.mapping = {
        "solaris" = "10.69.8.0";
        "xynthar" = "10.69.8.2";
        "yggdrasil" = "10.69.8.3";
        "alexandria" = "10.69.8.4";
      };

      # Ad blocking via blocklists
      blocking = {
        denylists.ads = [
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        ];
        clientGroupsBlock.default = [ "ads" ];
      };

      # Expose Prometheus metrics at /metrics
      prometheus.enable = true;

      # Listen on port 53 for DNS, port 4000 for HTTP API + metrics
      ports = {
        dns = 53;
        http = 4000;
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      53
      4000
    ];
    allowedUDPPorts = [ 53 ];
  };
}
