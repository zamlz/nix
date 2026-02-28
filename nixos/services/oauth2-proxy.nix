# OAuth2 Proxy — forward auth middleware for Pocket ID.
# Runs on yggdrasil (localhost only), used by Caddy to gate access to
# services that don't support OIDC natively (e.g. Glances).
#
# Note: We use a raw systemd service instead of the NixOS module because
# the module always injects --pass-host-header and --proxy-websockets flags
# which are incompatible with static upstreams used in forward auth mode.
#
# Debugging:
#   systemctl status oauth2-proxy
#   journalctl -u oauth2-proxy
#   curl http://localhost:4180/ping
{
  config,
  constants,
  pkgs,
  ...
}:
let
  port = toString constants.services.oauth2-proxy.port;
in
{
  sops = {
    secrets = {
      oauth2-proxy-client-secret = { };
      oauth2-proxy-cookie-secret = { };
    };
    templates.oauth2-proxy-env = {
      content = ''
        OAUTH2_PROXY_CLIENT_SECRET=${config.sops.placeholder.oauth2-proxy-client-secret}
        OAUTH2_PROXY_COOKIE_SECRET=${config.sops.placeholder.oauth2-proxy-cookie-secret}
      '';
    };
  };

  systemd.services.oauth2-proxy = {
    description = "OAuth2 Proxy";
    after = [
      "network.target"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.oauth2-proxy}/bin/oauth2-proxy"
        "--provider=oidc"
        "--client-id=72ba6487-5eac-423b-b622-2e088499fe13"
        "--oidc-issuer-url=https://pocket-id.${constants.domainSuffix}"
        "--scope=openid email profile"
        "--http-address=127.0.0.1:${port}"
        "--upstream=static://202"
        "--redirect-url=https://oauth.${constants.domainSuffix}/oauth2/callback"
        "--cookie-domain=.${constants.domainSuffix}"
        "--cookie-secure=true"
        "--cookie-samesite=lax"
        "--reverse-proxy=true"
        "--set-xauthrequest=true"
        "--skip-provider-button=true"
        "--email-domain=*"
        "--pass-host-header=false"
        "--proxy-websockets=false"
      ];
      EnvironmentFile = config.sops.templates.oauth2-proxy-env.path;
      Restart = "on-failure";
      DynamicUser = true;
    };
  };
}
