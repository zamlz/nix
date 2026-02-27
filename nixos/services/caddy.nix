# Caddy reverse proxy — provides HTTPS for all homelab services.
# Deployed on yggdrasil via its configuration.nix.
#
# TLS certificates are obtained via Cloudflare DNS-01 ACME challenge.
# All services are accessible at https://<service>.lab.zamlz.org
# DNS entries are managed in Blocky (blocky.nix).
#
# Debugging:
#   systemctl status caddy
#   journalctl -u caddy
#   curl -v https://grafana.lab.zamlz.org
{
  config,
  pkgs,
  constants,
  firewallUtils,
  ...
}:
let
  reverseProxyHttpPort = 80;
  reverseProxyHttpsPort = 443;

  mkVhost = backend: {
    extraConfig = ''
      tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      }
      reverse_proxy http://${backend}
    '';
  };

  # Generate virtualHosts from services registry
  generatedHosts = builtins.listToAttrs (
    map (name: {
      name = "${name}.${constants.domainSuffix}";
      value = mkVhost "${constants.publicServices.${name}.host}:${
        toString constants.publicServices.${name}.port
      }";
    }) (builtins.attrNames constants.publicServices)
  );
in
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule {
      port = reverseProxyHttpPort;
      subnet = constants.parentSubnet;
    })
    (firewallUtils.mkOpenPortForSubnetRule {
      port = reverseProxyHttpsPort;
      subnet = constants.parentSubnet;
    })
  ];

  sops.secrets.cloudflare-api-token = { };

  sops.templates.caddy-env = {
    content = ''
      CLOUDFLARE_API_TOKEN=${config.sops.placeholder.cloudflare-api-token}
    '';
    owner = "caddy";
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates.caddy-env.path;

  services.caddy = {
    enable = true;
    package = pkgs.caddy-with-cloudflare;
    httpPort = reverseProxyHttpPort;
    httpsPort = reverseProxyHttpsPort;

    virtualHosts = generatedHosts // {
      "${constants.domainSuffix}" =
        mkVhost "${constants.services.homepage.host}:${toString constants.services.homepage.port}";
    };
  };
}
