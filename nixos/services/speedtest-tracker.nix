# Speedtest Tracker — scheduled internet speed tests with historical graphs.
# Runs as an OCI container on yggdrasil behind Caddy.
# Accessible at https://speedtest-tracker.lab.zamlz.org via Caddy.
#
# Requires a sops secret:
#   speedtest-tracker-app-key — Laravel app key in format "base64:<32 bytes>"
#   Generate with: echo "base64:$(openssl rand -base64 32)"
#
# First-time setup:
#   Default login: admin@example.com / password
#   Change immediately after first login.
#
# Debugging:
#   docker logs speedtest-tracker
#   curl http://localhost:3003
#   Access https://speedtest-tracker.lab.zamlz.org in a browser
{
  config,
  constants,
  firewallUtils,
  ...
}:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.speedtest-tracker) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  sops.secrets.speedtest-tracker-app-key = { };

  sops.templates.speedtest-tracker-env = {
    content = ''
      APP_KEY=${config.sops.placeholder.speedtest-tracker-app-key}
      APP_URL=https://speedtest-tracker.${constants.domainSuffix}
      DB_CONNECTION=sqlite
    '';
  };

  virtualisation.oci-containers.containers.speedtest-tracker = {
    image = "lscr.io/linuxserver/speedtest-tracker:latest";
    environmentFiles = [ config.sops.templates.speedtest-tracker-env.path ];
    ports = [ "${toString constants.services.speedtest-tracker.port}:80" ];
    volumes = [ "speedtest-tracker-data:/config" ];
  };
}
