{
  pkgs,
  systemConfig,
  ...
}:
{
  services.displayManager.ly.enable = systemConfig.useGUI;
  programs.niri.enable = systemConfig.useGUI;

  # FIXME: Move to home-manager?
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  services.playerctld.enable = true;
}
