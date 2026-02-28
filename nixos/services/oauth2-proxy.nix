# OAuth2 Proxy — forward auth middleware for Pocket ID.
# Runs on yggdrasil (localhost only), used by Caddy to gate access to
# services that don't support OIDC natively (e.g. Glances).
#
# Debugging:
#   systemctl status oauth2-proxy
#   journalctl -u oauth2-proxy
#   curl http://localhost:4180/ping
{
  config,
  constants,
  ...
}:
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

  services.oauth2-proxy = {
    enable = true;
    provider = "oidc";
    clientID = "72ba6487-5eac-423b-b622-2e088499fe13";
    scope = "openid email profile";
    httpAddress = "127.0.0.1:${toString constants.services.oauth2-proxy.port}";
    upstream = [ "static://202" ];
    redirectURL = "https://oauth.${constants.domainSuffix}/oauth2/callback";
    cookie.domain = ".${constants.domainSuffix}";

    passHostHeader = false;
    extraConfig = {
      oidc-issuer-url = "https://pocket-id.${constants.domainSuffix}";
      reverse-proxy = true;
      set-xauthrequest = true;
      cookie-secure = true;
      cookie-samesite = "lax";
      skip-provider-button = true;
      email-domain = "*";
      proxy-websockets = false;
    };

    keyFile = config.sops.templates.oauth2-proxy-env.path;
  };
}
