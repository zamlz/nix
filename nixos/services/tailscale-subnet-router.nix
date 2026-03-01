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
{ pkgs, constants, ... }:
{
  services.tailscale.useRoutingFeatures = "server";

  # extraUpFlags only applies on initial auth, so use a dedicated service
  # to idempotently apply subnet routing config on every boot.
  systemd.services.tailscale-set-routes = {
    description = "Advertise LAN subnet routes via Tailscale";
    after = [
      "tailscale.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.tailscale ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Wait until tailscaled is ready
      until tailscale status >/dev/null 2>&1; do sleep 1; done
      tailscale set --advertise-routes=${constants.parentSubnet}
    '';
  };
}
