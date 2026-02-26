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
{ constants, firewallUtils, ... }:
let
  dnsPort = 53;
in
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule { port = dnsPort; })
    (firewallUtils.mkOpenPortForSubnetRule {
      port = dnsPort;
      proto = "udp";
    })
    (firewallUtils.mkOpenPortForSubnetRule { inherit (constants.services.blocky) port; })
  ];

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
      # Includes host IPs + reverse proxy URLs (*.lab.zamlz.org → Caddy host)
      customDNS.mapping =
        let
          caddyIp = constants.hostIpAddressMap.yggdrasil;
          serviceDns = builtins.listToAttrs (
            map (name: {
              name = "${name}.${constants.domainSuffix}";
              value = caddyIp;
            }) (builtins.attrNames constants.services)
          );
        in
        constants.hostIpAddressMap // serviceDns // { ${constants.domainSuffix} = caddyIp; };

      blocking = {
        denylists.ads = [
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        ];
        clientGroupsBlock.default = [ "ads" ];
      };

      prometheus.enable = true;

      ports = {
        dns = dnsPort;
        http = constants.services.blocky.port;
      };
    };
  };

}
