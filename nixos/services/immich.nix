# Immich - self-hosted photo and video management solution.
#
# Debugging:
#   systemctl status immich
#   journalctl -u immich
#   Access http://<host>:2283 in a browser
{
  config,
  constants,
  firewallUtils,
  ...
}:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.immich) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  sops.secrets.immich-oidc-client-secret = { };

  services.immich = {
    enable = true;
    inherit (constants.services.immich) port;
    host = "0.0.0.0";
    openFirewall = false;
    accelerationDevices = [ "/dev/dri/renderD128" ];
    settings.oauth = {
      enabled = true;
      issuerUrl = "https://pocket-id.${constants.domainSuffix}/.well-known/openid-configuration";
      clientId = "69e15412-f80d-423f-a8cb-6ac0d693d9f0";
      clientSecret._secret = config.sops.secrets.immich-oidc-client-secret.path;
      buttonText = "Login with Pocket ID";
      autoRegister = false;
    };
  };

  # Allows immich to access devices for hardware acceleration
  hardware.graphics.enable = true;
  users.users.immich.extraGroups = [
    "video"
    "render"
  ];
}
