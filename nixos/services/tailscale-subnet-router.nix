# Tailscale subnet router — advertises the parent LAN subnet into the tailnet.
# Deployed on yggdrasil only, allowing Tailscale clients anywhere to reach all
# homelab services via their LAN IPs without split DNS.
#
# useRoutingFeatures = "server" enables IP forwarding (required for subnet routing).
#
# After deploying, two manual steps in the Tailscale admin console:
#   1. Approve the advertised route: 10.69.0.0/16
#   2. Set custom DNS nameserver to Blocky's Tailscale IP (run `tailscale ip -4`
#      on yggdrasil to find it)
#
# Debugging:
#   tailscale status          # check advertised routes
#   tailscale netcheck        # connectivity diagnostics
{ constants, ... }:
{
  services.tailscale = {
    useRoutingFeatures = "server";
    extraUpFlags = [ "--advertise-routes=${constants.parentSubnet}" ];
  };
}
