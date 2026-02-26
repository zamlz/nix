# Caddy reverse proxy — provides clean URLs for all homelab services.
# Deployed on yggdrasil via its configuration.nix.
#
# All services are accessible at http://<service>.lab.zamlz.org
# DNS entries are managed in Blocky (blocky.nix).
#
# Debugging:
#   systemctl status caddy
#   journalctl -u caddy
#   curl -v http://grafana.lab.zamlz.org
{ constants, firewallUtils, ... }:
let
  reverseProxyHttpPort = 80;
  reverseProxyHttpsPort = 443;

  mkVhost = backend: {
    extraConfig = ''
      reverse_proxy http://${backend}
    '';
  };

  # Generate virtualHosts from services registry
  generatedHosts = builtins.listToAttrs (
    map (name: {
      name = "http://${name}.${constants.domainSuffix}";
      value = mkVhost "${constants.services.${name}.host}:${toString constants.services.${name}.port}";
    }) (builtins.attrNames constants.services)
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

  services.caddy = {
    enable = true;
    httpPort = reverseProxyHttpPort;
    httpsPort = reverseProxyHttpsPort;

    # Disable HTTPS for now — all services are HTTP-only on the LAN
    globalConfig = ''
      auto_https off
    '';

    virtualHosts = generatedHosts // {
      "http://${constants.domainSuffix}" =
        mkVhost "${constants.services.homepage.host}:${toString constants.services.homepage.port}";
    };
  };
}
