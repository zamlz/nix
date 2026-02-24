{ constants, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule { port = constants.ports.glances; }) # Glances web UI
  ];

  services.glances = {
    enable = true;
    extraArgs = [
      "--webserver"
    ];
    openFirewall = false;
  };
}
