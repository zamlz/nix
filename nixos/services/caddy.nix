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
  inherit (constants.services.caddy) httpPort httpsPort;

  # Allowed IPs for glances (LAN subnet)
  allowedSubnet = constants.lanSubnet;

  tls = ''
    tls {
      dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }
  '';

  mkVhost = backend: {
    extraConfig = ''
      ${tls}
      reverse_proxy http://${backend}
    '';
  };

  mkRestrictedVhost = backend: {
    extraConfig = ''
      ${tls}
      @blocked not remote_ip ${allowedSubnet}
      respond @blocked 403
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

  # Generate Glances vhosts with IP restriction
  glancesHosts = builtins.listToAttrs (
    map (host: {
      name = "${host}.${constants.domainSuffix}";
      value = mkRestrictedVhost "${host}:${toString constants.ports.glances}";
    }) constants.glancesHosts
  );
in
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule {
      port = httpPort;
      subnet = constants.parentSubnet;
    })
    (firewallUtils.mkOpenPortForSubnetRule {
      port = httpsPort;
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
    inherit httpPort httpsPort;

    virtualHosts =
      generatedHosts
      // glancesHosts
      // {
        "${constants.domainSuffix}" =
          mkVhost "${constants.services.homepage.host}:${toString constants.services.homepage.port}";
      };
  };
}
