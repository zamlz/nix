# Homepage dashboard — centralized service overview for the homelab.
# Deployed on yggdrasil via Caddy at http://lab.zamlz.org.
#
# Debugging:
#   systemctl status homepage-dashboard
#   curl http://lab.zamlz.org
{
  config,
  constants,
  firewallUtils,
  ...
}:
let
  hostname = config.networking.hostName;
  hostIp = constants.hostIpAddressMap.${hostname};

  serviceEntries = map (name: {
    ${constants.publicServices.${name}.meta.name} = {
      inherit (constants.publicServices.${name}.meta) description icon;
      href = "http://${name}.${constants.domainSuffix}";
    };
  }) (builtins.attrNames constants.publicServices);

  # Per-host Glances entries
  glancesHosts = [
    "yggdrasil"
    "solaris"
    "alexandria"
  ];
  glancesEntries = map (host: {
    "Glances (${host})" = {
      description = "System monitoring";
      href = "http://${host}:${toString constants.ports.glances}";
      icon = "glances";
    };
  }) glancesHosts;
in
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule { inherit (constants.services.homepage) port; })
  ];

  services.homepage-dashboard = {
    enable = true;
    listenPort = constants.services.homepage.port;
    openFirewall = false;
    allowedHosts = "${hostname},${hostIp},${constants.domainSuffix}";

    settings = {
      title = "Homelab";
      theme = "dark";
      color = "slate";
      headerStyle = "clean";
    };

    services = [
      { "Services" = serviceEntries; }
      { "Monitoring" = glancesEntries; }
    ];

    widgets = [
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];
  };
}
