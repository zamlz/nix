# Prometheus node exporter — exposes system metrics (CPU, RAM, disk, network)
# on port 9100. Deployed on all hosts via server.nix.
#
# Debugging:
#   systemctl status prometheus-node-exporter
#   curl http://localhost:9100/metrics
{ firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule { port = 9100; }) # Node exporter metrics
  ];

  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = false;
  };
}
