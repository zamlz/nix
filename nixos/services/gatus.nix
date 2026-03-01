# Gatus — declarative service health monitoring with status page.
# Runs natively on yggdrasil behind Caddy.
# Accessible at https://gatus.lab.zamlz.org via Caddy.
#
# Endpoints are auto-generated from constants.publicServices —
# adding a new service to constants automatically adds it here.
#
# Prometheus metrics available at /metrics (same port).
# See TODO: integrate speedtest-tracker and gatus into Prometheus.
#
# Debugging:
#   systemctl status gatus
#   journalctl -u gatus
#   curl http://localhost:3002/metrics
#   Access https://gatus.lab.zamlz.org in a browser
{ constants, firewallUtils, ... }:
let
  endpoints = map (name: {
    name = constants.publicServices.${name}.meta.name;
    url = "https://${name}.${constants.domainSuffix}";
    conditions = [ "[STATUS] < 500" ];
  }) (builtins.attrNames constants.publicServices);
in
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.gatus) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  services.gatus = {
    enable = true;
    settings = {
      web.port = constants.services.gatus.port;
      inherit endpoints;
    };
  };
}
