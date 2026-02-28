{ constants, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      port = constants.ports.glances;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  services.glances = {
    enable = true;
    extraArgs = [
      "--webserver"
    ];
    openFirewall = false;
  };
}
