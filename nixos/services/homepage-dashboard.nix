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
  glancesHosts = [
    "yggdrasil"
    "solaris"
    "alexandria"
  ];
  glancesEntries = map (host: {
    "${host}" = {
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
        image = "https://images.unsplash.com/photo-1502790671504-542ad42d5189";
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
