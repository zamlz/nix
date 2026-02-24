# Homepage dashboard — centralized service overview for the homelab.
# Deployed on yggdrasil (10.69.8.3) on port 80.
#
# Debugging:
#   systemctl status homepage-dashboard
#   Access http://yggdrasil in a browser
{
  config,
  constants,
  lib,
  firewallUtils,
  ...
}:
let
  hostname = config.networking.hostName;
  hostIp = constants.hostIpAddressMap.${hostname};
in
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule { port = 80; }) # Homepage dashboard web UI
  ];

  services.homepage-dashboard = {
    enable = true;
    listenPort = 80;
    openFirewall = false;
    allowedHosts = "${hostname},${hostIp}";

    settings = {
      title = "Homelab";
      theme = "dark";
      color = "slate";
      headerStyle = "clean";
    };

    widgets = [
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];

    bookmarks = [
      {
        "Bookmarks" = [
          {
            "GitHub" = [
              {
                href = "https://github.com";
                icon = "github";
              }
            ];
          }
          {
            "YouTube" = [
              {
                href = "https://youtube.com";
                icon = "youtube";
              }
            ];
          }
        ];
      }
    ];

    services = [
      {
        "yggdrasil" = [
          {
            "Grafana" = {
              description = "Monitoring dashboards";
              href = "http://yggdrasil:${toString constants.ports.grafana}";
              icon = "grafana";
            };
          }
          {
            "Prometheus" = {
              description = "Metrics collection";
              href = "http://yggdrasil:${toString constants.ports.prometheusServer}";
              icon = "prometheus";
            };
          }
          {
            "Blocky" = {
              description = "DNS server and ad blocker";
              href = "http://yggdrasil:${toString constants.ports.blockyHttp}";
              icon = "blocky";
            };
          }
          {
            "Kavita" = {
              description = "Book and manga reader";
              href = "http://yggdrasil:${toString constants.ports.kavita}";
              icon = "kavita";
            };
          }
          {
            "Jellyfin" = {
              description = "Media server";
              href = "http://yggdrasil:${toString constants.ports.jellyfin}";
              icon = "jellyfin";
            };
          }
          {
            "Glances" = {
              description = "System monitoring";
              href = "http://yggdrasil:${toString constants.ports.glances}";
              icon = "glances";
            };
          }
        ];
      }
      {
        "solaris" = [
          {
            "Open WebUI" = {
              description = "Ollama LLM interface";
              href = "http://solaris:${toString constants.ports.openWebui}";
              icon = "open-webui";
            };
          }
          {
            "Glances" = {
              description = "System monitoring";
              href = "http://solaris:${toString constants.ports.glances}";
              icon = "glances";
            };
          }
        ];
      }
      {
        "alexandria" = [
          {
            "Glances" = {
              description = "System monitoring";
              href = "http://alexandria:${toString constants.ports.glances}";
              icon = "glances";
            };
          }
        ];
      }
    ];
  };

  # Allow binding to privileged port 80 as non-root
  systemd.services.homepage-dashboard.serviceConfig = {
    AmbientCapabilities = lib.mkForce "CAP_NET_BIND_SERVICE";
    CapabilityBoundingSet = lib.mkForce "CAP_NET_BIND_SERVICE";
    PrivateUsers = lib.mkForce false;
  };
}
