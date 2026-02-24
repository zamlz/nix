let
  constants = import ../constants.nix;
in
{
  # Generate iptables firewall rules to open a port for a specific subnet.
  # Defaults to the LAN subnet. Use this instead of openFirewall/allowedTCPPorts
  # to restrict access to trusted networks only.
  #
  # Usage: mkOpenPortForSubnetRule { port = 8080; }
  #        mkOpenPortForSubnetRule { port = 53; proto = "udp"; }
  #        mkOpenPortForSubnetRule { port = 8096; subnet = "10.69.0.0/16"; }
  mkOpenPortForSubnetRule =
    {
      port,
      proto ? "tcp",
      subnet ? constants.lanSubnet,
    }:
    {
      networking.firewall = {
        extraCommands = ''
          iptables -I nixos-fw -s ${subnet} -p ${proto} --dport ${toString port} -j nixos-fw-accept
        '';
        extraStopCommands = ''
          iptables -D nixos-fw -s ${subnet} -p ${proto} --dport ${toString port} -j nixos-fw-accept || true
        '';
      };
    };
}
