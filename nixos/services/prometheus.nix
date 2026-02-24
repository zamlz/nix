# Prometheus metrics collector — scrapes node-exporter and blocky metrics.
# Deployed on yggdrasil (10.69.8.3).
#
# Debugging:
#   systemctl status prometheus
#   curl http://localhost:9090/targets    # check scrape target health
#   curl http://localhost:9090/metrics    # prometheus's own metrics
{ constants, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule { port = constants.ports.prometheusServer; }) # Prometheus web UI and API
  ];

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "15s";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = builtins.map (host: "${host}:${toString constants.ports.prometheusNodeExporter}") (
              builtins.attrNames constants.hostIpAddressMap
            );
          }
        ];
      }
      {
        job_name = "blocky";
        static_configs = [
          {
            targets = [ "${constants.dnsServer}:${toString constants.ports.blockyHttp}" ];
          }
        ];
      }
    ];
  };
}
