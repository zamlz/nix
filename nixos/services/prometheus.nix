# Prometheus metrics collector — scrapes node-exporter and blocky metrics.
# Deployed on yggdrasil (10.69.8.3).
#
# Debugging:
#   systemctl status prometheus
#   curl http://localhost:9090/targets    # check scrape target health
#   curl http://localhost:9090/metrics    # prometheus's own metrics
_: {
  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "15s";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "solaris:9100"
              "xynthar:9100"
              "yggdrasil:9100"
              "alexandria:9100"
            ];
          }
        ];
      }
      {
        job_name = "blocky";
        static_configs = [
          {
            targets = [ "localhost:4000" ];
          }
        ];
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [ 9090 ];
}
