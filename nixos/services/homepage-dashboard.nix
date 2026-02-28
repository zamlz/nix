# Homepage dashboard — centralized service overview for the homelab.
# Accessed via Caddy reverse proxy.
#
# Debugging:
#   systemctl status homepage-dashboard
#   curl https://lab.zamlz.org
{
  config,
  constants,
  firewallUtils,
  ...
}:
let
  hostname = config.networking.hostName;
  hostIp = constants.hostIpAddressMap.${hostname};
  backgroundUrl = "https://i.ibb.co/R4bb12zv/background.webp";

  # Build a service entry for the dashboard
  mkServiceEntry = name: {
    ${constants.publicServices.${name}.meta.name} = {
      inherit (constants.publicServices.${name}.meta) description icon;
      href = "http://${name}.${constants.domainSuffix}";
    };
  };

  # Group services by their meta.group field
  servicesByGroup =
    group:
    map mkServiceEntry (
      builtins.filter (name: constants.publicServices.${name}.meta.group == group) (
        builtins.attrNames constants.publicServices
      )
    );

  # Per-host Glances entries
  glancesEntries = map (host: {
    "${host}" = {
      description = "System monitoring";
      href = "https://${host}.${constants.domainSuffix}";
      icon = "glances";
    };
  }) constants.glancesHosts;
in
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.homepage) port;
      hosts = [ constants.services.caddy.host ];
    })
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
      headerStyle = "boxedWidgets";
      quicklaunch = {
        searchDescriptions = true;
        hideInternetSearch = true;
        showSearchSuggestions = true;
      };
      cardBlur = "md";
      hideVersion = true;
      disableUpdateCheck = true;
      background = {
        image = backgroundUrl;
        opacity = 30;
      };
      layout = {
        "Media & Apps".columns = 2;
        "Utilities".columns = 2;
        "Monitoring" = {
          columns = 3;
          style = "row";
        };
      };
    };

    services = [
      { "Media & Apps" = servicesByGroup "Media & Apps"; }
      { "Utilities" = servicesByGroup "Utilities"; }
      { "Monitoring" = glancesEntries; }
    ];

    widgets = [
      {
        datetime = {
          locale = "en";
          format = {
            dateStyle = "long";
            timeStyle = "short";
            hourCycle = "h12";
          };
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
      {
        openmeteo = {
          label = "Union City";
          latitude = 37.5934;
          longitude = -122.0439;
          units = "imperial";
        };
      }
    ];
  };
}
