{
  pkgs,
  systemConfig,
  ...
}:
{
  programs.niri.enable = systemConfig.useGUI;

  # FIXME: Move to home-manager?
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  services.playerctld.enable = true;
}
