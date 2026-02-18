{
  pkgs,
  ...
}:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      cfg = {
        pipewireSupport = true;
      };
    };
  };

  home.sessionVariables = {
    # This tells firefox to use wayland natively
    MOZ_ENABLE_WAYLAND = "1";
    # This tells firefox to use xdg portal for screensharing and file picking
    GTK_USE_PORTAL = "1";
  };
}
