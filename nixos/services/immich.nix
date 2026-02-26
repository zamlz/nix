# Immich - self-hosted photo and video management solution.
#
# Debugging:
#   systemctl status immich
#   journalctl -u immich
#   Access http://<host>:2283 in a browser
{ constants, firewallUtils, ... }:
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule { inherit (constants.services.immich) port; })
  ];

  services.immich = {
    enable = true;
    inherit (constants.services.immich) port;
    host = "0.0.0.0";
    openFirewall = false;
    accelerationDevices = [ "/dev/dri/renderD128" ];
  };

  # Allows immich to access devices for hardware acceleration
  hardware.graphics.enable = true;
  users.users.immich.extraGroups = [
    "video"
    "render"
  ];
}
