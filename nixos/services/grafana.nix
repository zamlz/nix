# Grafana dashboard — visualizes Prometheus metrics.
# Accessed via Caddy reverse proxy.
#
# Debugging:
#   systemctl status grafana
#   Access https://grafana.lab.zamlz.org in a browser
{
  config,
  constants,
  firewallUtils,
  ...
}:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.grafana) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  sops.secrets.grafana-secret-key = {
    owner = "grafana";
  };
  sops.secrets.grafana-oidc-client-secret = {
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

      server.root_url = "https://grafana.${constants.domainSuffix}";

      "auth.generic_oauth" = {
        enabled = true;
        name = "Pocket ID";
        client_id = "aff4c4b2-1eb7-4ce8-a559-c806430f2c30";
        client_secret = "$__file{${config.sops.secrets.grafana-oidc-client-secret.path}}";
        scopes = "openid email profile";
        auth_url = "https://pocket-id.${constants.domainSuffix}/authorize";
        token_url = "https://pocket-id.${constants.domainSuffix}/api/oidc/token";
        api_url = "https://pocket-id.${constants.domainSuffix}/api/oidc/userinfo";
        allow_sign_up = false;
        oauth_allow_insecure_email_lookup = true;
        skip_org_role_sync = true;
      };
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
