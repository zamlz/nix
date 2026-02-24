{ firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule { port = 61208; }) # Glances web UI
  ];

  services.glances = {
    enable = true;
    extraArgs = [
      "--webserver"
    ];
    openFirewall = false;
  };
}
