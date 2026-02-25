# Tailscale subnet router — advertises the LAN to the tailnet so remote
# clients can reach LAN IPs (10.69.8.x) through the Tailscale tunnel.
# Deployed only on yggdrasil via its configuration.nix.
#
# After deploying, approve the route in the Tailscale admin console:
#   tailscale.com → Machines → yggdrasil → Edit route settings → approve 10.69.8.0/24
#
# Then configure DNS in Tailscale admin:
#   DNS → Global nameservers → add yggdrasil's Tailscale IP
#   DNS → disable MagicDNS
#
# This lets remote clients (e.g. laptop at a coffee shop) use Blocky for
# DNS resolution and reach all LAN services by hostname.
#
# Debugging:
#   tailscale status
#   ip route show table 52   # tailscale routing table
{ constants, ... }:
{
  services.tailscale.extraUpFlags = [
    "--advertise-routes=${constants.lanSubnet}"
  ];

  # Required for forwarding packets from the tunnel to the LAN
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
