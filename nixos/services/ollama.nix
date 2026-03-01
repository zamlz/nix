{
  config,
  constants,
  pkgs,
  firewallUtils,
  ...
}:
{
  imports = [
    (firewallUtils.mkOpenPortForHostsRule {
      inherit (constants.services.openwebui) port;
      hosts = [ constants.services.caddy.host ];
    })
  ];

  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    loadModels = [
      "llama3.1:8b" # fast, good quality
      "mistral:7b" # great for coding/instructions
      "qwen2.5:14b" # fits at Q4, noticeably smarter
    ];
    syncModels = true;
    openFirewall = false;
  };

  sops.secrets.openwebui-oidc-client-secret = { };

  sops.templates.openwebui-env = {
    content = ''
      OAUTH_CLIENT_SECRET=${config.sops.placeholder.openwebui-oidc-client-secret}
    '';
  };

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    inherit (constants.services.openwebui) port;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_URL = "https://openwebui.${constants.domainSuffix}";
      ENABLE_OAUTH_SIGNUP = "true";
      OAUTH_PROVIDER_NAME = "Pocket ID";
      OPENID_PROVIDER_URL = "https://pocket-id.${constants.domainSuffix}/.well-known/openid-configuration";
      OAUTH_CLIENT_ID = "54711771-394d-4121-8fd6-976d8b7af0cf";
      OAUTH_SCOPES = "openid email profile";
      OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "true";
    };
    openFirewall = false;
  };

  systemd.services.open-webui.serviceConfig.EnvironmentFile =
    config.sops.templates.openwebui-env.path;
}
