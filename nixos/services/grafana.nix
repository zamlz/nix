# Grafana dashboard — visualizes Prometheus metrics.
# Deployed on yggdrasil (10.69.8.3).
#
# Debugging:
#   systemctl status grafana
#   Access http://yggdrasil:3000 in a browser
#   Default login: admin / admin (change on first login)
{
  config,
  constants,
  firewallUtils,
  ...
}:
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule { inherit (constants.services.grafana) port; }) # Grafana web UI
  ];

  sops.secrets.grafana-secret-key = {
    owner = "grafana";
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = constants.services.grafana.port;
      };
      security.secret_key = "$__file{${config.sops.secrets.grafana-secret-key.path}}";
    };
    provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        url = "http://${constants.services.prometheus.host}:${toString constants.services.prometheus.port}";
        isDefault = true;
      }
    ];
  };
}
