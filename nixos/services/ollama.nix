{
  constants,
  pkgs,
  firewallUtils,
  ...
}:
{
  imports = [
    (firewallUtils.mkOpenPortForSubnetRule { inherit (constants.services.openwebui) port; }) # Open WebUI
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

  services.open-webui = {
    enable = true;
    inherit (constants.services.openwebui) port;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = "false"; # disable login for local use
    };
    openFirewall = false;
  };
}
