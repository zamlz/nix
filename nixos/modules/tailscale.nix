# Tailscale VPN mesh — encrypted overlay network using tailscale.com.
# Deployed on all hosts via server.nix.
#
# Setup:
#   1. Generate a reusable auth key at tailscale.com → Settings → Keys
#   2. sops secrets.yaml → add tailscale-authkey: <key>
#   3. Deploy — hosts auto-join the tailnet on first boot
#
# Debugging:
#   tailscale status
#   tailscale ping <hostname>
#   tailscale netcheck
{ config, ... }:
{
  # WireGuard UDP port — open globally for direct connections from anywhere
  networking.firewall.allowedUDPPorts = [ 41641 ];

  # Trust the tailscale interface — traffic over the tailnet is already authenticated
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale-authkey.path;
  };

  sops.secrets.tailscale-authkey = { };
}
