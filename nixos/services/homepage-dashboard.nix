# Homepage dashboard — centralized service overview for the homelab.
# Deployed on yggdrasil (10.69.8.3) on port 80.
#
# Debugging:
#   systemctl status homepage-dashboard
#   Access http://yggdrasil in a browser
{ lib, ... }:
{
  services.homepage-dashboard = {
    enable = true;
    listenPort = 80;
    openFirewall = true;
    allowedHosts = "yggdrasil,10.69.8.3";

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

    services = [
      {
        "yggdrasil" = [
          {
            "Grafana" = {
              description = "Monitoring dashboards";
              href = "http://yggdrasil:3000";
              icon = "grafana";
            };
          }
          {
            "Prometheus" = {
              description = "Metrics collection";
              href = "http://yggdrasil:9090";
              icon = "prometheus";
            };
          }
          {
            "Blocky" = {
              description = "DNS server and ad blocker";
              href = "http://yggdrasil:4000";
              icon = "blocky";
            };
          }
          {
            "Kavita" = {
              description = "Book and manga reader";
              href = "http://yggdrasil:5000";
              icon = "kavita";
            };
          }
          {
            "Glances" = {
              description = "System monitoring";
              href = "http://yggdrasil:61208";
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
              href = "http://solaris:8080";
              icon = "open-webui";
            };
          }
          {
            "Glances" = {
              description = "System monitoring";
              href = "http://solaris:61208";
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
              href = "http://alexandria:61208";
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
