# Prometheus node exporter — exposes system metrics (CPU, RAM, disk, network)
# on port 9100. Deployed on all hosts via server.nix.
#
# Debugging:
#   systemctl status prometheus-node-exporter
#   curl http://localhost:9100/metrics
#   ls /var/lib/prometheus-node-exporter/textfile/  # custom .prom files
{ constants, firewallUtils, ... }:
let
  textfileDir = "/var/lib/prometheus-node-exporter/textfile";
in
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      port = constants.ports.prometheusNodeExporter;
      hosts = [ constants.services.prometheus.host ];
    })
  ];

  systemd.tmpfiles.rules = [
    "d ${textfileDir} 0755 root root -"
  ];

  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = false;
    extraFlags = [
      "--collector.textfile.directory=${textfileDir}"
    ];
  };
}
